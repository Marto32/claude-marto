#!/bin/bash
# ============================================================================
# PreCompact Hook - State Preservation Before Compaction
# ============================================================================
#
# This hook fires before context compaction occurs. It ensures workflow
# state is fully persisted to files before context is compressed.
#
# For AUTO compaction (triggered by context pressure), this is critical
# for preserving in-flight state that might only exist in context.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin
#   CLAUDE_PROJECT_DIR  - Path to user's project
#
# Input (JSON via stdin):
#   session_id        - Current session identifier
#   transcript_path   - Path to conversation transcript
#   reason            - Why compacting: manual, auto
#
# Output:
#   stdout            - Content to preserve in post-compact context
#   Exit 0            - Allow compaction to proceed
# ============================================================================

set -euo pipefail

# Determine script directory and load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Initialize workflows directory
init_workflows_dir

# Read hook input from stdin
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')
REASON=$(echo "$HOOK_INPUT" | jq -r '.reason // "manual"')

log_hook "PreCompact: reason=$REASON session=$SESSION_ID"

# ============================================================================
# Emergency State Extraction for Auto-Compaction
# ============================================================================

if [[ "$REASON" == "auto" ]]; then
    log_hook "AUTO-COMPACT triggered - performing emergency state extraction"

    # Try to extract recent state from transcript before it's compacted
    if [[ -f "$TRANSCRIPT_PATH" ]]; then
        # Look for recent AGENT_RESULT blocks we might have missed processing
        RECENT_RESULTS=$(grep -o '<!-- AGENT_RESULT.*-->' "$TRANSCRIPT_PATH" 2>/dev/null | tail -10 || echo "")

        if [[ -n "$RECENT_RESULTS" ]]; then
            # Save to emergency log for later processing
            EMERGENCY_LOG="$WORKFLOWS_DIR/emergency-extract-$(date +%Y%m%d-%H%M%S).log"
            echo "# Emergency extraction from auto-compact" > "$EMERGENCY_LOG"
            echo "# Session: $SESSION_ID" >> "$EMERGENCY_LOG"
            echo "# Timestamp: $(date -Iseconds)" >> "$EMERGENCY_LOG"
            echo "" >> "$EMERGENCY_LOG"
            echo "$RECENT_RESULTS" >> "$EMERGENCY_LOG"

            log_hook "Saved emergency extraction to: $EMERGENCY_LOG"
        fi

        # Look for any workflow state mentions in recent messages
        # that might indicate state we haven't captured
        RECENT_STATE=$(grep -E 'workflow.*complete|phase.*:.*|verdict.*:' "$TRANSCRIPT_PATH" 2>/dev/null | tail -5 || echo "")

        if [[ -n "$RECENT_STATE" ]]; then
            echo "$RECENT_STATE" >> "${EMERGENCY_LOG:-$WORKFLOWS_DIR/emergency-state.log}"
        fi
    fi
fi

# ============================================================================
# Update State Files with Compaction Marker
# ============================================================================

for STATE_FILE in "$WORKFLOWS_DIR"/*.local.md; do
    [[ -f "$STATE_FILE" ]] || continue

    WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")
    log_hook "Preserving state for workflow: $WORKFLOW_ID"

    # Add compaction event to state file
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    echo "" >> "$STATE_FILE"
    echo "## Compaction Event - $TIMESTAMP" >> "$STATE_FILE"
    echo "Reason: $REASON" >> "$STATE_FILE"
    echo "Session: $SESSION_ID" >> "$STATE_FILE"
    echo "State preserved successfully." >> "$STATE_FILE"
done

# ============================================================================
# Output Minimal Resume Context
# ============================================================================
# This output goes into the post-compact context. Keep it MINIMAL
# to avoid wasting the fresh context space.

RESUME_OUTPUT=""
WORKFLOW_COUNT=0

for STATE_FILE in "$WORKFLOWS_DIR"/*.local.md; do
    [[ -f "$STATE_FILE" ]] || continue

    ((WORKFLOW_COUNT++)) || true

    WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")
    WORKFLOW_TYPE=$(get_state_field "$STATE_FILE" "workflow_type")
    PHASE=$(get_state_field "$STATE_FILE" "phase")

    # Minimal pointer - NOT full state
    RESUME_OUTPUT+="WORKFLOW: /$WORKFLOW_TYPE ($WORKFLOW_ID)
  STATE: $STATE_FILE
  PHASE: $PHASE
"
done

if [[ $WORKFLOW_COUNT -gt 0 ]]; then
    echo "=== POST-COMPACTION: ACTIVE WORKFLOWS ==="
    echo ""
    echo "$RESUME_OUTPUT"
    echo ""
    echo "Read the state files above to restore context and continue."
    echo "The Stop hook will enforce workflow completion."
    echo ""
    echo "=== END POST-COMPACTION CONTEXT ==="
fi

log_hook "PreCompact complete: preserved $WORKFLOW_COUNT workflow(s)"
exit 0
