#!/usr/bin/env bash
# Run all L1 skill triggering tests
# Usage: ./run-all.sh [--verbose] [--timeout SECONDS]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "========================================"
echo " xo1997-dev L1 Skill Triggering Tests"
echo "========================================"
echo ""
echo "Repository: $PLUGIN_ROOT"
echo "Test time: $(date)"
echo "Claude version: $(claude --version 2>/dev/null || echo 'not found')"
echo ""

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code CLI not found"
    echo "Install Claude Code first: https://claude.ai/code"
    exit 1
fi

# Parse arguments
VERBOSE=false
TIMEOUT=300
MAX_TURNS=5

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --timeout|-t)
            TIMEOUT="$2"
            shift 2
            ;;
        --max-turns|-m)
            MAX_TURNS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v        Show verbose output"
            echo "  --timeout SECONDS    Set timeout per test (default: 300)"
            echo "  --max-turns TURNS    Set max turns per test (default: 5)"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get list of skill tests from prompt files
PROMPTS_DIR="${SCRIPT_DIR}/prompts"
if [ ! -d "$PROMPTS_DIR" ]; then
    echo "ERROR: Prompts directory not found: $PROMPTS_DIR"
    exit 1
fi

# Read skill names from prompt files
SKILLS=()
for prompt_file in "$PROMPTS_DIR"/*.txt; do
    if [ -f "$prompt_file" ]; then
        skill_name=$(basename "$prompt_file" .txt)
        SKILLS+=("$skill_name")
    fi
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo "ERROR: No prompt files found in $PROMPTS_DIR"
    exit 1
fi

echo "Skills to test: ${#SKILLS[@]}"
echo "  ${SKILLS[*]}"
echo ""

# Track results
passed=0
failed=0
skipped=0

# Run each test
for skill in "${SKILLS[@]}"; do
    echo "----------------------------------------"
    echo "Testing: $skill"
    echo "----------------------------------------"

    start_time=$(date +%s)

    if [ "$VERBOSE" = true ]; then
        if timeout "$TIMEOUT" "${SCRIPT_DIR}/run-test.sh" "$skill" "$MAX_TURNS"; then
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo ""
            echo "  [PASS] $skill (${duration}s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo ""
            if [ $exit_code -eq 124 ]; then
                echo "  [FAIL] $skill (timeout after ${TIMEOUT}s)"
            else
                echo "  [FAIL] $skill (${duration}s)"
            fi
            failed=$((failed + 1))
        fi
    else
        # Capture output for non-verbose mode
        if output=$(timeout "$TIMEOUT" "${SCRIPT_DIR}/run-test.sh" "$skill" "$MAX_TURNS" 2>&1); then
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo "  [PASS] (${duration}s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            if [ $exit_code -eq 124 ]; then
                echo "  [FAIL] (timeout after ${TIMEOUT}s)"
            else
                echo "  [FAIL] (${duration}s)"
            fi
            echo ""
            echo "  Output:"
            echo "$output" | sed 's/^/    /'
            failed=$((failed + 1))
        fi
    fi

    echo ""
done

# Print summary
echo "========================================"
echo " L1 Test Results Summary"
echo "========================================"
echo ""
echo "  Passed:  $passed"
echo "  Failed:  $failed"
echo ""

if [ $failed -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
else
    echo "STATUS: PASSED"
    exit 0
fi
