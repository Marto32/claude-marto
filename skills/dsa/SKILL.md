---
name: dsa
description: "Code-agnostic guidance for selecting appropriate data structures and algorithms to solve specific classes of problems. Use when agents need to determine which DSA approaches, patterns, or library implementations to use for: (1) Performance optimization problems, (2) Choosing between data structure options (arrays, trees, graphs, hash maps), (3) Identifying algorithmic patterns (DP, greedy, backtracking), (4) Mapping problem types to solutions, (5) Finding language-specific library implementations instead of custom code. Strongly emphasizes using well-tested libraries over implementing from scratch."
---

# Data Structures and Algorithms Selection Guide

## Overview

This skill helps agents select the most appropriate data structures and algorithms for solving specific problems. It provides language-agnostic guidance on when to use specific DSA patterns and, critically, when to use existing library implementations versus custom code.

**Core Philosophy:** Always prefer battle-tested library implementations over custom code unless the implementation is trivial (< 30 lines) or highly specialized.

## Quick Decision Framework

When faced with a problem requiring DSA:

1. **Identify the problem pattern** → See references/problem-patterns.md
2. **Select data structure** → See references/data-structures.md
3. **Choose algorithm** → See references/algorithms.md
4. **Find library implementation** → Use context7 or language docs
5. **Implement custom only if:**
   - Very simple (< 30 lines)
   - Educational purpose
   - Highly specialized with no library
   - Performance-critical after profiling

## When to Use This Skill

Use this skill when:

- **Optimizing performance:** Need to improve time/space complexity
- **Choosing data structures:** Multiple options exist (array vs hash map vs tree)
- **Recognizing patterns:** Problem feels familiar but unclear which approach
- **Finding libraries:** Need to locate language-appropriate implementations
- **Avoiding custom code:** Want to use proven solutions instead of reinventing
- **Interview preparation:** Learning DSA patterns and trade-offs

## Core Workflow

### Step 1: Understand the Problem

Before selecting DSA, clarify:

- **Input characteristics:** Size, range, sorted/unsorted, mutable/immutable
- **Operations needed:** Search, insert, delete, update, range queries
- **Constraints:** Time limits, space limits, online/offline processing
- **Expected complexity:** What's acceptable? O(n)? O(n log n)? O(n²)?

### Step 2: Identify the Pattern

Most problems fit established patterns. Read `references/problem-patterns.md` to find:

- **Array/String patterns:** Two pointers, sliding window, prefix sum
- **Tree patterns:** Traversal, BST operations, path problems
- **Graph patterns:** Shortest path, connectivity, topological sort
- **DP patterns:** Linear, 2D grid, subsequence, knapsack, interval
- **Backtracking patterns:** Subsets, permutations, grid exploration
- **Design patterns:** LRU cache, trie, union-find

**Example:** "Find all pairs that sum to target" → Two pointers or hash map pattern

### Step 3: Select Data Structure

Based on operations and constraints, choose appropriate data structure. Read `references/data-structures.md` for detailed guidance on:

- **Arrays/Lists:** Indexed access, sequential processing
- **Hash Maps/Sets:** Fast lookup, uniqueness, grouping
- **Trees:** Sorted data, hierarchical relationships, range queries
- **Heaps:** Priority operations, K-largest/smallest
- **Graphs:** Network relationships, paths, connectivity
- **Specialized:** Tries, union-find, segment trees

**Key Decision Points:**

| Need | Use | Avoid |
|------|-----|-------|
| Fast lookup by key | Hash map | Linear search in array |
| Sorted order + fast ops | Balanced BST | Sorting repeatedly |
| Priority extraction | Heap | Sorting each time |
| Range queries | Segment/Fenwick tree | Linear scan |
| Connectivity | Union-Find | Repeated DFS/BFS |

### Step 4: Choose Algorithm

Select algorithm based on problem type. Read `references/algorithms.md` for comprehensive coverage of:

- **Sorting:** When to sort, which algorithm, library usage
- **Searching:** Linear, binary, pattern matching
- **Graph algorithms:** BFS, DFS, Dijkstra, Floyd-Warshall, MST, topological sort
- **Dynamic Programming:** Recognize DP problems, common patterns
- **Greedy:** When greedy works, verification strategies
- **Divide and Conquer:** Breaking down problems
- **Backtracking:** Exhaustive search with pruning

**Complexity Guidelines by Input Size:**

| Input Size | Max Complexity | Approach |
|-----------|----------------|----------|
| n ≤ 10 | O(n!) | Backtracking, permutations |
| n ≤ 20 | O(2^n) | Subsets, bitmask DP |
| n ≤ 100 | O(n³) | Floyd-Warshall, cubic DP |
| n ≤ 1000 | O(n²) | Nested loops, quadratic DP |
| n ≤ 10⁵ | O(n log n) | Sorting, balanced trees |
| n ≤ 10⁶ | O(n) | Hash maps, linear algorithms |
| n ≤ 10⁹ | O(log n) | Binary search, math |
| Any n | O(1) | Hash lookup, formulas |

### Step 5: Find Library Implementation

**Critical Step:** Before implementing anything, search for library implementations.

**For data structures, use context7 or search:**

- Python: Check built-ins, `collections`, `heapq`, third-party like `sortedcontainers`, `networkx`
- JavaScript: Built-ins, npm packages
- Java: `java.util.*` collections
- C++: STL containers and algorithms
- Rust: Standard collections, crates.io
- Go: Standard library, modules

**For algorithms, search for:**

- Graph libraries: networkx (Python), JGraphT (Java), Boost Graph (C++), petgraph (Rust)
- Specialized libraries: NumPy/SciPy for numerical, regex for patterns, etc.

**Use context7 workflow:**

1. Identify the data structure or algorithm needed
2. Use context7 to find language-specific libraries
3. Read documentation for API and usage examples
4. Implement using the library

**Example workflow:**
```
User needs: "Find shortest path in weighted graph"
Pattern: Shortest path algorithm (Dijkstra)
Library search: Use context7 for "networkx shortest path" or "boost graph dijkstra"
Implementation: Use library functions, don't implement Dijkstra from scratch
```

### Step 6: Implement or Use Library

**Decision matrix:**

| Scenario | Action |
|----------|--------|
| Standard library exists | ✅ Always use it |
| Well-known third-party library | ✅ Use it |
| Simple algorithm (< 30 lines) | ⚠️ Consider implementing (e.g., binary search, DFS) |
| Complex algorithm | ❌ Find library or use simpler approach |
| Specialized requirement | ⚠️ Custom only if necessary |
| Educational purpose | ✅ Implement but note it's for learning |

## Common Patterns and Solutions

### Array Problems → Use Hash Maps

**Pattern:** Two sum, checking pairs, frequency counting

```python
# ❌ Don't: Nested loops O(n²)
for i in range(len(arr)):
    for j in range(i+1, len(arr)):
        if arr[i] + arr[j] == target:
            return True

# ✅ Do: Hash map O(n)
seen = set()
for num in arr:
    if target - num in seen:
        return True
    seen.add(num)
```

### Sorted Data → Use Binary Search

**Pattern:** Search in sorted array, find bounds

```python
# ✅ Use library
import bisect
idx = bisect.bisect_left(arr, target)  # Find insertion point

# ⚠️ Or implement (it's simple but edge cases are tricky)
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = left + (right - left) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
```

### Graph Problems → Use Libraries

**Pattern:** Shortest path, connectivity, components

```python
# ✅ Do: Use graph library
import networkx as nx

G = nx.Graph()
G.add_edges_from([(1, 2), (2, 3), (3, 4)])
path = nx.shortest_path(G, source=1, target=4)

# ❌ Don't: Implement Dijkstra unless necessary
# (Hundreds of lines, easy to get wrong)
```

### Dynamic Programming → Often Custom

**Pattern:** Optimization with overlapping subproblems

```python
# ✅ Use memoization decorator
from functools import lru_cache

@lru_cache(maxsize=None)
def fib(n):
    if n <= 1:
        return n
    return fib(n-1) + fib(n-2)

# ✅ Or bottom-up DP (problem-specific)
def coin_change(coins, amount):
    dp = [float('inf')] * (amount + 1)
    dp[0] = 0
    for i in range(1, amount + 1):
        for coin in coins:
            if coin <= i:
                dp[i] = min(dp[i], dp[i - coin] + 1)
    return dp[amount] if dp[amount] != float('inf') else -1
```

### String Matching → Use Built-ins or Regex

**Pattern:** Finding substrings, pattern matching

```python
# ✅ Do: Use built-in methods
text = "hello world"
if "world" in text:  # Simple substring
    print("found")

# ✅ Or regex for patterns
import re
if re.search(r'\b\w{5}\b', text):  # Find 5-letter words
    print("matched")

# ❌ Don't: Implement KMP, Boyer-Moore unless specific need
```

## Anti-Patterns to Avoid

### 1. Premature Optimization

❌ **Don't** jump to complex data structures without measuring
✅ **Do** start simple, profile, then optimize

### 2. Custom Implementation of Standard Algorithms

❌ **Don't** implement sorting, hash maps, balanced trees from scratch
✅ **Do** use language standard libraries

### 3. Wrong Data Structure

❌ **Don't** use array when you need fast lookup → Use hash map
❌ **Don't** use hash map when you need sorted iteration → Use balanced BST
✅ **Do** match structure to required operations

### 4. Ignoring Time Complexity

❌ **Don't** use O(n²) when input can be 10⁶
✅ **Do** check constraints and ensure complexity is acceptable

### 5. Reinventing the Wheel

❌ **Don't** implement graph algorithms, regex engines, or compression
✅ **Do** use specialized libraries for complex domains

## Language-Specific Library Guidance

### Python
- **Arrays:** `list`, `collections.deque`
- **Hash:** `dict`, `set`, `collections.Counter`, `collections.defaultdict`
- **Sorted:** `sortedcontainers` (SortedList, SortedDict, SortedSet)
- **Heaps:** `heapq`, `queue.PriorityQueue`
- **Graphs:** `networkx`, `graph-tool`
- **Strings:** `re` (regex), built-in string methods
- **Algorithms:** `itertools`, `functools`, `bisect`

### JavaScript
- **Arrays:** `Array`
- **Hash:** `Map`, `Set`, `Object`
- **Sorted:** No built-in, use libraries like `sorted-array`
- **Heaps:** No built-in, use npm packages like `heap-js`
- **Graphs:** `graphlib`, `cytoscape.js`
- **Strings:** `String`, `RegExp`

### Java
- **Arrays:** `ArrayList`, `LinkedList`
- **Hash:** `HashMap`, `HashSet`, `LinkedHashMap`
- **Sorted:** `TreeMap`, `TreeSet`
- **Heaps:** `PriorityQueue`
- **Graphs:** JGraphT, Apache Commons Graph
- **Collections:** Rich `java.util.*` ecosystem

### C++
- **Arrays:** `std::vector`, `std::array`, `std::deque`
- **Hash:** `std::unordered_map`, `std::unordered_set`
- **Sorted:** `std::map`, `std::set`
- **Heaps:** `std::priority_queue`, heap algorithms
- **Graphs:** Boost Graph Library
- **Algorithms:** STL `<algorithm>` header

### Rust
- **Arrays:** `Vec<T>`, `VecDeque<T>`
- **Hash:** `HashMap`, `HashSet`
- **Sorted:** `BTreeMap`, `BTreeSet`
- **Heaps:** `BinaryHeap`
- **Graphs:** `petgraph` crate
- **Collections:** Rich standard library

### Go
- **Arrays:** Slices
- **Hash:** `map`
- **Sorted:** No built-in ordered map, use third-party
- **Heaps:** `container/heap` interface
- **Graphs:** `gonum/graph`

## Resources

### references/data-structures.md
Comprehensive guide to data structures including:

- Arrays, lists, linked lists
- Hash maps, hash sets
- Trees (BST, heaps, tries)
- Graphs, queues, stacks
- Specialized structures (union-find, segment trees, bloom filters)
- When to use each structure
- Library recommendations per language
- Custom implementation guidance

**Read this when:** Choosing between data structure options

### references/algorithms.md
Comprehensive guide to algorithms including:

- Sorting and searching
- Graph algorithms (BFS, DFS, Dijkstra, Floyd-Warshall, MST, topological sort)
- Dynamic programming patterns
- String algorithms (KMP, Rabin-Karp, Boyer-Moore)
- Divide and conquer, greedy, backtracking
- Mathematical algorithms
- Bit manipulation

**Read this when:** Implementing specific algorithms or choosing algorithmic approach

### references/problem-patterns.md
Maps common problem types to DSA solutions including:

- Array patterns (two pointers, sliding window, prefix sum)
- Tree patterns (traversal, BST, LCA, paths)
- Graph patterns (connectivity, shortest path, topological sort, cycles)
- DP patterns (linear, 2D grid, subsequence, knapsack, interval, state machine)
- Backtracking patterns (subsets, permutations, grid exploration)
- Design patterns (LRU cache, trie, union-find)
- Complexity cheat sheet by input size

**Read this when:** Problem seems familiar but unclear which approach to use

## Best Practices

1. **Understand before coding:** Clarify constraints and requirements first
2. **Check for patterns:** Most problems fit known patterns
3. **Library first:** Search for existing implementations
4. **Start simple:** Use simplest solution that meets requirements
5. **Profile before optimizing:** Don't assume bottlenecks
6. **Correctness over cleverness:** Clear code beats clever code
7. **Test edge cases:** Empty input, single element, duplicates, negatives
8. **Document complexity:** Note time and space complexity in comments
9. **Use context7:** Find language-appropriate library implementations
10. **Iterate:** Get working solution first, optimize second

## Example Workflows

### Example 1: Finding Pairs with Target Sum

**Problem:** Given array, find all pairs that sum to target

**Step 1:** Identify pattern → Two pointers or hash map
**Step 2:** Consider constraints → Is array sorted? Size?
**Step 3:** Choose approach:
- If sorted: Two pointers O(n)
- If unsorted: Hash map O(n)
**Step 4:** Implement using built-ins (set/dict in Python, Set/Map in JS)

### Example 2: Shortest Path in Weighted Graph

**Problem:** Find shortest path between two nodes in weighted graph

**Step 1:** Identify pattern → Shortest path (graph algorithm)
**Step 2:** Consider constraints → Negative weights? Graph size?
**Step 3:** Choose algorithm:
- Non-negative weights: Dijkstra
- Negative weights: Bellman-Ford
- All pairs: Floyd-Warshall
**Step 4:** Use context7 to find library (e.g., `networkx.dijkstra_path()`)
**Step 5:** Implement using library function

### Example 3: Maximum Subarray Sum

**Problem:** Find contiguous subarray with largest sum

**Step 1:** Identify pattern → Array optimization problem
**Step 2:** Recognize as Kadane's algorithm (DP variant)
**Step 3:** Simple enough to implement (< 10 lines):
```python
def max_subarray(arr):
    max_sum = current_sum = arr[0]
    for num in arr[1:]:
        current_sum = max(num, current_sum + num)
        max_sum = max(max_sum, current_sum)
    return max_sum
```
**Step 4:** Note: Also available in NumPy for numerical arrays

### Example 4: LRU Cache

**Problem:** Implement Least Recently Used cache

**Step 1:** Identify pattern → Design problem (cache with eviction)
**Step 2:** Check references/problem-patterns.md → LRU pattern
**Step 3:** Find library:
- Python: `functools.lru_cache` decorator or `cachetools.LRUCache`
- JavaScript: `lru-cache` npm package
- Java: Guava's `Cache`
**Step 4:** Use library instead of implementing hash map + doubly-linked list

## Summary

- **Pattern recognition** is key to selecting right DSA
- **Libraries over custom** for complex data structures and algorithms
- **Simple implementations** acceptable for basic algorithms (< 30 lines)
- **Context7** is your friend for finding language-specific libraries
- **Complexity matters** - check input constraints first
- **Test and iterate** - working solution beats perfect solution
