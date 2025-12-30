---
model: claude-opus-4-5
---

# Spec Command

Create and review architectural designs using specialized architect agents, followed by principal architect review.

## Input

$ARGUMENTS

## Resume vs New Workflow

**Before creating a new workflow, check for existing workflows:**

### Step 1: Check for Existing Workflows

```bash
# List any existing spec workflows
ls .claude/workflows/spec-wf-*.local.md 2>/dev/null
```

If workflows exist, read their state files and check:
1. Is the `architect_type` and `original_context` similar to current request?
2. Is `current_verdict` NOT `approved`?

### Step 2: If Matching Incomplete Workflow Found

**Ask the user:**
```
AskUserQuestion(
  questions=[{
    "question": "Found existing workflow {WORKFLOW_ID} for {architect_type} design (verdict: {current_verdict}, iteration: {iteration}). Resume or start fresh?",
    "header": "Workflow",
    "options": [
      {"label": "Resume existing", "description": "Continue revision loop from iteration {iteration}"},
      {"label": "Start fresh", "description": "Create new workflow, abandon old one"}
    ],
    "multiSelect": false
  }]
)
```

**If "Resume existing":**
- Use the existing WORKFLOW_ID
- Read the state file to determine current state
- Continue from where it left off (e.g., spawn principal-architect if awaiting review)

**If "Start fresh":**
- Archive the old workflow: `mv {old-file} {old-file}.abandoned.md`
- Proceed to create a new workflow

### Step 3: Explicit Resume by Workflow ID

If first argument is `resume` followed by a workflow ID:
```
/spec resume spec-wf-a1b2c3d4
```

1. Look for `.claude/workflows/spec-wf-a1b2c3d4.local.md`
2. If found, resume that workflow (skip to current state)
3. If not found, error: "Workflow spec-wf-a1b2c3d4 not found"

### Step 4: List Active Workflows

If $ARGUMENTS is `list` or `status`:
```
/spec list
```

List all active spec workflows with their status:
```
Active /spec workflows:
- spec-wf-a1b2c3d4: backend design (verdict: revision_required, iteration: 2)
- spec-wf-e5f6g7h8: frontend design (verdict: approved_with_conditions, iteration: 1)
```

## Workflow State Management

**CRITICAL:** This command uses hook-based workflow enforcement. The Stop hook will prevent premature exit and ensure the design revision loop completes until APPROVED.

### Initialize Workflow State (MANDATORY - After Validation)

After validating input (architect type and context), create the workflow state file:

1. **Generate a unique workflow ID:**
   ```bash
   WORKFLOW_ID="spec-wf-$(openssl rand -hex 4)"
   ```

2. **Create the workflows directory:**
   ```bash
   mkdir -p .claude/workflows
   ```

3. **Create the state file** at `.claude/workflows/{WORKFLOW_ID}.local.md`:
   ```markdown
   ---
   workflow_id: {WORKFLOW_ID}
   workflow_type: spec
   parent_session_id: {from context if available, or "unknown"}
   created_at: {ISO timestamp}
   iteration: 1
   max_iterations: 10
   completion_promise: "DESIGN_APPROVED"

   architect_type: {system|backend|frontend}
   original_context: {$REMAINING_ARGUMENTS summary}

   design_document: null
   feedback_document: null
   research_document: null

   reviews: []
   current_verdict: pending
   awaiting: architect_design
   ---

   ## Continuation Context
   Starting /spec workflow with {architect_type} architect.
   ```

4. **Record the WORKFLOW_ID** - you'll use it in ALL subagent prompts.

### State File Updates

Update the state file at these points:
- After design architect completes: set `design_document`, set `awaiting` to `principal_review`
- After principal architect reviews: set `current_verdict`, set `feedback_document`
- On revision: increment `iteration`, update `awaiting`

### Subagent Prompt Format

ALL subagent prompts MUST include the workflow context:
```
[WORKFLOW:{WORKFLOW_ID}]

{rest of prompt}

IMPORTANT: End your response with an AGENT_RESULT block (see agent documentation).
```

## Argument Parsing

Parse the first argument to determine the architect type, then extract remaining context:

**Expected Format**: `/spec <architect-type> <documents-and-context>`

Where:
- `<architect-type>`: One of `system`, `backend`, or `frontend`
- `<documents-and-context>`: PRDs, spec documents, design outputs, file paths, and/or user-provided context

### Architect Type Mapping

| First Argument | Agent to Invoke |
|----------------|-----------------|
| `system` | @system-architect (high-level system design, C4 Container/Component level) |
| `backend` | @backend-architect (APIs, databases, services, security) |
| `frontend` | @frontend-architect (UI components, accessibility, performance) |

## Input Validation (MANDATORY)

Before proceeding, validate the input:

1. **Check for architect type**: First argument must be `system`, `backend`, or `frontend`
   - If missing or invalid: Display usage error (see Error Messages below)

2. **Check for context**: Must have additional context beyond the architect type
   - If only architect type provided: "Error: No context provided. Please include PRD, documents, or a description of what to design."

3. **Check referenced files exist**: If file paths are provided, verify they exist
   - If not found: "Warning: File '{path}' not found. Proceeding with other context provided."

**DO NOT proceed if architect type validation fails.** Return the appropriate error message and stop.

## Orchestration Architecture

**CRITICAL:** This command runs at the main Claude thread level and orchestrates ALL sub-agent spawning. Sub-agents cannot spawn other sub-agents.

```
/spec (main thread - orchestrator)
  │
  ├─► Step 1: @deep-code-research (if existing codebase)
  │
  ├─► Step 2: @{system|backend|frontend}-architect (design)
  │
  └─► Step 3: @principal-architect (review loop)
```

## Workflow

### Step 0: Determine if Research Needed

Check if this is an existing codebase that needs research:

1. Look for existing source files (src/, lib/, app/, etc.)
2. Check if a recent research document exists in docs/research/
3. If existing codebase AND no recent research: spawn @deep-code-research first

### Step 1: Pre-Design Research (Conditional)

**If existing codebase needs research**, spawn `@deep-code-research` FIRST:

```
Task(
  subagent_type="claude-marto-toolkit:deep-code-research",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Analyze the codebase to support {architect-type} design work.

CONTEXT:
$REMAINING_ARGUMENTS

Focus on:
1. Existing patterns relevant to {architect-type} concerns
2. Integration points and dependencies
3. Current architecture and conventions
4. Test patterns in use

Save research to: docs/research/codebase-research-{feature-name}-{date}.md

IMPORTANT: End your response with an AGENT_RESULT block."
)
```

**Wait for completion.** Update state file: set `research_document` to the output path.

**Skip this step if:**
- Confirmed greenfield project
- Recent research document already exists
- User explicitly says no research needed

### Step 2: Invoke Design Architect

Based on the parsed architect type, spawn the appropriate design agent:

**For `system`:**
```
Task(
  subagent_type="claude-marto-toolkit:system-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Design a system architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

{IF_RESEARCH_EXISTS}
CODEBASE RESEARCH: {research-doc-path}
{/IF_RESEARCH_EXISTS}

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/system-design-{feature-name}-{date}.md
- Include architecture diagrams using @mermaid skill where appropriate

IMPORTANT: End your response with an AGENT_RESULT block."
)
```

**For `backend`:**
```
Task(
  subagent_type="claude-marto-toolkit:backend-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Design backend architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

{IF_RESEARCH_EXISTS}
CODEBASE RESEARCH: {research-doc-path}
{/IF_RESEARCH_EXISTS}

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/backend-design-{feature-name}-{date}.md
- Include API specifications, data models, and sequence diagrams using @mermaid skill where appropriate

IMPORTANT: End your response with an AGENT_RESULT block."
)
```

**For `frontend`:**
```
Task(
  subagent_type="claude-marto-toolkit:frontend-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Design frontend architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

{IF_RESEARCH_EXISTS}
CODEBASE RESEARCH: {research-doc-path}
{/IF_RESEARCH_EXISTS}

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/frontend-design-{feature-name}-{date}.md
- Include component hierarchy diagrams and user flow diagrams using @mermaid skill where appropriate

IMPORTANT: End your response with an AGENT_RESULT block."
)
```

**Wait for completion.** Update state file: set `design_document` to the output path, set `awaiting` to `principal_review`.

### Step 3: Invoke Principal Architect Review

Once the design document is created, spawn the principal architect to review it. **Pass ALL original context documents** to enable thorough requirements tracing:

```
Task(
  subagent_type="claude-marto-toolkit:principal-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Review the design document that was just created.

DESIGN DOCUMENT TO REVIEW:
{path-from-step-1}

ORIGINAL CONTEXT DOCUMENTS (PRD, specs, requirements, related designs):
$REMAINING_ARGUMENTS

DESIGN LEVEL: {system|backend|frontend} (based on architect type used in Step 1)

REVIEW INSTRUCTIONS:
1. Read the design document created by the architect
2. Read ALL original context documents provided above - these are your source of truth for requirements
3. Check for CLAUDE.md in the project root for project-specific principles
4. Trace each design element back to requirements in the context documents
5. Apply your review framework based on the design level (system/backend/frontend)
6. Create feedback document at: docs/design/feedback/{original-filename}-feedback.md
7. Include requirements alignment table showing coverage of original requirements
8. Include a clear verdict: APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED

IMPORTANT: The context documents above are the SAME documents the architect received. Use them to verify the design fully addresses the stated requirements.

IMPORTANT: End your response with an AGENT_RESULT block including the verdict.

Return:
- Path to the design document
- Path to the feedback document
- The verdict
- Summary of requirements coverage"
)
```

**After completion:** Update state file: set `current_verdict` to the verdict, set `feedback_document` to the output path.

### Step 4: Revision Loop (Until Approved)

Based on the principal architect's verdict, handle accordingly:

#### If APPROVED

The loop ends. Update state file: set `current_verdict` to `approved`.

1. Read the design document
2. Add an approval section at the top (after the title/header):

```markdown
## Approval Status

✅ **APPROVED** - {date}

[Principal Architect Review]({relative-path-to-feedback-document})
```

3. Proceed to Step 5 (Report Results)

#### If APPROVED WITH CONDITIONS

The design is fundamentally sound but needs targeted updates. Re-invoke the same architect type to apply the required changes:

```
Task(
  subagent_type="claude-marto-toolkit:{architect-type}-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Update your design document based on principal architect feedback.

CURRENT DESIGN DOCUMENT:
{path-to-design-document}

PRINCIPAL ARCHITECT FEEDBACK:
{path-to-feedback-document}

ORIGINAL CONTEXT (PRD, specs, requirements):
$REMAINING_ARGUMENTS

INSTRUCTIONS:
1. Read the current design document
2. Read the principal architect feedback carefully
3. Address ONLY the conditions listed in the 'Conditions for Approval' section
4. Do NOT redesign from scratch - make targeted updates to resolve the specific conditions
5. Update the design document in place (same file path)
6. Note which conditions were addressed at the end of the document

IMPORTANT: End your response with an AGENT_RESULT block.

Return the path to the updated design document."
)
```

After the architect completes, update state file: increment `iteration`, set `awaiting` to `principal_review`.

Then **re-invoke the principal architect** (repeat Step 3) to re-review the updated design.

Continue this loop until the verdict is APPROVED.

#### If REVISION REQUIRED

The design has fundamental issues and needs significant rework. Ask the user which architect should perform the revision:

```
AskUserQuestion(
  questions=[{
    "question": "The principal architect requires revision of the design. Which architect should address the feedback?",
    "header": "Architect",
    "options": [
      {"label": "Same architect ({type})", "description": "Use the same architect type that created the original design"},
      {"label": "System architect", "description": "For fundamental system-level issues"},
      {"label": "Backend architect", "description": "For API, database, or service-layer issues"},
      {"label": "Frontend architect", "description": "For UI, component, or state management issues"}
    ],
    "multiSelect": false
  }]
)
```

Once the user selects an architect, re-invoke that architect with full context:

```
Task(
  subagent_type="claude-marto-toolkit:{selected-architect}-architect",
  prompt="[WORKFLOW:{WORKFLOW_ID}]

Revise the design based on principal architect feedback.

CURRENT DESIGN DOCUMENT (for reference):
{path-to-design-document}

PRINCIPAL ARCHITECT FEEDBACK:
{path-to-feedback-document}

ORIGINAL CONTEXT (PRD, specs, requirements):
$REMAINING_ARGUMENTS

CRITICAL/MAJOR ISSUES TO ADDRESS:
{list critical and major issues from feedback}

INSTRUCTIONS:
1. Read the principal architect feedback document thoroughly
2. Read the original PRD and requirements
3. Address ALL critical issues - these are blocking
4. Address ALL major issues - these create significant tech debt if ignored
5. You may choose to address minor issues at your discretion
6. Create a revised design document (update in place at the same path)
7. Include a 'Revision Notes' section documenting what changed and why

IMPORTANT: End your response with an AGENT_RESULT block.

Return the path to the revised design document."
)
```

After the architect completes, update state file: increment `iteration`, set `awaiting` to `principal_review`.

Then **re-invoke the principal architect** (repeat Step 3) to re-review the revised design.

Continue this loop until the verdict is APPROVED.

**Loop Safeguard:** If the revision loop exceeds 3 iterations without reaching APPROVED, pause and ask the user:

```
AskUserQuestion(
  questions=[{
    "question": "The design has gone through 3 revision cycles without approval. How would you like to proceed?",
    "header": "Action",
    "options": [
      {"label": "Continue revising", "description": "Attempt another revision cycle"},
      {"label": "Force approve", "description": "Accept the current design despite outstanding issues"},
      {"label": "Abort", "description": "Stop the spec process and review manually"}
    ],
    "multiSelect": false
  }]
)
```

### Step 5: Report Results to User

Provide a summary including:

1. **Design Document Created**
   - Path to the design document
   - Brief summary of what was designed
   - Approval status badge: ✅ APPROVED

2. **Review History** (if revisions occurred)
   - Number of revision cycles
   - Summary of major changes made during revision

3. **Design Review Completed**
   - Path to the feedback document (final approval)
   - Summary of any informational notes

4. **Next Steps**
   - "Ready for implementation planning. Run: `@implementation-planner {design-doc-path}`"

## Example Usage

```bash
# System-level design from a PRD
/spec system docs/prd/user-auth-prd.md

# Backend design with inline context
/spec backend "Design an API for user authentication with OAuth2 support. Must integrate with existing PostgreSQL database."

# Frontend design with multiple inputs
/spec frontend docs/design/backend-design-auth.md "Create React components for login, registration, and password reset flows"

# System design with multiple documents
/spec system docs/prd/dashboard-prd.md docs/research/codebase-analysis.md "Focus on real-time data streaming architecture"
```

## Error Messages

**No arguments:**
```
Error: No arguments provided.

Usage: /spec <architect-type> <context>

Where:
  <architect-type>  One of: system, backend, frontend
  <context>         PRD files, design documents, or description of what to design

Examples:
  /spec system docs/prd/feature.md
  /spec backend "Design REST API for user management"
  /spec frontend docs/design/backend-api.md "Create React components for the API"
```

**Invalid architect type:**
```
Error: Invalid architect type '{provided}'.

Valid architect types are:
  system   - High-level system architecture (service boundaries, data flow, scalability)
  backend  - Backend design (APIs, databases, security, reliability)
  frontend - Frontend design (UI components, accessibility, performance)

Usage: /spec <architect-type> <context>

Example: /spec backend docs/prd/user-api.md
```

**No context provided:**
```
Error: No context provided after architect type.

Usage: /spec {type} <context>

Please provide one or more of:
  - Path to PRD or requirements document
  - Path to existing design documents (for cross-referencing)
  - Inline description of what to design

Example: /spec {type} docs/prd/feature.md "Additional context here"
```

## Directory Management

The design and feedback directories may not exist. Create them as needed:

```bash
mkdir -p docs/design
mkdir -p docs/design/feedback
```

## Critical Boundaries

**Input Requirements:**
- First argument must be a valid architect type
- At least one form of context (document or inline description) must be provided

**Workflow Requirements:**
- Design agent MUST complete before invoking principal architect
- Principal architect MUST receive both the design document AND original requirements/PRD
- Revision loop MUST continue until APPROVED verdict is received (or user aborts)
- Design document MUST be updated with approval status once APPROVED
- Both documents (design + feedback) MUST be saved before reporting to user

**Revision Loop Requirements:**
- APPROVED: Add approval status section to design doc, then report results
- APPROVED WITH CONDITIONS: Re-invoke SAME architect type to apply targeted updates, then re-review
- REVISION REQUIRED: Ask user which architect should revise, re-invoke that architect, then re-review
- Loop safeguard triggers after 3 iterations without approval

**DO NOT:**
- Skip the principal architect review step
- Skip the revision loop when verdict is not APPROVED
- Proceed with invalid architect type
- Invoke principal architect without a completed design document
- Report success without APPROVED verdict (unless user force-approves)
- Report success without approval status added to design document
