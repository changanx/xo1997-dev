#!/usr/bin/env bash
# Test skill triggering with natural language prompts
# Usage: ./run-test.sh <skill-name> [max-turns]
#
# Tests whether Claude triggers a skill based on a natural prompt
# (without explicitly mentioning the skill name)

set -e

SKILL_NAME="$1"
MAX_TURNS="${2:-3}"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: $0 <skill-name> [max-turns]"
    echo "Example: $0 brainstorming"
    echo "Example: $0 tdd 5"
    exit 1
fi

# Skill name aliases (prompt file name -> actual skill name)
declare -A SKILL_ALIASES=(
    ["debugging"]="systematic-debugging"
    ["tdd"]="test-driven-development"
    ["writing-plans"]="write-plan"
)

# Get the actual skill name to match
ACTUAL_SKILL_NAME="${SKILL_ALIASES[$SKILL_NAME]:-$SKILL_NAME}"

# Get paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROMPT_FILE="${SCRIPT_DIR}/prompts/${SKILL_NAME}.txt"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "ERROR: Prompt file not found: $PROMPT_FILE"
    echo ""
    echo "Available prompts:"
    ls -1 "${SCRIPT_DIR}/prompts/"*.txt 2>/dev/null | xargs -n1 basename | sed 's/\.txt$//' || echo "  (none)"
    exit 1
fi

# Read prompt
PROMPT=$(cat "$PROMPT_FILE")

# Setup output directory
TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/xo1997-dev-tests/${TIMESTAMP}/l1-triggering/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

echo "=== L1 Skill Triggering Test ==="
echo "Skill: $SKILL_NAME"
echo "Prompt file: $PROMPT_FILE"
echo "Max turns: $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

# Copy prompt for reference
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Run Claude with JSON output
LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$OUTPUT_DIR"

echo "Running claude -p with natural language prompt..."
timeout 300 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_ROOT" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --verbose \
    --output-format stream-json \
    > "$LOG_FILE" 2>&1 || true

echo ""
echo "=== Results ==="

# Check if skill was triggered (check both original name and alias)
SKILL_PATTERN='"skill":"([^"]*:)?'"${ACTUAL_SKILL_NAME}"'"'
ORIGINAL_PATTERN='"skill":"([^"]*:)?'"${SKILL_NAME}"'"'
if grep -q '"name":"Skill"' "$LOG_FILE" && (grep -qE "$SKILL_PATTERN" "$LOG_FILE" || grep -qE "$ORIGINAL_PATTERN" "$LOG_FILE"); then
    echo "PASS: Skill '$SKILL_NAME' was triggered (matched as '$ACTUAL_SKILL_NAME')"
    TRIGGERED=true
else
    echo "FAIL: Skill '$SKILL_NAME' was NOT triggered"
    TRIGGERED=false
fi

# Show what skills WERE triggered
echo ""
echo "Skills triggered in this run:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

# Check for premature action
echo ""
echo "Checking for premature action..."
FIRST_SKILL_LINE=$(grep -n '"name":"Skill"' "$LOG_FILE" | head -1 | cut -d: -f1)
if [ -n "$FIRST_SKILL_LINE" ]; then
    PREMATURE_TOOLS=$(head -n "$FIRST_SKILL_LINE" "$LOG_FILE" | \
        grep '"type":"tool_use"' | \
        grep -v '"name":"Skill"' | \
        grep -v '"name":"TodoWrite"' || true)
    if [ -n "$PREMATURE_TOOLS" ]; then
        echo "WARNING: Tools invoked BEFORE Skill tool:"
        echo "$PREMATURE_TOOLS" | head -5
        echo ""
        echo "This indicates Claude started working before loading the skill."
    else
        echo "OK: No premature tool invocations detected"
    fi
else
    echo "WARNING: No Skill invocation found at all"
fi

# Show first assistant message
echo ""
echo "First assistant response (truncated):"
grep '"type":"assistant"' "$LOG_FILE" | head -1 | jq -r '.message.content[0].text // .message.content' 2>/dev/null | head -c 500 || echo "  (could not extract)"

echo ""
echo "Full log: $LOG_FILE"
echo "Timestamp: $TIMESTAMP"

if [ "$TRIGGERED" = "true" ]; then
    exit 0
else
    exit 1
fi
