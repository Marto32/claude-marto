#!/bin/bash
# Common utilities for claude-marto-toolkit hooks
#
# Environment variables available:
#   CLAUDE_PLUGIN_ROOT  - Path to this plugin's directory
#   CLAUDE_PROJECT_DIR  - Path to the user's project directory

set -euo pipefail

# ============================================================================
# Path Configuration
# ============================================================================

# Workflows directory is in the PROJECT, not the plugin
WORKFLOWS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/workflows"
REGISTRY_FILE="$WORKFLOWS_DIR/registry.json"
HOOKS_LOG="$WORKFLOWS_DIR/hooks.log"

# ============================================================================
# Initialization
# ============================================================================

init_workflows_dir() {
    mkdir -p "$WORKFLOWS_DIR"
    if [[ ! -f "$REGISTRY_FILE" ]]; then
        echo '{"workflows": {}, "session_to_workflow": {}}' > "$REGISTRY_FILE"
    fi
}

# ============================================================================
# Logging
# ============================================================================

log_hook() {
    local MSG="$1"
    local TIMESTAMP
    TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    echo "[$TIMESTAMP] $MSG" >> "$HOOKS_LOG" 2>/dev/null || true
}

# ============================================================================
# Registry Operations
# ============================================================================

# Get workflow ID for a session from registry
get_workflow_for_session() {
    local SESSION_ID="$1"
    if [[ -f "$REGISTRY_FILE" ]]; then
        jq -r --arg s "$SESSION_ID" '.session_to_workflow[$s] // empty' "$REGISTRY_FILE" 2>/dev/null || echo ""
    fi
}

# Add workflow to registry
register_workflow() {
    local WORKFLOW_ID="$1"
    local WORKFLOW_TYPE="$2"
    local PARENT_SESSION="$3"
    local STATE_FILE="$4"

    if [[ -f "$REGISTRY_FILE" ]]; then
        local TIMESTAMP
        TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

        jq --arg wf "$WORKFLOW_ID" \
           --arg type "$WORKFLOW_TYPE" \
           --arg sess "$PARENT_SESSION" \
           --arg state "$STATE_FILE" \
           --arg ts "$TIMESTAMP" \
           '.workflows[$wf] = {
               "type": $type,
               "parent_session_id": $sess,
               "state_file": $state,
               "created_at": $ts,
               "subagent_sessions": []
           } |
           .session_to_workflow[$sess] = $wf' \
           "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" && mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"
    fi
}

# Register a subagent session
register_subagent() {
    local WORKFLOW_ID="$1"
    local SUBAGENT_SESSION="$2"
    local AGENT_TYPE="$3"

    if [[ -f "$REGISTRY_FILE" ]]; then
        jq --arg wf "$WORKFLOW_ID" \
           --arg sess "$SUBAGENT_SESSION" \
           --arg type "$AGENT_TYPE" \
           '.workflows[$wf].subagent_sessions += [{"session_id": $sess, "agent_type": $type, "status": "running"}] |
            .session_to_workflow[$sess] = $wf' \
           "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" && mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"
    fi
}

# Update subagent status
update_subagent_status() {
    local WORKFLOW_ID="$1"
    local SESSION_ID="$2"
    local STATUS="$3"

    if [[ -f "$REGISTRY_FILE" ]]; then
        jq --arg wf "$WORKFLOW_ID" \
           --arg sess "$SESSION_ID" \
           --arg status "$STATUS" \
           '.workflows[$wf].subagent_sessions = [
               .workflows[$wf].subagent_sessions[] |
               if .session_id == $sess then .status = $status else . end
           ]' \
           "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" && mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE" 2>/dev/null || true
    fi
}

# Remove workflow from registry
unregister_workflow() {
    local WORKFLOW_ID="$1"

    if [[ -f "$REGISTRY_FILE" ]]; then
        jq --arg wf "$WORKFLOW_ID" '
            del(.workflows[$wf]) |
            .session_to_workflow = (.session_to_workflow | with_entries(select(.value != $wf)))
        ' "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" && mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"
    fi
}

# ============================================================================
# State File Operations
# ============================================================================

# Get state file path for workflow
get_state_file() {
    local WORKFLOW_ID="$1"
    echo "$WORKFLOWS_DIR/${WORKFLOW_ID}.local.md"
}

# Parse YAML frontmatter field from state file
# Handles both simple values and quoted strings
get_state_field() {
    local STATE_FILE="$1"
    local FIELD="$2"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo ""
        return
    fi

    # Extract value after "field:" and trim whitespace
    local VALUE
    VALUE=$(sed -n '/^---$/,/^---$/p' "$STATE_FILE" | grep "^${FIELD}:" | head -1 | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Remove surrounding quotes if present
    VALUE=$(echo "$VALUE" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")

    echo "$VALUE"
}

# Update YAML frontmatter field in state file
set_state_field() {
    local STATE_FILE="$1"
    local FIELD="$2"
    local VALUE="$3"

    if [[ ! -f "$STATE_FILE" ]]; then
        return 1
    fi

    # macOS/Linux compatible sed in-place editing
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/^${FIELD}:.*/${FIELD}: ${VALUE}/" "$STATE_FILE"
    else
        sed -i "s/^${FIELD}:.*/${FIELD}: ${VALUE}/" "$STATE_FILE"
    fi
}

# Increment a numeric field in state file
increment_state_field() {
    local STATE_FILE="$1"
    local FIELD="$2"

    local CURRENT
    CURRENT=$(get_state_field "$STATE_FILE" "$FIELD")

    if [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
        local NEW_VALUE=$((CURRENT + 1))
        set_state_field "$STATE_FILE" "$FIELD" "$NEW_VALUE"
        echo "$NEW_VALUE"
    else
        echo "$CURRENT"
    fi
}

# ============================================================================
# AGENT_RESULT Parsing
# ============================================================================

# Parse AGENT_RESULT block from text
# Returns the content between <!-- AGENT_RESULT and -->
parse_agent_result() {
    local TEXT="$1"

    # Use perl for reliable multiline extraction (works on macOS and Linux)
    echo "$TEXT" | perl -0777 -ne 'print $1 if /<!-- AGENT_RESULT\s*(.*?)\s*-->/s' 2>/dev/null || echo ""
}

# Get a field from parsed AGENT_RESULT content
get_result_field() {
    local RESULT="$1"
    local FIELD="$2"

    echo "$RESULT" | grep "^${FIELD}:" | head -1 | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# ============================================================================
# Hook Output Helpers
# ============================================================================

# Output JSON to block the stop/action and provide continuation prompt
output_block() {
    local REASON="$1"
    local SYSTEM_MSG="$2"

    jq -n \
        --arg reason "$REASON" \
        --arg msg "$SYSTEM_MSG" \
        '{"decision": "block", "reason": $reason, "systemMessage": $msg}'
}

# Output JSON with just a system message (non-blocking)
output_system_message() {
    local MSG="$1"
    jq -n --arg msg "$MSG" '{"systemMessage": $msg}'
}

# Output JSON with additional context (for SessionStart)
output_additional_context() {
    local CONTEXT="$1"
    jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
}

# Allow the action to proceed (exit cleanly)
output_allow() {
    exit 0
}

# ============================================================================
# Transcript Helpers
# ============================================================================

# Get the last assistant message from a transcript (JSONL format)
get_last_assistant_message() {
    local TRANSCRIPT_PATH="$1"

    if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
        echo ""
        return
    fi

    grep '"role":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 | jq -r '
        .message.content |
        map(select(.type == "text")) |
        map(.text) |
        join("\n")
    ' 2>/dev/null || echo ""
}

# Get the first user message from a transcript (contains spawn prompt)
get_first_user_message() {
    local TRANSCRIPT_PATH="$1"

    if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
        echo ""
        return
    fi

    grep '"role":"user"' "$TRANSCRIPT_PATH" 2>/dev/null | head -1 | jq -r '
        .message.content[0].text // .message.content // ""
    ' 2>/dev/null || echo ""
}

# Extract workflow ID from prompt text [WORKFLOW:xxx]
extract_workflow_id_from_prompt() {
    local PROMPT="$1"
    echo "$PROMPT" | grep -oP '(?<=\[WORKFLOW:)[^\]]+' 2>/dev/null | head -1 || echo ""
}

# Extract task ID from prompt text [TASK:xxx]
extract_task_id_from_prompt() {
    local PROMPT="$1"
    echo "$PROMPT" | grep -oP '(?<=\[TASK:)[^\]]+' 2>/dev/null | head -1 || echo ""
}

# ============================================================================
# Workflow Lifecycle
# ============================================================================

# Clean up a completed workflow
cleanup_workflow() {
    local WORKFLOW_ID="$1"
    local ARCHIVE="${2:-true}"  # Archive by default

    local STATE_FILE
    STATE_FILE=$(get_state_file "$WORKFLOW_ID")

    if [[ -f "$STATE_FILE" ]]; then
        if [[ "$ARCHIVE" == "true" ]]; then
            # Archive instead of delete (for debugging)
            mv "$STATE_FILE" "${STATE_FILE%.local.md}.completed.md"
            log_hook "Archived workflow state: $WORKFLOW_ID"
        else
            rm "$STATE_FILE"
            log_hook "Deleted workflow state: $WORKFLOW_ID"
        fi
    fi

    # Remove from registry
    unregister_workflow "$WORKFLOW_ID"
    log_hook "Cleaned up workflow: $WORKFLOW_ID"
}

# Find workflow for a session (checks registry and state files)
find_workflow_for_session() {
    local SESSION_ID="$1"

    # First check registry
    local WORKFLOW_ID
    WORKFLOW_ID=$(get_workflow_for_session "$SESSION_ID")

    if [[ -n "$WORKFLOW_ID" ]]; then
        echo "$WORKFLOW_ID"
        return
    fi

    # Fallback: scan state files for parent_session_id match
    for STATE_FILE in "$WORKFLOWS_DIR"/*.local.md; do
        [[ -f "$STATE_FILE" ]] || continue

        local PARENT_SESSION
        PARENT_SESSION=$(get_state_field "$STATE_FILE" "parent_session_id")

        if [[ "$PARENT_SESSION" == "$SESSION_ID" ]]; then
            get_state_field "$STATE_FILE" "workflow_id"
            return
        fi
    done

    echo ""
}

# ============================================================================
# Utility Functions
# ============================================================================

# Generate a unique workflow ID
generate_workflow_id() {
    local TYPE="$1"
    local RANDOM_SUFFIX

    if command -v openssl &>/dev/null; then
        RANDOM_SUFFIX=$(openssl rand -hex 4)
    else
        RANDOM_SUFFIX=$(head -c 8 /dev/urandom | xxd -p | head -c 8)
    fi

    echo "${TYPE}-wf-${RANDOM_SUFFIX}"
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Get file size in bytes (cross-platform)
get_file_size() {
    local FILE="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f%z "$FILE" 2>/dev/null || echo "0"
    else
        stat -c%s "$FILE" 2>/dev/null || echo "0"
    fi
}
