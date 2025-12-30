#!/bin/bash
# ============================================================================
# SessionStart Hook - Context Injection on Resume
# ============================================================================
#
# This hook fires when a session starts or resumes. It checks for active
# workflows and injects context to help Claude continue where it left off.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin
#   CLAUDE_PROJECT_DIR  - Path to user's project
#
# Input (JSON via stdin):
#   session_id        - New session identifier
#   reason            - Why session started: startup, resume, clear, compact
#
# Output:
#   Exit 0 with no output    - No context to inject
#   Exit 0 with JSON output  - Inject additional context
# ============================================================================

set -euo pipefail

# Determine script directory and load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Initialize workflows directory (creates if needed)
init_workflows_dir

# Read hook input from stdin
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
REASON=$(echo "$HOOK_INPUT" | jq -r '.reason // "startup"')

log_hook "SessionStart: reason=$REASON session=$SESSION_ID"

# ============================================================================
# Build Context for Active Workflows
# ============================================================================

CONTEXT=""
WORKFLOW_COUNT=0

for STATE_FILE in "$WORKFLOWS_DIR"/*.local.md; do
    [[ -f "$STATE_FILE" ]] || continue

    WORKFLOW_TYPE=$(get_state_field "$STATE_FILE" "workflow_type")
    WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")

    ((WORKFLOW_COUNT++)) || true

    case "$WORKFLOW_TYPE" in
        cook)
            PHASE=$(get_state_field "$STATE_FILE" "phase")
            TASKS_VERIFIED=$(get_state_field "$STATE_FILE" "tasks_verified")
            TASKS_TOTAL=$(get_state_field "$STATE_FILE" "tasks_total")
            IMPL_PLAN=$(get_state_field "$STATE_FILE" "implementation_plan")

            CONTEXT+="ACTIVE WORKFLOW: /cook
  Workflow ID: $WORKFLOW_ID
  Phase: $PHASE
  Progress: $TASKS_VERIFIED/$TASKS_TOTAL tasks verified
  Implementation Plan: $IMPL_PLAN
  State File: $STATE_FILE

  TO RESUME: Read the state file above to continue the workflow.
  The Stop hook will enforce completion - just continue working.

"
            ;;

        spec)
            VERDICT=$(get_state_field "$STATE_FILE" "current_verdict")
            ARCHITECT=$(get_state_field "$STATE_FILE" "architect_type")
            DESIGN_DOC=$(get_state_field "$STATE_FILE" "design_document")
            ITERATION=$(get_state_field "$STATE_FILE" "iteration")

            CONTEXT+="ACTIVE WORKFLOW: /spec
  Workflow ID: $WORKFLOW_ID
  Architect Type: $ARCHITECT
  Current Verdict: $VERDICT
  Design Document: $DESIGN_DOC
  Iteration: $ITERATION
  State File: $STATE_FILE

  TO RESUME: Read the state file above to continue the revision loop.
  The Stop hook will enforce completion until design is APPROVED.

"
            ;;

        *)
            CONTEXT+="ACTIVE WORKFLOW: $WORKFLOW_TYPE
  Workflow ID: $WORKFLOW_ID
  State File: $STATE_FILE

  TO RESUME: Read the state file for details.

"
            ;;
    esac
done

# ============================================================================
# Add Session Continuity Context
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PROGRESS_FILE="$PROJECT_DIR/claude-progress.txt"

if [[ -f "$PROGRESS_FILE" ]]; then
    # Get last few lines for context (not full file to save context space)
    LAST_PROGRESS=$(tail -20 "$PROGRESS_FILE" 2>/dev/null || echo "")

    if [[ -n "$LAST_PROGRESS" ]]; then
        CONTEXT+="SESSION CONTINUITY:
  Progress file: claude-progress.txt
  Last entries:
$LAST_PROGRESS

"
    fi
fi

# ============================================================================
# Add Post-Compaction Recovery Context
# ============================================================================

if [[ "$REASON" == "compact" ]]; then
    CONTEXT+="POST-COMPACTION RECOVERY:
  This session was compacted to manage context size.
  Workflow state has been preserved in the state files listed above.
  Read the state files to restore full context and continue.

"
fi

# ============================================================================
# Output Context
# ============================================================================

if [[ -n "$CONTEXT" ]]; then
    log_hook "Injecting context for $WORKFLOW_COUNT active workflow(s)"

    # Wrap context with clear markers
    FULL_CONTEXT="=== CLAUDE-MARTO-TOOLKIT: SESSION CONTEXT ===

$CONTEXT
=== END SESSION CONTEXT ==="

    output_additional_context "$FULL_CONTEXT"
else
    log_hook "No active workflows - no context to inject"
    output_allow
fi
