---
model: claude-opus-4-5
---

# Cook Command

Execute an implementation plan end-to-end by orchestrating specialized agents in sequence.

## Input

$ARGUMENTS

## Input Validation (MANDATORY)

**This command requires a SINGLE implementation plan document as input.**

Before proceeding, validate the input:

1. **Check argument count**: Must be exactly ONE file path
   - If zero arguments: "Error: No implementation plan provided. Please provide a path to an implementation plan document (output from @implementation-planner)."
   - If multiple arguments: "Error: Expected a single implementation plan, but received multiple paths. Please provide exactly one implementation plan document."

2. **Check file exists**: The file must exist at the provided path
   - If not found: "Error: Implementation plan not found at '{path}'. Please verify the path is correct."

3. **Validate file is an implementation plan**: The file must contain implementation plan structure
   - Check for "## Implementation Tasks" section
   - Check for task IDs (e.g., "1.1", "1.1.1")
   - Check for "Source Design:" header linking to design document
   - If missing: Return the invalid format error (see Error Messages below)

**DO NOT proceed if validation fails.** Return the appropriate error message and stop.

## Orchestration Architecture

**CRITICAL:** This command runs at the main Claude thread level and orchestrates ALL sub-agent spawning. Sub-agents cannot spawn other sub-agents - only this command can spawn agents.

```
/cook (main thread - orchestrator)
  │
  ├─► Phase 1: @deep-code-research (understand codebase)
  │
  ├─► Phase 2: @unit-test-specialist (write tests FIRST - parallelized per task)
  │
  ├─► Phase 3: @ic4 (implement until tests pass - parallelized per task)
  │
  ├─► Phase 4: @verifier (end-to-end verification)
  │
  └─► Phase 5: Report results
```

## Workflow

### Step 0: Parse Implementation Plan

Read the implementation plan and extract:
1. **Source design document path** from the header
2. **All task IDs** and their descriptions
3. **`[PARALLEL]` vs `[SEQUENTIAL]` markers** for execution order
4. **Dependencies** (`Deps:` fields)
5. **File paths** affected by each task
6. **Testing requirements** for each task

Build a task execution graph respecting dependencies.

### Step 1: Pre-Implementation Research

Spawn `@deep-code-research` to understand the codebase before any implementation:

```
Task(
  subagent_type="claude-marto-toolkit:deep-code-research",
  prompt="Analyze the codebase for implementing tasks from the following plan:

IMPLEMENTATION PLAN: $ARGUMENTS

SOURCE DESIGN: {extracted-design-doc-path}

FILES TO BE MODIFIED:
{list of all file paths from tasks}

Produce a comprehensive research document covering:
1. Existing code patterns in the affected files
2. Test patterns and conventions used in the project
3. Integration points and dependencies
4. Language, frameworks, and test runners used
5. Any potential conflicts with existing code

Save your research to: docs/research/codebase-research-{feature-name}-{date}.md"
)
```

**Wait for completion before proceeding.** Capture the research document path.

### Step 2: Write Tests First (TDD Red Phase)

For each implementation task, spawn `@unit-test-specialist` to write failing tests.

**Parallel Execution:** For tasks marked `[PARALLEL]` with no unmet dependencies, spawn multiple agents in a SINGLE message:

```
# Example: Tasks 1.1, 1.2, 1.3 are parallel with no deps
Task(
  subagent_type="claude-marto-toolkit:unit-test-specialist",
  prompt="Write comprehensive failing tests for Task 1.1: {description}

FILES: {file paths}
TEST REQUIREMENTS: {from plan}
CODEBASE CONTEXT: {research-doc-path}

Create tests that:
- Define expected behavior before implementation exists
- Cover happy path, edge cases, and error conditions
- Follow existing test patterns found in the research
- Target 95%+ coverage for this task's scope

The tests should FAIL initially - implementation doesn't exist yet.
Commit the tests with message: 'test(task-1.1): add failing tests for {description}'"
)
Task(
  subagent_type="claude-marto-toolkit:unit-test-specialist",
  prompt="Write comprehensive failing tests for Task 1.2: {description}..."
)
Task(
  subagent_type="claude-marto-toolkit:unit-test-specialist",
  prompt="Write comprehensive failing tests for Task 1.3: {description}..."
)
```

**Sequential Execution:** For tasks marked `[SEQUENTIAL]`, spawn one at a time:

```
Task(...task 2.1...)
[Wait for completion]
Task(...task 2.2...)
[Wait for completion]
```

**Track Progress:** After each @unit-test-specialist completes, mark the test-writing phase done for that task.

### Step 3: Implementation (TDD Green Phase)

After tests exist for a task, spawn `@ic4` to implement until tests pass.

**Parallel Execution:** Spawn multiple @ic4 agents in a SINGLE message for independent tasks:

```
Task(
  subagent_type="claude-marto-toolkit:ic4",
  prompt="Implement Task 1.1: {description}

FILES: {file paths}
TESTS: Tests already written at {test file paths}
CODEBASE CONTEXT: {research-doc-path}

Your job:
1. Run the existing failing tests to understand what's expected
2. Write minimal implementation to make tests pass
3. Run tests after each change - iterate until ALL GREEN
4. Refactor while keeping tests green
5. Commit with message: 'feat(task-1.1): implement {description}

Task: 1.1
Tests: All passing'"
)
Task(
  subagent_type="claude-marto-toolkit:ic4",
  prompt="Implement Task 1.2: {description}..."
)
```

**Respect Dependencies:** Only spawn @ic4 for a task after:
1. Its tests are written (Step 2 complete for this task)
2. All tasks in its `Deps:` list are implemented

**Track Progress:** Mark tasks `[x]` complete in the plan as @ic4 agents finish.

### Step 4: Post-Implementation Verification

After ALL implementation tasks complete, spawn `@verifier`:

```
Task(
  subagent_type="claude-marto-toolkit:verifier",
  prompt="Verify the implementation from this plan is complete and working:

IMPLEMENTATION PLAN: $ARGUMENTS
SOURCE DESIGN: {design-doc-path}

For each task:
1. Confirm tests exist and pass
2. Verify implementation matches design requirements
3. Run end-to-end verification if applicable
4. Check for regressions in existing features

Report:
- Pass/fail status per task
- Any issues found
- Screenshots if browser testing was performed"
)
```

### Step 5: Handle Verification Results

**If verification passes:**
1. Update the implementation plan marking all tasks `[x]` complete
2. List GitHub Issues ready to close (with commands)
3. Proceed to Step 6

**If verification fails:**
1. Identify which tasks failed
2. Spawn @ic4 to fix the specific issues:
   ```
   Task(
     subagent_type="claude-marto-toolkit:ic4",
     prompt="Fix verification failure for Task X.Y:

   FAILURE: {description of what failed}
   FILES: {affected files}

   Debug and fix the issue. Add additional test coverage if needed.
   Commit the fix."
   )
   ```
3. Re-run verification (repeat Step 4)

### Step 6: Report Results

Provide a summary including:

1. **Execution Summary**
   - Total tasks: X
   - Tests written: X (by @unit-test-specialist)
   - Implementations complete: X (by @ic4)
   - Verification: PASSED/FAILED

2. **Commits Made**
   - List of commits with hashes

3. **GitHub Issues Ready to Close**
   ```
   Issues Ready to Close:
   - Issue #15: Feature Name - Verified in commit abc123

   To close, run:
     gh issue close 15 --comment "Verified in commit abc123"
   ```

4. **Next Steps** (if any issues remain)

## Execution Patterns

### Fully Parallel Plan
When all root tasks are `[PARALLEL]` with `Deps: none`:
```
1. @deep-code-research
2. PARALLEL: @unit-test-specialist for all tasks (single message, multiple Task calls)
3. Wait for all tests
4. PARALLEL: @ic4 for all tasks (single message, multiple Task calls)
5. Wait for all implementations
6. @verifier
7. Report
```

### Mixed Parallel/Sequential
```
1. @deep-code-research
2. Spawn tests for tasks with Deps: none (may be parallel)
3. As test-writing completes, spawn @ic4 for those tasks
4. As tasks complete, spawn tests for newly unblocked tasks
5. Continue until all tasks complete
6. @verifier
7. Report
```

### Dependency Chain Example
```
Task 1.1 (Deps: none) → write tests → implement
Task 1.2 (Deps: 1.1) → [wait for 1.1] → write tests → implement
Task 1.3 (Deps: 1.1, 1.2) → [wait for 1.1 AND 1.2] → write tests → implement
```

## Critical Boundaries

**This command MUST:**
- Spawn @deep-code-research FIRST before any other agents
- Spawn @unit-test-specialist to write tests BEFORE spawning @ic4
- Spawn @ic4 only AFTER tests exist for that task
- Spawn @verifier only AFTER all @ic4 agents complete
- Respect `[PARALLEL]`/`[SEQUENTIAL]` markers from the plan
- Respect task dependencies (`Deps:` fields)
- Use SINGLE messages with multiple Task calls for parallel execution

**This command will NOT:**
- Allow sub-agents to spawn other sub-agents (architecture constraint)
- Skip the test-first phase (TDD is mandatory)
- Skip verification (quality gate is mandatory)
- Implement directly (only orchestrate agents)

## Error Messages

**No input:**
```
Error: No implementation plan provided.

Usage: /cook <path-to-implementation-plan>

Example: /cook docs/implementation_plans/implementation-plan-auth-2024-01-15.md

To create an implementation plan from a design document, run:
  @implementation-planner <path-to-design-document>
```

**Multiple inputs:**
```
Error: Expected a single implementation plan, but received multiple paths.

This command accepts exactly ONE implementation plan document.

Usage: /cook <path-to-implementation-plan>

If you have multiple implementation plans, execute them one at a time.
```

**File not found:**
```
Error: Implementation plan not found at '{path}'.

Please verify the file path is correct and the file exists.
```

**Invalid format:**
```
Error: '{path}' does not appear to be a valid implementation plan.

Valid implementation plans (from @implementation-planner) contain:
- "Source Design:" header linking to the design document
- "## Implementation Tasks" section
- Numbered task IDs (1.1, 1.1.1, etc.)
- [PARALLEL]/[SEQUENTIAL] execution markers
- Complexity tags [S], [M], [L]
- Dependencies (Deps: X.Y)

To create an implementation plan from a design document:
  @implementation-planner <path-to-design-document>
```
