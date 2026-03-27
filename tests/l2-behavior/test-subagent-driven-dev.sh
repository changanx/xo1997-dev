#!/usr/bin/env bash
# Test: subagent-driven-development skill behavior
# Verifies that the skill enforces correct workflow order and requirements
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: subagent-driven-development behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify skill describes correct workflow order (spec compliance before code quality)
echo "Test 1: Workflow ordering (spec compliance before code quality)..."

output=$(run_claude "In the subagent-driven-development skill, what comes first: spec compliance review or code quality review? Be specific about the order." 60)

if assert_order "$output" "spec.*compliance\|specification" "code.*quality" "Spec compliance before code quality"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify self-review requirement
echo "Test 2: Self-review requirement..."

output=$(run_claude "Does the subagent-driven-development skill require implementers to do self-review before reporting completion? What should they check?" 60)

if assert_contains "$output" "self-review\|self review\|self.*check" "Mentions self-review"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify plan is read once, not per task
echo "Test 3: Plan reading efficiency..."

output=$(run_claude "In subagent-driven-development, how many times should the controller read the plan file? When does this happen?" 60)

if assert_contains "$output" "once\|one time\|single\|beginning" "Read plan once at beginning"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify spec compliance reviewer skepticism
echo "Test 4: Spec compliance reviewer mindset..."

output=$(run_claude "What is the spec compliance reviewer's attitude toward the implementer's report in subagent-driven-development? Should they trust the report?" 60)

if assert_contains "$output" "not trust\|don't trust\|skeptical\|verify.*independently\|suspiciously\|distrust" "Reviewer is skeptical"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if assert_contains "$output" "read.*code\|inspect.*code\|verify.*code\|check.*code" "Reviewer reads code"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify review loops
echo "Test 5: Review loop mechanism..."

output=$(run_claude "In subagent-driven-development, what happens if a reviewer finds issues? Is it a one-time review or a loop?" 60)

if assert_contains "$output" "loop\|again\|repeat\|until.*approved\|until.*pass\|re-review\|iterate" "Review loops mentioned"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify worktree requirement
echo "Test 6: Worktree requirement..."

output=$(run_claude "What are the prerequisites before using subagent-driven-development? Is worktree required?" 60)

if assert_contains "$output" "worktree\|using-git-worktrees" "Mentions worktree requirement"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 7: Verify task context provision
echo "Test 7: Task context provision..."

output=$(run_claude "In subagent-driven-development, how does the controller provide task information to implementer subagents? Does it make them read a file or provide text directly?" 60)

if assert_contains "$output" "provide.*directly\|full.*text\|in the prompt\|include.*task" "Provides text directly"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
