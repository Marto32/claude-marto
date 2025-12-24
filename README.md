# Claude Marto Toolkit

A comprehensive Claude Code plugin providing specialized subagents, skills, and commands for software development workflows.

## Installation

### From Local Path

If you have this repository cloned locally:

```bash
/plugin install /path/to/claude-marto
```

### From GitHub

```bash
/plugin install github:username/claude-marto
```

### Via Project Settings

Add directly to your project's `.claude/settings.json`:

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

### Installation Scopes

| Scope | Location | Behavior |
|-------|----------|----------|
| `user` | `~/.claude/settings.json` | Available in all projects (default) |
| `project` | `.claude/settings.json` | Shared with team via git |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |

```bash
# Install to specific scope
/plugin install /path/to/claude-marto --scope user
/plugin install /path/to/claude-marto --scope project
/plugin install /path/to/claude-marto --scope local
```

### Verify Installation

After installing, verify with:
```bash
/help
```

You should see the `/code-explain` command listed and can invoke agents like `@system-architect`.

## What's Included

### Agents (16 specialized subagents)

Invoke with `@agent-name` in Claude Code:

| Agent | Description | Category |
|-------|-------------|----------|
| `@system-architect` | System architecture and scalability design | Engineering |
| `@backend-architect` | Backend systems, APIs, and database design | Engineering |
| `@frontend-architect` | UI/UX, accessibility, and frontend performance | Engineering |
| `@prototype-designer` | Single-machine prototype design and rapid POCs | Engineering |
| `@ic4` | Implementation orchestrator with tests and documentation | Engineering |
| `@cook` | Design-to-implementation orchestrator with research and verification | Orchestration |
| `@security-engineer` | Security vulnerabilities and compliance | Quality |
| `@performance-engineer` | Performance optimization and bottleneck analysis | Quality |
| `@refactoring-expert` | Code quality and technical debt reduction | Quality |
| `@requirements-analyst` | Requirements discovery and PRD creation | Analysis |
| `@deep-research-agent` | Comprehensive research and investigation | Analysis |
| `@deep-code-research` | Deep codebase analysis for design and implementation | Analysis |
| `@tech-stack-researcher` | Technology choices and architecture planning | Analysis |
| `@learning-guide` | Code explanation and programming education | Communication |
| `@technical-writer` | Technical documentation creation | Communication |
| `@unit-test-specialist` | Comprehensive unit testing with 95%+ coverage | Engineering |

### Skills

| Skill | Description |
|-------|-------------|
| `skill-creator` | Guide for creating effective Claude skills with templates and validation |

The skill-creator skill includes:
- `init_skill.py` - Initialize new skill directories with templates
- `package_skill.py` - Package skills into distributable .skill files
- `quick_validate.py` - Validate skill structure and frontmatter

### Commands

| Command | Description |
|---------|-------------|
| `/code-explain` | Comprehensive code explanation with visual diagrams, step-by-step breakdowns, and learning paths |

## Directory Structure

```
claude-marto/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── agents/                    # Specialized subagents
│   ├── backend-architect.md
│   ├── cook.md
│   ├── deep-code-research.md
│   ├── deep-research-agent.md
│   ├── frontend-architect.md
│   ├── ic4.md
│   ├── learning-guide.md
│   ├── performance-engineer.md
│   ├── prototype-designer.md
│   ├── refactoring-expert.md
│   ├── requirements-analyst.md
│   ├── security-engineer.md
│   ├── system-architect.md
│   ├── tech-stack-researcher.md
│   ├── technical-writer.md
│   └── unit-test-specialist/
├── skills/
│   └── skill-creator/         # Skill creation toolkit
│       ├── SKILL.md
│       ├── scripts/
│       └── references/
├── commands/
│   └── code-explain.md        # Code explanation command
└── README.md
```

## Usage Examples

### Using Agents

```
@system-architect Design a scalable microservices architecture for an e-commerce platform
```

```
@security-engineer Review this authentication implementation for vulnerabilities
```

```
@refactoring-expert Help me reduce technical debt in the user service module
```

### Using Skills

The skill-creator skill activates automatically when you ask Claude to help create a new skill:

```
Help me create a new skill for PDF processing
```

### Using Commands

```
/code-explain src/auth/jwt.ts
```

## Resources

- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Agent Skills Guide](https://code.claude.com/docs/en/skills)
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)

## License

MIT License
