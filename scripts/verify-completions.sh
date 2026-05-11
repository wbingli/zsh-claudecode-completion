#!/bin/bash
#
# Test runner for the _claude completion script.
#
# Discovers and executes every scripts/tests/test-*.sh file, then prints a
# summary. Each subtest is self-contained: it sources lib/common.sh, builds
# its own fixture, drives zsh through expect, and exits 0/non-zero.
#
# Usage:
#   ./scripts/verify-completions.sh                  # run everything
#   ./scripts/verify-completions.sh test-session-ids # run a single test
#
# Exit codes:
#   0 - all tests passed
#   1 - one or more tests failed

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/tests"

if [[ ! -d "$TEST_DIR" ]]; then
    echo "Error: test directory not found: $TEST_DIR" >&2
    exit 1
fi

# Build the list of tests to run.
declare -a tests
if (( $# > 0 )); then
    for arg in "$@"; do
        # Accept both bare names and full paths.
        if [[ -f "$TEST_DIR/$arg.sh" ]]; then
            tests+=("$TEST_DIR/$arg.sh")
        elif [[ -f "$arg" ]]; then
            tests+=("$arg")
        else
            echo "Error: test not found: $arg" >&2
            exit 1
        fi
    done
else
    while IFS= read -r -d '' f; do
        tests+=("$f")
    done < <(find "$TEST_DIR" -maxdepth 1 -name 'test-*.sh' -type f -print0 | sort -z)
fi

if (( ${#tests[@]} == 0 )); then
    echo "Error: no test files found under $TEST_DIR" >&2
    exit 1
fi

declare -i passed=0 failed=0
declare -a failures

for t in "${tests[@]}"; do
    name=$(basename "$t" .sh)
    echo "=== $name ==="
    if bash "$t"; then
        passed+=1
    else
        failed+=1
        failures+=("$name")
    fi
    echo
done

echo "================================="
echo "Tests passed: $passed   failed: $failed"
if (( failed > 0 )); then
    echo
    echo "Failed tests:"
    printf '  - %s\n' "${failures[@]}"
    echo
    echo "VERIFICATION FAILED"
    exit 1
fi

echo "VERIFICATION PASSED"
exit 0
