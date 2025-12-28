# Algorithmic Patterns

This section catalogs strategic patterns for processing data and solving problems. Each pattern represents a proven approach that applies across many specific algorithms.

---

## Transformation Patterns

### Sorting

**Intent**

Impose an order on a collection to enable efficient subsequent operations such as binary search, duplicate detection, or merge operations.

**Motivation**

Consider finding all duplicate entries in a customer database. Comparing every pair would require quadratic time. By sorting first, duplicates become adjacent, allowing a single linear scan to find them. The sorting cost is amortized across many subsequent operations that benefit from the ordering.

**Applicability**

Use Sorting when:
- Subsequent operations benefit from ordered data
- Finding duplicates, medians, or percentiles
- Preparing data for binary search
- Merging multiple sorted sequences
- Grouping related items

Avoid when:
- Only a single element is needed (use selection)
- Data must remain in original order
- Hash-based approach would be more efficient
- Input is already sorted or nearly sorted (verify first)

**Structure**

Transform unordered collection to ordered collection. Comparison-based sorting compares element pairs; distribution-based sorting uses element properties directly.

**Consequences**

Benefits:
- Enables O(log n) binary search
- Makes duplicates adjacent
- Simplifies merge operations
- Foundation for many other algorithms

Liabilities:
- O(n log n) minimum for comparison-based sorting
- May not preserve original order (stability varies)
- Requires comparable elements
- Upfront cost may not be amortized

**Implementation Notes**

Always use standard library sorting. Built-in implementations are highly optimized, stable when needed, and handle edge cases. Custom sorting is justified only for specialized requirements (external sorting, partial sorting, custom comparison that can't be expressed as a comparator).

**Related Patterns**

- *Binary Search*: Often follows sorting
- *Hash Table*: Alternative for lookup-heavy workloads
- *Heap*: For extracting k largest/smallest without full sort

---

### Binary Search

**Intent**

Locate a target value or boundary in a sorted sequence by repeatedly halving the search space.

**Motivation**

Consider looking up a word in a dictionary. Reading every entry sequentially would be impractical. Because entries are sorted, you can open to the middle, determine which half contains the word, and repeat. Each step halves the remaining search space, finding any word in a large dictionary with just a few comparisons.

**Applicability**

Use Binary Search when:
- Data is sorted (or can be sorted once for many queries)
- Finding exact matches or boundaries
- Searching in a monotonic function's domain
- Any "minimize X such that condition holds" problem

Avoid when:
- Data is unsorted and queries are few
- Linear scan is acceptable (small data)
- Hash-based lookup is possible

**Structure**

Maintain a range [low, high] guaranteed to contain the target. Compute midpoint, compare, and narrow range to the appropriate half. Continue until range collapses or target is found.

**Consequences**

Benefits:
- O(log n) search in sorted data
- Simple to implement correctly
- Memory-efficient (no auxiliary storage)
- Generalizes to boundary-finding problems

Liabilities:
- Requires sorted data
- Edge cases are subtle (off-by-one errors)
- Cannot exploit locality in clustered queries
- Slower than hash lookup for point queries

**Implementation Notes**

Standard libraries provide binary search. When implementing custom variants, be meticulous about loop invariants and boundary conditions—binary search bugs are notoriously subtle.

**Related Patterns**

- *Sorting*: Usually a prerequisite
- *Ternary Search*: For unimodal functions
- *Exponential Search*: For unbounded sorted sequences

---

## Decomposition Patterns

### Divide and Conquer

**Intent**

Solve a problem by breaking it into independent subproblems of the same type, solving each recursively, and combining results.

**Motivation**

Consider sorting a large array. Sorting the entire array at once is complex. Instead, divide the array in half, sort each half independently, and merge the sorted halves. Each half is sorted the same way, recursively, until reaching trivially small arrays. The work of combining sorted halves is linear, while the recursive structure yields O(n log n) overall.

**Applicability**

Use Divide and Conquer when:
- Problem naturally decomposes into similar subproblems
- Subproblems are independent (no shared state)
- Combining solutions is efficient
- Recursive structure matches problem structure

Avoid when:
- Subproblems overlap significantly (use Dynamic Programming)
- Decomposition overhead exceeds benefits
- Problem doesn't have recursive structure
- Combining results is as expensive as the original problem

**Structure**

1. **Divide**: Split problem into smaller subproblems
2. **Conquer**: Solve subproblems recursively (or directly if trivial)
3. **Combine**: Merge subproblem solutions into overall solution

**Consequences**

Benefits:
- Often achieves optimal time complexity
- Naturally parallelizable (independent subproblems)
- Conceptually clear structure
- Reduces complex problems to simpler cases

Liabilities:
- Recursion overhead (stack space, function calls)
- Not applicable when subproblems share dependencies
- Combine step complexity determines overall efficiency
- May require careful base case handling

**Implementation Notes**

Consider iterative equivalents for deep recursion to avoid stack overflow. The Master Theorem helps analyze complexity of divide-and-conquer recurrences.

**Related Patterns**

- *Dynamic Programming*: When subproblems overlap
- *Binary Search*: Simplest divide-and-conquer pattern
- *Merge Sort*: Classic divide-and-conquer algorithm

---

### Dynamic Programming

**Intent**

Solve optimization or counting problems by identifying overlapping subproblems, solving each once, and combining results using optimal substructure.

**Motivation**

Consider computing the nth Fibonacci number. The naive recursive approach recomputes the same values exponentially many times. By storing each Fibonacci number once computed, subsequent references retrieve the cached value. This transforms exponential time to linear time. The same principle applies to optimization problems: solve each subproblem once, then combine optimal subsolutions.

**Applicability**

Use Dynamic Programming when:
- Problem has optimal substructure (optimal solution contains optimal subsolutions)
- Subproblems overlap (same subproblem appears multiple times)
- Problem asks for optimization (min/max) or counting
- State space is not too large to enumerate

Avoid when:
- Subproblems are independent (use Divide and Conquer)
- No overlapping subproblems exist
- Greedy approach works (simpler and often faster)
- State space is too large

**Structure**

Two equivalent approaches:
1. **Top-down (Memoization)**: Recursively solve, caching results
2. **Bottom-up (Tabulation)**: Fill table from base cases upward

**Consequences**

Benefits:
- Polynomial time for problems with exponential naive solutions
- Systematic approach to optimization problems
- Solution reconstruction often possible
- Well-understood design paradigm

Liabilities:
- Identifying state and transitions can be non-obvious
- Space requirements may be significant
- Not all problems have DP solutions
- Implementation can be complex for multi-dimensional state

**Implementation Notes**

Start by identifying the state (what information defines a subproblem) and the transition (how states relate). Verify optimal substructure before committing to DP. Often, space can be optimized by keeping only needed rows/columns of the DP table.

**Related Patterns**

- *Divide and Conquer*: When subproblems are independent
- *Greedy*: When local optimal leads to global optimal
- *Memoization*: Implementation technique for top-down DP

---

### Greedy

**Intent**

Construct a solution incrementally by making locally optimal choices at each step, without reconsidering previous decisions.

**Motivation**

Consider making change with the fewest coins. Intuitively, you'd repeatedly choose the largest coin that doesn't exceed the remaining amount. This greedy approach works for standard currency denominations. Each local choice (largest valid coin) leads to the global optimum (fewest coins). No backtracking or exploration of alternatives is needed.

**Applicability**

Use Greedy when:
- Local optimal choice leads to global optimal (greedy choice property)
- Problem has optimal substructure
- Problem involves scheduling, selection, or ordering
- Proof of correctness can be established

Avoid when:
- Greedy choice property doesn't hold
- Backtracking or exploration is needed
- Problem requires considering all combinations
- No proof of correctness exists (verify carefully!)

**Structure**

1. Make the locally optimal choice
2. Reduce to a smaller subproblem
3. Repeat until problem is solved

**Consequences**

Benefits:
- Simple and intuitive algorithms
- Often very efficient (single pass through data)
- Low memory requirements
- Easy to implement

Liabilities:
- Doesn't always yield optimal solutions
- Correctness proofs can be subtle
- Easy to apply incorrectly (looks right but isn't)
- No recovery from bad choices

**Implementation Notes**

Greedy algorithms require proof of correctness—intuition is insufficient. Common proof techniques: exchange argument (show no benefit from deviating), matroid theory (for certain combinatorial problems). When unsure, test against known solutions or use DP instead.

**Related Patterns**

- *Dynamic Programming*: When greedy doesn't work
- *Sorting*: Often precedes greedy selection
- *Heap*: Efficient selection of "best" element

---

## Search and Traversal Patterns

### Breadth-First Search

**Intent**

Explore a graph or state space level by level, visiting all nodes at distance k before any node at distance k+1.

**Motivation**

Consider finding the shortest path in a maze (unweighted graph). Starting from the entrance, explore all cells one step away, then all cells two steps away, and so on. The first time you reach the exit, you've found a shortest path. BFS guarantees this because it exhausts closer cells before reaching farther ones.

**Applicability**

Use BFS when:
- Finding shortest path in unweighted graphs
- Level-order traversal is needed
- All nodes at a given distance should be processed together
- Exploring states in order of "distance" from start

Avoid when:
- Graph has weighted edges (use Dijkstra)
- Depth-first properties are needed
- Memory is severely constrained (BFS uses O(width) space)
- Only path existence matters, not length

**Structure**

1. Initialize queue with starting node(s)
2. While queue is not empty:
   - Dequeue front node
   - Process node
   - Enqueue all unvisited neighbors

**Consequences**

Benefits:
- Guarantees shortest path in unweighted graphs
- Complete: will find solution if one exists
- Natural for level-based processing
- Predictable memory usage

Liabilities:
- O(V + E) time and O(V) space
- Memory grows with frontier width
- Not suitable for weighted shortest paths
- May explore many irrelevant nodes

**Implementation Notes**

Use a queue (not recursion). Track visited nodes to avoid cycles. For shortest path reconstruction, store parent pointers. Consider bidirectional BFS for point-to-point shortest paths.

**Related Patterns**

- *DFS*: When depth-first exploration is preferred
- *Dijkstra*: For weighted shortest paths
- *A\**: For heuristic-guided search

---

### Depth-First Search

**Intent**

Explore a graph or state space by following paths to their deepest extent before backtracking.

**Motivation**

Consider detecting whether a graph contains a cycle. Starting from any node, follow edges as deep as possible. If you encounter a node currently on your path, you've found a cycle. DFS naturally maintains the current path on its call stack, making cycle detection straightforward. The depth-first approach explores complete paths, revealing structural properties.

**Applicability**

Use DFS when:
- Path-based properties matter (cycles, connectivity)
- Topological sorting is needed
- Generating all paths or configurations
- Memory efficiency is important (O(depth) vs O(width))
- Tree traversals (preorder, inorder, postorder)

Avoid when:
- Shortest path is needed in unweighted graphs
- Level-order processing is required
- Very deep graphs risk stack overflow
- Breadth-first properties are essential

**Structure**

1. Start at source node, mark visited
2. For each unvisited neighbor:
   - Recursively visit neighbor
3. Process node (timing depends on application)

**Consequences**

Benefits:
- O(V + E) time, O(V) space (path length in best case)
- Natural recursive implementation
- Reveals path-based properties
- Foundation for many graph algorithms

Liabilities:
- Doesn't find shortest paths
- Deep graphs may cause stack overflow
- Order of exploration depends on neighbor ordering
- May miss closer solutions

**Implementation Notes**

Recursive implementation is natural but risks stack overflow. Iterative implementation with explicit stack handles deep graphs. Node states (unvisited, visiting, visited) enable cycle detection in directed graphs.

**Related Patterns**

- *BFS*: For shortest paths, level order
- *Backtracking*: DFS with pruning
- *Topological Sort*: Application of DFS

---

### Backtracking

**Intent**

Systematically explore all possible solutions by building candidates incrementally and abandoning ("backtracking") partial candidates that cannot lead to valid solutions.

**Motivation**

Consider placing 8 queens on a chessboard such that none attack each other. A brute-force approach would try all 64^8 placements—impossibly many. Instead, place queens row by row. If placing a queen in a row leaves no valid position for subsequent rows, immediately backtrack and try a different position. This pruning eliminates vast swaths of the search space.

**Applicability**

Use Backtracking when:
- Problem asks for all solutions or any valid solution
- Constraints allow pruning invalid partial solutions
- Solution is built incrementally through choices
- Exhaustive search is necessary

Avoid when:
- Problem has polynomial-time solution
- Pruning is ineffective (search space remains exponential)
- Greedy or DP approaches work
- Approximate solutions suffice

**Structure**

1. Check if current state is a complete solution
2. If complete, record/return solution
3. For each possible next choice:
   - Make choice
   - If choice is valid/promising, recurse
   - Undo choice (backtrack)

**Consequences**

Benefits:
- Finds all solutions when needed
- Pruning can dramatically reduce search space
- Conceptually straightforward
- Guarantees completeness

Liabilities:
- Worst case is exponential
- Effectiveness depends on pruning quality
- May be slow for large search spaces
- Requires recognizing invalid partial solutions

**Implementation Notes**

Optimize pruning—the earlier invalid branches are cut, the better. Consider constraint propagation to identify forced choices. For optimization problems, track best solution found and prune branches that can't improve it.

**Related Patterns**

- *DFS*: Backtracking is DFS with pruning
- *Dynamic Programming*: When overlapping subproblems exist
- *Branch and Bound*: Backtracking with bounds for optimization

---

## Graph Algorithm Patterns

### Shortest Path

**Intent**

Find the path of minimum total weight between vertices in a weighted graph.

**Motivation**

Consider route planning in a road network. Roads have different lengths, and you want the shortest total distance. This is fundamentally different from unweighted shortest path: a path with more edges might be shorter than one with fewer edges. Algorithms like Dijkstra systematically explore paths in order of accumulated distance.

**Applicability**

Choose algorithm based on graph properties:

| Scenario | Algorithm |
|----------|-----------|
| Unweighted graph | BFS |
| Non-negative weights, single source | Dijkstra |
| Negative weights allowed, single source | Bellman-Ford |
| All pairs, dense graph | Floyd-Warshall |
| All pairs, sparse graph | Johnson's algorithm |
| With heuristic guidance | A* |

**Structure**

Dijkstra (most common case):
1. Initialize distances: source = 0, others = ∞
2. Use priority queue ordered by distance
3. Extract minimum, relax edges to neighbors
4. Repeat until destination reached or queue empty

**Consequences**

Benefits:
- Optimal shortest paths (algorithm-dependent guarantees)
- Well-understood complexity bounds
- Extensive library support
- Foundation for many applications

Liabilities:
- Dijkstra fails with negative weights
- All-pairs is expensive for large graphs
- Memory for storing distances/predecessors
- Heuristic choice affects A* performance

**Implementation Notes**

Use graph libraries for standard algorithms. Dijkstra requires priority queue with decrease-key; Fibonacci heaps give optimal complexity but are rarely needed in practice. For A*, heuristic must be admissible (never overestimates) for optimality.

**Related Patterns**

- *BFS*: Unweighted shortest path
- *Heap*: For efficient minimum extraction in Dijkstra
- *Dynamic Programming*: Bellman-Ford is DP on path length

---

### Minimum Spanning Tree

**Intent**

Find a subset of edges that connects all vertices with minimum total weight, forming a tree.

**Motivation**

Consider designing a network connecting multiple cities. Cable has a cost per mile, and you want to connect all cities at minimum total cost. Any solution must reach every city (spanning) and have no redundant connections (tree—adding any edge creates a cycle). MST algorithms find the optimal set of connections.

**Applicability**

Use MST when:
- Connecting all nodes with minimum cost
- Clustering (remove longest MST edges)
- Approximating NP-hard problems (traveling salesman)
- Network design and analysis

Avoid when:
- Graph is already a tree
- Path weights matter, not just connectivity
- Directed graph (need minimum spanning arborescence)

**Structure**

Two classic approaches:
- **Kruskal**: Sort edges by weight, add edges that don't create cycles (use Union-Find)
- **Prim**: Grow tree from start vertex, always adding minimum edge to a new vertex (use Heap)

**Consequences**

Benefits:
- Optimal solution guaranteed
- O(E log V) for both classic algorithms
- Simple to implement with proper data structures
- Well-understood properties

Liabilities:
- Doesn't preserve path distances
- Requires undirected graph (directed variant is harder)
- All edges needed in memory for Kruskal
- May not be unique (multiple MSTs possible)

**Implementation Notes**

Kruskal with Union-Find is conceptually simple and efficient. Prim with binary heap is equally efficient. Choice often depends on available data structures. Graph libraries provide optimized implementations.

**Related Patterns**

- *Union-Find*: Essential for Kruskal
- *Heap*: Essential for Prim
- *Shortest Path*: Different optimization (paths vs. total weight)

---

### Topological Sort

**Intent**

Order vertices of a directed acyclic graph (DAG) such that for every edge (u, v), u appears before v.

**Motivation**

Consider scheduling tasks with dependencies. Some tasks must complete before others can start. A valid schedule must respect all dependencies. Topological sort produces an ordering where dependent tasks come after their prerequisites. If no such ordering exists, the dependencies contain a cycle.

**Applicability**

Use Topological Sort when:
- Scheduling with dependencies
- Build system ordering
- Prerequisite chains (course scheduling)
- Determining if a directed graph is acyclic

Avoid when:
- Graph has cycles (no topological order exists)
- Order doesn't matter for the application
- Graph is undirected

**Structure**

Two approaches:
- **Kahn's algorithm (BFS)**: Repeatedly remove vertices with no incoming edges
- **DFS-based**: Reverse of DFS finish order

**Consequences**

Benefits:
- Linear time O(V + E)
- Detects cycles as byproduct
- Multiple valid orderings often possible
- Foundation for DP on DAGs

Liabilities:
- Only works on DAGs
- Doesn't minimize any objective
- Multiple orderings can be arbitrary
- Edge direction must be meaningful

**Implementation Notes**

Kahn's algorithm is iterative and uses in-degree counting. DFS approach leverages existing traversal. Both detect cycles. Choose based on what other information is needed (e.g., DFS gives finish times).

**Related Patterns**

- *DFS*: Foundation of one approach
- *BFS*: Foundation of Kahn's algorithm
- *Strongly Connected Components*: For handling graphs with cycles

---

## Optimization Techniques

### Memoization

**Intent**

Cache results of expensive function calls to avoid redundant computation when the same inputs recur.

**Motivation**

Consider computing combinations C(n, k) using the recursive formula C(n, k) = C(n-1, k-1) + C(n-1, k). Naive recursion recomputes the same values exponentially many times. By storing each computed value in a table keyed by (n, k), subsequent calls with the same arguments return immediately. The exponential recursion becomes polynomial.

**Applicability**

Use Memoization when:
- Function is pure (same inputs always give same output)
- Same inputs occur multiple times
- Computing from scratch is expensive
- Memory for cache is available

Avoid when:
- Inputs rarely repeat
- Function has side effects
- Memory is severely constrained
- Cache overhead exceeds computation cost

**Structure**

1. Before computing, check if result is cached
2. If cached, return cached result
3. If not, compute result, cache it, return it

**Consequences**

Benefits:
- Transforms repeated computation to lookup
- Simple to add to existing recursive code
- Automatic with language support (decorators)
- Space-time trade-off under your control

Liabilities:
- Memory usage grows with distinct inputs
- Cache invalidation if underlying data changes
- Not applicable to impure functions
- May obscure algorithm's structure

**Implementation Notes**

Many languages provide memoization decorators or built-in support. Hash tables are natural cache structures. Consider cache size limits (LRU eviction) for unbounded input spaces.

**Related Patterns**

- *Dynamic Programming*: Memoization is top-down DP
- *Hash Table*: Implementation substrate
- *LRU Cache*: When cache size must be bounded

---

### Two Pointers

**Intent**

Process a sequence using two indices that move based on conditions, avoiding nested iteration.

**Motivation**

Consider finding two numbers in a sorted array that sum to a target. Checking all pairs requires quadratic time. Instead, place one pointer at the start and one at the end. If the sum is too small, advance the left pointer; if too large, retreat the right pointer. Each element is visited at most twice, yielding linear time.

**Applicability**

Use Two Pointers when:
- Working with sorted sequences
- Finding pairs with some property
- Partitioning or rearranging in-place
- Merging sorted sequences

Avoid when:
- Sequence is not sorted and cannot be sorted
- Problem requires examining all pairs
- Non-linear relationships between elements

**Structure**

Initialize two pointers (often at extremes or both at start). Move pointers based on comparison with target condition. Continue until pointers meet or cross.

**Consequences**

Benefits:
- Reduces O(n²) to O(n) for certain problems
- Constant extra space
- Simple and efficient
- Works well with sorted data

Liabilities:
- Requires sortedness for many applications
- Limited to problems with monotonic relationships
- Not always obvious which pointer to move
- Edge cases at boundaries

**Implementation Notes**

The key insight is identifying which pointer to move and why. Often, sortedness guarantees that moving one pointer can only improve or maintain the solution quality in a predictable direction.

**Related Patterns**

- *Binary Search*: Related technique for sorted data
- *Sliding Window*: Two pointers with different movement pattern
- *Merge*: Two-pointer technique for combining sorted sequences

---

### Sliding Window

**Intent**

Process contiguous subarrays or substrings by maintaining a window that expands and contracts based on conditions.

**Motivation**

Consider finding the longest substring without repeating characters. Checking all substrings would be cubic. Instead, maintain a window using two pointers. Expand the right boundary to include new characters; when a repeat occurs, contract the left boundary until the window is valid again. Each character enters and leaves the window at most once, yielding linear time.

**Applicability**

Use Sliding Window when:
- Problem involves contiguous sequences (subarrays, substrings)
- Looking for optimal window satisfying some constraint
- Window validity is monotonic (expanding can only violate/satisfy constraint)
- Need to process all windows efficiently

Avoid when:
- Problem doesn't involve contiguous elements
- No monotonicity in window validity
- Each window must be processed independently

**Structure**

1. Initialize left and right boundaries
2. Expand right boundary, updating window state
3. While window violates constraint, contract left boundary
4. Track optimal window encountered

**Consequences**

Benefits:
- Reduces quadratic to linear time
- Constant or linear extra space
- Elegant handling of "optimal contiguous subsequence" problems
- Clear pattern for many string/array problems

Liabilities:
- Only works for contiguous sequences
- Requires monotonic constraint behavior
- State tracking can be complex
- Edge cases at boundaries

**Implementation Notes**

The constraint must be monotonic: once violated by expansion, contraction restores validity, and vice versa. Common state tracking includes hash maps for character counts or running totals.

**Related Patterns**

- *Two Pointers*: Foundation technique
- *Hash Table*: For tracking window contents
- *Deque*: For sliding window maximum/minimum

---

## Pattern Selection Guide

### By Problem Characteristic

| Characteristic | Consider | See |
|----------------|----------|-----|
| Optimal with overlapping subproblems | Dynamic Programming | DP Pattern |
| Local choice leads to global optimal | Greedy | Greedy Pattern |
| Generate all valid configurations | Backtracking | Backtracking Pattern |
| Independent subproblems | Divide and Conquer | D&C Pattern |
| Graph connectivity/paths | Graph Algorithms | BFS, DFS, Shortest Path |
| Sorted sequence operations | Two Pointers, Binary Search | Search Patterns |
| Contiguous subsequence | Sliding Window | Window Pattern |

### By Problem Type

| Problem Type | First Choice | Alternative |
|--------------|--------------|-------------|
| Shortest path (unweighted) | BFS | — |
| Shortest path (weighted) | Dijkstra | Bellman-Ford (negative weights) |
| Minimum cost connection | MST (Kruskal/Prim) | — |
| Task scheduling | Topological Sort | — |
| Optimization with constraints | Dynamic Programming | Greedy (if proven) |
| All valid solutions | Backtracking | — |
| Pair finding in sorted data | Two Pointers | Binary Search |
| Substring/subarray optimization | Sliding Window | — |

### By Complexity Target

| Input Size | Feasible Complexity | Suitable Patterns |
|------------|---------------------|-------------------|
| n ≤ 20 | O(2ⁿ) | Backtracking, bitmask DP |
| n ≤ 100 | O(n³) | DP, Floyd-Warshall |
| n ≤ 10,000 | O(n²) | Simple DP, quadratic algorithms |
| n ≤ 1,000,000 | O(n log n) | Sorting, balanced trees, heap |
| n ≤ 100,000,000 | O(n) | Linear scan, hash table, two pointers |
| n > 100,000,000 | O(log n) | Binary search, math |
