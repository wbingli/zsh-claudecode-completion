#!/bin/bash
#
# Test for subcommand dispatch (issue #230).
#
# `_arguments` counts positional arguments from $words[2]. The nested
# blocks (`plugin validate`, `mcp add`, ...) used to hand it the whole
# command line, so their positionals were counted from `claude` and never
# completed. `_claude` now trims $words at each subcommand level. This
# test covers:
#   - positionals of nested subcommands, also with flags before the command
#   - command words are only looked for before the cursor
#   - `plugin eval` targets and flags in any order, and `eval init`
#   - none of the above prints a zsh error

set -e
TEST_NAME=test-nested-positionals
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# The two names share no prefix, so a TAB lists both instead of inserting
# the common part.
work="$home/work"
mkdir -p "$work/alpha-dir"
: > "$work/server.sh"

# Any error zsh raises inside a completion function is printed as
# `<function>:<line>: <message>`, e.g. `_alternative:7: bad option: -J`.
assert_clean() {
    local output="$1"
    assert_no_completion_errors "$output"
    if grep -Eq '(^|[^[:alnum:]_])_[[:alnum:]_]+:[0-9]+: ' <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "zsh error printed during completion"
    fi
}

complete() { run_completion "$home" "$work" "$1"; }

log "case 1: 'claude plugin validate <TAB>' completes a path"
output=$(complete 'claude plugin validate \t')
assert_clean "$output"
assert_contains "alpha-dir" "$output" "plugin validate path"

log "case 2: 'claude plugin validate --<TAB>' still lists its flags"
output=$(complete 'claude plugin validate --\t')
assert_clean "$output"
assert_contains "--strict" "$output" "plugin validate flags"

log "case 3: 'claude mcp add name <TAB>' completes the command path"
output=$(complete 'claude mcp add myserver \t')
assert_clean "$output"
assert_contains "server.sh" "$output" "mcp add commandOrUrl"

log "case 4: flags before the command do not shift the positionals"
output=$(complete 'claude --verbose plugin validate \t')
assert_clean "$output"
assert_contains "alpha-dir" "$output" "plugin validate path after a leading flag"
output=$(complete 'claude --model opus plugin marketplace add \t')
assert_clean "$output"
assert_contains "alpha-dir" "$output" "marketplace add source after a leading flag with a value"

log "case 5: 'claude plugin marketplace <TAB>' lists marketplace commands"
output=$(complete 'claude plugin marketplace \t')
assert_clean "$output"
assert_contains "Add a marketplace" "$output" "marketplace command list"

log "case 6: a partial command word is completed, not treated as the command"
output=$(complete 'claude plugin\t')
assert_clean "$output"
assert_contains "plugins" "$output" "candidates for 'plugin'"
assert_not_contains "marketplace" "$output" "candidates for 'plugin'"

# Type the whole line, move the cursor back to just after `--m` with
# twelve backward-char keys (the length of ` mcp get foo`), then TAB.
# `--m` is ambiguous on purpose, so zsh lists the flags instead of
# inserting the rest of one.
log "case 7: words after the cursor are not taken as the command"
output=$(complete 'claude --m mcp get foo\002\002\002\002\002\002\002\002\002\002\002\002\t')
assert_clean "$output"
assert_contains "--model" "$output" "top-level flag before a later command word"

log "case 8: 'claude plugin eval <TAB>' offers init and paths, without errors"
output=$(complete 'claude plugin eval \t')
assert_clean "$output"
assert_contains "init" "$output" "plugin eval candidates"
assert_contains "alpha-dir" "$output" "plugin eval candidates"

log "case 9: 'claude plugin eval --<TAB>' lists eval flags"
output=$(complete 'claude plugin eval --\t')
assert_clean "$output"
assert_contains "--ablation" "$output" "plugin eval flags"

log "case 10: eval flags are still offered after the target"
output=$(complete 'claude plugin eval alpha-dir --\t')
assert_clean "$output"
assert_contains "--ablation" "$output" "plugin eval flags after the target"

log "case 11: 'claude plugin eval init --<TAB>' lists init flags only"
output=$(complete 'claude plugin eval init --\t')
assert_clean "$output"
assert_contains "--bare" "$output" "plugin eval init flags"
assert_not_contains "--ablation" "$output" "plugin eval init flags"

log "case 12: init is found after eval flags too"
output=$(complete 'claude plugin eval --verbose init --\t')
assert_clean "$output"
assert_contains "--bare" "$output" "plugin eval init flags after --verbose"
assert_not_contains "--ablation" "$output" "plugin eval init flags after --verbose"

log "case 13: 'init' as an option value or after a target is not the command"
output=$(complete 'claude plugin eval --case init --\t')
assert_clean "$output"
assert_contains "--ablation" "$output" "eval flags after '--case init'"
assert_not_contains "--bare" "$output" "eval flags after '--case init'"
output=$(complete 'claude plugin eval alpha-dir init --\t')
assert_clean "$output"
assert_contains "--ablation" "$output" "eval flags after a target and 'init'"
assert_not_contains "--bare" "$output" "eval flags after a target and 'init'"

# `--json [path]` takes a value only when one follows, and `--tag <tag...>`
# and `--allow-tools <tools...>` take every word up to the next option.
log "case 14: 'init' after an optional value that is already given is the command"
output=$(complete 'claude plugin eval --json result.json init --\t')
assert_clean "$output"
assert_contains "--bare" "$output" "init flags after '--json result.json'"
assert_not_contains "--ablation" "$output" "init flags after '--json result.json'"

log "case 15: 'init' as an optional or repeated option value is not the command"
for opt in '--json' '--tag smoke' '--allow-tools Bash'; do
    output=$(complete "claude plugin eval $opt init --\\t")
    assert_clean "$output"
    assert_contains "--ablation" "$output" "eval flags after '$opt init'"
    assert_not_contains "--bare" "$output" "eval flags after '$opt init'"
done

log "case 16: an option ends a repeated value list, so 'init' is the command again"
output=$(complete 'claude plugin eval --tag smoke --verbose init --\t')
assert_clean "$output"
assert_contains "--bare" "$output" "init flags after '--tag smoke --verbose'"
assert_not_contains "--ablation" "$output" "init flags after '--tag smoke --verbose'"

log "case 17: top-level positionals are unaffected"
output=$(complete 'claude install \t')
assert_clean "$output"
assert_contains "stable" "$output" "install target"

pass "nested positional and plugin eval completion OK"
