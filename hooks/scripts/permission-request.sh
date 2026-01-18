#!/bin/bash
# Permission request hook for claude-marto-toolkit
#
# Implements smart auto-accept logic:
# - Auto-accepts most tool permission requests
# - For AskUserQuestion: auto-accepts simple yes/no questions, pauses for complex ones
#
# Environment variables available:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin's directory
#   CLAUDE_PROJECT_DIR  - Path to the user's project directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# Simple label patterns (case-insensitive, may have "(Recommended)" suffix)
# These patterns indicate a simple binary choice that can be auto-accepted
SIMPLE_LABELS=(
    # Confirmations
    "yes" "no" "ok" "okay" "cancel"
    # Actions
    "allow" "deny" "proceed" "continue" "skip" "stop"
    # Approvals
    "approve" "reject" "accept" "decline" "confirm"
    # Common compound forms
    "yes, continue" "no, cancel" "yes, proceed" "no, stop"
)

# ============================================================================
# Helper Functions
# ============================================================================

# Output JSON to allow the permission request
output_permission_allow() {
    cat << 'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow"
    }
  }
}
JSON
}

# Output JSON to deny the permission request (will show prompt to user)
output_permission_deny() {
    local REASON="${1:-Complex question requires user interaction}"
    jq -n \
        --arg reason "$REASON" \
        '{
            "hookSpecificOutput": {
                "hookEventName": "PermissionRequest",
                "decision": {
                    "behavior": "deny",
                    "message": $reason
                }
            }
        }'
}

# Check if a label matches simple patterns (case-insensitive)
# Returns 0 (true) if simple, 1 (false) if complex
is_simple_label() {
    local LABEL="$1"

    # Lowercase and strip "(Recommended)" suffix for comparison
    local NORMALIZED
    NORMALIZED=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]' | sed 's/ *(recommended)$//')

    for PATTERN in "${SIMPLE_LABELS[@]}"; do
        if [[ "$NORMALIZED" == "$PATTERN" ]]; then
            return 0
        fi
    done

    return 1
}

# Check if an AskUserQuestion request is simple enough to auto-accept
# Returns 0 (true) if simple, 1 (false) if complex
is_simple_question() {
    local TOOL_INPUT="$1"

    # Parse questions array
    local QUESTION_COUNT
    QUESTION_COUNT=$(echo "$TOOL_INPUT" | jq '.questions | length' 2>/dev/null || echo "0")

    # Rule 1: Must be a single question
    if [[ "$QUESTION_COUNT" != "1" ]]; then
        log_hook "Complex: multiple questions ($QUESTION_COUNT)"
        return 1
    fi

    # Get the first (only) question
    local QUESTION
    QUESTION=$(echo "$TOOL_INPUT" | jq '.questions[0]' 2>/dev/null)

    # Rule 2: multiSelect must be false
    local MULTI_SELECT
    MULTI_SELECT=$(echo "$QUESTION" | jq -r '.multiSelect // false' 2>/dev/null)
    if [[ "$MULTI_SELECT" == "true" ]]; then
        log_hook "Complex: multiSelect enabled"
        return 1
    fi

    # Rule 3: Must have exactly 2 options
    local OPTION_COUNT
    OPTION_COUNT=$(echo "$QUESTION" | jq '.options | length' 2>/dev/null || echo "0")
    if [[ "$OPTION_COUNT" != "2" ]]; then
        log_hook "Complex: not 2 options ($OPTION_COUNT)"
        return 1
    fi

    # Rule 4: Both labels must match simple patterns
    local LABEL1 LABEL2
    LABEL1=$(echo "$QUESTION" | jq -r '.options[0].label // ""' 2>/dev/null)
    LABEL2=$(echo "$QUESTION" | jq -r '.options[1].label // ""' 2>/dev/null)

    if ! is_simple_label "$LABEL1"; then
        log_hook "Complex: label1 not simple: $LABEL1"
        return 1
    fi

    if ! is_simple_label "$LABEL2"; then
        log_hook "Complex: label2 not simple: $LABEL2"
        return 1
    fi

    # All rules passed - this is a simple question
    log_hook "Simple question detected: [$LABEL1] / [$LABEL2]"
    return 0
}

# ============================================================================
# Main Logic
# ============================================================================

main() {
    # Read the permission request JSON from stdin
    local REQUEST
    REQUEST=$(cat)

    # Extract tool name
    local TOOL_NAME
    TOOL_NAME=$(echo "$REQUEST" | jq -r '.tool_name // ""' 2>/dev/null)

    log_hook "PermissionRequest: tool=$TOOL_NAME"

    # Handle non-AskUserQuestion tools - auto-accept all
    if [[ "$TOOL_NAME" != "AskUserQuestion" ]]; then
        log_hook "Auto-accepting non-AskUserQuestion tool: $TOOL_NAME"
        output_permission_allow
        exit 0
    fi

    # Handle AskUserQuestion - check if simple or complex
    local TOOL_INPUT
    TOOL_INPUT=$(echo "$REQUEST" | jq '.tool_input // {}' 2>/dev/null)

    if is_simple_question "$TOOL_INPUT"; then
        log_hook "Auto-accepting simple AskUserQuestion"
        output_permission_allow
        exit 0
    else
        log_hook "Pausing for complex AskUserQuestion"
        output_permission_deny "This question requires your input"
        exit 0
    fi
}

# Run main
main
