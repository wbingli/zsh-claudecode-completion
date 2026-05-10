#!/bin/bash
#
# Interactive completion test for the global flag layer.
# Tabs through `claude --` and confirms _arguments doesn't error out.

set -e
TEST_NAME=test-global-flags
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

log "completing 'claude --<TAB>'"
output=$(run_completion "$home" "$home" 'claude --\t')
assert_no_completion_errors "$output"

pass "global flag completion OK"
