#!/usr/bin/env bash
# Test: systematic-debugging skill behavior
# Verifies that the skill enforces information gathering before code changes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: systematic-debugging behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify information gathering first
echo "Test 1: Information gathering required first..."

output=$(run_claude "In systematic-debugging, what is the first thing to do when encountering a bug? Can I immediately start changing code?" 30)

if assert_contains "$output" "gather\|collect\|information\|understand\|investigate\|no\|cannot\|before.*change" "Must gather information first"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify prohibition on immediate fixes
echo "Test 2: Prohibition on immediate fixes..."

output=$(run_claude "The systematic-debugging skill says I should not immediately fix bugs. Why? What's the reasoning?" 30)

if assert_contains "$output" "understand\|root.*cause\|why\|symptom\|actual.*cause\|premature" "Explains why no immediate fix"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify hypothesis formation
echo "Test 3: Hypothesis formation..."

output=$(run_claude "How does systematic-debugging approach finding the root cause? What role do hypotheses play?" 30)

if assert_contains "$output" "hypothesis\|hypothese\|guess\|theory\|test" "Mentions hypothesis"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify this is a rigid discipline
echo "Test 4: Rigid discipline type..."

output=$(run_claude "Is systematic-debugging a flexible guideline or a rigid discipline? What happens if I skip the investigation phase?" 30)

if assert_contains "$output" "rigid\|discipline\|must\|required\|cannot.*skip\|strict" "Indicates rigid discipline"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify steps/phases
echo "Test 5: Debugging phases..."

output=$(run_claude "What are the main phases or steps in systematic-debugging? List them in order." 30)

if assert_contains "$output" "gather\|collect\|investigate" "Has information gathering phase"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if assert_contains "$output" "hypothesis\|analyze\|identify" "Has hypothesis/analysis phase"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify verification requirement
echo "Test 6: Verification requirement..."

output=$(run_claude "After fixing a bug in systematic-debugging, what must be done to verify the fix?" 30)

if assert_contains "$output" "verify\|test\|confirm\|reproduce" "Requires verification"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
