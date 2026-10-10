#!/bin/bash
#
# Regression test for `claude agents` completion. The `agents` subcommand
# accepts only flags (no positional args). `_arguments` counts positionals
# from $words[2], so when it was handed the whole command line the `agents`
# word itself was an unmatched positional and `claude agents <TAB>` /
# `claude agents --<TAB>` produced no completions at all. `_claude` now
# trims $words so the subcommand is $words[1].

set -e
TEST_NAME=test-agents-subcommand
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

log "case 1: 'claude agents <TAB>' completes without error"
output=$(run_completion "$home" "$home" 'claude agents \t')
assert_no_completion_errors "$output"

log "case 2: 'claude agents --<TAB>' lists agents-specific flags"
output=$(run_completion "$home" "$home" 'claude agents --\t')
assert_no_completion_errors "$output"
for flag in --add-dir --cwd --effort --json --model --permission-mode \
            --plugin-dir --settings --strict-mcp-config; do
    assert_contains -- "$flag" "$output" "agents flag '$flag'"
done

log "case 3: 'claude agents --permission-mode <TAB>' offers mode values"
output=$(run_completion "$home" "$home" 'claude agents --permission-mode \t')
assert_no_completion_errors "$output"
for mode in acceptEdits bypassPermissions manual plan; do
    assert_contains "$mode" "$output" "permission-mode value '$mode'"
done

pass "agents subcommand completion OK"
