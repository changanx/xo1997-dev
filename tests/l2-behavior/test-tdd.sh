#!/usr/bin/env bash
# Test: test-driven-development skill behavior
# Verifies that the skill enforces RED-GREEN-REFACTOR discipline
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: test-driven-development behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify RED-GREEN-REFACTOR order
echo "Test 1: RED-GREEN-REFACTOR order..."

output=$(run_claude "What is the RED-GREEN-REFACTOR cycle in test-driven-development? What order must these phases be followed?" 30)

if assert_order "$output" "red\|write.*test\|failing.*test" "green\|make.*pass\|implement" "RED before GREEN"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify test must be written first
echo "Test 2: Test must be written first..."

output=$(run_claude "In test-driven-development, can I write implementation code before writing tests? What does the skill say about this?" 30)

if assert_contains "$output" "no\|cannot\|must.*first\|test.*first\|before.*implement\|never.*implement.*first" "Prohibits implementation before test"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify failing test requirement
echo "Test 3: Failing test requirement..."

output=$(run_claude "After writing a test in TDD, what must happen before writing implementation? What should the test do?" 30)

if assert_contains "$output" "fail\|failing\|run.*test\|verify.*fail" "Test must fail first"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify minimal implementation
echo "Test 4: Minimal implementation principle..."

output=$(run_claude "In test-driven-development, how much code should I write to make a test pass? What is the minimal implementation principle?" 30)

if assert_contains "$output" "minimal\|simplest\|just enough\|bare.*minimum\|smallest" "Mentions minimal implementation"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify REFACTOR phase
echo "Test 5: REFACTOR phase..."

output=$(run_claude "After a test passes in TDD, what happens in the REFACTOR phase? Can I skip it?" 30)

if assert_contains "$output" "refactor\|clean\|improve\|optimize" "Mentions REFACTOR phase"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify this is a rigid discipline
echo "Test 6: Rigid discipline type..."

output=$(run_claude "Is test-driven-development a flexible guideline or a rigid discipline? Can I adapt it to skip steps?" 30)

if assert_contains "$output" "rigid\|discipline\|must\|required\|cannot.*skip\|strict\|enforce" "Indicates rigid discipline"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
