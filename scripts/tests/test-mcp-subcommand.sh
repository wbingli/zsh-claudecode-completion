#!/bin/bash
#
# Subcommand completion test. Catches issues with alias-expanded flags
# appearing before the subcommand and with the per-subcommand _arguments
# blocks (e.g. `claude mcp <TAB>`).

set -e
TEST_NAME=test-mcp-subcommand
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

log "completing 'claude mcp <TAB>'"
output=$(run_completion "$home" "$home" 'claude mcp \t')
assert_no_completion_errors "$output"

pass "mcp subcommand completion OK"
