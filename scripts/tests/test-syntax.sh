#!/bin/bash
#
# Static syntax check: confirm `zsh -n _claude` parses without errors.
# This catches typos, unterminated strings, and other parse-time issues
# without needing an interactive session.

set -e
TEST_NAME=test-syntax
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_dep zsh
[[ -f "$COMPLETION_FILE" ]] || fail "completion file not found: $COMPLETION_FILE"

log "running zsh -n on $COMPLETION_FILE"
output=$(zsh -n "$COMPLETION_FILE" 2>&1) || {
    printf '%s\n' "$output" >&2
    fail "zsh -n reported syntax errors"
}

pass "static syntax OK"
