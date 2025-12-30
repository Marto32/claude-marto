#!/bin/bash
# ============================================================================
# PostToolUse Hook - Context Monitoring
# ============================================================================
#
# This hook fires after Task tool usage to monitor context consumption
# and warn when context is getting large. This helps orchestrators
# know when to consider manual compaction.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin
#   CLAUDE_PROJECT_DIR  - Path to user's project
#
# Input (JSON via stdin):
#   session_id        - Current session identifier
#   transcript_path   - Path to conversation transcript
#   tool_name         - Name of the tool that was used
#   tool_input        - Input that was provided to the tool
#   tool_output       - Output from the tool
#
# Output:
#   Exit 0 with no output    - Silent success
#   Exit 0 with JSON output  - Add system message warning
# ============================================================================

set -euo pipefail

# Determine script directory and load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Read hook input from stdin
HOOK_INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""')

# Only monitor for Task tool (subagent spawns consume significant context)
if [[ "$TOOL_NAME" != "Task" ]]; then
    exit 0
fi

# Initialize for logging
init_workflows_dir

# ============================================================================
# Context Size Estimation
# ============================================================================

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
    exit 0
fi

# Get transcript file size as proxy for context usage
TRANSCRIPT_SIZE=$(get_file_size "$TRANSCRIPT_PATH")

# Thresholds (in bytes) - adjust based on experience
# These are rough estimates; actual context limits vary by model
WARNING_THRESHOLD=400000    # ~400KB - approaching limits
CRITICAL_THRESHOLD=600000   # ~600KB - should compact soon
SEVERE_THRESHOLD=800000     # ~800KB - compact immediately

log_hook "PostToolUse: Task completed, transcript size=$TRANSCRIPT_SIZE bytes"

# ============================================================================
# Issue Warnings Based on Context Size
# ============================================================================

if [[ $TRANSCRIPT_SIZE -gt $SEVERE_THRESHOLD ]]; then
    log_hook "SEVERE context pressure: $TRANSCRIPT_SIZE bytes"

    output_system_message "CONTEXT CRITICAL: Transcript is ${TRANSCRIPT_SIZE} bytes. Run /compact NOW to avoid losing work. Workflow state is preserved in .claude/workflows/"

elif [[ $TRANSCRIPT_SIZE -gt $CRITICAL_THRESHOLD ]]; then
    log_hook "CRITICAL context pressure: $TRANSCRIPT_SIZE bytes"

    output_system_message "Context usage high (${TRANSCRIPT_SIZE} bytes). Consider running /compact soon. State is externalized to .claude/workflows/ for safety."

elif [[ $TRANSCRIPT_SIZE -gt $WARNING_THRESHOLD ]]; then
    log_hook "WARNING context pressure: $TRANSCRIPT_SIZE bytes"

    # Just log, don't warn user for moderate usage
    # output_system_message "Context usage moderate. Workflow state is being tracked in .claude/workflows/"
fi

# ============================================================================
# Track Subagent Count for Additional Context Estimation
# ============================================================================

# Count how many Task invocations have occurred (rough estimate of subagent spawns)
TASK_COUNT=$(grep -c '"tool_name":"Task"' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ $TASK_COUNT -gt 10 ]]; then
    log_hook "High subagent count: $TASK_COUNT Tasks spawned"

    # If many subagents and approaching warning threshold
    if [[ $TRANSCRIPT_SIZE -gt $((WARNING_THRESHOLD / 2)) ]]; then
        log_hook "Many subagents ($TASK_COUNT) with moderate context - monitoring"
    fi
fi

exit 0
