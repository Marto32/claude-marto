# Claude Marto Agent Toolkit

A structured agent system for **human-in-the-loop design and development** with session continuity and GitHub Issues integration.

## Overview

This toolkit solves a fundamental problem with AI-assisted development: **context windows are finite, but projects are not**.

When Claude runs out of context mid-project, it loses track of what's done, what's remaining, and what state the code is in. This system creates persistent artifacts that survive across sessions, enabling coherent multi-session development.

**Key Principle:** GitHub Issues are the source of truth. Local files are synced working copies that agents read/write during sessions.

**Design Philosophy:** Human-in-the-loop at every stage. Architects produce designs for human review. Implementation plans are approved before execution. Code reviews catch issues before merge.

## Two Commands to Rule Them All

Most workflows use just two commands:

### `/spec` — Design with Auto-Review

```bash
/spec <type> <context>
```

Creates an architectural design and automatically reviews it for quality.

| Type | What It Designs |
|------|-----------------|
| `system` | High-level architecture (service boundaries, data flow, scalability) |
| `backend` | APIs, databases, security, reliability patterns |
| `frontend` | UI components, accessibility, state management |

**What happens:**
1. Spawns the appropriate architect agent (@system-architect, @backend-architect, or @frontend-architect)
2. Architect creates design doc → `docs/design/{type}-design-{name}-{date}.md`
3. Automatically spawns @principal-architect to review the design
4. Review produces feedback → `docs/design/feedback/{name}-feedback.md`
5. Returns verdict: **APPROVED** / **APPROVED WITH CONDITIONS** / **REVISION REQUIRED**

```bash
# Examples
/spec system docs/prd/user-auth.md
/spec backend "Design REST API for user management with OAuth2"
/spec frontend docs/design/backend-api.md "Create React components"
```

### `/cook` — Execute Implementation Plan

```bash
/cook <implementation-plan.md>
```

Executes an implementation plan end-to-end with TDD and auto-review.

**What happens:**
1. Parses the implementation plan (from @implementation-planner)
2. Spawns @deep-code-research to understand the codebase
3. Spawns @unit-test-specialist for each task (writes failing tests first)
4. Spawns @ic4 agents for each task (implements until tests pass)
5. Spawns @verifier to confirm everything works
6. Automatically runs code review on completed work

**Architecture note:** The `/cook` command orchestrates at the main thread level. All spawned agents are "leaf workers" that do their own work without spawning sub-agents (Claude Code limitation).

```bash
# Example
/cook docs/implementation_plans/implementation-plan-auth-2024-01-15.md
```

### The Complete Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  /spec system docs/prd/feature.md                                       │
│     └→ Creates system design + auto-review                              │
│                                                                         │
│  /spec backend docs/design/system-design.md                             │
│     └→ Creates backend design + auto-review                             │
│                                                                         │
│  /spec frontend docs/design/system-design.md                            │
│     └→ Creates frontend design + auto-review                            │
│                                                                         │
│  @implementation-planner docs/design/backend-design.md                  │
│     └→ Creates implementation plan with atomic tasks                    │
│                                                                         │
│  /cook docs/implementation_plans/plan.md                                │
│     └→ Implements everything with TDD + auto code review                │
└─────────────────────────────────────────────────────────────────────────┘
```

## Walkthrough: Building a Task API from Scratch

Here's a complete example of building a working app with this toolkit.

### Step 1: Write Your PRD

```bash
mkdir -p docs/prd
```

Create a simple requirements doc at `docs/prd/task-api.md`:

```markdown
## Task Management API

### Requirements
- Users can create, read, update, delete tasks
- Tasks have: title, description, status (todo/in-progress/done), due date
- REST API with JSON responses
- SQLite database for simplicity
- Basic input validation

### Non-Functional
- Response time < 200ms
- Handle 100 concurrent users
```

### Step 2: Design the System

```bash
/spec system docs/prd/task-api.md
```

**What happens:**
1. @system-architect creates `docs/design/system-design-task-api-*.md`
2. @principal-architect reviews and creates `docs/design/feedback/*-feedback.md`
3. Returns verdict — review both files before proceeding

### Step 3: Design the Backend

```bash
/spec backend docs/prd/task-api.md docs/design/system-design-task-api-*.md
```

**What happens:**
1. @backend-architect creates `docs/design/backend-design-task-api-*.md` with:
   - API endpoints (GET/POST/PUT/DELETE /tasks)
   - Database schema
   - Error handling patterns
2. @principal-architect reviews against the PRD
3. Returns verdict — approve or request changes

### Step 4: Create Implementation Plan

```bash
@implementation-planner docs/design/backend-design-task-api-*.md
```

**Output:** `docs/implementation_plans/implementation-plan-task-api-*.md`

```markdown
1.0 Database Layer [SEQUENTIAL]
  1.1 Create SQLite schema [S]
  1.2 Create Task model [S]
  1.3 Create TaskRepository [M]

2.0 API Layer [SEQUENTIAL after 1.0]
  2.1 Create Express app setup [S]
  2.2 Implement POST /tasks [M]
  2.3 Implement GET /tasks [S]
  ...
```

Review and approve the plan before proceeding.

### Step 5: Build It

```bash
/cook docs/implementation_plans/implementation-plan-task-api-*.md
```

**What happens:**
1. @cook orchestrates everything
2. @ic4 writes tests first, then implements each task
3. @verifier confirms the API works
4. Code review runs automatically
5. Returns working code with tests

### Step 6: Ship It

```bash
git add .
git commit -m "Implement Task Management API"
```

### What You Get

```
my-task-app/
├── docs/
│   ├── prd/task-api.md                      # Requirements
│   ├── design/
│   │   ├── system-design-task-api-*.md      # Architecture
│   │   ├── backend-design-task-api-*.md     # API design
│   │   └── feedback/*-feedback.md           # Review feedback
│   ├── implementation_plans/
│   │   └── implementation-plan-*.md         # Task breakdown
│   └── code_review/review-*.md              # Code review
├── src/
│   ├── models/task.js
│   ├── repositories/taskRepository.js
│   ├── routes/tasks.js
│   └── app.js
├── tests/
│   ├── models/task.test.js
│   ├── repositories/taskRepository.test.js
│   └── routes/tasks.test.js
└── package.json
```

### Shorter Workflows

**Skip system design for smaller features:**
```bash
/spec backend "Add a /health endpoint that returns {status: 'ok'}"
@implementation-planner docs/design/backend-design-health-*.md
/cook docs/implementation_plans/implementation-plan-health-*.md
```

**Use @ic4 directly for tiny changes:**
```bash
@ic4 "Add a createdAt timestamp to the Task model. Write tests first."
```

## Architecture

### Flattened Agent Architecture

**Key constraint:** Sub-agents cannot spawn other sub-agents in Claude Code. All orchestration happens at the slash command level.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SLASH COMMANDS (Orchestrators)               │
│         /cook                              /spec                │
│    (main thread)                      (main thread)             │
└──────────┬────────────────────────────────┬─────────────────────┘
           │                                │
           ▼                                ▼
┌──────────────────────────────┐  ┌──────────────────────────────┐
│    LEAF AGENTS (No Spawning) │  │    LEAF AGENTS (No Spawning) │
│                              │  │                              │
│  @deep-code-research         │  │  @deep-code-research         │
│  @unit-test-specialist       │  │  @system-architect           │
│  @ic4                        │  │  @backend-architect          │
│  @verifier                   │  │  @frontend-architect         │
│                              │  │  @principal-architect        │
└──────────────────────────────┘  └──────────────────────────────┘
```

### Tool Selection (LSP-First)

All agents prefer LSP tools when available for accurate code navigation:
- `mcp__lsp__go_to_definition` → Falls back to Grep + Read
- `mcp__lsp__find_references` → Falls back to Grep for symbol
- `mcp__lsp__workspace_symbols` → Falls back to Glob + Grep

### GitHub Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Issues                            │
│                      (Source of Truth)                          │
│  Issue #1: User login ✓    Issue #2: Password reset (open)     │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼ ./github-sync.sh pull (session start)
┌─────────────────────────────────────────────────────────────────┐
│                        Local Files                              │
│                      (Working Copy)                             │
│  feature_list.json │ feature_index.json │ claude-progress.txt  │
└──────────────────────────────┬──────────────────────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
     ┌───────────┐      ┌───────────┐      ┌───────────┐
     │   /cook   │      │   @ic4    │      │ @verifier │
     │ orchestrate│      │ implement │      │  verify   │
     └───────────┘      └───────────┘      └───────────┘
                               │
                               ▼ ./github-sync.sh push-status (session end)
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Issues Updated                       │
│  Issue #1: ✓ closed    Issue #2: status:verified → closed      │
└─────────────────────────────────────────────────────────────────┘
```

## Design-to-Implementation Workflow

This toolkit is designed for **human-in-the-loop development**. Each stage produces artifacts for human review before proceeding.

### The Full Pipeline (Large Features)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: HIGH-LEVEL ARCHITECTURE                                            │
│ Agent: @system-architect                                                    │
│ Input: Requirements, feature request, or problem statement                  │
│ Output: System design document (architecture, components, data flow)        │
│ Human Review: ✓ Approve overall approach before detailed design             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌─────────────────────────────────┐ ┌─────────────────────────────────┐
│ STAGE 2A: BACKEND DESIGN        │ │ STAGE 2B: FRONTEND DESIGN       │
│ Agent: @backend-architect       │ │ Agent: @frontend-architect      │
│ Input: System design from above │ │ Input: System design from above │
│ Output: API specs, DB schemas   │ │ Output: Component specs, UI/UX  │
└─────────────────────────────────┘ └─────────────────────────────────┘
                    │                               │
                    └───────────────┬───────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 2C: DESIGN REVIEW                                                     │
│ Agent: @principal-architect                                                 │
│ Input: Design docs from 2A/2B + PRD                                         │
│ Output: Feedback in docs/design/feedback/ with verdict                      │
│ Human Review: ✓ Review findings, decide if revision needed                  │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ VERDICT: APPROVED           → Proceed to Stage 3                    │   │
│   │ VERDICT: APPROVED W/CONDITIONS → Fix conditions, then Stage 3       │   │
│   │ VERDICT: REVISION REQUIRED  → Human routes back to 2A/2B            │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 3: IMPLEMENTATION PLANNING                                            │
│ Agent: @implementation-planner                                              │
│ Input: Backend + Frontend design documents                                  │
│ Output: Hierarchical task checklist with IDs, deps, [PARALLEL]/[SEQUENTIAL]│
│ Human Review: ✓ Approve implementation plan before coding begins           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 4: EXECUTION                                                          │
│ Command: /cook <implementation-plan.md>                                     │
│ Spawns: @deep-code-research → @unit-test-specialist → @ic4 → @verifier     │
│ Output: Working code with tests, verification report                        │
│ Human Review: ✓ Code review runs automatically after implementation         │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 5: CODE REVIEW                                                        │
│ Command: /code-review (runs automatically after /cook)                      │
│ Agent: @pragmatic-code-review                                               │
│ Output: Review saved to docs/code_review/                                   │
│ Human Review: ✓ Address any critical issues before merge                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Smaller Features (Skip System Architecture)

For features that don't need high-level system design:

```
@backend-architect or @frontend-architect
           │
           ▼
@principal-architect (review)
           │
     ┌─────┴─────┐
     │           │
  APPROVED    REVISION
     │        REQUIRED
     ▼           │
@implementation-planner ←──┘ (human routes back)
           │
           ▼
/cook <implementation-plan.md>
           │
           ▼
Automatic code review
```

### Single Component (Use Agents Directly)

For simple, isolated changes:

```
@ic4 (with task details)
  └→ Uses @Explore to understand codebase
  └→ Uses @unit-test-specialist for TDD
  └→ Implements until tests pass
```

### Workflow Commands

| Command | Purpose |
|---------|---------|
| `/spec <type> <context>` | Create design + auto-review (type: system/backend/frontend) |
| `/cook <plan.md>` | Execute implementation plan + code review |
| `/code-review` | Review current branch changes |

### Key Agents by Stage

| Stage | Agent | Purpose |
|-------|-------|---------|
| Architecture | @system-architect | High-level system design |
| Design | @backend-architect | APIs, databases, services |
| Design | @frontend-architect | UI components, accessibility |
| Design Review | @principal-architect | Critique designs, validate against PRD |
| Planning | @implementation-planner | Break design into atomic tasks |
| Execution | /cook | Orchestrate implementation (command, not agent) |
| Execution | @ic4 | Implementation (receives tests, makes them pass) |
| Quality | @verifier | End-to-end verification |
| Quality | @pragmatic-code-review | Code review with Pragmatic Quality framework |

## Prerequisites

```bash
# Install GitHub CLI
brew install gh  # macOS
# or: https://cli.github.com/

# Authenticate
gh auth login

# Verify
gh auth status
```

## Installation

### Adding to Your Existing Agent Toolkit

If you have an existing Claude agent repo:

```bash
# 1. Copy new agents to your agents directory
cp -r agents/orchestration/* /path/to/your-toolkit/agents/orchestration/
cp -r agents/quality/* /path/to/your-toolkit/agents/quality/

# 2. Copy scripts and templates
cp -r scripts/* /path/to/your-toolkit/scripts/
cp -r templates/* /path/to/your-toolkit/templates/

# 3. Copy documentation
cp -r docs/* /path/to/your-toolkit/docs/

# 4. Apply patches to existing agents (see docs/patches-for-existing-agents.md)
```

### Starting Fresh

If starting a new toolkit:

```bash
# Just use this directory structure as-is
git clone https://github.com/you/claude-marto-toolkit
```

## Quick Start

### New Project

```bash
# 1. Create/clone your repo
git clone https://github.com/you/my-project
cd my-project

# 2. Run @initializer with your design doc
# (In Claude) "Initialize this project for long-running development. Here's my design doc: [paste or attach]"

# 3. @initializer will:
#    - Create 50-200 GitHub Issues for features
#    - Set up labels (type:feature, priority:*, category:*)
#    - Install github-sync.sh
#    - Create local tracking files
#    - Set up init.sh

# 4. Start developing
./github-sync.sh pull    # Sync from GitHub
./init.sh                # Start environment
# (In Claude) "Implement the next feature"
```

### Existing Project

```bash
# 1. Navigate to your project
cd my-existing-project

# 2. Run @retrofitter
# (In Claude) "Retrofit this project for session continuity"

# 3. @retrofitter will:
#    - Survey existing code and GitHub Issues
#    - Normalize issue labels
#    - Create issues for features found in code
#    - Close issues for completed features
#    - Set up sync infrastructure

# 4. Continue developing as normal
```

## Agents

### Which Agent When?

```
"I'm starting a brand new project"
  → @initializer (creates GitHub Issues, sets up tracking)

"I have an existing project and want to add tracking"
  → @retrofitter (normalizes issues, adopts infrastructure)

"I need to implement the next feature"
  → /cook (command that orchestrates the full workflow)
  → or @ic4 directly (if you know exactly what to build)

"I need to verify a feature works end-to-end"
  → @verifier (browser automation, screenshots, closes issue)

"I need to understand existing code first"
  → @deep-code-research (before implementing)

"Requirements are unclear"
  → @requirements-analyst (before designing)

"I need to design a system/feature"
  → @prototype-designer (general architecture)
  → @backend-architect (APIs, databases)
  → @frontend-architect (UI, components)

"I have a design and want it reviewed before implementation"
  → @principal-architect (critiques design, outputs feedback with verdict)
```

### Typical Workflow

```
Day 1 (Setup):
  @initializer  →  Creates 50-200 GitHub Issues

Day 2+ (Development loop):
  /cook <plan.md>  →  Executes implementation plan
    └→ @deep-code-research (understand codebase)
    └→ @unit-test-specialist (write tests first)
    └→ @ic4 (implement until tests pass)
    └→ @verifier (verify & close issue)

Repeat until all issues closed.
```

### New Agents (in this toolkit)

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **@initializer** | Set up new project with GitHub Issues | First session of new project |
| **@retrofitter** | Add tracking to existing project | Adopting mid-development |
| **@verifier** | End-to-end verification | After implementing a feature |
| **@principal-architect** | Review and critique designs | After design, before implementation |
| **@unit-test-specialist** | Write comprehensive tests | TDD red phase (before implementation) |

**Note:** `/cook` is a **command**, not an agent. It orchestrates agents at the main thread level.

### Your Existing Agents

These work with the system. See [patches-for-existing-agents.md](./docs/patches-for-existing-agents.md) for integration updates.

| Agent | Integration Notes |
|-------|-------------------|
| **@deep-code-research** | No changes needed |
| **@ic4** | Add one-feature-at-a-time rule |
| **@requirements-analyst** | No changes needed |
| **@prototype-designer** | No changes needed |
| **@backend-architect** | No changes needed |
| **@frontend-architect** | No changes needed |
| **@dsa** | No changes needed |
| **@unit-test-specialist** | No changes needed |
| **@technical-writer** | No changes needed |
| **@code-reviewer** | Review code quality | No changes needed |

## Workflows

### Workflow 1: New Project from Design Doc

```
User provides design document
            │
            ▼
    ┌───────────────┐
    │ @initializer  │ ── Creates GitHub Issues
    └───────┬───────┘    Sets up infrastructure
            │
            ▼
    ┌───────────────┐
    │    /cook      │ ── Command orchestrates:
    └───────┬───────┘
            │
    ┌───────┴───────────────────────┐
    │                               │
    ▼                               ▼
┌───────────────┐           ┌───────────────┐
│@deep-code-    │           │@unit-test-    │
│   research    │           │  specialist   │
└───────┬───────┘           └───────┬───────┘
        │                           │
        └───────────┬───────────────┘
                    ▼
            ┌───────────────┐
            │    @ic4       │ ── Implements until
            └───────┬───────┘    tests pass
                    │
                    ▼
            ┌───────────────┐
            │  @verifier    │ ── Runs verification
            └───────┬───────┘    Captures screenshots
                    │
                    ▼
            Issue closed ✓
            Next feature...
```

### Workflow 2: Continue Existing Project

```bash
# Session Start (ALWAYS do this first)
./github-sync.sh pull          # Get latest from GitHub
cat feature_index.json         # See status
head -40 claude-progress.txt   # See recent history
./init.sh                      # Start environment
```

```
# In Claude
"Continue implementing features"

    ┌───────────────┐
    │    /cook      │ ── Command orchestrates implementation
    └───────┬───────┘
            │
            ▼
    (implementation workflow as above)
```

```bash
# Session End (ALWAYS do this)
git add . && git commit -m "Session N: Implemented feature X"
./github-sync.sh push-status   # Update GitHub labels
./github-sync.sh close-verified # Close completed issues
```

### Workflow 3: Single Feature Implementation

```
User: "Implement user authentication"
            │
            ▼
    ┌───────────────┐
    │@deep-code-    │ ── Check existing auth code
    │   research    │
    └───────┬───────┘
            │
            ▼
    ┌───────────────┐
    │  @prototype-  │ ── Design auth system
    │   designer    │
    └───────┬───────┘
            │
            ▼
    ┌───────────────┐
    │    @ic4       │ ── Implement auth
    └───────┬───────┘
            │
            ▼
    ┌───────────────┐
    │  @verifier    │ ── Test login flow
    └───────────────┘
```

### Workflow 4: Complex Feature with Backend + Frontend

```
User: "Build a real-time dashboard"
            │
            ├─────────────────────┐
            ▼                     ▼
    ┌───────────────┐     ┌───────────────┐
    │  @backend-    │     │  @frontend-   │
    │  architect    │     │  architect    │
    └───────┬───────┘     └───────┬───────┘
            │                     │
            └─────────┬───────────┘
                      ▼
              ┌───────────────┐
              │  @principal-  │ ── Review designs
              │   architect   │    Output: feedback + verdict
              └───────┬───────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
      APPROVED    APPROVED      REVISION
         │        W/COND.       REQUIRED
         │            │            │
         └────────────┼────────────┘
                      ▼
              Human decides:
              - Proceed → @implementation-planner
              - Revise  → back to architects
                      │
                      ▼
    ┌───────────────┐     ┌───────────────┐
    │    @ic4       │     │    @ic4       │
    │  (backend)    │     │  (frontend)   │
    └───────┬───────┘     └───────┬───────┘
            │                     │
            └─────────┬───────────┘
                      ▼
              ┌───────────────┐
              │  @verifier    │
              └───────────────┘
```

## File Reference

### feature_index.json
**Purpose:** Quick status overview (always small, read first)

```json
{
  "totals": { "total": 50, "completed": 12, "remaining": 38 },
  "next_priority": { "id": 13, "title": "Password reset" },
  "categories": {
    "authentication": { "total": 5, "done": 5 },
    "user-management": { "total": 10, "done": 7 }
  }
}
```

### feature_list.json
**Purpose:** All incomplete features (synced from GitHub)

```json
{
  "source": "github",
  "features": [
    {
      "id": 13,
      "github_issue": 13,
      "github_url": "https://github.com/you/repo/issues/13",
      "title": "Password reset",
      "verification_steps": ["Navigate to /forgot", "Enter email", "..."],
      "passes": false
    }
  ]
}
```

### claude-progress.txt
**Purpose:** Human-readable session history

```
# QUICK STATUS
Total: 50 | Done: 12 | Remaining: 38 | Progress: 24%
NEXT FEATURE: #13 - Password reset

## Session History
### Session 005 - 2025-01-15
Completed: #12 - Email verification
Next: #13 - Password reset
```

### github-sync.sh
**Purpose:** Sync between GitHub Issues and local files

```bash
./github-sync.sh pull           # GitHub → local
./github-sync.sh push-status    # Add verified labels
./github-sync.sh close-verified # Close completed issues
./github-sync.sh status         # Show sync status
```

## Session Protocols

### Session Start (Mandatory)

Every session MUST begin with:

```bash
# 1. Sync from GitHub
./github-sync.sh pull

# 2. Check status
cat feature_index.json

# 3. Read recent history
head -40 claude-progress.txt

# 4. Check git state
git log --oneline -10

# 5. Start environment
./init.sh
```

### Session End (Mandatory)

Every session MUST end with:

```bash
# 1. Commit changes
git add .
git commit -m "Session N: [summary]"

# 2. If feature verified, close on GitHub (source of truth)
gh issue edit <id> --add-label "status:verified"
gh issue close <id> --comment "Verified in commit $(git rev-parse --short HEAD)"

# 3. Sync to regenerate local files
./github-sync.sh pull

# 4. Append session notes to claude-progress.txt
# (Manual append — this is the only local-only data)

# 5. Verify clean state
git status
```

## GitHub Labels

| Label | Purpose |
|-------|---------|
| `type:feature` | Identifies feature issues |
| `priority:1` | Highest priority (do first) |
| `priority:2` | High priority |
| `priority:3` | Normal priority |
| `category:*` | Groups related features |
| `status:verified` | Verified complete |
| `status:in-progress` | Currently being worked on |
| `status:blocked` | Blocked by dependency |

## Key Rules

### One Feature at a Time
```
❌ WRONG: "Implement features 1-10"
✅ RIGHT: "Implement feature #1" → verify → close → then #2
```

### Verify Before Closing
```
❌ WRONG: Mark done because code looks complete
✅ RIGHT: Run @verifier → capture screenshots → then close
```

### Always Sync
```
❌ WRONG: Start working without syncing
✅ RIGHT: ./github-sync.sh pull first, always
```

### Clean State at Session End
```
❌ WRONG: Leave uncommitted changes
✅ RIGHT: Commit everything, sync to GitHub, clean state
```

## Troubleshooting

### "gh: command not found"
```bash
# Install GitHub CLI
brew install gh  # macOS
sudo apt install gh  # Ubuntu
# Or download from https://cli.github.com/
```

### "Not authenticated"
```bash
gh auth login
# Follow prompts, choose HTTPS
```

### Files out of sync with GitHub
```bash
./github-sync.sh pull  # Force sync from GitHub
```

### Feature marked complete but shouldn't be
```bash
# Reopen on GitHub
gh issue reopen ISSUE_NUMBER

# Re-sync locally
./github-sync.sh pull
```

### Context window running out mid-feature
```bash
# Commit partial progress
git add .
git commit -m "WIP: Feature #X - [what's done]"

# Update progress notes
# Add to claude-progress.txt: "PARTIAL - remaining work: ..."

# Next session will pick up from WIP
```

## Example: Full Project Lifecycle

```bash
# === Day 1: Project Setup ===
git clone https://github.com/me/my-saas
cd my-saas

# In Claude: "Initialize this project. Design doc: [attached]"
# @initializer creates 75 GitHub Issues, sets up infrastructure

# === Day 2: First Features ===
./github-sync.sh pull
./init.sh
# In Claude: "Implement the next feature"
# @cook → @ic4 → @verifier
# Features #1, #2, #3 completed

# === Day 5: Mid-Project ===
./github-sync.sh pull
cat feature_index.json  # 15 done, 60 remaining
# In Claude: "Continue"
# More features implemented

# === Day 10: New Developer Joins ===
# They run:
./github-sync.sh pull
cat feature_index.json  # Instant overview
head -40 claude-progress.txt  # Recent history
# Can immediately continue where team left off

# === Day 20: Project Complete ===
./github-sync.sh status
# All 75 issues closed ✓
```

## Toolkit Structure

```
claude-marto-toolkit/
├── README.md                           # This file
├── agents/
│   ├── orchestration/
│   │   ├── initializer.md              # New project setup
│   │   └── retrofitter.md              # Existing project adoption
│   └── quality/
│       ├── principal-architect.md      # Design review and critique
│       └── verifier.md                 # End-to-end verification
├── commands/
│   ├── spec.md                         # /spec - Create design + auto-review
│   ├── cook.md                         # /cook - Execute implementation plan (orchestrator)
│   └── code-review.md                  # /code-review - Review branch changes
├── scripts/
│   ├── github-sync.sh                  # GitHub ↔ local sync (copy to projects)
│   └── init.sh.template                # Reference only (agents generate project-specific)
├── templates/
│   ├── feature_list.template.json      # Feature tracking format
│   ├── feature_index.template.json     # Quick status format
│   └── claude-progress.template.txt    # Progress log format
└── docs/
    ├── agent-harness-recommendations.md  # Full analysis & rationale
    └── patches-for-existing-agents.md    # Updates for existing agents
```

## Project Structure (After Setup)

After running @initializer or @retrofitter, your project will have:

```
my-project/
├── github-sync.sh                # Copied from toolkit
├── init.sh                       # Generated for this project
├── feature_list.json             # Synced from GitHub
├── feature_index.json            # Quick status
├── claude-progress.txt           # Session history
├── .github/
│   └── ISSUE_TEMPLATE/
│       └── feature.md            # Feature issue template
├── .claude/
│   └── archives/
│       └── completed_features.json
├── docs/
│   └── design/
│       └── feedback/             # Design review output from @principal-architect
├── verification/
│   └── screenshots/
└── src/                          # Your code
```

## Related Documentation

- [Agent Harness Recommendations](./docs/agent-harness-recommendations.md) - Full analysis and rationale
- [Patches for Existing Agents](./docs/patches-for-existing-agents.md) - How to update your current agents
- [Scripts](./scripts/) - github-sync.sh (copy to projects) and init.sh.template (reference only)
- [Templates](./templates/) - File format templates