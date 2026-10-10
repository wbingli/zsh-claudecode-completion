#!/bin/bash
#
# Regression test for the top-level command list in _claude.
#
# The list used to live in a local array named `commands`, which is the name
# of zsh's special hash of executables. A local of that name hides the hash
# from _claude and from every completer it calls, so `$+commands[jq]` was
# always 0 there. The array is now `claude_commands`, and known_commands and
# the '1:command:(...)' spec are derived from it. This test verifies that:
#   - a completer reached through _claude still sees zsh's $commands hash
#   - `claude <TAB>` lists every command exactly once
#   - every listed command has a branch in the dispatch case statement

set -e
TEST_NAME=test-commands-shadow
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# Any zsh error raised during completion is printed as "_name:NN: message".
assert_no_zsh_errors() {
    local output="$1"
    if grep -Eq '_[A-Za-z_]+:[0-9]+: ' <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "zsh error printed during completion"
    fi
}

log "case 1: a completer called from _claude sees zsh's \$commands hash"
# Replace _files with a probe that reports what it sees. `zsh` is certainly
# in the hash, since the test shell itself is zsh found on PATH.
cat >> "$home/.zshrc" <<'ZSHRC'
_files() { compadd -- "cmdhash-${+commands[zsh]}-seen" }
ZSHRC
output=$(run_completion "$home" "$home" 'claude --settings \t')
assert_no_completion_errors "$output"
assert_no_zsh_errors "$output"
assert_not_contains "cmdhash-0-seen" "$output" "probe output (\$commands is shadowed)"
assert_contains "cmdhash-1-seen" "$output" "probe output"

# Command names, read from the claude_commands array in _claude. This comes
# after case 1 so that a regression of the shadow is reported as such, rather
# than as a missing array.
names=()
while IFS= read -r name; do
    names+=("$name")
done < <(sed -n "/^claude_commands=(/,/^)/s/^  '\([a-z-]*\):.*/\1/p" "$COMPLETION_FILE")
(( ${#names[@]} > 0 )) || fail "no claude_commands array found in $COMPLETION_FILE"
for sentinel in mcp daemon remote-control; do
    [[ " ${names[*]} " == *" $sentinel "* ]] || fail "'$sentinel' missing from claude_commands"
done

log "case 2: 'claude <TAB>' lists each command exactly once"
output=$(run_completion "$home" "$home" 'claude \t')
assert_no_completion_errors "$output"
assert_no_zsh_errors "$output"
# One token per line, without escape sequences, so `plugin` and `plugins`
# (or `stop` inside a description) are not confused.
tokens=$(sed 's/\x1b\[[0-9;?]*[A-Za-z]//g' <<< "$output" | tr -s ' \t\r' '\n')
for name in "${names[@]}"; do
    count=$(grep -cxF -- "$name" <<< "$tokens" || true)
    if [[ "$count" != 1 ]]; then
        printf '%s\n' "$output" >&2
        fail "expected '$name' exactly once in 'claude <TAB>', found $count"
    fi
done

log "case 3: every command has a branch in the dispatch case statement"
# The scanner detects every name in claude_commands; one without a branch
# would fall through to the top-level flags and command list.
for name in "${names[@]}"; do
    grep -Eq "^  ([a-z|-]+\|)?$name(\|[a-z|-]+)?\)\$" "$COMPLETION_FILE" \
        || fail "no case branch for command '$name'"
done

pass "command list OK (${#names[@]} commands)"
