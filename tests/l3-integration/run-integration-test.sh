#!/usr/bin/env bash
# Run L3 integration tests for xo1997-dev
# Usage: ./run-integration-test.sh <test-name> [--timeout SECONDS]
#
# Tests full workflow execution: brainstorming -> writing-plans -> execution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default timeout for integration tests (30 minutes)
TIMEOUT=1800
VERBOSE=false

# Parse arguments
TEST_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --timeout|-t)
            TIMEOUT="$2"
            shift 2
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 <test-name> [options]"
            echo ""
            echo "Arguments:"
            echo "  test-name         Name of the test (e.g., springboot-user-crud)"
            echo ""
            echo "Options:"
            echo "  --timeout, -t SECONDS  Set timeout (default: 1800)"
            echo "  --verbose, -v          Show verbose output"
            echo "  --help, -h             Show this help"
            echo ""
            echo "Available tests:"
            for dir in "$SCRIPT_DIR"/*/; do
                if [ -d "$dir" ] && [ -f "$dir/design.md" ]; then
                    basename "$dir"
                fi
            done
            exit 0
            ;;
        *)
            if [ -z "$TEST_NAME" ]; then
                TEST_NAME="$1"
            else
                echo "Unknown option: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$TEST_NAME" ]; then
    echo "ERROR: Test name required"
    echo "Usage: $0 <test-name>"
    echo ""
    echo "Available tests:"
    for dir in "$SCRIPT_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/design.md" ]; then
            echo "  $(basename "$dir")"
        fi
    done
    exit 1
fi

TEST_DIR="$SCRIPT_DIR/$TEST_NAME"
if [ ! -d "$TEST_DIR" ]; then
    echo "ERROR: Test directory not found: $TEST_DIR"
    exit 1
fi

DESIGN_FILE="$TEST_DIR/design.md"
PLAN_FILE="$TEST_DIR/plan.md"

if [ ! -f "$DESIGN_FILE" ]; then
    echo "ERROR: Design file not found: $DESIGN_FILE"
    exit 1
fi

# Setup output directory
TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/xo1997-dev-tests/${TIMESTAMP}/l3-integration/${TEST_NAME}"
mkdir -p "$OUTPUT_DIR"

echo "========================================"
echo " xo1997-dev L3 Integration Test"
echo "========================================"
echo ""
echo "Test: $TEST_NAME"
echo "Design: $DESIGN_FILE"
echo "Plan: $PLAN_FILE"
echo "Output: $OUTPUT_DIR"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code CLI not found"
    echo "Install Claude Code first: https://claude.ai/code"
    exit 1
fi

# Copy test files for reference
cp "$DESIGN_FILE" "$OUTPUT_DIR/design.md"
if [ -f "$PLAN_FILE" ]; then
    cp "$PLAN_FILE" "$OUTPUT_DIR/plan.md"
fi

# Create a test project directory
PROJECT_DIR="$OUTPUT_DIR/project"
mkdir -p "$PROJECT_DIR/docs/specs"
mkdir -p "$PROJECT_DIR/docs/plans"

# Copy design to expected location
cp "$DESIGN_FILE" "$PROJECT_DIR/docs/specs/design.md"
if [ -f "$PLAN_FILE" ]; then
    cp "$PLAN_FILE" "$PROJECT_DIR/docs/plans/plan.md"
fi

cd "$PROJECT_DIR"

echo "Starting integration test..."
echo ""

# Run the full workflow test
LOG_FILE="$OUTPUT_DIR/claude-output.json"

# Test prompt that triggers the full workflow
PROMPT="I have a design document at docs/specs/design.md. Please:
1. Review the design document
2. If approved, create an implementation plan at docs/plans/plan.md
3. Execute the plan using subagent-driven-development

Follow the xo1997-dev workflow strictly."

echo "Prompt: $PROMPT"
echo ""

if [ "$VERBOSE" = true ]; then
    timeout "$TIMEOUT" claude -p "$PROMPT" \
        --plugin-dir "$PLUGIN_ROOT" \
        --dangerously-skip-permissions \
        --max-turns 50 \
        --output-format stream-json \
        | tee "$LOG_FILE" || true
else
    timeout "$TIMEOUT" claude -p "$PROMPT" \
        --plugin-dir "$PLUGIN_ROOT" \
        --dangerously-skip-permissions \
        --max-turns 50 \
        --output-format stream-json \
        > "$LOG_FILE" 2>&1 || true
fi

echo ""
echo "========================================"
echo " Integration Test Results"
echo "========================================"
echo ""

# Check what skills were triggered
echo "Skills triggered:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

echo ""

# Check for key workflow steps
echo "Workflow steps detected:"

# Check for brainstorming/skill invocation
if grep -q '"skill":"[^"]*brainstorming' "$LOG_FILE"; then
    echo "  [PASS] brainstorming skill triggered"
else
    echo "  [SKIP] brainstorming skill (design already provided)"
fi

# Check for writing-plans
if grep -q '"skill":"[^"]*writing-plans' "$LOG_FILE"; then
    echo "  [PASS] writing-plans skill triggered"
else
    echo "  [INFO] writing-plans may have been skipped (plan already provided)"
fi

# Check for subagent-driven-development
if grep -q '"skill":"[^"]*subagent-driven-development' "$LOG_FILE"; then
    echo "  [PASS] subagent-driven-development skill triggered"
else
    echo "  [FAIL] subagent-driven-development skill NOT triggered"
fi

# Check for TDD
if grep -q '"skill":"[^"]*test-driven-development' "$LOG_FILE"; then
    echo "  [PASS] TDD skill triggered during implementation"
else
    echo "  [WARN] TDD skill not detected (may be embedded in subagent)"
fi

echo ""

# Check for file creation
echo "Files created:"
if [ -d "$PROJECT_DIR/src" ]; then
    find "$PROJECT_DIR/src" -name "*.java" 2>/dev/null | head -10 || echo "  (none)"
else
    echo "  (no src directory)"
fi

echo ""

# Check for test execution
echo "Test execution:"
if grep -q "mvn test\|npm test\|PASS\|FAIL" "$LOG_FILE"; then
    echo "  [INFO] Test commands detected in output"
    grep -c "PASS" "$LOG_FILE" 2>/dev/null && echo "    PASS count: $(grep -c 'PASS' "$LOG_FILE")" || true
    grep -c "FAIL" "$LOG_FILE" 2>/dev/null && echo "    FAIL count: $(grep -c 'FAIL' "$LOG_FILE")" || true
else
    echo "  [WARN] No test execution detected"
fi

echo ""
echo "Full log: $LOG_FILE"
echo "Timestamp: $TIMESTAMP"
echo ""

# Determine overall status
if grep -q '"skill":"[^"]*subagent-driven-development' "$LOG_FILE"; then
    echo "STATUS: PASSED (workflow executed)"
    exit 0
else
    echo "STATUS: FAILED (workflow incomplete)"
    exit 1
fi
