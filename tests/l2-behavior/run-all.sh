#!/usr/bin/env bash
# Run all L2 behavior tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "========================================"
echo " L2 Behavior Tests"
echo "========================================"
echo ""

passed=0
failed=0

for test_script in "$SCRIPT_DIR"/test-*.sh; do
    test_name=$(basename "$test_script" .sh)

    echo "--- Running: $test_name ---"

    if bash "$test_script" 2>&1; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi

    echo ""
done

echo "========================================"
echo " Summary"
echo "========================================"
echo "  Passed: $passed"
echo "  Failed: $failed"
echo ""

if [ "$failed" -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
else
    echo "STATUS: PASSED"
    exit 0
fi
