#!/bin/bash
# ============================================================================
# SubagentStop Hook - Quality Gates and State Updates
# ============================================================================
#
# This hook fires when a subagent (spawned via Task tool) completes.
# It parses the agent's output, applies quality gates, and updates
# the parent workflow's state.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin
#   CLAUDE_PROJECT_DIR  - Path to user's project
#
# Input (JSON via stdin):
#   session_id        - Subagent's session identifier
#   transcript_path   - Path to subagent's conversation transcript
#   stop_hook_active  - Whether stop hook is already active
#
# Output:
#   Exit 0 with no output    - Allow stop
#   Exit 0 with JSON output  - Control behavior (block with feedback)
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

log_hook "SubagentStop triggered: session=$SESSION_ID"

# ============================================================================
# Validate Transcript
# ============================================================================

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
    log_hook "Transcript not found: $TRANSCRIPT_PATH - allowing stop"
    output_allow
fi

# ============================================================================
# Extract Agent Output
# ============================================================================

LAST_OUTPUT=$(get_last_assistant_message "$TRANSCRIPT_PATH")

if [[ -z "$LAST_OUTPUT" ]]; then
    log_hook "No assistant output in transcript - allowing stop"
    output_allow
fi

# ============================================================================
# Parse AGENT_RESULT Marker
# ============================================================================

AGENT_RESULT=$(parse_agent_result "$LAST_OUTPUT")

# Variables we'll populate
WORKFLOW_ID=""
AGENT_TYPE=""
TASK_ID=""
STATUS=""

if [[ -n "$AGENT_RESULT" ]]; then
    # Structured result found - parse fields
    WORKFLOW_ID=$(get_result_field "$AGENT_RESULT" "workflow_id")
    AGENT_TYPE=$(get_result_field "$AGENT_RESULT" "agent_type")
    TASK_ID=$(get_result_field "$AGENT_RESULT" "task_id")
    STATUS=$(get_result_field "$AGENT_RESULT" "status")

    log_hook "Parsed AGENT_RESULT: workflow=$WORKFLOW_ID agent=$AGENT_TYPE task=$TASK_ID status=$STATUS"
else
    # No structured result - try heuristic detection from prompt
    log_hook "No AGENT_RESULT marker - using heuristic detection"

    FIRST_PROMPT=$(get_first_user_message "$TRANSCRIPT_PATH")

    # Extract workflow ID from [WORKFLOW:xxx] in prompt
    WORKFLOW_ID=$(extract_workflow_id_from_prompt "$FIRST_PROMPT")
    TASK_ID=$(extract_task_id_from_prompt "$FIRST_PROMPT")

    # Detect agent type from prompt content
    if echo "$FIRST_PROMPT" | grep -qiE '\bic4\b|implement.*until.*pass|make.*tests.*pass'; then
        AGENT_TYPE="ic4"
    elif echo "$FIRST_PROMPT" | grep -qiE 'unit-test-specialist|write.*failing.*test|TDD.*red'; then
        AGENT_TYPE="unit-test-specialist"
    elif echo "$FIRST_PROMPT" | grep -qiE '\bverifier\b|verification|verify.*implementation'; then
        AGENT_TYPE="verifier"
    elif echo "$FIRST_PROMPT" | grep -qiE 'principal-architect|review.*design'; then
        AGENT_TYPE="principal-architect"
    elif echo "$FIRST_PROMPT" | grep -qiE 'deep-code-research|analyze.*codebase|codebase.*research'; then
        AGENT_TYPE="deep-code-research"
    elif echo "$FIRST_PROMPT" | grep -qiE 'system-architect'; then
        AGENT_TYPE="system-architect"
    elif echo "$FIRST_PROMPT" | grep -qiE 'backend-architect'; then
        AGENT_TYPE="backend-architect"
    elif echo "$FIRST_PROMPT" | grep -qiE 'frontend-architect'; then
        AGENT_TYPE="frontend-architect"
    else
        AGENT_TYPE="unknown"
    fi

    # Try to detect status from output
    if echo "$LAST_OUTPUT" | grep -qiE 'success|complete|passed|all.*pass'; then
        STATUS="success"
    elif echo "$LAST_OUTPUT" | grep -qiE 'fail|error|exception'; then
        STATUS="failure"
    else
        STATUS="unknown"
    fi

    log_hook "Heuristic detection: workflow=$WORKFLOW_ID agent=$AGENT_TYPE task=$TASK_ID status=$STATUS"
fi

# ============================================================================
# Update Registry
# ============================================================================

if [[ -n "$WORKFLOW_ID" ]]; then
    update_subagent_status "$WORKFLOW_ID" "$SESSION_ID" "$STATUS"
fi

# ============================================================================
# Apply Agent-Specific Quality Gates
# ============================================================================

case "$AGENT_TYPE" in
    # ========================================================================
    # IC4 - Implementation Agent
    # ========================================================================
    ic4)
        # Check for test failures in structured result
        if [[ "$STATUS" == "failure" ]]; then
            TESTS_FAILED=$(get_result_field "$AGENT_RESULT" "tests_failed")
            log_hook "IC4 quality gate: status=failure tests_failed=$TESTS_FAILED"

            output_block \
                "@ic4 completed with failures. Tests did not pass.

Review the agent's output above for details on what failed.
Options:
1. Retry @ic4 with additional context about the failure
2. Debug the test expectations
3. Check if dependencies are missing

Workflow: $WORKFLOW_ID
Task: $TASK_ID" \
                "Quality Gate: IC4 tests not passing"
        fi

        # Check output for failure indicators even if status unknown
        if [[ "$STATUS" == "unknown" ]]; then
            if echo "$LAST_OUTPUT" | grep -qiE 'tests?\s+(fail|failed|failing)|FAILED|assertion.*error'; then
                log_hook "IC4 quality gate: detected failure in output"

                output_block \
                    "@ic4 output indicates test failures.

Review the test output above and determine:
1. What tests are failing
2. Whether to retry implementation
3. If tests need adjustment

Workflow: $WORKFLOW_ID
Task: $TASK_ID" \
                    "Quality Gate: IC4 possible test failures detected"
            fi
        fi

        # Update parent workflow state if successful
        if [[ "$STATUS" == "success" ]] && [[ -n "$WORKFLOW_ID" ]] && [[ -n "$TASK_ID" ]]; then
            STATE_FILE=$(get_state_file "$WORKFLOW_ID")
            if [[ -f "$STATE_FILE" ]]; then
                source "$SCRIPT_DIR/lib/cook-logic.sh"
                update_cook_task_status "$STATE_FILE" "$TASK_ID" "implemented"
            fi
        fi
        ;;

    # ========================================================================
    # Unit Test Specialist
    # ========================================================================
    unit-test-specialist)
        if [[ "$STATUS" == "failure" ]]; then
            log_hook "unit-test-specialist quality gate: failed to create tests"

            output_block \
                "@unit-test-specialist failed to create tests.

Review the agent's output above for details.
Common issues:
1. Unclear test requirements
2. Missing context about expected behavior
3. Project test infrastructure issues

Workflow: $WORKFLOW_ID
Task: $TASK_ID" \
                "Quality Gate: Test creation failed"
        fi

        # Update parent workflow state if successful
        if [[ "$STATUS" == "success" ]] && [[ -n "$WORKFLOW_ID" ]] && [[ -n "$TASK_ID" ]]; then
            STATE_FILE=$(get_state_file "$WORKFLOW_ID")
            if [[ -f "$STATE_FILE" ]]; then
                source "$SCRIPT_DIR/lib/cook-logic.sh"
                update_cook_task_status "$STATE_FILE" "$TASK_ID" "tests_written"
            fi
        fi
        ;;

    # ========================================================================
    # Verifier Agent
    # ========================================================================
    verifier)
        if [[ "$STATUS" == "failure" ]]; then
            FEATURES_FAILED=$(get_result_field "$AGENT_RESULT" "features_failed")
            log_hook "Verifier quality gate: verification failed ($FEATURES_FAILED features)"

            output_block \
                "@verifier found verification failures.

$FEATURES_FAILED feature(s) did not pass verification.

NEXT ACTIONS:
1. Read the verification report for details
2. Identify which features failed and why
3. Spawn @ic4 to fix the specific issues
4. Re-run verification after fixes

Workflow: $WORKFLOW_ID" \
                "Quality Gate: Verification failed"
        fi

        # Check for failure indicators in output
        if echo "$LAST_OUTPUT" | grep -qiE 'verification.*fail|FAIL|regression|screenshot.*mismatch'; then
            if [[ "$STATUS" != "success" ]]; then
                log_hook "Verifier quality gate: detected failure in output"
                # Don't block on heuristic - just log
            fi
        fi
        ;;

    # ========================================================================
    # Principal Architect - Review Agent
    # ========================================================================
    principal-architect)
        # Never block principal architect - it's informational
        # But update spec workflow state with the verdict

        if [[ -n "$WORKFLOW_ID" ]]; then
            VERDICT=$(get_result_field "$AGENT_RESULT" "verdict")
            FEEDBACK_DOC=$(get_result_field "$AGENT_RESULT" "feedback_document")

            if [[ -n "$VERDICT" ]]; then
                STATE_FILE=$(get_state_file "$WORKFLOW_ID")
                if [[ -f "$STATE_FILE" ]]; then
                    source "$SCRIPT_DIR/lib/spec-logic.sh"
                    update_spec_verdict "$STATE_FILE" "$VERDICT" "$FEEDBACK_DOC"
                fi
            fi
        fi

        log_hook "Principal architect completed: verdict=$VERDICT"
        ;;

    # ========================================================================
    # Design Architects
    # ========================================================================
    system-architect|backend-architect|frontend-architect)
        # Update spec workflow with design document path
        if [[ -n "$WORKFLOW_ID" ]]; then
            DESIGN_DOC=$(get_result_field "$AGENT_RESULT" "design_document")

            if [[ -n "$DESIGN_DOC" ]]; then
                STATE_FILE=$(get_state_file "$WORKFLOW_ID")
                if [[ -f "$STATE_FILE" ]]; then
                    source "$SCRIPT_DIR/lib/spec-logic.sh"
                    update_spec_design "$STATE_FILE" "$DESIGN_DOC"
                fi
            fi
        fi

        log_hook "$AGENT_TYPE completed: design=$DESIGN_DOC"
        ;;

    # ========================================================================
    # Deep Code Research
    # ========================================================================
    deep-code-research)
        # Never block research - it's informational
        RESEARCH_DOC=$(get_result_field "$AGENT_RESULT" "research_document")
        log_hook "Deep code research completed: document=$RESEARCH_DOC"

        # Could update workflow state with research path if needed
        if [[ -n "$WORKFLOW_ID" ]] && [[ -n "$RESEARCH_DOC" ]]; then
            STATE_FILE=$(get_state_file "$WORKFLOW_ID")
            if [[ -f "$STATE_FILE" ]]; then
                # Add research document to state
                set_state_field "$STATE_FILE" "research_document" "$RESEARCH_DOC"
            fi
        fi
        ;;

    # ========================================================================
    # Unknown Agent
    # ========================================================================
    *)
        log_hook "Unknown agent type: $AGENT_TYPE - no quality gate applied"
        ;;
esac

# ============================================================================
# Default: Allow Stop
# ============================================================================

log_hook "SubagentStop complete: allowing stop for $AGENT_TYPE"
output_allow
