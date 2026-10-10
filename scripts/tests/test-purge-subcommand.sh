#!/bin/bash
#
# Test for `claude purge`, which Claude v2.1.288 promoted from
# `claude project purge`, and for `claude plugin test`. The old
# `project purge` spelling still runs, so it has to keep completing too.

set -e
TEST_NAME=test-purge-subcommand
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT
mkdir -p "$home/work/some-project"

log "case 1: 'claude <TAB>' lists purge"
output=$(run_completion "$home" "$home/work" 'claude \t')
assert_no_completion_errors "$output"
assert_contains "purge" "$output" "top-level command list"

log "case 2: 'claude purge --<TAB>' lists purge flags"
output=$(run_completion "$home" "$home/work" 'claude purge --\t')
assert_no_completion_errors "$output"
for flag in --all --dry-run --interactive --yes; do
    assert_contains "$flag" "$output" "purge flag '$flag'"
done

log "case 3: 'claude purge <TAB>' completes a directory path"
output=$(run_completion "$home" "$home/work" 'claude purge \t')
assert_no_completion_errors "$output"
assert_contains "some-project" "$output" "purge path completion"

log "case 4: 'claude project purge --<TAB>' still lists the same flags"
output=$(run_completion "$home" "$home/work" 'claude project purge --\t')
assert_no_completion_errors "$output"
for flag in --all --dry-run --interactive --yes; do
    assert_contains "$flag" "$output" "project purge flag '$flag'"
done

log "case 5: 'claude plugin <TAB>' lists test"
output=$(run_completion "$home" "$home/work" 'claude plugin \t')
assert_no_completion_errors "$output"
assert_contains "Run a mod" "$output" "plugin subcommand list"

log "case 6: 'claude plugin test <TAB>' completes a directory path"
output=$(run_completion "$home" "$home/work" 'claude plugin test \t')
assert_no_completion_errors "$output"
assert_contains "some-project" "$output" "plugin test directory completion"

pass "purge and plugin test completion OK"
