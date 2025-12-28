# Computational Patterns

This section catalogs tactical patterns for specific problem classes. These patterns represent proven techniques that recur across many concrete problems, providing templates for recognition and solution.

---

## Sequence Manipulation Patterns

### Prefix Computation

**Intent**

Precompute cumulative values to answer range queries in constant time after linear preprocessing.

**Motivation**

Consider answering thousands of queries asking for the sum of elements between indices i and j in an array. Computing each sum from scratch requires linear time per query. By precomputing prefix sums once—where prefix[k] is the sum of all elements before index k—each range sum becomes a constant-time subtraction: sum(i, j) = prefix[j+1] - prefix[i].

**Applicability**

Use Prefix Computation when:
- Many range queries on static data
- Operation is associative (sum, XOR, product modulo)
- Range queries dominate updates
- Preprocessing time is acceptable

Avoid when:
- Data changes frequently between queries (consider Segment Tree)
- Few queries don't justify preprocessing
- Operation lacks inverse (min/max don't subtract cleanly)
- Memory for prefix array is prohibitive

**Structure**

1. Build prefix array: prefix[0] = identity, prefix[i] = prefix[i-1] ⊕ array[i-1]
2. Query range [i, j]: result = prefix[j+1] ⊕⁻¹ prefix[i]

**Consequences**

Benefits:
- O(n) preprocessing, O(1) queries
- Simple implementation
- Works for any invertible associative operation
- Memory overhead is just O(n)

Liabilities:
- Static data only (updates require rebuild)
- Doesn't work for non-invertible operations (min, max)
- Integer overflow risk with sums
- 2D/3D prefix structures grow more complex

**Implementation Notes**

For min/max range queries on static data, use Sparse Tables (O(n log n) preprocessing, O(1) query) instead. For dynamic data, Segment Trees handle updates efficiently.

**Related Patterns**

- *Segment Tree*: When updates are needed
- *Sparse Table*: For min/max on static data
- *Difference Array*: Dual technique for range updates

---

### Monotonic Ordering

**Intent**

Maintain a stack or queue preserving increasing/decreasing order to efficiently find next greater/smaller elements or sliding window extrema.

**Motivation**

Consider finding, for each element in an array, the index of the next greater element. Checking every subsequent element yields quadratic time. A monotonic decreasing stack tracks candidates: when a new element arrives, pop all smaller elements (they've found their answer) and push the new element. Each element enters and leaves the stack once, yielding linear time.

**Applicability**

Use Monotonic Ordering when:
- Finding next/previous greater/smaller elements
- Sliding window maximum/minimum
- Histogram-based problems (largest rectangle)
- Trapping rain water type problems

Avoid when:
- No "next greater/smaller" structure exists
- Random access to extrema is needed
- Problem requires different ordering semantics

**Structure**

Monotonic stack:
1. For each element, pop elements that violate ordering
2. Popped elements have found their "next" element
3. Push current element

Monotonic deque (for sliding window):
1. Remove elements outside window from front
2. Remove elements that can't be answers from back
3. Front contains window extremum

**Consequences**

Benefits:
- Linear time for next greater/smaller problems
- O(n) for sliding window extrema
- Constant extra space per element
- Elegant solution to specific problem class

Liabilities:
- Limited to monotonicity-preserving problems
- Less intuitive than brute force
- Direction of iteration matters
- Edge cases at array boundaries

**Implementation Notes**

Store indices rather than values to handle position-related requirements. For sliding window, a deque naturally supports both ends. Process order (left-to-right vs right-to-left) depends on whether you need "next" or "previous" elements.

**Related Patterns**

- *Sliding Window*: Often uses monotonic deque
- *Stack*: Underlying data structure
- *Two Pointers*: Alternative for some array problems

---

### In-Place Partitioning

**Intent**

Rearrange elements of an array in-place according to some criterion, using constant extra space.

**Motivation**

Consider separating an array into negative numbers followed by non-negative numbers without using extra space. Allocating a second array is wasteful. Using two pointers—one seeking negative numbers from the left, one seeking non-negatives from the right—elements can be swapped into position. The array is partitioned in a single pass with O(1) extra space.

**Applicability**

Use In-Place Partitioning when:
- Separating elements by some predicate
- Memory constraints prohibit copying
- Order within partitions doesn't matter (or use stable variant)
- Dutch national flag type problems

Avoid when:
- Relative order must be preserved (may need stable partition)
- Multiple complex predicates apply
- Non-destructive partitioning is required

**Structure**

Two-way partition:
1. Left pointer seeks elements that should be right
2. Right pointer seeks elements that should be left
3. Swap and continue until pointers meet

Three-way partition (Dutch National Flag):
1. Three regions: confirmed low, unknown, confirmed high
2. Classify each unknown element, swap into correct region
3. Continue until unknown region is empty

**Consequences**

Benefits:
- O(n) time, O(1) space
- Single pass through data
- Foundation for Quicksort
- Handles two or three partitions elegantly

Liabilities:
- Unstable (doesn't preserve relative order)
- Only handles 2-3 partitions easily
- Swapping has overhead for large elements
- Complex boundary conditions

**Implementation Notes**

For more than three partitions, use counting sort or stable partition approaches. The Dutch National Flag problem (0s, 1s, 2s) is the classic three-way example.

**Related Patterns**

- *Two Pointers*: Underlying technique
- *Quicksort*: Uses partitioning
- *Counting Sort*: For many distinct values

---

## Tree Traversal Patterns

### Recursive Tree Processing

**Intent**

Process tree structures by defining computation at each node in terms of its children's results.

**Motivation**

Consider computing the height of a binary tree. The height is 1 plus the maximum of the left and right subtree heights. This recursive definition matches the tree's structure perfectly. Each node need only compute its local contribution given its children's answers, and recursion handles the rest.

**Applicability**

Use Recursive Tree Processing when:
- Problem decomposes by subtrees
- Node computation depends on children (or ancestors)
- Tree structure is well-formed
- Stack depth is manageable

Avoid when:
- Very deep trees risk stack overflow
- Iterative traversal is more appropriate
- Non-tree structures (cycles) exist
- Performance requires avoiding function call overhead

**Structure**

Bottom-up (children inform parent):
1. Recursively process children
2. Combine children's results
3. Return current node's result

Top-down (parent informs children):
1. Process current node with inherited information
2. Pass information to children recursively
3. Combine results if needed

**Consequences**

Benefits:
- Natural match for tree structure
- Clean, readable code
- Handles complex properties elegantly
- Easy to reason about correctness

Liabilities:
- Stack overflow on deep trees
- Function call overhead
- May require careful state management
- Not always obvious which direction (up/down)

**Implementation Notes**

For very deep trees, convert to iterative with explicit stack. Many problems can be solved either bottom-up or top-down; choose based on what information flows naturally. Postorder for computing values from children; preorder for passing values to children.

**Related Patterns**

- *DFS*: Tree traversal is a form of DFS
- *Dynamic Programming*: DP on trees uses this structure
- *Divide and Conquer*: Conceptually similar decomposition

---

### Level-Order Processing

**Intent**

Process tree nodes grouped by their distance from the root, visiting all nodes at depth k before any at depth k+1.

**Motivation**

Consider finding the rightmost node at each level of a binary tree. Processing nodes level by level, the last node encountered at each level is the answer. BFS naturally provides this grouping, and tracking level boundaries allows per-level operations.

**Applicability**

Use Level-Order Processing when:
- Computation depends on depth or level
- Need to process nodes at same distance together
- Finding level extrema (leftmost, rightmost)
- Level-based aggregation

Avoid when:
- Depth information isn't relevant
- Recursive structure is more natural
- Memory for queue is problematic

**Structure**

1. Initialize queue with root (and marker or count for levels)
2. Process nodes by level:
   - For each node at current level, process and enqueue children
   - Advance level when current level exhausted

**Consequences**

Benefits:
- Natural level grouping
- O(n) time, O(width) space
- Simple iterative implementation
- Extends easily to multi-tree BFS

Liabilities:
- Queue space proportional to tree width
- Less natural for height/depth-dependent properties
- Extra bookkeeping for level boundaries
- Not inherently recursive (may be less elegant)

**Implementation Notes**

Track levels either with a sentinel/marker in the queue or by processing in batches (count nodes at each level). Zigzag and other variants modify the within-level processing order.

**Related Patterns**

- *BFS*: Level-order is BFS on trees
- *Queue*: Implementation substrate
- *Recursive Tree Processing*: Alternative approach

---

### Path Accumulation

**Intent**

Track or aggregate values along paths from root to leaves (or between arbitrary nodes).

**Motivation**

Consider finding whether any root-to-leaf path has a specified sum. As you traverse, maintain the cumulative sum. At each leaf, check if the sum matches the target. This avoids recomputing path sums from scratch—each path extension just adds the current node's value.

**Applicability**

Use Path Accumulation when:
- Path sums, products, or other aggregations
- Finding paths with specific properties
- Ancestor-to-descendant relationships
- Recording path history for backtracking

Avoid when:
- Paths between arbitrary nodes (may need LCA)
- No cumulative property is relevant
- Non-tree structure

**Structure**

1. Pass accumulated value down during traversal
2. At each node, update accumulation
3. At leaves or target nodes, check/record result
4. Optionally backtrack accumulation state

**Consequences**

Benefits:
- O(n) for single traversal
- Incremental updates avoid recomputation
- Natural for DFS traversal
- Handles various aggregation types

Liabilities:
- Backtracking state can be complex
- Not all properties accumulate nicely
- May need to track full path, not just aggregate
- Stack space for deep trees

**Implementation Notes**

For "all paths" problems, may need to copy path state or use backtracking carefully. For problems requiring any-to-any paths, precompute LCA or use different techniques.

**Related Patterns**

- *Prefix Computation*: Similar cumulative idea
- *Recursive Tree Processing*: Often combined
- *Backtracking*: For generating all paths

---

## Graph Analysis Patterns

### Connected Component Discovery

**Intent**

Partition a graph into groups of mutually reachable vertices.

**Motivation**

Consider determining the number of isolated networks in a system where connections are edges. Starting from any unvisited node, explore all reachable nodes (they form one component). Repeat for remaining unvisited nodes. Each exploration discovers one connected component.

**Applicability**

Use Connected Component Discovery when:
- Counting or enumerating components
- Determining if two nodes are in same component
- Island counting in grids
- Network partition analysis

Avoid when:
- Only need to know if specific pair is connected (Union-Find may be simpler)
- Graph structure changes frequently
- Components aren't the primary concern

**Structure**

DFS/BFS approach:
1. For each unvisited node, start new component
2. Explore all reachable nodes, marking them
3. Count or record component

Union-Find approach:
1. Initially, each node is its own component
2. For each edge, union the endpoints
3. Count distinct representatives

**Consequences**

Benefits:
- O(V + E) for DFS/BFS approach
- Naturally extends to counting, labeling, or sizing components
- Works for directed (strongly connected) or undirected graphs
- Reveals graph structure

Liabilities:
- Full graph traversal required
- Memory for visited tracking
- For dynamic graphs, Union-Find may be better
- Directed graphs need special handling (Tarjan, Kosaraju)

**Implementation Notes**

For undirected graphs, simple DFS suffices. For directed graphs, strongly connected components require Tarjan's or Kosaraju's algorithm. Grid problems are a special case with 4 or 8 neighbors.

**Related Patterns**

- *DFS/BFS*: Exploration mechanism
- *Union-Find*: Alternative for dynamic connectivity
- *Flood Fill*: Grid-specific variant

---

### Bipartite Verification

**Intent**

Determine whether a graph's vertices can be divided into two groups such that all edges cross between groups.

**Motivation**

Consider assigning students and projects where each edge represents compatibility. Can students form one group and projects another? This is possible if and only if the graph is bipartite—no odd cycles exist. A two-coloring attempt reveals whether such division is possible.

**Applicability**

Use Bipartite Verification when:
- Two-group assignment problems
- Conflict checking (can items be split with no conflicts within groups?)
- Graph matching preprocessing
- Detecting odd cycles

Avoid when:
- More than two groups needed
- Graph is known to be bipartite by construction
- Only cycle detection is needed (simpler methods exist)

**Structure**

1. Start BFS/DFS from any node, color it 0
2. Color all neighbors with opposite color (1)
3. If neighbor already has same color, graph is not bipartite
4. Repeat for all components

**Consequences**

Benefits:
- O(V + E) time
- Simple modification of BFS/DFS
- Produces actual coloring if bipartite
- Identifies problematic edge if not bipartite

Liabilities:
- Full graph traversal
- Memory for color assignments
- Only handles two-partition case
- Doesn't help with optimal partition

**Implementation Notes**

Can use DFS or BFS; the coloring logic is the same. Must handle disconnected components by starting fresh for each.

**Related Patterns**

- *BFS/DFS*: Foundation technique
- *Graph Coloring*: Generalization to k colors
- *Connected Components*: Related structure discovery

---

### Cycle Detection

**Intent**

Determine whether a graph contains any cycles.

**Motivation**

Consider validating a dependency graph for a build system. If dependencies form a cycle, the build cannot complete. Detecting cycles during construction prevents invalid configurations. In directed graphs, a cycle appears when DFS encounters a node currently being processed.

**Applicability**

Use Cycle Detection when:
- Validating DAG property
- Detecting deadlocks in resource graphs
- Finding redundant constraints
- Prerequisite validation

Avoid when:
- Cycles are expected and acceptable
- Only topological order matters (detection is implicit)
- Graph is known to be acyclic by construction

**Structure**

Directed graph (three-color DFS):
1. White: unvisited, Gray: in current path, Black: complete
2. If DFS reaches Gray node, cycle exists
3. Node becomes Black when all descendants processed

Undirected graph:
1. Track parent during DFS
2. If neighbor is visited and not parent, cycle exists

**Consequences**

Benefits:
- O(V + E) time
- Naturally integrated with DFS
- Can identify cycle edges or nodes
- Immediate termination on detection

Liabilities:
- Directed vs undirected require different approaches
- Finding all cycles is more complex
- Only detects existence, not specific cycle (without more work)
- Need careful handling of multi-edges

**Implementation Notes**

For undirected graphs with Union-Find: a cycle exists if an edge connects nodes in the same set. Topological sort failure also indicates cycles in directed graphs.

**Related Patterns**

- *DFS*: Foundation technique
- *Topological Sort*: Fails if cycle exists
- *Union-Find*: Alternative for undirected

---

## Optimization Problem Patterns

### State Space DP

**Intent**

Model a problem as transitions between discrete states, computing optimal values by considering all possible transitions.

**Motivation**

Consider finding the minimum cost to paint n houses with k colors, where adjacent houses can't share colors. The state is (house index, color of current house). Transitions are choosing a different color for the next house. The minimum cost is the minimum over final states of the accumulated costs along transition paths.

**Applicability**

Use State Space DP when:
- Problem has clear discrete states
- Transitions between states are well-defined
- Optimal value of state depends only on reachable prior states
- State space is enumerable

Avoid when:
- State space is too large
- Continuous state variables
- No clear recurrence relation
- Greedy or simpler approach works

**Structure**

1. Define state: what information is needed?
2. Define transitions: how do states relate?
3. Define base cases: initial states
4. Define goal: which final states matter?
5. Compute in dependency order (topological or dimensional)

**Consequences**

Benefits:
- Systematic approach to optimization
- Guaranteed optimal (within state space)
- Clear structure for implementation
- Amenable to space optimization

Liabilities:
- State identification can be non-obvious
- State space explosion for complex problems
- Memory for storing state values
- Transition logic can be complex

**Implementation Notes**

Think carefully about what information is truly needed in the state—minimizing state dimension reduces complexity. Consider whether top-down (memoization) or bottom-up (tabulation) is more natural.

**Related Patterns**

- *Dynamic Programming*: This is DP's core technique
- *Memoization*: Top-down implementation
- *Topological Sort*: For computing in correct order

---

### Interval Merging

**Intent**

Combine overlapping or adjacent intervals into non-overlapping canonical form.

**Motivation**

Consider a calendar application receiving meeting requests as time intervals. To find free time, first merge all meetings: sort by start time, then combine any meetings that overlap or are adjacent. The result is a minimal set of intervals covering the same time.

**Applicability**

Use Interval Merging when:
- Combining overlapping ranges
- Finding total coverage
- Counting non-overlapping intervals
- Preprocessing for interval queries

Avoid when:
- Intervals are already disjoint
- Original interval identity matters
- No overlap processing needed

**Structure**

1. Sort intervals by start time
2. Initialize result with first interval
3. For each subsequent interval:
   - If overlaps with last in result, merge
   - Otherwise, add to result
4. Result contains merged intervals

**Consequences**

Benefits:
- O(n log n) due to sorting
- Linear merge pass after sort
- Produces minimal representation
- Simple and robust

Liabilities:
- Requires sorting (or sorted input)
- Merging loses original interval identity
- Doesn't handle weighted intervals
- Assumes intervals are on comparable scale

**Implementation Notes**

Overlap condition: interval B overlaps result's last if B.start ≤ last.end. Merging: new end is max(B.end, last.end). Consider whether endpoints are inclusive or exclusive.

**Related Patterns**

- *Sorting*: Preprocessing step
- *Sweep Line*: Alternative for complex interval problems
- *Greedy*: Interval scheduling often uses greedy

---

### Subset Selection

**Intent**

Find an optimal subset of items satisfying given constraints.

**Motivation**

Consider packing a knapsack with items of given weights and values, maximizing total value without exceeding weight capacity. This is the classic subset selection problem: which items to include? Dynamic programming over (item index, remaining capacity) states yields the optimal selection.

**Applicability**

Use Subset Selection when:
- Choosing which items to include
- Subject to budget, capacity, or count constraints
- Optimizing sum of selected item values
- Counting valid selections

Avoid when:
- All items must be used (not selection)
- Ordering matters (permutation, not subset)
- Continuous quantities (not discrete selection)
- Greedy provably works

**Structure**

0/1 Knapsack style:
1. State: (index, remaining capacity)
2. Transition: include or exclude item
3. Recurrence: max(include_value + subproblem, exclude_subproblem)
4. Base: no items or no capacity

**Consequences**

Benefits:
- Systematic exploration of combinations
- Polynomial time for pseudo-polynomial capacity
- Extensible to variations (bounded, unbounded)
- Produces actual selection via backtracking

Liabilities:
- Pseudo-polynomial: depends on capacity magnitude
- Exponential for large capacities
- Memory for DP table
- Not suitable for continuous capacities

**Implementation Notes**

Space optimization: keep only current and previous row. Unbounded variant (items reusable) has simpler structure. Counting variant changes max to sum.

**Related Patterns**

- *Dynamic Programming*: Implementation technique
- *Backtracking*: For generating all solutions
- *Greedy*: Approximation for some variants

---

### Sequence Alignment

**Intent**

Find the optimal way to match two sequences, allowing insertions, deletions, and substitutions.

**Motivation**

Consider comparing two DNA sequences to find evolutionary distance. Some positions match, some differ, and sequences may have insertions or deletions relative to each other. Edit distance (minimum operations to transform one to another) quantifies similarity. Dynamic programming on (position in first sequence, position in second) yields optimal alignment.

**Applicability**

Use Sequence Alignment when:
- Computing edit distance or similarity
- Finding longest common subsequence
- Diff algorithms for text comparison
- Bioinformatics sequence analysis

Avoid when:
- Sequences must match exactly
- Only existence of match matters (use hashing)
- Alignment isn't meaningful

**Structure**

1. State: (i, j) = subproblem for prefixes of length i and j
2. Transitions:
   - Match/mismatch: (i-1, j-1) + cost
   - Delete from first: (i-1, j) + cost
   - Delete from second: (i, j-1) + cost
3. Take minimum (or maximum for similarity)

**Consequences**

Benefits:
- O(nm) time and space for sequences of length n, m
- Produces optimal alignment
- Extensible to various cost models
- Well-understood problem

Liabilities:
- Quadratic in sequence lengths
- Memory for DP table (can optimize to linear for value only)
- Backtracking needed for actual alignment
- Various definitions of "optimal" exist

**Implementation Notes**

Space optimization: only need previous row for value computation. For actual alignment, either store full table or recompute path. Various scoring schemes exist (Levenshtein, Needleman-Wunsch, Smith-Waterman for local alignment).

**Related Patterns**

- *Dynamic Programming*: Core technique
- *Longest Common Subsequence*: Special case
- *Prefix Computation*: Similar 2D DP structure

---

## Search Space Patterns

### Exhaustive Enumeration

**Intent**

Generate all possible configurations of a combinatorial space to find valid or optimal solutions.

**Motivation**

Consider generating all permutations of a set. The space is factorial in size, and each permutation is a valid configuration. By systematically making choices (which element next?), undoing them (backtrack), and recording complete solutions, all permutations can be enumerated.

**Applicability**

Use Exhaustive Enumeration when:
- All solutions are needed
- Space is small enough to enumerate (≤ 20 items for 2^n, ≤ 10 for n!)
- No polynomial-time algorithm exists
- Validation or testing requires completeness

Avoid when:
- Only one solution is needed (unless enumeration is unavoidable)
- Space is too large
- Polynomial algorithm exists
- Approximation suffices

**Structure**

1. Define choice space at each step
2. For each choice:
   - Make choice (update state)
   - Recurse to next step
   - Undo choice (backtrack)
3. At complete configuration, record solution

**Consequences**

Benefits:
- Guaranteed completeness
- Finds all solutions
- Pruning can reduce practical runtime
- Template applies to many problems

Liabilities:
- Exponential or factorial worst case
- May be infeasible for large inputs
- Implementation must carefully undo state
- Output size may itself be exponential

**Implementation Notes**

Subsets: 2^n configurations (each element in or out). Permutations: n! configurations. Combinations: C(n,k) configurations. Use bitmasks for small n subsets.

**Related Patterns**

- *Backtracking*: Enumeration with pruning
- *Bit Manipulation*: For subset enumeration
- *Recursion*: Implementation technique

---

### Binary Decision

**Intent**

Model a problem as a sequence of binary (yes/no) decisions, enabling binary search on decision outcomes.

**Motivation**

Consider finding the minimum capacity needed for k workers to complete all jobs within a time limit. Directly computing the minimum is complex. Instead, for any capacity, you can check if it suffices. Binary search on capacity: if current capacity works, try smaller; if not, try larger. The minimum is the boundary where feasibility changes.

**Applicability**

Use Binary Decision when:
- "Find minimum X such that condition holds"
- Condition is monotonic (if X works, X+1 works)
- Checking condition is easier than optimizing directly
- Parameter space is ordered

Avoid when:
- Condition is not monotonic
- Optimization has direct solution
- Discrete candidates are few (linear scan may suffice)
- Parameter isn't searchable

**Structure**

1. Define search range [lo, hi]
2. Define feasibility check function
3. Binary search:
   - mid = (lo + hi) / 2
   - If feasible(mid), answer ≤ mid, search lower
   - Else answer > mid, search higher
4. Return boundary value

**Consequences**

Benefits:
- Reduces optimization to decision
- O(log range) checks
- Works when direct optimization is hard
- Often simpler to implement

Liabilities:
- Requires monotonic property
- Check function may be expensive
- Floating-point requires tolerance handling
- Range must be bounded

**Implementation Notes**

This is "binary search on answer" or "parametric search." The key insight is that feasibility is monotonic. Be careful with boundary conditions and integer/float handling.

**Related Patterns**

- *Binary Search*: Core technique
- *Greedy Verification*: Often used to check feasibility
- *Two Pointers*: Related technique for some problems

---

### Meet in the Middle

**Intent**

Split a large search space into two halves, enumerate each separately, then combine results efficiently.

**Motivation**

Consider finding subsets of a 40-element set whose sum equals a target. Enumerating all 2^40 subsets is infeasible. Instead, split into two 20-element sets. Enumerate all 2^20 subset sums for each half. For each sum in the first half, binary search for the complementary sum in the second. Total work is O(2^20 log 2^20), vastly smaller than 2^40.

**Applicability**

Use Meet in the Middle when:
- Full enumeration is just beyond feasible (2^n for n ≈ 40)
- Problem can be split into independent halves
- Combining half-solutions is efficient (sorting + search)
- Optimization or counting over combinations

Avoid when:
- Problem doesn't split cleanly
- n is small enough for full enumeration
- n is large enough that even 2^(n/2) is infeasible
- Better algorithms exist

**Structure**

1. Split input into two halves
2. Enumerate all solutions for first half
3. Enumerate all solutions for second half
4. Combine: for each first-half result, find matching second-half results

**Consequences**

Benefits:
- Reduces 2^n to 2^(n/2)
- Enables problems just beyond brute force
- Conceptually elegant
- Space is manageable (2^(n/2))

Liabilities:
- Only halves the exponent
- Combining step must be efficient
- Not always applicable
- Memory for half-enumerations

**Implementation Notes**

Common combining techniques: sort one half, binary search from other; use hash maps for exact matching; two pointers if both halves are sorted. Watch for duplicate handling.

**Related Patterns**

- *Exhaustive Enumeration*: What we're optimizing
- *Binary Search*: Often used in combining step
- *Hash Table*: Alternative for combining

---

## Pattern Selection Guide

### By Problem Signature

| Signature | Consider |
|-----------|----------|
| "Find sum/count over range [i,j]" | Prefix Computation |
| "Next greater/smaller element" | Monotonic Ordering |
| "Partition array by predicate" | In-Place Partitioning |
| "Root-to-leaf property" | Path Accumulation |
| "Level-by-level processing" | Level-Order Processing |
| "Number of connected groups" | Connected Component Discovery |
| "Can graph be 2-colored?" | Bipartite Verification |
| "Does graph contain cycle?" | Cycle Detection |
| "Optimal with state transitions" | State Space DP |
| "Combine overlapping ranges" | Interval Merging |
| "Choose subset under constraint" | Subset Selection |
| "Transform sequence to sequence" | Sequence Alignment |
| "Generate all configurations" | Exhaustive Enumeration |
| "Minimum X where condition holds" | Binary Decision |
| "2^n where n ≈ 40" | Meet in the Middle |

### By Data Structure

| Primary Structure | Relevant Patterns |
|-------------------|-------------------|
| Array | Prefix, Monotonic, Partitioning, Sliding Window |
| Tree | Recursive Processing, Level-Order, Path Accumulation |
| Graph | Components, Bipartite, Cycle Detection |
| Intervals | Merging, Sweep Line |
| Sequences | Alignment, LCS, Edit Distance |

### By Complexity

| Target Time | Suitable Patterns |
|-------------|-------------------|
| O(1) per query | Prefix Computation (after O(n) prep) |
| O(n) | Monotonic, Partitioning, Level-Order, Component Discovery |
| O(n log n) | Interval Merging, Binary Decision |
| O(nm) | Sequence Alignment, 2D DP |
| O(2^(n/2)) | Meet in the Middle |
| O(2^n) or O(n!) | Exhaustive Enumeration |
