---
name: dsa
description: "A catalog of reusable data structure and algorithm patterns for solving recurring software problems. Use when agents need to: (1) Select appropriate data structures for specific access patterns, (2) Choose algorithmic strategies for problem classes, (3) Understand trade-offs between different approaches, (4) Apply proven patterns to new contexts. Emphasizes understanding intent and consequences over implementation details."
---

# Data Structures & Algorithms: A Pattern Catalog

## Preface

This catalog documents proven patterns for organizing data and solving computational problems. Like architectural patterns in building design, these patterns represent distilled wisdom from decades of software engineering practice.

Each pattern addresses a recurring problem, describes its core solution, and explains the trade-offs involved. The goal is not to memorize implementations, but to develop judgment about when and why to apply each pattern.

**Philosophy**

1. **Understand intent before implementation** - Know what problem a pattern solves
2. **Recognize the forces at play** - Performance, memory, complexity, maintainability
3. **Weigh consequences explicitly** - Every pattern has trade-offs
4. **Prefer proven solutions** - Use well-tested libraries over custom implementations
5. **Match pattern to context** - The "best" pattern depends on your constraints

## How to Use This Catalog

### Pattern Format

Each pattern follows a consistent structure:

- **Intent**: The fundamental problem this pattern addresses
- **Motivation**: A concrete scenario illustrating the need
- **Applicability**: When to use this pattern
- **Structure**: How the pattern works conceptually
- **Consequences**: Benefits and liabilities
- **Implementation Notes**: Practical considerations
- **Related Patterns**: Patterns that complement or substitute

### Navigation

The catalog is organized into three sections:

1. **Structural Patterns** (`references/data-structures.md`)
   Patterns for organizing and accessing data: arrays, hash tables, trees, graphs, and specialized structures.

2. **Algorithmic Patterns** (`references/algorithms.md`)
   Strategies for processing data: divide and conquer, dynamic programming, greedy methods, and graph traversal.

3. **Computational Patterns** (`references/problem-patterns.md`)
   Tactical techniques for specific problem classes: two pointers, sliding window, memoization, and backtracking.

## Quick Reference

### When Data Access Drives the Design

| Primary Operation | Consider | See Pattern |
|-------------------|----------|-------------|
| Key-based lookup | Hash Table | Structural: Hash-Based |
| Ordered traversal | Balanced Tree | Structural: Tree-Based |
| Priority extraction | Heap | Structural: Priority Queue |
| Range queries | Segment Tree | Structural: Specialized |
| Prefix/substring matching | Trie | Structural: Specialized |
| Dynamic connectivity | Union-Find | Structural: Specialized |

### When Algorithm Strategy Drives the Design

| Problem Characteristic | Consider | See Pattern |
|------------------------|----------|-------------|
| Overlapping subproblems | Dynamic Programming | Algorithmic: DP |
| Optimal substructure, local choice | Greedy | Algorithmic: Greedy |
| Generate all possibilities | Backtracking | Algorithmic: Backtracking |
| Combine independent subproblems | Divide and Conquer | Algorithmic: D&C |
| Network/relationship structure | Graph Algorithms | Algorithmic: Graph |

### When Tactical Technique Drives the Design

| Situation | Consider | See Pattern |
|-----------|----------|-------------|
| Sorted array, find pair | Two Pointers | Computational |
| Contiguous subarray property | Sliding Window | Computational |
| Cumulative values | Prefix Sum | Computational |
| Next/previous greater element | Monotonic Stack | Computational |

## Core Principles

### Principle 1: Match Structure to Access Pattern

The choice of data structure should follow from how you need to access and modify data, not from the problem domain.

**Questions to ask:**
- What operations dominate? (insert, lookup, delete, iterate)
- What ordering is required? (none, insertion order, sorted order)
- What are the key types? (integers, strings, composite)
- Is the data static or dynamic?

### Principle 2: Recognize Algorithmic Signatures

Certain problem characteristics strongly suggest specific algorithmic approaches:

- **"Find optimal X subject to constraints"** → Often Dynamic Programming
- **"Make locally optimal choice at each step"** → Consider Greedy (verify correctness)
- **"Generate all valid configurations"** → Backtracking
- **"Process in dependency order"** → Topological Sort
- **"Find shortest/cheapest path"** → Graph shortest-path algorithms

### Principle 3: Understand the Trade-off Space

Every pattern exists in a trade-off space. Common dimensions:

| Dimension | Typical Trade-off |
|-----------|-------------------|
| Time vs. Space | Caching/memoization uses space to save time |
| Preprocessing vs. Query | Build index once to speed repeated queries |
| Simplicity vs. Efficiency | Simple algorithms often acceptable for small inputs |
| Generality vs. Performance | Specialized structures outperform general ones |

### Principle 4: Prefer Libraries to Custom Code

For any pattern with established library implementations:

1. **First choice**: Language standard library
2. **Second choice**: Well-maintained third-party library
3. **Last resort**: Custom implementation

Custom implementations are appropriate when:
- The algorithm is trivial (binary search, simple DFS)
- Requirements are highly specialized
- Educational purposes justify the effort
- No suitable library exists

## Pattern Selection Workflow

### Step 1: Characterize the Problem

Before selecting patterns, understand:

- **Input**: Size, type, distribution, mutability
- **Output**: What result is needed
- **Operations**: What transformations are applied
- **Constraints**: Time budget, space budget, other requirements

### Step 2: Identify Candidate Patterns

Based on problem characteristics:

1. What data structures naturally represent the entities?
2. What algorithmic strategy fits the problem structure?
3. What tactical techniques apply to subproblems?

### Step 3: Evaluate Trade-offs

For each candidate pattern:

1. Does it meet performance requirements?
2. Is implementation complexity justified?
3. Are library implementations available?
4. What are the failure modes?

### Step 4: Validate and Refine

Before committing to a pattern:

1. Work through examples manually
2. Consider edge cases
3. Verify correctness arguments
4. Profile if performance-critical

## Common Pitfalls

### Pitfall 1: Premature Pattern Selection

**Problem**: Choosing complex patterns before understanding the actual requirements.

**Solution**: Start with the simplest approach. Add complexity only when measurements demonstrate the need.

### Pitfall 2: Pattern Mismatch

**Problem**: Applying a pattern to a problem it wasn't designed for.

**Solution**: Verify that your problem matches the pattern's intent, not just its surface appearance.

### Pitfall 3: Ignoring Consequences

**Problem**: Adopting a pattern while ignoring its liabilities.

**Solution**: Every pattern has trade-offs. Ensure the liabilities are acceptable in your context.

### Pitfall 4: Reinventing the Wheel

**Problem**: Implementing complex patterns from scratch when libraries exist.

**Solution**: Search for existing implementations. The time saved and bugs avoided are usually worth any library overhead.

## Reading the Reference Materials

The reference documents provide detailed pattern descriptions. For each pattern, consider:

1. **Does the intent match my problem?** - If not, this pattern may not apply
2. **Does my context match the applicability criteria?** - Consider the forces at play
3. **Are the consequences acceptable?** - Evaluate both benefits and liabilities
4. **What related patterns might help?** - Often patterns work together

## Summary

Effective use of data structures and algorithms comes from:

1. **Pattern recognition** - Seeing problems through the lens of known patterns
2. **Trade-off analysis** - Understanding what you gain and lose with each choice
3. **Contextual judgment** - Matching patterns to specific requirements
4. **Pragmatic implementation** - Using libraries where appropriate, custom code where necessary

The patterns in this catalog are tools. Like any tools, their value comes from knowing when and how to apply them. Master the intent and consequences; implementation details will follow.
