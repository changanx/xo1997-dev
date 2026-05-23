#!/usr/bin/env bash
# Test: subagent-driven-development skill behavior
# Verifies subagent dispatching and coordination
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: subagent-driven-development behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify subagent dispatching
echo "Test 1: Subagent dispatching..."

output=$(run_claude "How does subagent-driven-development dispatch work? What agent type is used?" 60)

if assert_contains "$output" "general-purpose\|Agent\|subagent\|子代理\|dispatch" "Mentions subagent dispatching"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify task tracking
echo "Test 2: Task tracking..."

output=$(run_claude "How does subagent-driven-development track task progress? What tools are used?" 60)

if assert_contains "$output" "TaskUpdate\|TaskCreate\|TaskList\|task\|任务\|跟踪" "Mentions task tracking"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify review checkpoint
echo "Test 3: Review checkpoint..."

output=$(run_claude "Does subagent-driven-development have review checkpoints? When do they happen?" 60)

if assert_contains "$output" "review\|审查\|checkpoint\|检查点\|每.*步" "Mentions review checkpoints"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify finishing skill integration
echo "Test 4: Finishing skill integration..."

output=$(run_claude "What happens after all tasks are complete in subagent-driven-development? Which skill is called?" 60)

if assert_contains "$output" "finishing\|完成\|branch\|分支" "Mentions finishing-a-development-branch"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify error handling
echo "Test 5: Error handling..."

output=$(run_claude "What happens when a subagent fails in subagent-driven-development? How is the error handled?" 60)

if assert_contains "$output" "fail\|error\|失败\|错误\|retry\|重试\|block\|阻塞" "Mentions error handling"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify plan reading
echo "Test 6: Plan reading..."

output=$(run_claude "How does subagent-driven-development read the implementation plan? What does it extract?" 60)

if assert_contains "$output" "plan\|计划\|extract\|提取\|step\|步骤\|task\|任务" "Mentions plan reading"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed