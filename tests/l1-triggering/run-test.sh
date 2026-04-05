#!/usr/bin/env bash
# Run single L1 triggering test
# Usage: ./run-test.sh <skill-name> [max-turns]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <skill-name> [max-turns]"
    echo ""
    echo "Available skills:"
    ls -1 "$SCRIPT_DIR/prompts/" | sed 's/.txt$//' | sed 's/^/  /'
    exit 1
fi

SKILL_NAME="$1"
MAX_TURNS="${2:-3}"
PROMPT_FILE="$SCRIPT_DIR/prompts/${SKILL_NAME}.txt"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Prompt file not found: $PROMPT_FILE"
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

echo "=== L1 Triggering Test: $SKILL_NAME ==="
echo "Prompt: $PROMPT"
echo ""

# Run with JSON output for analysis
OUTPUT=$(run_claude_json "$PROMPT" 120)

# Check for skill trigger
if echo "$OUTPUT" | grep -qE '"skill":"([^"]*:)?'"${SKILL_NAME}"'"'; then
    echo "[PASS] Skill '$SKILL_NAME' was triggered"
else
    echo "[FAIL] Skill '$SKILL_NAME' was NOT triggered"
    echo ""
    echo "Skills found in output:"
    echo "$OUTPUT" | grep -o '"skill":"[^"]*"' | sort -u | sed 's/^/  /'
    exit 1
fi

# Check for no premature action
if assert_no_premature_action "$OUTPUT"; then
    echo ""
    echo "=== Test PASSED ==="
else
    echo ""
    echo "=== Test FAILED ==="
    exit 1
fi
