#!/bin/bash
#
# Coverage for the _claude_background_session_ids completer used by the
# background-session subcommands (`claude attach|logs|stop|kill|respawn|rm`).
#
# The completer matches what `claude agents` itself does: a session is
# anything with a ~/.claude/jobs/<id>/state.json file. roster.json is
# intentionally NOT consulted — it can contain pre-spawn placeholders that
# never became real sessions, and it omits sessions imported via /bg from an
# interactive terminal.

set -e
TEST_NAME=test-background-session-ids
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps
require_dep jq

# ---------------------------------------------------------------------------
# Fixture builder
# ---------------------------------------------------------------------------
#
# Creates three sessions:
#   - 7c5dcf5d: full state.json with name + state ("done")
#   - 9a1b2c3d: state.json with `intent` but no `name` (exercises the
#               intent-as-label fallback observed in real installs)
#   - 6d75c459: present in a roster.json but has NO state.json — the
#               completer must skip these "pre-spawn placeholder" entries.
#   - 55eab974: state.json only, no roster entry (sessions imported via
#               /bg never appear in roster.json — must still complete).
build_fixture() {
    local home="$1"
    local daemon_dir="$home/.claude/daemon"
    local jobs_dir="$home/.claude/jobs"
    mkdir -p "$daemon_dir" \
             "$jobs_dir/7c5dcf5d" \
             "$jobs_dir/9a1b2c3d" \
             "$jobs_dir/55eab974"

    # roster.json with a worker that has no jobs/<id>/state.json — verifies
    # the completer doesn't surface roster-only placeholders.
    cat > "$daemon_dir/roster.json" <<'JSON'
{
  "proto": 1,
  "workers": {
    "6d75c459": {"sessionId": "6d75c459-aaaa-bbbb-cccc-ffffffffffff"}
  }
}
JSON

    cat > "$jobs_dir/7c5dcf5d/state.json" <<'JSON'
{"name": "investigate flaky test", "state": "done"}
JSON

    cat > "$jobs_dir/9a1b2c3d/state.json" <<'JSON'
{"intent": "address PR review comments", "state": "idle"}
JSON

    cat > "$jobs_dir/55eab974/state.json" <<'JSON'
{"name": "imported via /bg", "state": "done"}
JSON

    # mtime-driven ordering: 7c5dcf5d (oldest) → 9a1b2c3d → 55eab974 (newest).
    # The completer sorts by state.json mtime DESC to match `claude agents`
    # ordering (newest first), so 55eab974 should appear before 9a1b2c3d and
    # 9a1b2c3d before 7c5dcf5d in the offered completions.
    touch -d "2026-05-01T10:00:00" "$jobs_dir/7c5dcf5d/state.json"
    touch -d "2026-05-05T10:00:00" "$jobs_dir/9a1b2c3d/state.json"
    touch -d "2026-05-12T10:00:00" "$jobs_dir/55eab974/state.json"
}

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT
build_fixture "$home"

work_dir="$home/work"
mkdir -p "$work_dir"

# ---------------------------------------------------------------------------
# Test 1: completer lists every session that has a state.json, with labels
# enriched from the state.json contents.
# ---------------------------------------------------------------------------
log "case 1: state.json-backed sessions surface for 'claude attach'"
output=$(run_completion "$home" "$work_dir" 'claude attach \t')
assert_no_completion_errors "$output"
assert_contains "7c5dcf5d" "$output" "name+state session id"
assert_contains "investigate flaky test" "$output" "name field used as label"
assert_contains "done" "$output" "state field used as label"
assert_contains "9a1b2c3d" "$output" "intent-only session id"
assert_contains "address PR review comments" "$output" "intent field used as label fallback"
assert_contains "55eab974" "$output" "imported-via-/bg session id (not in roster)"
assert_contains "imported via /bg" "$output" "imported-session label"
# roster-only placeholder must NOT appear because it has no state.json
assert_not_contains "6d75c459" "$output" "roster-only placeholder is filtered out"

# Ordering check: state.json mtime drives the sort, so 55eab974 (newest)
# must appear before 9a1b2c3d (mid) before 7c5dcf5d (oldest). zsh prints
# matches across multiple lines/columns, so the assertion uses each id's
# byte offset in the captured output rather than relying on line-wise
# comparison.
log "case 1b: completions are ordered newest-first by state.json mtime"
pos_newest=$(printf '%s' "$output"   | grep -boa '55eab974' | head -1 | cut -d: -f1)
pos_middle=$(printf '%s' "$output"   | grep -boa '9a1b2c3d' | head -1 | cut -d: -f1)
pos_oldest=$(printf '%s' "$output"   | grep -boa '7c5dcf5d' | head -1 | cut -d: -f1)
if [[ -z "$pos_newest" || -z "$pos_middle" || -z "$pos_oldest" ]]; then
    printf '%s\n' "$output" >&2
    fail "could not locate all three session ids in the output for ordering check"
fi
if ! (( pos_newest < pos_middle && pos_middle < pos_oldest )); then
    printf '%s\n' "$output" >&2
    fail "expected newest-first order; got positions: 55eab974=$pos_newest 9a1b2c3d=$pos_middle 7c5dcf5d=$pos_oldest"
fi

# ---------------------------------------------------------------------------
# Test 2: each background-session subcommand wires up the completer
# ---------------------------------------------------------------------------
for cmd in logs stop kill rm respawn; do
    log "case 2.$cmd: 'claude $cmd' offers background session ids"
    output=$(run_completion "$home" "$work_dir" "claude $cmd \\t")
    assert_no_completion_errors "$output"
    assert_contains "7c5dcf5d" "$output" "$cmd offers state.json-backed id"
done

# ---------------------------------------------------------------------------
# Test 3: respawn --all is a valid completion alternative
# ---------------------------------------------------------------------------
log "case 3: 'claude respawn --' includes --all"
output=$(run_completion "$home" "$work_dir" 'claude respawn --\t')
assert_no_completion_errors "$output"
assert_contains -- "--all" "$output" "respawn --all flag"

# ---------------------------------------------------------------------------
# Test 4: new top-level commands are listed at the command position
# ---------------------------------------------------------------------------
log "case 4: 'claude <TAB>' lists the new background-session subcommands"
output=$(run_completion "$home" "$work_dir" 'claude \t')
assert_no_completion_errors "$output"
for cmd in attach logs stop kill respawn rm; do
    assert_contains "$cmd" "$output" "top-level command '$cmd'"
done

pass "background session id auto-suggestion OK"
