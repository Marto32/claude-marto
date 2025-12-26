# Claude Marto Agent Toolkit

A structured agent system for long-running software development with session continuity and GitHub Issues integration.

## Overview

This toolkit solves a fundamental problem with AI-assisted development: **context windows are finite, but projects are not**. 

When Claude runs out of context mid-project, it loses track of what's done, what's remaining, and what state the code is in. This system creates persistent artifacts that survive across sessions, enabling coherent multi-session development.

**Key Principle:** GitHub Issues are the source of truth. Local files are synced working copies that agents read/write during sessions.

## Architecture

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
     │   @cook   │      │   @ic4    │      │ @verifier │
     │ orchestrate│      │ implement │      │  verify   │
     └───────────┘      └───────────┘      └───────────┘
                               │
                               ▼ ./github-sync.sh push-status (session end)
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Issues Updated                       │
│  Issue #1: ✓ closed    Issue #2: status:verified → closed      │
└─────────────────────────────────────────────────────────────────┘
```

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
  → @cook (orchestrates the full workflow)
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
```

### Typical Workflow

```
Day 1 (Setup):
  @initializer  →  Creates 50-200 GitHub Issues

Day 2+ (Development loop):
  @cook  →  Picks next feature
    └→ @deep-code-research (if needed)
    └→ @ic4  →  Implements feature
    └→ @verifier  →  Verifies & closes issue

Repeat until all issues closed.
```

### New Agents (in this toolkit)

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **@initializer** | Set up new project with GitHub Issues | First session of new project |
| **@retrofitter** | Add tracking to existing project | Adopting mid-development |
| **@cook** | Orchestrate with session protocols | Main development workflow |
| **@verifier** | End-to-end verification | After implementing a feature |

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
    │    @cook      │ ── Reads feature_index.json
    └───────┬───────┘    Picks highest priority feature
            │
            ▼
    ┌───────────────┐
    │@deep-code-    │ ── Analyzes relevant code
    │   research    │    (if existing code)
    └───────┬───────┘
            │
            ▼
    ┌───────────────┐
    │    @ic4       │ ── Implements feature
    └───────┬───────┘    Writes tests
            │
            ▼
    ┌───────────────┐
    │  @verifier    │ ── Runs verification steps
    └───────┬───────┘    Captures screenshots
            │            Updates GitHub Issue
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
    │    @cook      │ ── Reads progress, picks next feature
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
            ▼                     ▼
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
│   │   ├── cook.md                     # Design-to-implementation orchestrator
│   │   ├── initializer.md              # New project setup
│   │   └── retrofitter.md              # Existing project adoption
│   └── quality/
│       └── verifier.md                 # End-to-end verification
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
├── verification/
│   └── screenshots/
└── src/                          # Your code
```

## Related Documentation

- [Agent Harness Recommendations](./docs/agent-harness-recommendations.md) - Full analysis and rationale
- [Patches for Existing Agents](./docs/patches-for-existing-agents.md) - How to update your current agents
- [Scripts](./scripts/) - github-sync.sh (copy to projects) and init.sh.template (reference only)
- [Templates](./templates/) - File format templates