# Problem Patterns and DSA Selection Guide

This guide maps common problem types to appropriate data structures and algorithms. Use this to quickly identify the right approach for a given problem.

## Array and String Problems

### Two Pointers
**Pattern:** Two pointers moving through array/string
**Problems:**
- Palindrome checking
- Pair sum in sorted array
- Remove duplicates in-place
- Container with most water
- Trapping rain water

**Approach:** Simple iteration with two indices
**Data structures:** Array/string
**Time complexity:** Usually O(n)

### Sliding Window
**Pattern:** Window expands/contracts across array
**Problems:**
- Longest substring without repeating characters
- Maximum sum subarray of size k
- Minimum window substring
- Longest substring with k distinct characters

**Approach:** Two pointers with hash map for tracking
**Data structures:** Hash map + array
**Time complexity:** O(n)

### Prefix Sum
**Pattern:** Precompute cumulative sums
**Problems:**
- Range sum queries
- Subarray sum equals k
- Continuous subarray sum
- Product of array except self

**Approach:** Build prefix array in O(n), query in O(1)
**Data structures:** Array
**Alternative:** Fenwick tree for mutable arrays

### Monotonic Stack/Queue
**Pattern:** Maintain decreasing/increasing order
**Problems:**
- Next greater element
- Largest rectangle in histogram
- Sliding window maximum
- Daily temperatures

**Approach:** Stack/deque with monotonic property
**Data structures:** Stack or deque
**Time complexity:** O(n)

## Hash Map Problems

### Frequency Counting
**Pattern:** Count occurrences of elements
**Problems:**
- Two sum
- First unique character
- Group anagrams
- Top K frequent elements

**Approach:** Hash map for counting
**Data structures:**
- Python: `collections.Counter`
- Others: Hash map

### Index Mapping
**Pattern:** Map values to indices
**Problems:**
- Two sum (return indices)
- Longest consecutive sequence
- Clone graph with hash map
- Copy with random pointer

**Approach:** Hash map storing value → index/node
**Data structures:** Hash map

### Grouping/Categorization
**Pattern:** Group related elements
**Problems:**
- Group anagrams
- Group shifted strings
- Valid Sudoku (track seen numbers per row/col/box)

**Approach:** Hash map with composite keys
**Data structures:**
- Python: `collections.defaultdict(list)`
- Others: Hash map of lists

## Tree Problems

### Binary Tree Traversal
**Patterns:**
- Preorder: Root → Left → Right (DFS)
- Inorder: Left → Root → Right (for BST gives sorted)
- Postorder: Left → Right → Root (deletion, calculation)
- Level order: BFS by level

**Problems:**
- Tree traversal variants
- Serialize/deserialize binary tree
- Vertical order traversal
- Binary tree right side view

**Approach:** Recursion or explicit stack/queue
**Data structures:** Stack (DFS), Queue (BFS)

### Binary Search Tree
**Pattern:** Exploit BST property (left < root < right)
**Problems:**
- Validate BST
- Kth smallest element in BST
- Convert sorted array to BST
- Lowest common ancestor in BST

**Approach:** Inorder traversal or binary search on tree
**Data structures:** BST or balanced BST library

### Lowest Common Ancestor
**Pattern:** Find common ancestor
**Problems:**
- LCA of binary tree
- LCA of BST
- LCA of deepest leaves

**Approach:** Recursion or parent pointers
**Data structures:** Tree + hash map for parent pointers

### Path Problems
**Pattern:** Root-to-leaf or node-to-node paths
**Problems:**
- Path sum
- Binary tree maximum path sum
- Diameter of binary tree
- Sum root to leaf numbers

**Approach:** Recursion with state passing
**Data structures:** Tree

## Graph Problems

### Connectivity
**Pattern:** Are nodes connected?
**Problems:**
- Number of connected components
- Number of islands
- Friend circles
- Graph valid tree

**Approach:** DFS/BFS or Union-Find
**Data structures:**
- Union-Find (preferred for dynamic connectivity)
- Adjacency list + visited set

### Shortest Path
**Pattern:** Find shortest/cheapest path
**Problems:**
- Shortest path in binary matrix
- Word ladder
- Network delay time
- Cheapest flights within K stops

**Approach:**
- Unweighted: BFS
- Weighted (non-negative): Dijkstra
- Weighted (negative allowed): Bellman-Ford
**Data structures:** Graph + priority queue (Dijkstra)

### Topological Sort
**Pattern:** Order with dependencies
**Problems:**
- Course schedule
- Task scheduling
- Alien dictionary
- Sequence reconstruction

**Approach:**
- Kahn's algorithm (BFS with in-degree)
- DFS with finish times
**Data structures:**
- Adjacency list
- Queue for Kahn's
- In-degree array

### Cycle Detection
**Pattern:** Does graph have cycle?
**Problems:**
- Course schedule (is DAG?)
- Redundant connection
- Detect cycle in undirected graph

**Approach:**
- Directed: DFS with colors (white/gray/black)
- Undirected: DFS with parent tracking or Union-Find
**Data structures:** Adjacency list + state tracking

### Bipartite
**Pattern:** Can graph be 2-colored?
**Problems:**
- Is graph bipartite?
- Possible bipartition

**Approach:** BFS/DFS with 2-coloring
**Data structures:** Adjacency list + color array

## Dynamic Programming Patterns

### Linear DP
**Pattern:** State depends on previous few states
**Problems:**
- Climbing stairs (Fibonacci)
- House robber
- Decode ways
- Jump game

**Approach:** 1D DP array or variables
**Recurrence:** `dp[i] = f(dp[i-1], dp[i-2], ...)`
**Space optimization:** Often O(n) → O(1)

### 2D Grid DP
**Pattern:** Move through 2D grid
**Problems:**
- Unique paths
- Minimum path sum
- Dungeon game
- Maximal square

**Approach:** 2D DP table
**Recurrence:** `dp[i][j] = f(dp[i-1][j], dp[i][j-1])`
**Space optimization:** Can use 1D array

### Subsequence DP
**Pattern:** Match/compare sequences
**Problems:**
- Longest common subsequence
- Edit distance
- Distinct subsequences
- Interleaving string

**Approach:** 2D DP table (string1 × string2)
**Recurrence:** Match vs mismatch cases
**Data structures:** 2D array

### Knapsack
**Pattern:** Select items with constraints
**Problems:**
- 0/1 Knapsack
- Partition equal subset sum
- Target sum
- Coin change

**Approach:** 2D DP (items × capacity) → 1D optimization
**Recurrence:** `dp[w] = max(dp[w], value + dp[w - weight])`
**Data structures:** 1D or 2D array

### Interval DP
**Pattern:** Optimal splitting of ranges
**Problems:**
- Burst balloons
- Minimum cost tree from leaf values
- Palindrome partitioning II
- Matrix chain multiplication

**Approach:** 2D DP with range [i, j]
**Recurrence:** Try all split points k in [i, j]
**Data structures:** 2D array

### State Machine DP
**Pattern:** States with transitions
**Problems:**
- Best time to buy/sell stock with cooldown
- Best time to buy/sell stock with fee
- Knight dialer

**Approach:** Multiple DP arrays for each state
**Recurrence:** State transitions with conditions
**Data structures:** Multiple 1D arrays or 2D array

## Backtracking Patterns

### Subset/Combination
**Pattern:** Generate all subsets/combinations
**Problems:**
- Subsets
- Combination sum
- Generate parentheses
- Letter combinations of phone number

**Approach:** Backtracking with choice at each step
**Data structures:** List for current path

### Permutation
**Pattern:** Generate all permutations
**Problems:**
- Permutations
- Permutations II (with duplicates)
- N-Queens
- Sudoku solver

**Approach:** Backtracking with swap or used set
**Data structures:** Set for used elements or in-place swaps

### Grid Exploration
**Pattern:** Explore grid paths
**Problems:**
- Word search
- N-Queens (grid variant)
- Rat in a maze

**Approach:** DFS with backtracking
**Data structures:** 2D grid + visited set

## Greedy Patterns

### Interval Scheduling
**Pattern:** Select non-overlapping intervals
**Problems:**
- Meeting rooms
- Non-overlapping intervals
- Minimum arrows to burst balloons

**Approach:** Sort by end time, greedily select
**Data structures:** Array + sorting
**Verification:** Prove greedy choice property

### Two-Heap Pattern
**Pattern:** Maintain median or balanced partition
**Problems:**
- Find median from data stream
- Sliding window median
- IPO problem

**Approach:** Max-heap for smaller half, min-heap for larger
**Data structures:** Two heaps
**Time complexity:** O(log n) insert, O(1) median

## Design Problems

### LRU Cache
**Pattern:** Cache with eviction
**Structure:** Hash map + doubly linked list
**Operations:** Get O(1), Put O(1)
**Libraries:** `functools.lru_cache` (Python), `lru-cache` (JS)

### Trie Operations
**Pattern:** Prefix-based operations
**Problems:**
- Implement Trie
- Add and search word
- Word search II
- Design search autocomplete

**Structure:** Trie (prefix tree)
**Libraries:** `pygtrie` (Python)
**Custom implementation:** Acceptable for basic trie

### Union-Find Applications
**Pattern:** Dynamic connectivity
**Problems:**
- Number of islands II
- Accounts merge
- Redundant connection
- Optimize water distribution

**Structure:** Union-Find with path compression
**Operations:** Union O(α(n)), Find O(α(n))
**Custom implementation:** Recommended (~30 lines)

## Stack and Queue Patterns

### Monotonic Stack
**Pattern:** Maintain increasing/decreasing stack
**Problems:**
- Next greater element
- Daily temperatures
- Largest rectangle in histogram
- Maximal rectangle

**Approach:** Push/pop to maintain monotonic property
**Data structures:** Stack
**Time complexity:** O(n)

### Queue Simulation
**Pattern:** Process in FIFO order
**Problems:**
- Moving average from data stream
- Recent counter
- Dota2 senate

**Data structures:** Queue or deque
**Libraries:** `collections.deque` (Python)

## Bit Manipulation Patterns

### Single Number
**Pattern:** Find unique element
**Problems:**
- Single number (XOR all)
- Single number II (count bits modulo 3)
- Single number III (two unique numbers)

**Approach:** XOR properties, bit counting
**Time complexity:** O(n)
**Space complexity:** O(1)

### Subset Enumeration
**Pattern:** Use bits to represent subsets
**Problems:**
- Subsets using bit manipulation
- Maximum XOR of two numbers

**Approach:** Iterate through 2^n bitmasks
**Data structures:** Integers as bitmasks

## Matrix Problems

### Matrix Traversal
**Pattern:** Traverse in specific order
**Problems:**
- Spiral matrix
- Rotate image
- Set matrix zeroes

**Approach:** Careful index manipulation
**Data structures:** 2D array

### Island Problems
**Pattern:** Connected components in grid
**Problems:**
- Number of islands
- Max area of island
- Surrounded regions

**Approach:** DFS/BFS from each unvisited cell
**Data structures:** 2D grid + visited set

## Decision Framework

1. **Identify the core problem type** (array, tree, graph, etc.)
2. **Look for matching patterns** in this reference
3. **Choose appropriate data structure** based on:
   - Operations needed (insert, search, delete)
   - Time complexity requirements
   - Space constraints
4. **Select algorithm** based on:
   - Problem constraints (size, ranges)
   - Required optimality (optimal vs approximate)
   - Implementation complexity
5. **Check for library implementations** before coding
6. **Implement custom only when:**
   - Very simple (< 30 lines)
   - Highly specialized
   - Educational value
   - No suitable library

## Common Anti-Patterns

### Don't Use When Better Exists

❌ **Manual string concatenation in loop**
```python
# Bad
result = ""
for s in strings:
    result += s  # O(n²)
```
✅ **Use join**
```python
# Good
result = "".join(strings)  # O(n)
```

❌ **Nested loops for search**
```python
# Bad
for i in range(len(arr)):
    for j in range(len(arr)):
        if arr[i] + arr[j] == target:  # O(n²)
```
✅ **Use hash map**
```python
# Good
seen = {}
for num in arr:
    if target - num in seen:  # O(n)
        return True
    seen[num] = True
```

❌ **Repeated sorting**
```python
# Bad
for query in queries:
    arr.sort()  # O(n log n) each time
    # process query
```
✅ **Sort once or use appropriate data structure**
```python
# Good
arr.sort()  # O(n log n) once
for query in queries:
    # process query on sorted arr
```

## Complexity Cheat Sheet

| Input Size | Max Complexity | Algorithms |
|-----------|----------------|------------|
| n ≤ 10 | O(n!) | Permutations, backtracking |
| n ≤ 20 | O(2^n) | Subsets, DP with bitmask |
| n ≤ 100 | O(n³) | Floyd-Warshall, DP |
| n ≤ 1000 | O(n²) | Nested loops, some DP |
| n ≤ 10⁵ | O(n log n) | Sorting, heap operations |
| n ≤ 10⁶ | O(n) | Hash map, linear scan |
| n ≤ 10⁹ | O(log n) | Binary search |
| Any n | O(1) | Math formulas, hash lookup |
