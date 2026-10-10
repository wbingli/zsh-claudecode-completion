#!/bin/bash
#
# Value completion for `--effort`. The CLI accepts `ultracode` (xhigh effort
# with ultracode turned on) although `--help` and the "Valid values" warning
# list only low, medium, high, xhigh, max — so a regeneration from help text
# alone would drop it. Covers both the top-level flag and `claude agents`.

set -e
TEST_NAME=test-effort-values
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

check_levels() {
    local output="$1" where="$2" level
    assert_no_completion_errors "$output"
    # Any zsh error raised inside a completion function looks like `_name:NN: ...`.
    assert_not_contains '_[a-z_]*:[0-9][0-9]*: ' "$output" "$where (zsh error)"
    for level in low medium high xhigh max ultracode; do
        assert_contains "$level" "$output" "$where"
    done
}

log "case 1: 'claude --effort <TAB>' offers every level including ultracode"
output=$(run_completion "$home" "$home" 'claude --effort \t')
check_levels "$output" "top-level --effort values"

log "case 2: 'claude agents --effort <TAB>' offers the same levels"
output=$(run_completion "$home" "$home" 'claude agents --effort \t')
check_levels "$output" "agents --effort values"

pass "--effort value completion OK"
