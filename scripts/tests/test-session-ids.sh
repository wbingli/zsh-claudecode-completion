#!/bin/bash
#
# Coverage for the _claude_session_ids completer (claude -r / --resume).
#
# Builds a fake $HOME/.claude/projects/<mangled-PWD>/ tree, then asserts that:
#   1. Indexed sessions (sessions-index.json) appear in the completion list.
#   2. Unindexed JSONL sessions appear too, with branch + summary parsed.
#   3. The originalPath fallback matches when the mangled directory is missing.
#   4. CLAUDE_COMPLETION_SESSION_LIMIT caps the displayed count.
#
# The fixture path is intentionally placed under a directory whose name
# contains a `.` so we also exercise the dot-mangling branch (commit history
# shows that branch was previously broken).

set -e
TEST_NAME=test-session-ids
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps
require_dep jq

# ---------------------------------------------------------------------------
# Fixture builder
# ---------------------------------------------------------------------------
# Args:
#   $1 home      — fake HOME root
#   $2 work_dir  — directory the user is "in" when they hit TAB
#   $3 mode      — "matching" | "fallback"
#       matching: place the project dir at the mangled-PWD path
#       fallback: place it under a different dir, but with originalPath set
#                 so the function's fallback search picks it up
build_fixture() {
    local home="$1" work_dir="$2" mode="$3"
    mkdir -p "$work_dir"

    local mangled="${work_dir//\//-}"
    mangled="${mangled//./-}"
    local proj_dir
    if [[ "$mode" == "matching" ]]; then
        proj_dir="$home/.claude/projects/$mangled"
    else
        proj_dir="$home/.claude/projects/-some-other-name"
    fi
    mkdir -p "$proj_dir"

    # An indexed session — newest, so it sorts first. Real indexed sessions
    # always have a backing JSONL on disk (the index points at it via
    # fullPath); make the fixture mirror that so the indexed-summary path
    # is what gets tested, not a missing-file edge case.
    local uuid_indexed="aaaaaaaa-1111-2222-3333-aaaaaaaaaaaa"
    cat > "$proj_dir/$uuid_indexed.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"indexed jsonl prompt (should be hidden by summary)"}}
JSONL
    touch -d "2026-05-09T12:00:00" "$proj_dir/$uuid_indexed.jsonl"

    cat > "$proj_dir/sessions-index.json" <<JSON
{
  "originalPath": "$work_dir",
  "entries": [
    {
      "sessionId": "$uuid_indexed",
      "modified": "2026-05-09T12:00:00",
      "gitBranch": "main",
      "summary": "indexed session label"
    }
  ]
}
JSON

    # A JSONL session not in the index — older, so it appears after the
    # indexed one (verifies pass-2 jq parsing, mtime sort).
    local uuid_jsonl="bbbbbbbb-1111-2222-3333-bbbbbbbbbbbb"
    cat > "$proj_dir/$uuid_jsonl.jsonl" <<JSONL
{"type":"user","gitBranch":"feature","message":{"content":"jsonl session prompt"}}
JSONL
    # ISO-8601 with T separator — BSD touch on macOS rejects the space form.
    touch -d "2026-05-08T10:00:00" "$proj_dir/$uuid_jsonl.jsonl"

    # A JSONL session whose label should come from a trailing `ai-title`
    # record (what `/resume` displays for recent, not-yet-indexed
    # sessions). The first user prompt is intentionally generic so the
    # assertion only passes if the ai-title path is actually taken.
    local uuid_aititle="dddddddd-1111-2222-3333-dddddddddddd"
    cat > "$proj_dir/$uuid_aititle.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"hello there"}}
{"type":"ai-title","aiTitle":"refactor-auth-flow","sessionId":"$uuid_aititle"}
JSONL
    touch -d "2026-05-08T11:00:00" "$proj_dir/$uuid_aititle.jsonl"

    # A JSONL session with a `/rename`-set custom title — outranks
    # ai-title, summary, and the prompt.
    local uuid_custom="eeeeeeee-1111-2222-3333-eeeeeeeeeeee"
    cat > "$proj_dir/$uuid_custom.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"some prompt"}}
{"type":"ai-title","aiTitle":"auto-generated-title","sessionId":"$uuid_custom"}
{"type":"custom-title","customTitle":"my-renamed-session","sessionId":"$uuid_custom"}
JSONL
    touch -d "2026-05-08T13:00:00" "$proj_dir/$uuid_custom.jsonl"

    # A JSONL session whose only user content is wrapped <command-name> —
    # the completer should pull "/exit" out of the tag instead of dropping
    # the session entirely (this mirrors what `/resume` shows).
    local uuid_cmdname="ffffffff-1111-2222-3333-ffffffffffff"
    cat > "$proj_dir/$uuid_cmdname.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"<command-name>/exit</command-name>\n<command-message>exit</command-message>"}}
JSONL
    touch -d "2026-05-08T09:00:00" "$proj_dir/$uuid_cmdname.jsonl"

    # A JSONL session that contains ONLY a <command-stdout>/<local-command-*>
    # wrapper with no <command-name> — the completer should filter this
    # out (claude --resume rejects it).
    local uuid_filtered="cccccccc-1111-2222-3333-cccccccccccc"
    cat > "$proj_dir/$uuid_filtered.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"<command-stdout>boring</command-stdout>"}}
JSONL
    touch -d "2026-05-07T10:00:00" "$proj_dir/$uuid_filtered.jsonl"

    printf '%s\n' "$proj_dir"
}

# ---------------------------------------------------------------------------
# Test 1: matching mangled path — basic case
# ---------------------------------------------------------------------------
home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# Use a subdirectory whose name contains a dot, to exercise dot-mangling.
work_dir="$home/proj.example/work"
build_fixture "$home" "$work_dir" "matching" >/dev/null

log "case 1: indexed + jsonl sessions, mangled path matches"
output=$(run_completion "$home" "$work_dir" 'claude -r \t')
assert_no_completion_errors "$output"
assert_contains "aaaaaaaa" "$output" "indexed session UUID prefix"
assert_contains "indexed session label" "$output" "indexed session summary"
assert_contains "main"     "$output" "indexed session branch"
assert_contains "bbbbbbbb" "$output" "jsonl session UUID prefix"
assert_contains "feature"  "$output" "jsonl session branch"
assert_contains "jsonl session prompt" "$output" "jsonl session summary"
# ai-title-bearing session uses its aiTitle as the label, not the prompt.
assert_contains "dddddddd" "$output" "ai-title session UUID prefix"
assert_contains "refactor-auth-flow" "$output" "ai-title session label"
assert_not_contains "hello there" "$output" "ai-title outranks first prompt"
# /rename customTitle outranks aiTitle/summary/prompt.
assert_contains "eeeeeeee" "$output" "custom-title session UUID prefix"
assert_contains "my-renamed-session" "$output" "custom-title label"
assert_not_contains "auto-generated-title" "$output" "customTitle outranks aiTitle"
# Sessions whose only content is a <command-name> tag still appear,
# labelled by the slash command (mirrors `/resume`).
assert_contains "ffffffff" "$output" "command-name session UUID prefix"
assert_contains "/exit"    "$output" "command-name label"
# Sessions with only a <command-stdout> wrapper (no <command-name>) must
# still be filtered out.
assert_not_contains "cccccccc" "$output" "filtered command-only session"
# Relative-time formatting (e.g. "1 day ago") replaces the old ISO date.
assert_contains " ago" "$output" "relative time label present"

# ---------------------------------------------------------------------------
# Test 2: fallback via sessions-index.json originalPath
# ---------------------------------------------------------------------------
rm -rf "$home/.claude"
work_dir2="$home/fallback.dir/work"
build_fixture "$home" "$work_dir2" "fallback" >/dev/null

log "case 2: mangled dir absent, originalPath fallback"
output=$(run_completion "$home" "$work_dir2" 'claude -r \t')
assert_no_completion_errors "$output"
assert_contains "aaaaaaaa" "$output" "fallback-located indexed UUID"
assert_contains "indexed session label" "$output" "fallback-located summary"

# ---------------------------------------------------------------------------
# Test 3: CLAUDE_COMPLETION_SESSION_LIMIT caps the listed sessions
# ---------------------------------------------------------------------------
rm -rf "$home/.claude"
work_dir3="$home/cap.test/work"
build_fixture "$home" "$work_dir3" "matching" >/dev/null

log "case 3: CLAUDE_COMPLETION_SESSION_LIMIT=1 caps output"
output=$(run_completion "$home" "$work_dir3" 'claude -r \t' \
    'set env(CLAUDE_COMPLETION_SESSION_LIMIT) "1"')
assert_no_completion_errors "$output"
# Newest is the indexed session (2026-05-09); the JSONL one is older and
# should be capped out.
assert_contains "aaaaaaaa" "$output" "newest session under cap"
assert_not_contains "bbbbbbbb" "$output" "older session capped out"

pass "session id auto-suggestion OK"
