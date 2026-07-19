#!/bin/bash
#
# Regression test for `claude agents` completion. The `agents` subcommand
# accepts only flags (no positional args), so an earlier `_arguments` block
# omitted the `:cmd:` placeholder that absorbs the subcommand word. When
# `_arguments` is invoked here as `claude`'s top-level completer, positionals
# are counted from $words[2] — without `:cmd:` the `agents` word fell through
# unmatched and `claude agents <TAB>` / `claude agents --<TAB>` produced no
# completions at all.

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
