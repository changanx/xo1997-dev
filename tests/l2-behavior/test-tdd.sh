#!/usr/bin/env bash
# Test: TDD skill behavior for PySide6
# Verifies RED-GREEN-REFACTOR cycle and pytest-qt patterns
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: TDD behavior (PySide6) ==="
echo ""

passed=0
failed=0

# Test 1: Verify iron law
echo "Test 1: Iron law - no code without failing test..."

output=$(run_claude "What is the iron law of TDD for PySide6 development?" 60)

if assert_contains "$output" "failing test\|失败\|RED\|GREEN\|先写测试\|no code" "Mentions iron law"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify pytest-qt usage
echo "Test 2: pytest-qt patterns..."

output=$(run_claude "How should Qt widgets be tested in TDD? What fixtures are needed?" 60)

if assert_contains "$output" "qtbot\|QtBot\|pytest\|fixture\|addWidget" "Mentions pytest-qt"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify signal testing
echo "Test 3: Signal testing..."

output=$(run_claude "How do you test if a Qt signal is emitted when clicking a widget?" 60)

if assert_contains "$output" "waitSignal\|Signal\|clicked\|信号" "Mentions signal testing"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify test file structure
echo "Test 4: Test file structure..."

output=$(run_claude "Where should PySide6 component tests be placed? What is the file naming convention?" 60)

if assert_contains "$output" "tests/\|test_\|_test\.py\|pytest" "Mentions test structure"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
