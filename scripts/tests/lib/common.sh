#!/bin/bash
#
# Shared helpers for completion verification tests.
#
# Each test script under scripts/tests/test-*.sh sources this file, then
# uses the helpers below to drive an interactive zsh under expect.

# Resolve the repo root regardless of where the test was invoked from.
COMMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$COMMON_LIB_DIR/../../.." && pwd)"
COMPLETION_FILE="$REPO_ROOT/_claude"

# Test name for log prefixes — set by each test file.
: "${TEST_NAME:=$(basename "${0##*/}" .sh)}"

log()  { printf '  [%s] %s\n' "$TEST_NAME" "$*"; }
fail() { printf '\n[%s] FAIL: %s\n' "$TEST_NAME" "$*" >&2; exit 1; }
pass() { printf '[%s] PASS%s\n'    "$TEST_NAME" "${1:+: $1}"; exit 0; }

require_dep() {
    command -v "$1" >/dev/null 2>&1 || fail "required dependency '$1' is not installed"
}

require_common_deps() {
    require_dep zsh
    require_dep expect
    [[ -f "$COMPLETION_FILE" ]] || fail "completion file not found: $COMPLETION_FILE"
}

# Create a temporary HOME with a minimal .zshrc that loads the completion.
# Caller is responsible for cleaning up.
#
#   home=$(make_test_home)
#   trap 'rm -rf "$home"' EXIT
make_test_home() {
    local home
    home=$(mktemp -d)
    cat > "$home/.zshrc" <<ZSHRC
fpath=($REPO_ROOT \$fpath)
autoload -Uz compinit && compinit -u -d /dev/null
autoload -Uz _claude && compdef _claude claude
setopt AUTO_LIST NO_BEEP
PS1='TEST> '
ZSHRC
    printf '%s\n' "$home"
}

# Drive zsh through expect: spawn with HOME=$home and CWD=$start_dir,
# source the test rc, send $send_keys, wait briefly for completion output,
# then exit cleanly. Everything zsh wrote to the tty is echoed to stdout
# so the caller can grep it.
#
# Usage: output=$(run_completion "$home" "$start_dir" 'claude -r \t' [extra_env])
# extra_env is an optional Tcl line, e.g.  'set env(CLAUDE_COMPLETION_SESSION_LIMIT) "1"'
run_completion() {
    local home="$1" start_dir="$2" send_keys="$3" extra_env="${4:-}"
    local output_file="$home/expect-output.txt"

    # The heredoc is unquoted so bash variables ($home, $send_keys, $start_dir,
    # $extra_env) expand. Tcl-level `$` escapes use `\$`, which bash collapses
    # to `$` before expect sees it. This mirrors the pattern in the previous
    # monolithic verify-completions.sh.
    expect <<EXPECT_SCRIPT > "$output_file" 2>&1
set timeout 15
set env(HOME) "$home"
$extra_env
cd "$start_dir"
spawn zsh -f

expect {
    -re {%|>|\$} {}
    timeout { puts "TIMEOUT_INITIAL"; exit 1 }
    eof { puts "EOF_INITIAL"; exit 1 }
}

send "source $home/.zshrc\r"
expect {
    "TEST>" {}
    -re "insecure directories" { send "y\r"; exp_continue }
    timeout { puts "TIMEOUT_RC"; exit 1 }
    eof { puts "EOF_RC"; exit 1 }
}

send "$send_keys"
sleep 1

expect {
    -re "invalid option definition" { puts "ERROR_INVALID_OPTION" }
    -re "_arguments:.*:.*:" { puts "ERROR_ARGUMENTS" }
    -re "TEST>" {}
    timeout {}
}

# Clear the half-typed line, then exit cleanly.
send "\003"
sleep 0.1
send "exit\r"
expect eof
puts "EXPECT_DONE"
EXPECT_SCRIPT

    local rc=$?
    cat "$output_file"
    return $rc
}

# Standard sanity checks for run_completion output.
assert_no_completion_errors() {
    local output="$1"
    if grep -q "ERROR_INVALID_OPTION" <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "invalid option definition detected"
    fi
    if grep -q "ERROR_ARGUMENTS" <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "_arguments parsing error detected"
    fi
    if ! grep -q "EXPECT_DONE" <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "expect harness did not finish (timeout or zsh crash)"
    fi
}

assert_contains() {
    local needle="$1" output="$2" desc="${3:-output}"
    if ! grep -q -- "$needle" <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "expected '$needle' to appear in $desc"
    fi
}

assert_not_contains() {
    local needle="$1" output="$2" desc="${3:-output}"
    if grep -q -- "$needle" <<< "$output"; then
        printf '%s\n' "$output" >&2
        fail "expected '$needle' to NOT appear in $desc"
    fi
}
