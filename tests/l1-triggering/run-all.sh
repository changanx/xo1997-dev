#!/usr/bin/env bash
# Run all L1 triggering tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "========================================"
echo " L1 Triggering Tests"
echo "========================================"
echo ""

passed=0
failed=0
skipped=0

for prompt_file in "$SCRIPT_DIR/prompts"/*.txt; do
    skill_name=$(basename "$prompt_file" .txt)

    echo "--- Testing: $skill_name ---"

    if OUTPUT=$(bash "$SCRIPT_DIR/run-test.sh" "$skill_name" 2>&1); then
        passed=$((passed + 1))
        echo "[PASS] $skill_name"
    else
        if echo "$OUTPUT" | grep -q "SKIP"; then
            skipped=$((skipped + 1))
            echo "[SKIP] $skill_name"
        else
            failed=$((failed + 1))
            echo "[FAIL] $skill_name"
        fi
    fi

    echo ""
done

echo "========================================"
echo " Summary"
echo "========================================"
echo "  Passed:  $passed"
echo "  Failed:  $failed"
echo "  Skipped: $skipped"
echo ""

if [ "$failed" -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
else
    echo "STATUS: PASSED"
    exit 0
fi
