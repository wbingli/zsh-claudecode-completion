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

    # An indexed session — newest, so it sorts first.
    cat > "$proj_dir/sessions-index.json" <<JSON
{
  "originalPath": "$work_dir",
  "entries": [
    {
      "sessionId": "aaaaaaaa-1111-2222-3333-aaaaaaaaaaaa",
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
    touch -d "2026-05-08 10:00:00" "$proj_dir/$uuid_jsonl.jsonl"

    # A JSONL session that contains ONLY a <command-*> wrapped prompt — the
    # completer should filter this out (claude --resume rejects it).
    local uuid_filtered="cccccccc-1111-2222-3333-cccccccccccc"
    cat > "$proj_dir/$uuid_filtered.jsonl" <<JSONL
{"type":"user","gitBranch":"main","message":{"content":"<command-stdout>boring</command-stdout>"}}
JSONL
    touch -d "2026-05-07 10:00:00" "$proj_dir/$uuid_filtered.jsonl"

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
# Filtered <command-*> session must not show up.
assert_not_contains "cccccccc" "$output" "filtered command-only session"

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
