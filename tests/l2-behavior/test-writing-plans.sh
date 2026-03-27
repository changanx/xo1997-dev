#!/usr/bin/env bash
# Test: writing-plans skill behavior
# Verifies worktree creation timing and task granularity requirements
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: writing-plans behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify worktree creation timing
echo "Test 1: Worktree creation timing..."

output=$(run_claude "In writing-plans, when is the worktree created? At what step does this happen?" 60)

if assert_contains "$output" "Step 2\|creating.*workspace\|worktree\|隔离\|isolat" "Mentions worktree creation"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify database design confirmation step
echo "Test 2: Database design confirmation..."

output=$(run_claude "What happens in Step 3 of writing-plans? What is confirmed or created?" 60)

if assert_contains "$output" "database\|数据库\|confirm\|确认" "Mentions database confirmation"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify task granularity
echo "Test 3: Task granularity requirement..."

output=$(run_claude "In writing-plans, what is the recommended time duration for each task step? How long should each step take?" 60)

if assert_contains "$output" "2.*5\|2-5\|分钟\|minute" "Mentions 2-5 minute granularity"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify file structure planning
echo "Test 4: File structure planning..."

output=$(run_claude "What is Step 4 of writing-plans? What is planned in this step?" 60)

if assert_contains "$output" "file\|文件\|structure\|结构\|规划" "Mentions file structure planning"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify plan document reviewer
echo "Test 5: Plan document reviewer..."

output=$(run_claude "Does writing-plans use a reviewer to check the plan? What is checked?" 60)

if assert_contains "$output" "review\|reviewer\|审查\|检查" "Mentions review process"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify execution mode selection
echo "Test 6: Execution mode selection..."

output=$(run_claude "In the final step of writing-plans (Step 9), how is the execution mode chosen? What are the options?" 60)

if assert_contains "$output" "subagent\|team-driven\|executing-plans\|子代理\|团队" "Mentions execution modes"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 7: Verify TDD in tasks
echo "Test 7: TDD requirement in tasks..."

output=$(run_claude "Do the tasks in writing-plans follow TDD? What are the standard steps for each task?" 60)

if assert_contains "$output" "test\|测试\|failing\|失败\|TDD" "Mentions TDD in tasks"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
