---
model: claude-opus-4-5
---

# Spec Command

Create and review architectural designs using specialized architect agents, followed by principal architect review.

## Input

$ARGUMENTS

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

## Workflow

### Step 1: Invoke Design Architect

Based on the parsed architect type, spawn the appropriate design agent:

**For `system`:**
```
Task(
  subagent_type="claude-marto-toolkit:system-architect",
  prompt="Design a system architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Check if a codebase research document exists - if not and this is not a greenfield project, spawn @deep-code-research first
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/system-design-{feature-name}-{date}.md
- Include architecture diagrams using @mermaid skill where appropriate"
)
```

**For `backend`:**
```
Task(
  subagent_type="claude-marto-toolkit:backend-architect",
  prompt="Design backend architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Check if a codebase research document exists - if not and this is not a greenfield project, spawn @deep-code-research first
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/backend-design-{feature-name}-{date}.md
- Include API specifications, data models, and sequence diagrams using @mermaid skill where appropriate"
)
```

**For `frontend`:**
```
Task(
  subagent_type="claude-marto-toolkit:frontend-architect",
  prompt="Design frontend architecture based on the following requirements and context:

$REMAINING_ARGUMENTS

IMPORTANT:
- If a CLAUDE.md file exists in the project root, read it first for project-specific architectural principles
- Check if a codebase research document exists - if not and this is not a greenfield project, spawn @deep-code-research first
- Output your design as a markdown document with clear sections
- Save the design document to: docs/design/frontend-design-{feature-name}-{date}.md
- Include component hierarchy diagrams and user flow diagrams using @mermaid skill where appropriate"
)
```

Wait for the design agent to complete and capture the path to the generated design document.

### Step 2: Invoke Principal Architect Review

Once the design document is created, spawn the principal architect to review it. **Pass ALL original context documents** to enable thorough requirements tracing:

```
Task(
  subagent_type="claude-marto-toolkit:principal-architect",
  prompt="Review the design document that was just created.

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

Return:
- Path to the design document
- Path to the feedback document
- The verdict
- Summary of requirements coverage"
)
```

### Step 3: Report Results to User

Provide a summary including:

1. **Design Document Created**
   - Path to the design document
   - Brief summary of what was designed

2. **Design Review Completed**
   - Path to the feedback document
   - Verdict: APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED
   - Summary of critical/major findings (if any)

3. **Next Steps**
   - If APPROVED: "Ready for implementation planning. Run: `@implementation-planner {design-doc-path}`"
   - If APPROVED WITH CONDITIONS: "Address the conditions noted in the feedback, then proceed to implementation planning."
   - If REVISION REQUIRED: "Review the feedback and re-run `/spec {type}` with revised requirements, or manually invoke the architect to address specific issues."

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
- Both documents (design + feedback) MUST be saved before reporting to user

**DO NOT:**
- Skip the principal architect review step
- Proceed with invalid architect type
- Invoke principal architect without a completed design document
- Report success without providing paths to both output documents
