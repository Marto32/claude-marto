#!/bin/bash
# /cook workflow completion logic for stop hook
#
# This file is sourced by stop.sh and expects common.sh to already be loaded.

# ============================================================================
# Cook Workflow Completion Check
# ============================================================================

check_cook_completion() {
    local STATE_FILE="$1"
    local HOOK_INPUT="$2"

    # Extract state fields
    local WORKFLOW_ID PHASE TASKS_TOTAL TASKS_VERIFIED ITERATION MAX_ITERATIONS
    WORKFLOW_ID=$(get_state_field "$STATE_FILE" "workflow_id")
    PHASE=$(get_state_field "$STATE_FILE" "phase")
    TASKS_TOTAL=$(get_state_field "$STATE_FILE" "tasks_total")
    TASKS_VERIFIED=$(get_state_field "$STATE_FILE" "tasks_verified")
    ITERATION=$(get_state_field "$STATE_FILE" "iteration")
    MAX_ITERATIONS=$(get_state_field "$STATE_FILE" "max_iterations")

    # Additional fields for context
    local TASKS_WITH_TESTS TASKS_IMPLEMENTED IMPL_PLAN
    TASKS_WITH_TESTS=$(get_state_field "$STATE_FILE" "tasks_with_tests")
    TASKS_IMPLEMENTED=$(get_state_field "$STATE_FILE" "tasks_implemented")
    IMPL_PLAN=$(get_state_field "$STATE_FILE" "implementation_plan")

    log_hook "Cook check: workflow=$WORKFLOW_ID phase=$PHASE verified=$TASKS_VERIFIED/$TASKS_TOTAL iteration=$ITERATION"

    # ========================================================================
    # Completion Check
    # ========================================================================

    if [[ "$PHASE" == "complete" ]]; then
        if [[ "$TASKS_VERIFIED" == "$TASKS_TOTAL" ]] || [[ "$TASKS_TOTAL" == "0" ]]; then
            log_hook "Cook workflow $WORKFLOW_ID complete - cleaning up"
            cleanup_workflow "$WORKFLOW_ID"
            output_allow
        fi
    fi

    # ========================================================================
    # Max Iterations Safety Valve
    # ========================================================================

    if [[ -n "$ITERATION" ]] && [[ -n "$MAX_ITERATIONS" ]]; then
        if [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
            if [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
                log_hook "Cook workflow $WORKFLOW_ID hit max iterations ($MAX_ITERATIONS) - forcing completion"
                echo "Cook workflow reached maximum iterations ($MAX_ITERATIONS) without completion." >&2
                echo "State preserved in: $STATE_FILE" >&2
                # Don't cleanup - preserve for manual inspection
                output_allow
            fi
        fi
    fi

    # ========================================================================
    # Not Complete - Continue Workflow
    # ========================================================================

    # Increment iteration
    local NEXT_ITERATION
    NEXT_ITERATION=$(increment_state_field "$STATE_FILE" "iteration")

    # Build continuation prompt based on current phase
    local CONTINUE_MSG SYSTEM_MSG

    case "$PHASE" in
        research)
            CONTINUE_MSG="Continue /cook workflow: $WORKFLOW_ID

CURRENT PHASE: Research (Phase 1)
STATE FILE: $STATE_FILE

The research phase should now be complete. Proceed to Phase 2: Writing Tests.

NEXT ACTIONS:
1. Read the state file to see the task list
2. For each task without tests, spawn @unit-test-specialist
3. Use [WORKFLOW:$WORKFLOW_ID] [TASK:X.Y] in each subagent prompt
4. After spawning test writers, update the state file phase to 'testing'"
            ;;

        testing)
            CONTINUE_MSG="Continue /cook workflow: $WORKFLOW_ID

CURRENT PHASE: Testing (Phase 2)
STATE FILE: $STATE_FILE
PROGRESS: $TASKS_WITH_TESTS/$TASKS_TOTAL tasks have tests

NEXT ACTIONS:
1. Read the state file for current task status
2. If tasks still need tests: spawn @unit-test-specialist for them
3. If all tasks have tests: update phase to 'implementation' and spawn @ic4
4. Use [WORKFLOW:$WORKFLOW_ID] [TASK:X.Y] in each subagent prompt
5. Update task status in state file as subagents complete"
            ;;

        implementation)
            CONTINUE_MSG="Continue /cook workflow: $WORKFLOW_ID

CURRENT PHASE: Implementation (Phase 3)
STATE FILE: $STATE_FILE
PROGRESS: $TASKS_IMPLEMENTED/$TASKS_TOTAL tasks implemented

NEXT ACTIONS:
1. Read the state file for current task status
2. If tasks still need implementation: spawn @ic4 for them
3. If all tasks implemented: update phase to 'verification' and spawn @verifier
4. Use [WORKFLOW:$WORKFLOW_ID] [TASK:X.Y] in each subagent prompt
5. Update task status in state file as subagents complete"
            ;;

        verification)
            CONTINUE_MSG="Continue /cook workflow: $WORKFLOW_ID

CURRENT PHASE: Verification (Phase 4)
STATE FILE: $STATE_FILE
PROGRESS: $TASKS_VERIFIED/$TASKS_TOTAL tasks verified

NEXT ACTIONS:
1. Read the state file and verification results
2. If verification passed: update phase to 'complete' and report success
3. If verification failed: spawn @ic4 to fix issues, then re-verify
4. Once all verified: update phase to 'complete'"
            ;;

        *)
            CONTINUE_MSG="Continue /cook workflow: $WORKFLOW_ID

STATE FILE: $STATE_FILE
CURRENT PHASE: $PHASE

Read the state file to determine current status and next actions.
Implementation plan: $IMPL_PLAN"
            ;;
    esac

    SYSTEM_MSG="Cook iteration $NEXT_ITERATION | Phase: $PHASE | Tasks: $TASKS_VERIFIED/$TASKS_TOTAL verified"

    output_block "$CONTINUE_MSG" "$SYSTEM_MSG"
}

# ============================================================================
# Cook Task Status Update
# ============================================================================

# Update a specific task's status in the state file
# Called by subagent-stop hook when a subagent completes
update_cook_task_status() {
    local STATE_FILE="$1"
    local TASK_ID="$2"
    local NEW_STATUS="$3"  # tests_written, implementing, implemented, verified, failed

    log_hook "Updating task $TASK_ID to status: $NEW_STATUS in $STATE_FILE"

    # This is a simplified implementation - for complex task tracking,
    # consider using a separate JSON file for task status

    # Update summary counters based on status
    case "$NEW_STATUS" in
        tests_written)
            increment_state_field "$STATE_FILE" "tasks_with_tests"
            ;;
        implemented)
            increment_state_field "$STATE_FILE" "tasks_implemented"
            ;;
        verified)
            increment_state_field "$STATE_FILE" "tasks_verified"
            ;;
    esac

    # Append to task log in state file
    local TIMESTAMP
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    echo "" >> "$STATE_FILE"
    echo "[$TIMESTAMP] Task $TASK_ID: $NEW_STATUS" >> "$STATE_FILE"
}

# ============================================================================
# Cook Phase Transition
# ============================================================================

# Transition to the next phase
advance_cook_phase() {
    local STATE_FILE="$1"
    local CURRENT_PHASE="$2"

    local NEXT_PHASE
    case "$CURRENT_PHASE" in
        research)
            NEXT_PHASE="testing"
            ;;
        testing)
            NEXT_PHASE="implementation"
            ;;
        implementation)
            NEXT_PHASE="verification"
            ;;
        verification)
            NEXT_PHASE="complete"
            ;;
        *)
            return 1
            ;;
    esac

    set_state_field "$STATE_FILE" "phase" "$NEXT_PHASE"
    log_hook "Cook phase transition: $CURRENT_PHASE -> $NEXT_PHASE"

    echo "$NEXT_PHASE"
}
