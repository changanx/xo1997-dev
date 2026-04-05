#!/usr/bin/env bash
# Test: component-development skill behavior
# Verifies CardWidget patterns and signal/slot connections
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: component-development behavior ==="
echo ""

passed=0
failed=0

# Test 1: CardWidget types
echo "Test 1: CardWidget types..."

output=$(run_claude "What are the different CardWidget types and when to use each?" 60)

if assert_contains "$output" "CardWidget\|SimpleCardWidget\|ElevatedCardWidget\|交互\|静态" "Mentions card types"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Component structure pattern
echo "Test 2: Component structure pattern..."

output=$(run_claude "What methods should a CardWidget subclass implement?" 60)

if assert_contains "$output" "_initUI\|_initLayout\|_connectSignals\|__init__" "Mentions component methods"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Signal-based communication
echo "Test 3: Signal-based communication..."

output=$(run_claude "How should PySide6 components communicate with each other?" 60)

if assert_contains "$output" "Signal\|signal\|信号\|emit\|connect" "Mentions signal communication"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: objectName for QSS
echo "Test 4: objectName requirement..."

output=$(run_claude "Why should PySide6 widgets set objectName?" 60)

if assert_contains "$output" "QSS\|样式\|style\|selector\|选择器" "Mentions QSS selector"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
