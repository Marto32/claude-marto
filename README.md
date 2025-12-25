# Claude Marto Toolkit

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
                               ▼ ./github-sync.sh pull
┌─────────────────────────────────────────────────────────────────┐
│                        Local Files                              │
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
                               ▼ ./github-sync.sh push-status
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Issues Updated                       │
│  Issue #1: ✓ closed    Issue #2: status:verified → closed      │
└─────────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

```bash
# Install GitHub CLI
brew install gh  # macOS
# or: https://cli.github.com/

# Authenticate
gh auth login
```

### From Local Path

```bash
/plugin install /path/to/claude-marto
```

### From GitHub

```bash
/plugin install github:username/claude-marto
```

### Via Project Settings

Add to your project's `.claude/settings.json`:

```json
{
  "plugins": {
    "installed": [
      {
        "name": "claude-marto-toolkit",
        "source": "github:username/claude-marto"
      }
    ]
  }
}
```

### Verify Installation

```bash
/help
```

You should see the `/code-explain` command listed and can invoke agents like `@system-architect`.

## Quick Start

### New Project

```bash
# 1. Create/clone your repo
git clone https://github.com/you/my-project && cd my-project

# 2. Run @initializer with your design doc
# (In Claude) "Initialize this project for long-running development"

# 3. Start developing
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

# 3. Continue developing as normal
```

## Agents

Invoke with `@agent-name` in Claude Code.

### Which Agent When?

| Situation | Agent |
|-----------|-------|
| Starting a brand new project | `@initializer` |
| Adding tracking to existing project | `@retrofitter` |
| Implementing the next feature | `@cook` → `@ic4` |
| Verifying a feature works | `@verifier` |
| Understanding existing code | `@deep-code-research` |
| Requirements are unclear | `@requirements-analyst` |
| Designing a system/feature | `@prototype-designer`, `@backend-architect`, `@frontend-architect` |

### Orchestration

| Agent | Description |
|-------|-------------|
| `@initializer` | First-run project setup, creates GitHub Issues |
| `@retrofitter` | Add session tracking to existing projects |
| `@cook` | Design-to-implementation orchestrator with session protocols |

### Engineering

| Agent | Description |
|-------|-------------|
| `@system-architect` | System architecture and scalability design |
| `@backend-architect` | Backend systems, APIs, and database design |
| `@frontend-architect` | UI/UX, accessibility, and frontend performance |
| `@prototype-designer` | Single-machine prototype design and rapid POCs |
| `@ic4` | Implementation orchestrator with tests and session protocol |
| `@unit-test-specialist` | Comprehensive unit testing with 95%+ coverage |

### Quality

| Agent | Description |
|-------|-------------|
| `@verifier` | End-to-end verification with browser automation |
| `@security-engineer` | Security vulnerabilities and compliance |
| `@performance-engineer` | Performance optimization and bottleneck analysis |
| `@refactoring-expert` | Code quality and technical debt reduction |

### Analysis

| Agent | Description |
|-------|-------------|
| `@requirements-analyst` | Requirements discovery and PRD creation |
| `@deep-research-agent` | Comprehensive research and investigation |
| `@deep-code-research` | Deep codebase analysis for design and implementation |
| `@tech-stack-researcher` | Technology choices and architecture planning |

### Communication

| Agent | Description |
|-------|-------------|
| `@learning-guide` | Code explanation and programming education |
| `@technical-writer` | Technical documentation creation |

## Workflows

### Typical Development Loop

```
Session Start:
  ./github-sync.sh pull
  cat feature_index.json
  ./init.sh

Development:
  @cook  →  Picks next feature
    └→ @deep-code-research (if needed)
    └→ @ic4  →  Implements feature
    └→ @verifier  →  Verifies & closes issue

Session End:
  git commit
  ./github-sync.sh push-status
```

### Parallel Backend + Frontend

```
@backend-architect  ──┬──  @ic4 (backend)  ──┐
                      │                       ├──  @verifier
@frontend-architect ──┴──  @ic4 (frontend) ──┘
```

## Session Protocols

### Session Start (Mandatory)

```bash
./github-sync.sh pull           # Sync from GitHub
cat feature_index.json          # Check status
head -40 claude-progress.txt    # Recent history
./init.sh                       # Start environment
```

### Session End (Mandatory)

```bash
git add . && git commit -m "Session N: [summary]"
./github-sync.sh push-status    # Update GitHub labels
./github-sync.sh close-verified # Close completed issues
```

## File Reference

| File | Purpose | How to Read |
|------|---------|-------------|
| `feature_index.json` | Quick status (<50 lines) | `cat feature_index.json` |
| `feature_list.json` | All features with details | `jq` filters only |
| `claude-progress.txt` | Session history | `head -40` |

## Skills & Commands

### Skills

| Skill | Description |
|-------|-------------|
| `skill-creator` | Guide for creating effective Claude skills |

### Commands

| Command | Description |
|---------|-------------|
| `/code-explain` | Code explanation with diagrams and learning paths |

## Directory Structure

```
claude-marto/
├── agents/
│   ├── orchestration/     # @cook, @initializer, @retrofitter
│   ├── engineering/       # @ic4, @backend-architect, etc.
│   ├── quality/           # @verifier, @security-engineer, etc.
│   ├── analysis/          # @deep-code-research, etc.
│   └── communication/     # @learning-guide, @technical-writer
├── skills/
│   └── skill-creator/
├── commands/
│   └── code-explain.md
└── README.md
```

## Key Rules

| Rule | Wrong | Right |
|------|-------|-------|
| One feature at a time | "Implement features 1-10" | Implement #1 → verify → close → then #2 |
| Verify before closing | Mark done because code looks complete | Run @verifier → screenshots → close |
| Always sync | Start working without syncing | `./github-sync.sh pull` first |
| Clean state | Leave uncommitted changes | Commit everything at session end |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `gh: command not found` | `brew install gh` or [cli.github.com](https://cli.github.com/) |
| Not authenticated | `gh auth login` |
| Files out of sync | `./github-sync.sh pull` |
| Context running out | Commit WIP, add notes to claude-progress.txt |

## License

MIT License
