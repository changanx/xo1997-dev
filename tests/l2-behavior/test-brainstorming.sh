#!/usr/bin/env bash
# Test: brainstorming skill behavior
# Verifies database design requirement and document verification gate
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: brainstorming behavior ==="
echo ""

passed=0
failed=0

# Test 1: Verify database design requirement
echo "Test 1: Database design requirement..."

output=$(run_claude "In the brainstorming skill, is database design required for Spring Boot projects? What must be included?" 60)

if assert_contains "$output" "database\|table\|schema\|entity\|必须\|required" "Mentions database design"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 2: Verify audit fields requirement
echo "Test 2: Audit fields requirement..."

output=$(run_claude "What audit fields must be included in database tables according to the brainstorming skill?" 60)

if assert_contains "$output" "id\|create_time\|update_time\|is_del\|审计" "Mentions audit fields"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 3: Verify document output location
echo "Test 3: Document output location..."

output=$(run_claude "Where does brainstorming save the design document? What is the file path pattern?" 60)

if assert_contains "$output" "docs/specs\|design\.md\|requirements\.md" "Mentions correct output path"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 4: Verify VERIFICATION-GATE mechanism
echo "Test 4: Document verification gate..."

output=$(run_claude "In brainstorming, after claiming to create a document, what must be done to verify it exists?" 60)

if assert_contains "$output" "verify\|check\|read\|confirm\|exists\|验证" "Mentions verification"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 5: Verify spec document reviewer
echo "Test 5: Spec document reviewer..."

output=$(run_claude "Does brainstorming use a subagent to review the design document? What does the spec-document-reviewer check?" 60)

if assert_contains "$output" "review\|subagent\|审查\|reviewer" "Mentions review process"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

# Test 6: Verify output files
echo "Test 6: Output files..."

output=$(run_claude "What are the main output files produced by brainstorming? What does each contain?" 60)

if assert_contains "$output" "design\.md\|requirements\.md" "Mentions output files"; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

echo ""

print_test_summary $passed $failed
