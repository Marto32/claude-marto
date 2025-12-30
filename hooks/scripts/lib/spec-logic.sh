#!/bin/bash
# /spec workflow completion logic for stop hook
#
# This file is sourced by stop.sh and expects common.sh to already be loaded.

# ============================================================================
# Spec Workflow Completion Check
# ============================================================================

check_spec_completion() {
    local STATE_FILE="$1"
    local HOOK_INPUT="$2"

    # Extract state fields
    local WORKFLOW_ID CURRENT_VERDICT ITERATION MAX_ITERATIONS ARCHITECT_TYPE
    WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")
    CURRENT_VERDICT=$(get_state_field "$STATE_FILE" "current_verdict")
    ITERATION=$(get_state_field "$STATE_FILE" "iteration")
    MAX_ITERATIONS=$(get_state_field "$STATE_FILE" "max_iterations")
    ARCHITECT_TYPE=$(get_state_field "$STATE_FILE" "architect_type")

    # Additional fields for context
    local DESIGN_DOC FEEDBACK_DOC ORIGINAL_CONTEXT AWAITING
    DESIGN_DOC=$(get_state_field "$STATE_FILE" "design_document")
    FEEDBACK_DOC=$(get_state_field "$STATE_FILE" "feedback_document")
    ORIGINAL_CONTEXT=$(get_state_field "$STATE_FILE" "original_context")
    AWAITING=$(get_state_field "$STATE_FILE" "awaiting")

    log_hook "Spec check: workflow=$WORKFLOW_ID verdict=$CURRENT_VERDICT iteration=$ITERATION awaiting=$AWAITING"

    # ========================================================================
    # Completion Check - Design Approved
    # ========================================================================

    if [[ "$CURRENT_VERDICT" == "approved" ]]; then
        log_hook "Spec workflow $WORKFLOW_ID approved - cleaning up"
        cleanup_workflow "$WORKFLOW_ID"
        output_allow
    fi

    # ========================================================================
    # Max Iterations Safety Valve
    # ========================================================================

    if [[ -n "$ITERATION" ]] && [[ -n "$MAX_ITERATIONS" ]]; then
        if [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
            if [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
                log_hook "Spec workflow $WORKFLOW_ID hit max iterations ($MAX_ITERATIONS) - forcing stop"
                echo "Spec workflow reached maximum iterations ($MAX_ITERATIONS) without approval." >&2
                echo "State preserved in: $STATE_FILE" >&2
                echo "Final verdict: $CURRENT_VERDICT" >&2
                # Don't cleanup - preserve for manual inspection
                output_allow
            fi
        fi
    fi

    # ========================================================================
    # Not Approved - Continue Revision Loop
    # ========================================================================

    # Increment iteration
    local NEXT_ITERATION
    NEXT_ITERATION=$(increment_state_field "$STATE_FILE" "iteration")

    # Build continuation prompt based on current verdict and state
    local CONTINUE_MSG SYSTEM_MSG

    case "$CURRENT_VERDICT" in
        approved_with_conditions)
            CONTINUE_MSG="Continue /spec revision loop: $WORKFLOW_ID

VERDICT: APPROVED WITH CONDITIONS
STATE FILE: $STATE_FILE
DESIGN DOCUMENT: $DESIGN_DOC
FEEDBACK DOCUMENT: $FEEDBACK_DOC
ARCHITECT TYPE: $ARCHITECT_TYPE

The design is fundamentally sound but needs targeted updates.

NEXT ACTIONS:
1. Read the feedback document for specific conditions to address
2. Spawn @${ARCHITECT_TYPE}-architect to apply the required changes:
   - Use prompt: \"[WORKFLOW:$WORKFLOW_ID] Update design based on principal architect feedback...\"
   - Include path to current design and feedback documents
   - Instruct to address ONLY the listed conditions
3. After architect completes, spawn @principal-architect to re-review
4. Update state file with new verdict when received"
            ;;

        revision_required)
            CONTINUE_MSG="Continue /spec revision loop: $WORKFLOW_ID

VERDICT: REVISION REQUIRED
STATE FILE: $STATE_FILE
DESIGN DOCUMENT: $DESIGN_DOC
FEEDBACK DOCUMENT: $FEEDBACK_DOC
ARCHITECT TYPE: $ARCHITECT_TYPE

The design has fundamental issues requiring significant rework.

NEXT ACTIONS:
1. Read the feedback document for critical/major issues
2. Ask the user which architect should perform the revision:
   - Same architect ($ARCHITECT_TYPE)
   - System architect (for system-level issues)
   - Backend architect (for API/database issues)
   - Frontend architect (for UI/component issues)
3. Spawn the selected architect with full context:
   - Use prompt: \"[WORKFLOW:$WORKFLOW_ID] Revise design based on principal architect feedback...\"
   - Include original PRD/requirements: $ORIGINAL_CONTEXT
4. After architect completes, spawn @principal-architect to re-review
5. Update state file with new verdict when received"
            ;;

        pending|"")
            # Design created but not yet reviewed
            if [[ -n "$DESIGN_DOC" ]] && [[ "$AWAITING" != "architect_design" ]]; then
                CONTINUE_MSG="Continue /spec workflow: $WORKFLOW_ID

STATUS: Design created, awaiting review
STATE FILE: $STATE_FILE
DESIGN DOCUMENT: $DESIGN_DOC
ORIGINAL CONTEXT: $ORIGINAL_CONTEXT

NEXT ACTIONS:
1. Spawn @principal-architect to review the design:
   - Use prompt: \"[WORKFLOW:$WORKFLOW_ID] Review the design document...\"
   - Include the design document path
   - Include the original context/PRD for requirements tracing
2. Parse the verdict from @principal-architect's AGENT_RESULT
3. Update state file with current_verdict and feedback_document"
            else
                # Still waiting for initial design
                CONTINUE_MSG="Continue /spec workflow: $WORKFLOW_ID

STATUS: Awaiting initial design
STATE FILE: $STATE_FILE
ARCHITECT TYPE: $ARCHITECT_TYPE
ORIGINAL CONTEXT: $ORIGINAL_CONTEXT

NEXT ACTIONS:
1. If research needed: spawn @deep-code-research first
2. Spawn @${ARCHITECT_TYPE}-architect to create the design:
   - Use prompt: \"[WORKFLOW:$WORKFLOW_ID] Design architecture based on...\"
   - Include the original context/PRD
3. Update state file with design_document path when complete
4. Then proceed to principal architect review"
            fi
            ;;

        *)
            # Unknown verdict state - provide generic continuation
            CONTINUE_MSG="Continue /spec workflow: $WORKFLOW_ID

STATE FILE: $STATE_FILE
CURRENT VERDICT: $CURRENT_VERDICT
DESIGN DOCUMENT: $DESIGN_DOC

Read the state file to determine current status and next actions."
            ;;
    esac

    SYSTEM_MSG="Spec revision $NEXT_ITERATION | Verdict: $CURRENT_VERDICT | Architect: $ARCHITECT_TYPE"

    output_block "$CONTINUE_MSG" "$SYSTEM_MSG"
}

# ============================================================================
# Spec Verdict Update
# ============================================================================

# Update the verdict in state file (called by subagent-stop hook)
update_spec_verdict() {
    local STATE_FILE="$1"
    local VERDICT="$2"
    local FEEDBACK_PATH="$3"

    log_hook "Updating spec verdict to: $VERDICT"

    set_state_field "$STATE_FILE" "current_verdict" "$VERDICT"

    if [[ -n "$FEEDBACK_PATH" ]]; then
        set_state_field "$STATE_FILE" "feedback_document" "$FEEDBACK_PATH"
    fi

    # Append to review history
    local TIMESTAMP ITERATION
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    ITERATION=$(get_state_field "$STATE_FILE" "iteration")

    echo "" >> "$STATE_FILE"
    echo "## Review $ITERATION - $TIMESTAMP" >> "$STATE_FILE"
    echo "Verdict: $VERDICT" >> "$STATE_FILE"
    if [[ -n "$FEEDBACK_PATH" ]]; then
        echo "Feedback: $FEEDBACK_PATH" >> "$STATE_FILE"
    fi
}

# ============================================================================
# Spec Design Document Update
# ============================================================================

# Update the design document path (called when architect creates/updates design)
update_spec_design() {
    local STATE_FILE="$1"
    local DESIGN_PATH="$2"

    log_hook "Updating spec design document: $DESIGN_PATH"

    set_state_field "$STATE_FILE" "design_document" "$DESIGN_PATH"
    set_state_field "$STATE_FILE" "awaiting" "principal_review"
}
