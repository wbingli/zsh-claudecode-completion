#!/bin/bash
#
# Test for `--setting-sources`, which takes a comma-separated list of
# `user`, `project` and `local`. Completion has to offer the values, leave
# out the ones already on the line, and join them with a comma rather than
# ending the word with a space.

set -e
TEST_NAME=test-setting-sources
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# Drop CSI escape sequences (colors, bold, bracketed paste) from tty output.
strip_ansi() {
    sed $'s/\033\\[[0-9;?]*[A-Za-z]//g' <<< "$1"
}

log "case 1: first value offers all three sources"
output=$(run_completion "$home" "$home" 'claude --setting-sources \t')
assert_no_completion_errors "$output"
assert_contains "local  *project  *user" "$output" "first-value list"

# zsh highlights the separator it will insert (`user<ESC>[1m,`) on terminals
# that can do bold and prints it plain elsewhere, so strip the escape
# sequences before looking at the completed word. A space there would end
# the list.
log "case 2: a unique match is followed by a comma, not a space"
output=$(run_completion "$home" "$home" 'claude --setting-sources us\t')
assert_no_completion_errors "$output"
plain=$(strip_ansi "$output")
assert_contains "setting-sources user," "$plain" "completed first value"
assert_not_contains "setting-sources user " "$plain" "completed first value"

log "case 3: second value leaves out the one already chosen"
output=$(run_completion "$home" "$home" 'claude --setting-sources user,\t')
assert_no_completion_errors "$output"
assert_contains "local  *project" "$output" "second-value list"
assert_not_contains "project  *user" "$output" "second-value list"

log "case 4: second value completes after the comma"
output=$(run_completion "$home" "$home" 'claude --setting-sources user,pro\t')
assert_no_completion_errors "$output"
plain=$(strip_ansi "$output")
assert_contains "setting-sources user,project" "$plain" "completed second value"
assert_not_contains "setting-sources user,project " "$plain" "completed second value"

log "case 5: 'claude agents --setting-sources' behaves the same"
output=$(run_completion "$home" "$home" 'claude agents --setting-sources local,\t')
assert_no_completion_errors "$output"
assert_contains "project  *user" "$output" "agents second-value list"
assert_not_contains "local  *project" "$output" "agents second-value list"

pass "--setting-sources value completion OK"
