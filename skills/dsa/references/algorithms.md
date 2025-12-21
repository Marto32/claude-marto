# Algorithms Reference

This guide helps select appropriate algorithms for common problems. Always prefer well-tested library implementations over custom code unless the algorithm is trivial or highly specialized.

## Sorting Algorithms

### When to Sort
- Data analysis and statistics (median, percentiles)
- Binary search preprocessing
- Grouping and organizing data
- Finding duplicates or unique elements
- Merge operations

### Library Sorting
**Always use built-in sorting unless you have specific constraints**

**Library recommendations:**
- Python: `sorted()`, `list.sort()`, `heapq.nsmallest/nlargest` for partial sorting
- JavaScript: `Array.sort()`, `Array.toSorted()`
- Java: `Arrays.sort()`, `Collections.sort()`
- C++: `std::sort()`, `std::stable_sort()`
- Rust: `slice.sort()`, `slice.sort_unstable()`
- Go: `sort.Slice()`, `sort.Sort()`

**Time complexity:** O(n log n) for comparison-based sorting

### Specialized Sorting

**Counting Sort** - For small integer ranges
- Time: O(n + k) where k is range
- Use when: Sorting integers in range [0, k] where k is small
- Custom implementation: Simple, acceptable for specific problems

**Radix Sort** - For fixed-width integers/strings
- Time: O(d * n) where d is digits/characters
- Use when: Sorting strings or large integers
- Library: Python `str.sort()` uses variant; implement for specific cases

**Custom comparators:**
- All languages support custom comparison functions
- Use for complex sorting criteria (multi-field, custom ordering)

## Searching Algorithms

### Linear Search
**Use when:**
- Unsorted data
- Small datasets (< 100 elements)
- Single search

**Implementation:** Use language built-ins
- Python: `in` operator, `list.index()`, `next(filter(...))`
- JavaScript: `Array.includes()`, `Array.find()`, `Array.findIndex()`
- Others: Simple loop

**Time complexity:** O(n)

### Binary Search
**Use when:**
- Sorted data
- Multiple searches on same data
- Finding insertion point
- First/last occurrence

**Library recommendations:**
- Python: `bisect` module (`bisect_left`, `bisect_right`)
- JavaScript: No built-in, implement or use lodash `_.sortedIndex`
- Java: `Arrays.binarySearch()`, `Collections.binarySearch()`
- C++: `std::binary_search()`, `std::lower_bound()`, `std::upper_bound()`
- Rust: `slice.binary_search()`
- Go: `sort.Search()`

**Custom implementation:** Acceptable - algorithm is simple but edge cases are tricky

**Time complexity:** O(log n)

### Two Pointers / Sliding Window
**Use when:**
- Finding pairs/triplets in sorted arrays
- Substring problems
- Array partitioning
- Removing duplicates in-place

**Implementation:** Simple pattern, implement as needed

**Common patterns:**
- Two pointers moving toward each other (palindrome, pair sum)
- Two pointers moving same direction (remove duplicates)
- Sliding window with expansion/contraction (longest substring)

## Graph Algorithms

### Graph Traversal

**Breadth-First Search (BFS)**
**Use when:**
- Shortest path in unweighted graphs
- Level-order processing
- Finding all nodes at distance k
- Connected components

**Library vs Custom:**
- Simple enough to implement with queue
- Use graph libraries for complex graphs
- Python `networkx`: `nx.bfs_edges()`, `nx.bfs_tree()`

**Time complexity:** O(V + E)

**Depth-First Search (DFS)**
**Use when:**
- Path existence
- Topological sorting
- Cycle detection
- Connected components
- Backtracking problems

**Library vs Custom:**
- Simple enough to implement (recursive or stack)
- Use graph libraries for complex operations
- Python `networkx`: `nx.dfs_edges()`, `nx.dfs_tree()`

**Time complexity:** O(V + E)

### Shortest Path

**Dijkstra's Algorithm**
**Use when:**
- Single-source shortest path
- Non-negative edge weights
- Road networks, routing

**Library recommendations:**
- Python: `networkx.shortest_path()`, `networkx.dijkstra_path()`
- Java: JGraphT
- C++: Boost Graph Library
- Rust: `petgraph::algo::dijkstra`

**Custom implementation:** Moderate complexity - use library unless educational

**Time complexity:** O((V + E) log V) with min-heap

**Bellman-Ford Algorithm**
**Use when:**
- Negative edge weights allowed
- Detecting negative cycles
- Single-source shortest path

**Library recommendations:**
- Python: `networkx.bellman_ford_path()`
- Most graph libraries provide this

**Custom implementation:** Acceptable - algorithm is straightforward

**Time complexity:** O(V * E)

**Floyd-Warshall Algorithm**
**Use when:**
- All-pairs shortest paths
- Small to medium graphs (V ≤ 500)
- Transitive closure

**Library recommendations:**
- Python: `networkx.floyd_warshall()`

**Custom implementation:** Very simple - just three nested loops

**Time complexity:** O(V³)

**A\* Search**
**Use when:**
- Shortest path with heuristic
- Game pathfinding
- Route planning with goal

**Library recommendations:**
- Python: `networkx.astar_path()`
- Pathfinding libraries in most languages

**Custom implementation:** Moderate - similar to Dijkstra with heuristic

### Graph Properties

**Topological Sort**
**Use when:**
- Task scheduling with dependencies
- Build systems
- Course prerequisites
- Detecting cycles in directed graphs

**Library recommendations:**
- Python: `networkx.topological_sort()`
- Graph libraries provide this

**Custom implementation:** Acceptable - DFS-based or Kahn's algorithm

**Time complexity:** O(V + E)

**Minimum Spanning Tree**
**Use when:**
- Connecting all nodes with minimum cost
- Network design
- Clustering

**Algorithms:**
- Kruskal's (edge-based, uses Union-Find)
- Prim's (vertex-based, uses min-heap)

**Library recommendations:**
- Python: `networkx.minimum_spanning_tree()`
- Graph libraries provide both algorithms

**Custom implementation:** Acceptable for learning - both are well-documented

**Time complexity:** O(E log V) for both

**Strongly Connected Components**
**Use when:**
- Finding cycles in directed graphs
- Web graph analysis
- Compiler optimization

**Algorithms:**
- Kosaraju's algorithm
- Tarjan's algorithm

**Library recommendations:**
- Python: `networkx.strongly_connected_components()`

**Custom implementation:** Moderate complexity - use library

## Dynamic Programming

**Use when:**
- Optimization problems with overlapping subproblems
- Counting problems
- Decision problems

**Common patterns:**
1. **Fibonacci/Climbing Stairs** - Sequential dependency
2. **Knapsack** - Subset selection with constraints
3. **Longest Common Subsequence** - String/array matching
4. **Edit Distance** - String transformation
5. **Matrix Chain Multiplication** - Optimal ordering
6. **Coin Change** - Combinations with target
7. **Longest Increasing Subsequence** - Sequence optimization

**Approach:**
1. Identify recursive structure
2. Add memoization (top-down) OR
3. Build table (bottom-up)

**Library support:**
- Python: `functools.lru_cache` for memoization
- Most languages: Implement as needed

**Custom implementation:** Almost always custom - problem-specific

**Optimization:**
- Space optimization: Often can reduce from 2D to 1D array
- Use bitmask DP for subset problems

## String Algorithms

### Pattern Matching

**Simple Search**
**Use when:**
- Single pattern search
- Pattern length < 10
- No repeated searches

**Library:**
- Python: `str.find()`, `str.index()`, `in` operator
- JavaScript: `String.includes()`, `String.indexOf()`
- All languages have built-in methods

**Time complexity:** O(n * m) worst case, but very fast in practice

**KMP (Knuth-Morris-Pratt)**
**Use when:**
- Multiple searches for same pattern
- Long patterns
- Need to avoid backtracking

**Library recommendations:**
- Most languages: Implement as needed
- Not commonly in standard libraries

**Custom implementation:** Moderate complexity - educational value

**Time complexity:** O(n + m)

**Rabin-Karp**
**Use when:**
- Multiple pattern search
- Plagiarism detection
- Rolling hash problems

**Custom implementation:** Acceptable - uses hashing

**Time complexity:** O(n + m) average, O(n * m) worst

**Boyer-Moore**
**Use when:**
- Large texts, long patterns
- Maximum performance needed

**Custom implementation:** Complex - use specialized libraries

**Aho-Corasick**
**Use when:**
- Searching multiple patterns simultaneously
- Dictionary matching
- Virus scanning

**Library recommendations:**
- Python: `pyahocorasick`
- Other languages: Specialized libraries

**Custom implementation:** Not recommended

### String Manipulation

**Longest Common Subsequence**
- Use dynamic programming
- Custom implementation common

**Longest Common Substring**
- Use DP or suffix array
- Custom implementation for DP variant

**Edit Distance (Levenshtein)**
- Use dynamic programming
- Python: `python-Levenshtein` library available
- Custom implementation: Acceptable

**Regular Expressions**
- Use built-in regex engines
- Python: `re`, JavaScript: `RegExp`, etc.
- Never implement regex engine

## Divide and Conquer

**Use when:**
- Problem can be broken into independent subproblems
- Combine step is efficient
- Tree-like problem structure

**Common applications:**
- Merge Sort
- Quick Sort (randomized)
- Binary Search
- Closest pair of points
- Strassen's matrix multiplication

**Implementation:** Usually custom based on problem

## Greedy Algorithms

**Use when:**
- Optimal substructure exists
- Greedy choice property holds
- Local optimum leads to global optimum

**Common problems:**
- Activity selection
- Huffman coding
- Minimum spanning tree (Kruskal, Prim)
- Dijkstra's shortest path
- Interval scheduling

**Warning:** Verify greedy approach works before implementing - not all optimization problems have greedy solutions

## Backtracking

**Use when:**
- Exhaustive search needed
- Constraints allow pruning
- Finding all/optimal solutions

**Common problems:**
- N-Queens
- Sudoku solver
- Subset sum
- Permutations/combinations
- Graph coloring

**Implementation:** Almost always custom - problem-specific

**Optimization:**
- Constraint propagation
- Heuristic ordering
- Memorization of states

## Mathematical Algorithms

### Number Theory

**GCD/LCM**
- Python: `math.gcd()`, `math.lcm()` (3.9+)
- Custom implementation: Euclidean algorithm is simple

**Prime Numbers**
- Sieve of Eratosthenes: Implement for range
- Primality testing: Use `sympy.isprime()` for large numbers
- Python: `sympy` library for number theory

**Modular Arithmetic**
- Modular exponentiation: `pow(base, exp, mod)` in Python
- Modular inverse: Use extended Euclidean algorithm

### Combinatorics

**Permutations/Combinations**
- Python: `itertools.permutations()`, `itertools.combinations()`
- Math formulas: `math.comb()`, `math.perm()` (Python 3.8+)

**Custom implementation:** Rarely needed - use libraries

## Bit Manipulation

**Use when:**
- Space optimization
- Fast operations
- Subset enumeration
- Single-number problems

**Common operations:**
- Set bit: `x | (1 << i)`
- Clear bit: `x & ~(1 << i)`
- Toggle bit: `x ^ (1 << i)`
- Check bit: `(x >> i) & 1`
- Count set bits: Python `bin(x).count('1')` or bit tricks
- Get rightmost set bit: `x & -x`

**Libraries:**
- Python: `bin()`, bitwise operators
- Most languages: Built-in operators

**Custom implementation:** Simple operations are fine

## Decision Framework

1. **Check for library implementation first**
2. **For classic algorithms (sorting, searching):** Always use libraries
3. **For graph algorithms:** Use graph libraries when available
4. **For DP/backtracking:** Usually custom implementation
5. **For simple algorithms (< 30 lines):** Acceptable to implement
6. **For complex algorithms:** Use libraries unless:
   - Highly specialized requirements
   - Educational purpose
   - No suitable library exists
7. **Always prioritize correctness over performance** - optimize only after measuring
