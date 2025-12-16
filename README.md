# My Claude Code Configuration

This directory contains my personal Claude Code setup including skills, agents, commands, and other configuration files.

## Directory Structure

```
~/.claude/
├── skills/           # Agent Skills (model-invoked)
├── agents/           # Subagents (user-invoked)
├── commands/         # Slash commands (user-invoked)
├── hooks/            # Event handlers
└── settings.json     # Configuration file
```

## What Goes Where?

### Skills (`skills/`)
**Model-invoked** - Claude automatically uses these when relevant to your task.

- Each skill is a folder with a `SKILL.md` file
- Claude reads these dynamically based on task context
- Include YAML frontmatter with `name` and `description`
- Best for: domain expertise, procedural knowledge, workflows

**Example structure:**
```
skills/
└── my-skill/
    ├── SKILL.md           # Main instructions
    ├── scripts/           # Optional executables
    ├── references/        # Optional documentation
    └── assets/            # Optional resources
```

**Learn more:**
- [Agent Skills Guide](https://code.claude.com/docs/en/skills)
- [Agent Skills Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Skills Explained](https://claude.com/blog/skills-explained)

### Agents (`agents/`)
**User-invoked** - You explicitly call these with `@agent-name` or via commands.

- Specialized AI assistants with their own context and tool permissions
- Operate independently and return results
- Best for: discrete tasks, specific workflows, parallel workers

**Example:**
```markdown
# agents/code-reviewer.md

You are a code review specialist focused on security and quality.
Your role is to review pull requests and provide actionable feedback...
```

**Learn more:**
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents)

### Commands (`commands/`)
**User-invoked** - You type `/command-name` to trigger these.

- Saved prompts that start workflows
- Can invoke agents for structured tasks
- Best for: frequently-used workflows, quick shortcuts

**Example:**
```markdown
# commands/review.md
---
description: Review code for security and quality issues
---

Please review the code in this repository for security vulnerabilities
and code quality issues. Provide actionable feedback.
```

**Learn more:**
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)

### Hooks (`hooks/`)
Event handlers that trigger automatically on certain actions.

**Learn more:**
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)

## Quick Reference: When to Use What?

| Need | Use |
|------|-----|
| Auto-triggered expertise | **Skill** |
| Explicit task delegation | **Agent** |
| Quick workflow shortcut | **Command** |
| Shared across projects | **Skill** |
| Specific tool permissions | **Agent** |
| Frequently typed prompt | **Command** |

## Key Principles

1. **Skills teach, Agents execute** - If multiple agents need the same knowledge, make it a skill
2. **All are markdown** - Same format, different invocation patterns
3. **Portable and shareable** - Copy/paste between projects or share with team
4. **Descriptions matter** - For skills especially, clear descriptions help Claude know when to use them

## Installation & Plugins

You can install pre-built skills, agents, and commands via plugins:

```bash
# Add a marketplace
/plugin marketplace add anthropics/skills

# Browse available plugins
/plugin

# Install a plugin
/plugin install plugin-name@marketplace-name
```

**Learn more:**
- [Plugins Guide](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

## Useful Resources

### Official Documentation
- [Claude Code Docs](https://code.claude.com/docs)
- [Claude Developer Platform](https://docs.claude.com)
- [Anthropic Skills Cookbook](https://github.com/anthropics/skills)

### Community Resources
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Model Context Protocol (MCP)](https://code.claude.com/docs/en/mcp)

### Tips & Best Practices
- Start with evaluation - identify gaps before building
- Keep skills modular and focused
- Use progressive disclosure in SKILL.md files
- Test changes incrementally
- Only use trusted sources for plugins

## Getting Started

1. **Create your first skill:**
   ```bash
   mkdir -p ~/.claude/skills/my-skill
   # Edit SKILL.md with your instructions
   ```

2. **Test it:**
   Ask Claude something that matches your skill's description

3. **Verify it loaded:**
   ```bash
   /skills list
   ```

## Notes

- Files are discovered automatically - no restart needed (usually)
- Skills can include executable Python/shell scripts
- Agents can invoke skills during their work
- Commands can invoke agents for planning
- Everything works together as a system

---

*Last updated: December 2024*