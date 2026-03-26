#!/usr/bin/env bash
# Test: team-driven-development skill behavior
# Verifies that the skill handles frontend-backend coordination correctly
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: team-driven-development behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify team coordinator role
echo "Test 1: Team coordinator role..."

output=$(run_claude "In team-driven-development, what is the role of team-coordinator? What are its responsibilities?" 30)

if assert_contains "$output" "coordinator\|coordinate\|orchestrat" "Mentions coordinator role"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify frontend and backend developer roles
echo "Test 2: Developer roles..."

output=$(run_claude "What agents are involved in team-driven-development? What does the frontend-developer and backend-developer do?" 30)

if assert_contains "$output" "frontend.*developer\|frontend-developer" "Mentions frontend-developer"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if assert_contains "$output" "backend.*developer\|backend-developer" "Mentions backend-developer"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify API change log mechanism
echo "Test 3: API change log mechanism..."

output=$(run_claude "How does team-driven-development handle API changes between frontend and backend? Is there a shared communication mechanism?" 30)

if assert_contains "$output" "api.*change\|api-change\|communication\|shared\|sync" "Mentions API change mechanism"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify blocker handling
echo "Test 4: Blocker handling..."

output=$(run_claude "In team-driven-development, what happens when one developer gets blocked by another? How are blockers handled?" 30)

if assert_contains "$output" "blocker\|block\|wait\|escalat\|coordinator" "Mentions blocker handling"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify parallel execution
echo "Test 5: Parallel execution..."

output=$(run_claude "Does team-driven-development run frontend and backend tasks sequentially or in parallel? How does it work?" 30)

if assert_contains "$output" "parallel\|concurrent\|same time\|independently" "Mentions parallel execution"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify session files
echo "Test 6: Session files..."

output=$(run_claude "What files does team-driven-development use to track progress and coordinate between agents? Where are they stored?" 30)

if assert_contains "$output" "team-session\|\.claude\|session" "Mentions session files"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
