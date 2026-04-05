#!/usr/bin/env bash
# Test: brainstorming skill behavior for PySide6
# Verifies design document requirements and Qt-specific considerations
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: brainstorming behavior (PySide6) ==="
echo ""

passed=0
failed=0

# Test 1: Verify HARD-GATE mechanism
echo "Test 1: HARD-GATE mechanism..."

output=$(run_claude "In the brainstorming skill, what must happen before writing code? Is there a HARD-GATE?" 60)

if assert_contains "$output" "HARD-GATE\|设计\|批准\|approve\|禁止\|不能" "Mentions design gate"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify design document output
echo "Test 2: Design document output location..."

output=$(run_claude "Where does the brainstorming skill save design documents for PySide6 projects?" 60)

if assert_contains "$output" "docs/specs\|design\.md\|设计文档" "Mentions output path"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify Qt-specific questions
echo "Test 3: Qt-specific questions..."

output=$(run_claude "What Qt-specific questions should brainstorming ask when designing a UI component?" 60)

if assert_contains "$output" "主题\|theme\|信号\|signal\|槽\|slot\|布局\|layout\|样式\|style" "Mentions Qt concepts"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify component structure discussion
echo "Test 4: Component structure..."

output=$(run_claude "What component structure does brainstorming suggest for PySide6 cards?" 60)

if assert_contains "$output" "CardWidget\|_initUI\|_initLayout\|_connectSignals\|组件" "Mentions component structure"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify transition to writing-plans
echo "Test 5: Transition to writing-plans..."

output=$(run_claude "After the design is approved in brainstorming, what skill should be invoked next?" 60)

if assert_contains "$output" "writing-plans\|实现计划\|plan" "Mentions writing-plans"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
