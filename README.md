# Claude Marto Toolkit

A comprehensive Claude Code plugin providing specialized subagents, skills, and commands for software development workflows.

## Installation

```bash
/plugin install claude-marto-toolkit
```

Or install from source:
```bash
/plugin install /path/to/claude-marto
```

## What's Included

### Agents (11 specialized subagents)

Invoke with `@agent-name` in Claude Code:

| Agent | Description | Category |
|-------|-------------|----------|
| `@system-architect` | System architecture and scalability design | Engineering |
| `@backend-architect` | Backend systems, APIs, and database design | Engineering |
| `@frontend-architect` | UI/UX, accessibility, and frontend performance | Engineering |
| `@security-engineer` | Security vulnerabilities and compliance | Quality |
| `@performance-engineer` | Performance optimization and bottleneck analysis | Quality |
| `@refactoring-expert` | Code quality and technical debt reduction | Quality |
| `@requirements-analyst` | Requirements discovery and PRD creation | Analysis |
| `@deep-research-agent` | Comprehensive research and investigation | Analysis |
| `@tech-stack-researcher` | Technology choices and architecture planning | Analysis |
| `@learning-guide` | Code explanation and programming education | Communication |
| `@technical-writer` | Technical documentation creation | Communication |

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
│   ├── system-architect.md
│   ├── backend-architect.md
│   ├── frontend-architect.md
│   ├── tech-stack-researcher.md
│   ├── deep-research-agent.md
│   ├── security-engineer.md
│   ├── performance-engineer.md
│   ├── requirements-analyst.md
│   ├── refactoring-expert.md
│   ├── learning-guide.md
│   └── technical-writer.md
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
