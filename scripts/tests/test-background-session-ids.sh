#!/bin/bash
#
# Coverage for the _claude_background_session_ids completer used by the
# background-session subcommands (`claude attach|logs|stop|kill|respawn|rm`).
#
# Fixture: builds ~/.claude/daemon/roster.json and ~/.claude/jobs/<id>/state.json
# under a fake HOME, then asserts:
#   1. Ids from roster.json appear in the completion list.
#   2. The label is enriched with the name + state pulled from state.json.
#   3. When roster.json is missing, the directory-scan fallback still works.
#   4. Each background-session subcommand triggers the completer.

set -e
TEST_NAME=test-background-session-ids
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps
require_dep jq

# ---------------------------------------------------------------------------
# Fixture builders
# ---------------------------------------------------------------------------

# Build a roster + state files for two background sessions.
build_roster_fixture() {
    local home="$1"
    local daemon_dir="$home/.claude/daemon"
    local jobs_dir="$home/.claude/jobs"
    mkdir -p "$daemon_dir" "$jobs_dir/7c5dcf5d" "$jobs_dir/9a1b2c3d"

    # Real roster.json shape (Claude v2.1.139): `{"workers": {"<short>": {...}}}`
    # where the OBJECT KEY is the short id. The completer keys off this shape.
    cat > "$daemon_dir/roster.json" <<'JSON'
{
  "proto": 1,
  "workers": {
    "7c5dcf5d": {"sessionId": "7c5dcf5d-aaaa-bbbb-cccc-dddddddddddd", "cliVersion": "2.1.139"},
    "9a1b2c3d": {"sessionId": "9a1b2c3d-aaaa-bbbb-cccc-eeeeeeeeeeee", "cliVersion": "2.1.139"}
  }
}
JSON

    cat > "$jobs_dir/7c5dcf5d/state.json" <<'JSON'
{"name": "investigate flaky test", "state": "working"}
JSON

    cat > "$jobs_dir/9a1b2c3d/state.json" <<'JSON'
{"name": "address PR review", "state": "needs_input"}
JSON
}

# Build only state.json dirs (no roster) — exercises the directory-scan
# fallback path used when the supervisor isn't running. Two entries are
# needed so the completion menu actually renders; with a single match zsh
# auto-inserts it without printing the description.
build_jobs_only_fixture() {
    local home="$1"
    local jobs_dir="$home/.claude/jobs"
    mkdir -p "$jobs_dir/deadbeef" "$jobs_dir/cafef00d"
    cat > "$jobs_dir/deadbeef/state.json" <<'JSON'
{"name": "orphan session", "state": "stopped"}
JSON
    cat > "$jobs_dir/cafef00d/state.json" <<'JSON'
{"name": "second orphan", "state": "stopped"}
JSON
}

# ---------------------------------------------------------------------------
# Test 1: roster-driven completion with enriched labels
# ---------------------------------------------------------------------------
home=$(make_test_home)
trap 'rm -rf "$home"' EXIT
build_roster_fixture "$home"

work_dir="$home/work"
mkdir -p "$work_dir"

log "case 1: roster ids + state.json labels surface for 'claude attach'"
output=$(run_completion "$home" "$work_dir" 'claude attach \t')
assert_no_completion_errors "$output"
assert_contains "7c5dcf5d" "$output" "first roster id"
assert_contains "9a1b2c3d" "$output" "second roster id"
assert_contains "investigate flaky test" "$output" "first session name from state.json"
assert_contains "address PR review" "$output" "second session name from state.json"
assert_contains "working" "$output" "first session state"
assert_contains "needs_input" "$output" "second session state"

# ---------------------------------------------------------------------------
# Test 2: each background-session subcommand wires up the completer
# ---------------------------------------------------------------------------
for cmd in logs stop kill rm respawn; do
    log "case 2.$cmd: 'claude $cmd' offers background session ids"
    output=$(run_completion "$home" "$work_dir" "claude $cmd \\t")
    assert_no_completion_errors "$output"
    assert_contains "7c5dcf5d" "$output" "$cmd offers roster id"
done

# ---------------------------------------------------------------------------
# Test 3: respawn --all is a valid completion alternative
# ---------------------------------------------------------------------------
log "case 3: 'claude respawn --' includes --all"
output=$(run_completion "$home" "$work_dir" 'claude respawn --\t')
assert_no_completion_errors "$output"
assert_contains -- "--all" "$output" "respawn --all flag"

# ---------------------------------------------------------------------------
# Test 4: jobs/ directory-scan fallback when roster.json is missing
# ---------------------------------------------------------------------------
rm -rf "$home/.claude"
build_jobs_only_fixture "$home"

log "case 4: fallback scans ~/.claude/jobs when roster.json is absent"
output=$(run_completion "$home" "$work_dir" 'claude attach \t')
assert_no_completion_errors "$output"
assert_contains "deadbeef" "$output" "fallback-discovered id"
assert_contains "cafef00d" "$output" "second fallback-discovered id"
assert_contains "orphan session" "$output" "fallback id picks up name from state.json"

# ---------------------------------------------------------------------------
# Test 5: new top-level commands are listed at the command position
# ---------------------------------------------------------------------------
log "case 5: 'claude <TAB>' lists the new background-session subcommands"
output=$(run_completion "$home" "$work_dir" 'claude \t')
assert_no_completion_errors "$output"
for cmd in attach logs stop kill respawn rm; do
    assert_contains "$cmd" "$output" "top-level command '$cmd'"
done

pass "background session id auto-suggestion OK"
