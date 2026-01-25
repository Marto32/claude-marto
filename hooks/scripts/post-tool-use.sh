#!/bin/bash
# ============================================================================
# PostToolUse Hook - Context Monitoring and Auto-Compaction
# ============================================================================
#
# This hook fires after Task tool usage to monitor context consumption.
# When context pressure is severe, it dumps state to workflow files and
# triggers compaction to avoid losing work.
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
#   Exit 0 with JSON output  - Add system message or trigger compaction
# ============================================================================

set -euo pipefail

# Determine script directory and load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Read hook input from stdin
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""')
TOOL_OUTPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_output // ""')

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
# State Extraction Functions
# ============================================================================

# Extract current workflow state from transcript and save to file
dump_context_state() {
    local TIMESTAMP
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    local STATE_DUMP_FILE="$WORKFLOWS_DIR/context-dump-${SESSION_ID:0:8}-$(date +%Y%m%d-%H%M%S).md"

    log_hook "Dumping context state to: $STATE_DUMP_FILE"

    # Create state dump header
    cat > "$STATE_DUMP_FILE" << EOF
---
session_id: $SESSION_ID
dump_timestamp: $TIMESTAMP
transcript_size: $TRANSCRIPT_SIZE
reason: context_pressure
---

# Context State Dump

This file captures the conversation state before compaction.

## Session Info
- Session ID: $SESSION_ID
- Transcript Size: $TRANSCRIPT_SIZE bytes
- Dump Time: $TIMESTAMP

EOF

    # Extract recent AGENT_RESULT blocks (contains workflow progress)
    if [[ -f "$TRANSCRIPT_PATH" ]]; then
        echo "## Recent Agent Results" >> "$STATE_DUMP_FILE"
        echo "" >> "$STATE_DUMP_FILE"

        # Get last 20 AGENT_RESULT blocks
        grep -o '<!-- AGENT_RESULT[^>]*-->' "$TRANSCRIPT_PATH" 2>/dev/null | tail -20 >> "$STATE_DUMP_FILE" || true
        echo "" >> "$STATE_DUMP_FILE"

        # Extract task list state if present
        echo "## Task List State" >> "$STATE_DUMP_FILE"
        echo "" >> "$STATE_DUMP_FILE"

        # Look for TaskList/TaskUpdate patterns in recent messages
        grep -E '"tool_name":"(TaskList|TaskUpdate|TaskCreate)"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -10 | while read -r line; do
            echo "\`\`\`json" >> "$STATE_DUMP_FILE"
            echo "$line" | jq -r '.tool_input // .tool_output // .' 2>/dev/null >> "$STATE_DUMP_FILE" || echo "$line" >> "$STATE_DUMP_FILE"
            echo "\`\`\`" >> "$STATE_DUMP_FILE"
        done || true
        echo "" >> "$STATE_DUMP_FILE"

        # Extract recent workflow mentions
        echo "## Workflow Progress Indicators" >> "$STATE_DUMP_FILE"
        echo "" >> "$STATE_DUMP_FILE"

        grep -E 'phase.*:|status.*:|completed.*:|WORKFLOW:' "$TRANSCRIPT_PATH" 2>/dev/null | tail -15 >> "$STATE_DUMP_FILE" || true
        echo "" >> "$STATE_DUMP_FILE"

        # Capture last assistant message summary
        echo "## Last Assistant Context" >> "$STATE_DUMP_FILE"
        echo "" >> "$STATE_DUMP_FILE"

        local LAST_MSG
        LAST_MSG=$(get_last_assistant_message "$TRANSCRIPT_PATH")
        if [[ -n "$LAST_MSG" ]]; then
            # Truncate to first 2000 chars to avoid bloat
            echo "${LAST_MSG:0:2000}" >> "$STATE_DUMP_FILE"
            if [[ ${#LAST_MSG} -gt 2000 ]]; then
                echo "... (truncated)" >> "$STATE_DUMP_FILE"
            fi
        fi
    fi

    echo "" >> "$STATE_DUMP_FILE"
    echo "---" >> "$STATE_DUMP_FILE"
    echo "End of context dump. Read this file after compaction to restore state." >> "$STATE_DUMP_FILE"

    log_hook "Context state dumped successfully to: $STATE_DUMP_FILE"
    echo "$STATE_DUMP_FILE"
}

# Update any active workflow state files with pre-compaction marker
update_workflow_states() {
    local TIMESTAMP
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    for STATE_FILE in "$WORKFLOWS_DIR"/*.local.md; do
        [[ -f "$STATE_FILE" ]] || continue

        local WORKFLOW_ID
        WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")

        log_hook "Updating workflow state before compaction: $WORKFLOW_ID"

        # Append compaction notice
        echo "" >> "$STATE_FILE"
        echo "## Pre-Compaction Checkpoint - $TIMESTAMP" >> "$STATE_FILE"
        echo "Context size: $TRANSCRIPT_SIZE bytes" >> "$STATE_FILE"
        echo "Auto-compaction triggered by PostToolUse hook." >> "$STATE_FILE"
        echo "Resume from this point after compaction completes." >> "$STATE_FILE"
    done
}

# ============================================================================
# Context Pressure Response
# ============================================================================

if [[ $TRANSCRIPT_SIZE -gt $SEVERE_THRESHOLD ]]; then
    log_hook "SEVERE context pressure: $TRANSCRIPT_SIZE bytes - triggering state dump and compaction"

    # Step 1: Dump current context state to file
    STATE_DUMP=$(dump_context_state)

    # Step 2: Update any active workflow states
    update_workflow_states

    # Step 3: Count active workflows for the message
    WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.local.md" 2>/dev/null | wc -l | tr -d ' ')

    # Step 4: Output directive to compact (this becomes a system message the agent MUST follow)
    jq -n \
        --arg size "$TRANSCRIPT_SIZE" \
        --arg dump "$STATE_DUMP" \
        --arg wf_count "$WORKFLOW_COUNT" \
        '{
            "systemMessage": ("COMPACTION REQUIRED: Context at " + $size + " bytes exceeds safe threshold.\n\n" +
                "State has been preserved to: " + $dump + "\n" +
                "Active workflows: " + $wf_count + "\n\n" +
                "You MUST run /compact NOW. After compaction, read the state dump file to restore context.\n" +
                "DO NOT continue work until compaction is complete.")
        }'

elif [[ $TRANSCRIPT_SIZE -gt $CRITICAL_THRESHOLD ]]; then
    log_hook "CRITICAL context pressure: $TRANSCRIPT_SIZE bytes - dumping state"

    # Proactively dump state but don't force compaction yet
    STATE_DUMP=$(dump_context_state)
    update_workflow_states

    output_system_message "Context usage critical (${TRANSCRIPT_SIZE} bytes). State preserved to: ${STATE_DUMP}. Run /compact soon to avoid losing work."

elif [[ $TRANSCRIPT_SIZE -gt $WARNING_THRESHOLD ]]; then
    log_hook "WARNING context pressure: $TRANSCRIPT_SIZE bytes"

    # Just log and optionally warn
    output_system_message "Context usage approaching limits (${TRANSCRIPT_SIZE} bytes). Workflow state is tracked in .claude/workflows/"
fi

# ============================================================================
# Track Subagent Count for Additional Context Estimation
# ============================================================================

# Count how many Task invocations have occurred (rough estimate of subagent spawns)
TASK_COUNT=$(grep -c '"tool_name":"Task"' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ $TASK_COUNT -gt 10 ]]; then
    log_hook "High subagent count: $TASK_COUNT Tasks spawned"

    # If many subagents and approaching warning threshold, preemptively dump state
    if [[ $TRANSCRIPT_SIZE -gt $((WARNING_THRESHOLD / 2)) ]]; then
        log_hook "Many subagents ($TASK_COUNT) with moderate context - preemptive state dump"
        dump_context_state > /dev/null 2>&1 || true
    fi
fi

exit 0
