#!/bin/bash
#
# Static guard for flags that the Claude CLI accepts but does NOT list as
# their own row in `claude --help`. These have been removed by an automated
# regeneration before (see PR #121); this test fails fast if it happens again.
#
# If you're intentionally removing one of these, verify the CLI actually
# rejects the flag (e.g. `claude --system-prompt-file /tmp/nope 2>&1` should
# say "Bad option", not "file not found") before deleting from this list.

set -e
TEST_NAME=test-hidden-flags
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

[[ -f "$COMPLETION_FILE" ]] || fail "completion file not found: $COMPLETION_FILE"

required_flags=(
    "--system-prompt-file"
    "--append-system-prompt-file"
)

for flag in "${required_flags[@]}"; do
    if ! grep -qF -- "'$flag[" "$COMPLETION_FILE"; then
        fail "missing required hidden flag '$flag' in $COMPLETION_FILE — the CLI still accepts it even though it's not listed in 'claude --help' (referenced inside --bare's description as ${flag%-file}[-file])"
    fi
    log "found $flag"
done

pass "hidden flags preserved"
