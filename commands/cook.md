---
model: claude-opus-4-5
---

# Cook Command

Launch the Cook orchestration agent to implement design documents end-to-end.

## Input

$ARGUMENTS

The arguments above are paths to one or more design documents that need implementation.

## Instructions

Spawn the `@cook` agent (claude-marto-toolkit:cook) with the design documents provided in $ARGUMENTS.

The cook agent must follow this workflow:

1. **@deep-code-research** (MANDATORY FIRST) - Build comprehensive codebase context before any implementation
2. **@ic4** (SPAWN MULTIPLE) - Spawn as many implementation agents as needed, parallelizing independent work
3. **@unit-test-specialist** (via @ic4) - Create comprehensive unit tests with 95%+ coverage
4. **@verifier** (MANDATORY LAST) - Verify all implementations work correctly before closing

## Critical Boundaries

**DO NOT EVER IMPLEMENT ON YOUR OWN.**

You are an orchestrator. Your only job is to:
- Read design documents
- Spawn subagents to do the work
- Coordinate their outputs
- Ensure quality gates are met

If you find yourself writing implementation code directly, STOP. Spawn an @ic4 agent instead.

## Spawn Now

Launch the cook agent with the design documents:

```
Task(
  subagent_type="claude-marto-toolkit:cook",
  prompt="Implement the following design documents: $ARGUMENTS

  WORKFLOW REMINDERS:
  1. Spawn @deep-code-research FIRST to understand the codebase
  2. Spawn @ic4 agents for ALL implementation (parallelize when possible)
  3. @ic4 will use @unit-test-specialist for tests
  4. Spawn @verifier after implementation to confirm everything works

  DO NOT IMPLEMENT DIRECTLY - ONLY SPAWN SUBAGENTS."
)
```
