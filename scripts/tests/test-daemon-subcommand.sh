#!/bin/bash
#
# Completion test for the hidden `claude daemon` subcommand. Verifies the
# subcommand list (`run`, `status`, `logs`, `uninstall`, `stop`), the
# daemon-wide options (`--json-path`, `--log-file`), and the stop-specific
# flags (`--any`, `--keep-workers`).

set -e
TEST_NAME=test-daemon-subcommand
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

log "case 1: 'claude daemon <TAB>' lists daemon subcommands"
output=$(run_completion "$home" "$home" 'claude daemon \t')
assert_no_completion_errors "$output"
for cmd in run status logs uninstall stop; do
    assert_contains "$cmd" "$output" "daemon subcommand '$cmd'"
done

log "case 2: 'claude daemon --<TAB>' offers daemon-wide options"
output=$(run_completion "$home" "$home" 'claude daemon run --\t')
assert_no_completion_errors "$output"
for flag in --json-path --log-file; do
    assert_contains -- "$flag" "$output" "daemon flag '$flag'"
done

log "case 3: 'claude daemon stop --<TAB>' includes stop-specific flags"
output=$(run_completion "$home" "$home" 'claude daemon stop --\t')
assert_no_completion_errors "$output"
for flag in --any --keep-workers; do
    assert_contains -- "$flag" "$output" "daemon stop flag '$flag'"
done

pass "daemon subcommand completion OK"
