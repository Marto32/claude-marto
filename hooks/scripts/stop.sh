#!/bin/bash
# ============================================================================
# Stop Hook - Enforce Workflow Completion
# ============================================================================
#
# This hook fires when the main agent or orchestrator tries to stop.
# It checks for active workflows and blocks the stop if completion
# criteria are not met, feeding back a continuation prompt.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin
#   CLAUDE_PROJECT_DIR  - Path to user's project
#
# Input (JSON via stdin):
#   session_id        - Current session identifier
#   transcript_path   - Path to conversation transcript
#   stop_hook_active  - Whether stop hook is already active
#
# Output:
#   Exit 0 with no output    - Allow stop
#   Exit 0 with JSON output  - Control behavior (block/allow with context)
#   Exit 2                   - Error (blocks with stderr message)
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

log_hook "Stop hook triggered: session=$SESSION_ID"

# ============================================================================
# Find Active Workflow for This Session
# ============================================================================

WORKFLOW_ID=$(find_workflow_for_session "$SESSION_ID")

if [[ -z "$WORKFLOW_ID" ]]; then
    log_hook "No active workflow for session $SESSION_ID - allowing stop"
    output_allow
fi

# Get state file
STATE_FILE=$(get_state_file "$WORKFLOW_ID")

if [[ ! -f "$STATE_FILE" ]]; then
    log_hook "State file not found for $WORKFLOW_ID - allowing stop"
    # Clean up orphaned registry entry
    unregister_workflow "$WORKFLOW_ID"
    output_allow
fi

# ============================================================================
# Dispatch to Workflow-Specific Logic
# ============================================================================

WORKFLOW_TYPE=$(get_state_field "$STATE_FILE" "workflow_type")
log_hook "Processing $WORKFLOW_TYPE workflow: $WORKFLOW_ID"

case "$WORKFLOW_TYPE" in
    cook)
        source "$SCRIPT_DIR/lib/cook-logic.sh"
        check_cook_completion "$STATE_FILE" "$HOOK_INPUT"
        ;;

    spec)
        source "$SCRIPT_DIR/lib/spec-logic.sh"
        check_spec_completion "$STATE_FILE" "$HOOK_INPUT"
        ;;

    *)
        log_hook "Unknown workflow type: $WORKFLOW_TYPE - allowing stop"
        output_allow
        ;;
esac

# If we reach here, something went wrong in the workflow logic
# Default to allowing stop to prevent infinite loops
log_hook "Workflow logic did not produce output - allowing stop as safety measure"
output_allow
