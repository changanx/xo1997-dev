#!/usr/bin/env bash
# Helper functions for pyside6-dev skill tests
# Adapted from xo1997-dev test framework for PySide6 desktop client workflow

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

# Get plugin root directory (two levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default timeout for Claude Code responses (seconds)
DEFAULT_TIMEOUT=${CLAUDE_TEST_TIMEOUT:-60}

# ==============================================================================
# Core Functions
# ==============================================================================

# Run Claude Code with a prompt and capture output
# Usage: run_claude "prompt text" [timeout_seconds] [extra_args...]
# Returns: Claude output to stdout
run_claude() {
    local prompt="$1"
    local timeout="${2:-$DEFAULT_TIMEOUT}"
    shift 2
    local extra_args=("$@")

    local output_file=$(mktemp)

    # Build command - use plugin directory
    local cmd="claude -p \"$prompt\" --plugin-dir \"$PLUGIN_ROOT\""
    if [ ${#extra_args[@]} -gt 0 ]; then
        cmd="$cmd ${extra_args[*]}"
    fi

    # Run Claude in headless mode with timeout
    if timeout "$timeout" bash -c "$cmd" > "$output_file" 2>&1; then
        cat "$output_file"
        rm -f "$output_file"
        return 0
    else
        local exit_code=$?
        cat "$output_file" >&2
        rm -f "$output_file"
        return $exit_code
    fi
}

# Run Claude with JSON output for detailed analysis
# Usage: run_claude_json "prompt text" [timeout_seconds]
# Returns: JSON output to stdout (stream-json format)
run_claude_json() {
    local prompt="$1"
    local timeout="${2:-$DEFAULT_TIMEOUT}"
    local output_file=$(mktemp)

    timeout "$timeout" claude -p "$prompt" \
        --plugin-dir "$PLUGIN_ROOT" \
        --verbose \
        --output-format stream-json \
        > "$output_file" 2>&1 || true

    cat "$output_file"
    rm -f "$output_file"
}

# ==============================================================================
# Assertion Functions
# ==============================================================================

# Check if output contains a pattern (case-insensitive by default)
# Usage: assert_contains "output" "pattern" "test name"
assert_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -qi "$pattern"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected to find: $pattern"
        echo "  In output:"
        echo "$output" | sed 's/^/    /'
        return 1
    fi
}

# Check if output does NOT contain a pattern
# Usage: assert_not_contains "output" "pattern" "test name"
assert_not_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -qi "$pattern"; then
        echo "  [FAIL] $test_name"
        echo "  Did not expect to find: $pattern"
        echo "  In output:"
        echo "$output" | sed 's/^/    /'
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Check if output matches a specific count
# Usage: assert_count "output" "pattern" expected_count "test name"
assert_count() {
    local output="$1"
    local pattern="$2"
    local expected="$3"
    local test_name="${4:-test}"

    local actual=$(echo "$output" | grep -oi "$pattern" | wc -l | tr -d ' ')

    if [ "$actual" -eq "$expected" ]; then
        echo "  [PASS] $test_name (found $actual instances)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected $expected instances of: $pattern"
        echo "  Found $actual instances"
        echo "  In output:"
        echo "$output" | sed 's/^/    /'
        return 1
    fi
}

# Check if pattern A appears before pattern B
# Usage: assert_order "output" "pattern_a" "pattern_b" "test name"
assert_order() {
    local output="$1"
    local pattern_a="$2"
    local pattern_b="$3"
    local test_name="${4:-test}"

    # Get line numbers where patterns appear (case-insensitive)
    local line_a=$(echo "$output" | grep -in "$pattern_a" | head -1 | cut -d: -f1)
    local line_b=$(echo "$output" | grep -in "$pattern_b" | head -1 | cut -d: -f1)

    if [ -z "$line_a" ]; then
        echo "  [FAIL] $test_name: pattern A not found: $pattern_a"
        return 1
    fi

    if [ -z "$line_b" ]; then
        echo "  [FAIL] $test_name: pattern B not found: $pattern_b"
        return 1
    fi

    if [ "$line_a" -lt "$line_b" ]; then
        echo "  [PASS] $test_name (A at line $line_a, B at line $line_b)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected '$pattern_a' before '$pattern_b'"
        echo "  But found A at line $line_a, B at line $line_b"
        return 1
    fi
}

# ==============================================================================
# Skill Trigger Detection (for JSON output)
# ==============================================================================

# Check if a skill was triggered in JSON output
# Usage: assert_skill_triggered "json_output" "skill_name"
assert_skill_triggered() {
    local json_output="$1"
    local skill_name="$2"
    local test_name="${3:-Skill $skill_name triggered}"

    # Match "skill":"skillname" or "skill":"pyside6-dev:skillname"
    local pattern='"skill":"([^"]*:)?'"${skill_name}"'"'

    if echo "$json_output" | grep -qE "$pattern"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected skill '$skill_name' to be triggered"
        echo "  Skills found in output:"
        echo "$json_output" | grep -o '"skill":"[^"]*"' | sort -u | sed 's/^/    /'
        return 1
    fi
}

# Check if skill was NOT triggered (for negative tests)
# Usage: assert_skill_not_triggered "json_output" "skill_name"
assert_skill_not_triggered() {
    local json_output="$1"
    local skill_name="$2"
    local test_name="${3:-Skill $skill_name NOT triggered}"

    local pattern='"skill":"([^"]*:)?'"${skill_name}"'"'

    if echo "$json_output" | grep -qE "$pattern"; then
        echo "  [FAIL] $test_name"
        echo "  Did not expect skill '$skill_name' to be triggered"
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Check for premature action (tools invoked before Skill tool)
# Usage: assert_no_premature_action "json_output"
assert_no_premature_action() {
    local json_output="$1"
    local test_name="${2:-No premature action}"

    # Find first Skill invocation
    local first_skill_line=$(echo "$json_output" | grep -n '"name":"Skill"' | head -1 | cut -d: -f1)

    if [ -z "$first_skill_line" ]; then
        echo "  [SKIP] $test_name (no Skill invocation found)"
        return 0
    fi

    # Check for tool invocations before Skill (excluding TodoWrite)
    local premature_tools=$(echo "$json_output" | head -n "$first_skill_line" | \
        grep '"type":"tool_use"' | \
        grep -v '"name":"Skill"' | \
        grep -v '"name":"TodoWrite"' || true)

    if [ -n "$premature_tools" ]; then
        echo "  [FAIL] $test_name"
        echo "  Tools invoked BEFORE Skill tool:"
        echo "$premature_tools" | head -5 | sed 's/^/    /'
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# ==============================================================================
# Test Environment Functions
# ==============================================================================

# Create a temporary test project directory
# Usage: test_project=$(create_test_project)
create_test_project() {
    local test_dir=$(mktemp -d)
    echo "$test_dir"
}

# Cleanup test project
# Usage: cleanup_test_project "$test_dir"
cleanup_test_project() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# ==============================================================================
# Output Functions
# ==============================================================================

# Print test header
# Usage: print_test_header "Test name"
print_test_header() {
    local test_name="$1"
    echo ""
    echo "=== $test_name ==="
    echo ""
}

# Print test section
# Usage: print_test_section "Section description"
print_test_section() {
    local section="$1"
    echo ""
    echo "--- $section ---"
}

# Print test summary
# Usage: print_test_summary passed failed
print_test_summary() {
    local passed="$1"
    local failed="$2"

    echo ""
    echo "========================================"
    echo " Test Summary"
    echo "========================================"
    echo "  Passed: $passed"
    echo "  Failed: $failed"
    echo ""

    if [ "$failed" -gt 0 ]; then
        echo "STATUS: FAILED"
        return 1
    else
        echo "STATUS: PASSED"
        return 0
    fi
}

# ==============================================================================
# Export Functions
# ==============================================================================

export -f run_claude
export -f run_claude_json
export -f assert_contains
export -f assert_not_contains
export -f assert_count
export -f assert_order
export -f assert_skill_triggered
export -f assert_skill_not_triggered
export -f assert_no_premature_action
export -f create_test_project
export -f cleanup_test_project
export -f print_test_header
export -f print_test_section
export -f print_test_summary
