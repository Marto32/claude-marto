# Data Structures Reference

This guide helps select the appropriate data structure for specific use cases. Always prefer well-tested libraries over custom implementations unless the use case is trivial.

## Arrays and Lists

### Dynamic Arrays (Lists)
**Use when:**
- Need indexed access (O(1) lookup by position)
- Order matters
- Appending to end is primary operation
- Memory locality is important for performance

**Common operations:**
- Access by index: O(1)
- Append to end: O(1) amortized
- Insert/delete at arbitrary position: O(n)
- Search unsorted: O(n)

**Library recommendations:**
- Python: Built-in `list`
- JavaScript: Built-in `Array`
- Java: `ArrayList`
- C++: `std::vector`
- Rust: `Vec<T>`
- Go: Slices

**Avoid custom implementation:** Almost never needed

### Linked Lists
**Use when:**
- Frequent insertions/deletions at beginning or middle
- Size changes frequently
- Don't need random access
- Building more complex structures (LRU cache, adjacency lists)

**Common operations:**
- Insert/delete at known position: O(1)
- Access by index: O(n)
- Search: O(n)

**Library recommendations:**
- Python: `collections.deque` (doubly-linked)
- Java: `LinkedList`
- C++: `std::list` (doubly-linked), `std::forward_list` (singly-linked)
- Rust: `std::collections::LinkedList`

**Custom implementation:** Only for educational purposes or specialized variants (e.g., skip lists)

## Hash-Based Structures

### Hash Maps (Dictionaries)
**Use when:**
- Need fast key-value lookups
- Keys are hashable
- Order doesn't matter (or use ordered variant)
- Want O(1) average case operations

**Common operations:**
- Insert/delete/lookup: O(1) average, O(n) worst
- Iteration: O(n)

**Library recommendations:**
- Python: Built-in `dict`, `collections.defaultdict`, `collections.Counter`
- JavaScript: Built-in `Map`, `Object`
- Java: `HashMap`, `LinkedHashMap` (ordered)
- C++: `std::unordered_map`
- Rust: `HashMap`, `BTreeMap` (ordered)
- Go: Built-in `map`

**Avoid custom implementation:** Hashing is complex and error-prone

### Hash Sets
**Use when:**
- Need to track unique elements
- Fast membership testing
- Deduplication
- Set operations (union, intersection, difference)

**Common operations:**
- Insert/delete/contains: O(1) average
- Set operations: O(n)

**Library recommendations:**
- Python: Built-in `set`, `frozenset`
- JavaScript: Built-in `Set`
- Java: `HashSet`, `LinkedHashSet` (ordered)
- C++: `std::unordered_set`
- Rust: `HashSet`, `BTreeSet` (ordered)
- Go: Use `map[K]struct{}`

**Avoid custom implementation:** Use hash map implementation as foundation if needed

## Tree-Based Structures

### Binary Search Trees (Balanced)
**Use when:**
- Need sorted data with fast operations
- Range queries are important
- Need min/max operations
- Want ordered iteration

**Common operations:**
- Insert/delete/search: O(log n) for balanced trees
- Min/max: O(log n) or O(1) with caching
- Range queries: O(log n + k) where k is results

**Library recommendations:**
- Python: `sortedcontainers.SortedDict`, `sortedcontainers.SortedList`, `sortedcontainers.SortedSet`
- Java: `TreeMap`, `TreeSet`
- C++: `std::map`, `std::set` (usually Red-Black trees)
- Rust: `BTreeMap`, `BTreeSet`
- Go: No built-in, use third-party like `google/btree`

**Custom implementation:** Rarely needed; balanced trees (AVL, Red-Black) are complex

### Heaps (Priority Queues)
**Use when:**
- Need repeated min/max extraction
- Implementing priority-based algorithms (Dijkstra, A*, Huffman coding)
- K-largest/smallest problems
- Median maintenance

**Common operations:**
- Insert: O(log n)
- Extract min/max: O(log n)
- Peek min/max: O(1)
- Build from array: O(n)

**Library recommendations:**
- Python: `heapq` (min-heap), `queue.PriorityQueue`
- JavaScript: No built-in, use library like `heap-js`
- Java: `PriorityQueue`
- C++: `std::priority_queue`, heap algorithms in `<algorithm>`
- Rust: `std::collections::BinaryHeap`
- Go: `container/heap` interface

**Custom implementation:** Simple to implement for basic cases, but use libraries for production

### Tries (Prefix Trees)
**Use when:**
- Autocomplete/typeahead
- Spell checking
- IP routing tables
- Dictionary implementations
- Prefix matching

**Common operations:**
- Insert/search word: O(m) where m is word length
- Prefix search: O(m + k) where k is results
- Space: O(ALPHABET_SIZE * N * M)

**Library recommendations:**
- Python: `pygtrie`, `marisa-trie` (compressed)
- Java: No standard library, use third-party
- C++: No standard library, implement or use third-party
- Rust: `radix_trie`
- Go: No standard library, implement or use third-party

**Custom implementation:** Acceptable for basic tries; use compressed tries (PATRICIA, radix) from libraries

## Queue and Stack Structures

### Stacks (LIFO)
**Use when:**
- Need last-in-first-out ordering
- Recursive algorithms (DFS, expression evaluation)
- Undo mechanisms
- Backtracking

**Common operations:**
- Push/pop: O(1)
- Peek: O(1)

**Library recommendations:**
- Python: `list` (use append/pop), `collections.deque`
- JavaScript: `Array` (use push/pop)
- Java: `Stack` (legacy), `ArrayDeque` (preferred)
- C++: `std::stack`
- Rust: `Vec<T>` (use push/pop)
- Go: Slice with append

**Custom implementation:** Trivial, but use built-ins

### Queues (FIFO)
**Use when:**
- Need first-in-first-out ordering
- BFS algorithms
- Task scheduling
- Buffer management

**Common operations:**
- Enqueue/dequeue: O(1)
- Peek: O(1)

**Library recommendations:**
- Python: `collections.deque`
- JavaScript: `Array` (shift/push) or better libraries
- Java: `ArrayDeque`, `LinkedList`
- C++: `std::queue`
- Rust: `VecDeque`
- Go: Use buffered channels or `container/list`

**Custom implementation:** Trivial with linked list or circular buffer

### Deques (Double-Ended Queues)
**Use when:**
- Need efficient operations at both ends
- Sliding window problems
- Palindrome checking
- Work-stealing queues

**Common operations:**
- Push/pop at either end: O(1)

**Library recommendations:**
- Python: `collections.deque`
- Java: `ArrayDeque`
- C++: `std::deque`
- Rust: `VecDeque`

**Custom implementation:** Not recommended

## Specialized Structures

### Union-Find (Disjoint Set)
**Use when:**
- Connected components in graphs
- Kruskal's MST algorithm
- Cycle detection
- Network connectivity

**Common operations:**
- Union: O(α(n)) ≈ O(1) with path compression
- Find: O(α(n)) ≈ O(1) with path compression
- α(n) is inverse Ackermann function

**Library recommendations:**
- Python: No standard library, implement or use `networkx`
- Java: No standard library, implement
- C++: No standard library, implement
- Rust: `petgraph::unionfind`

**Custom implementation:** Recommended - simple and educational (~20-30 lines)

### Graphs (Adjacency List/Matrix)
**Use when:**
- Representing networks, relationships, dependencies
- Path finding
- Network flow
- Social networks

**Representations:**
- Adjacency list: Better for sparse graphs, O(V + E) space
- Adjacency matrix: Better for dense graphs, O(V²) space

**Library recommendations:**
- Python: `networkx` (comprehensive), `graph-tool` (performance)
- JavaScript: `graphlib`, `cytoscape`
- Java: `JGraphT`
- C++: Boost Graph Library
- Rust: `petgraph`
- Go: `gonum/graph`

**Custom implementation:** Basic representations are simple (adjacency list with hash map); use libraries for algorithms

### Bloom Filters
**Use when:**
- Space-constrained membership testing
- Can tolerate false positives
- Web crawlers (URL deduplication)
- Cache filtering

**Common operations:**
- Insert: O(k) where k is hash functions
- Query: O(k) - may have false positives
- Space: Very efficient

**Library recommendations:**
- Python: `pybloom-live`
- Java: Guava's `BloomFilter`
- C++: No standard library, use third-party
- Rust: `bloomfilter`
- Go: `bits-and-blooms/bloom`

**Custom implementation:** Not recommended - tuning parameters is non-trivial

### Segment Trees / Fenwick Trees (BIT)
**Use when:**
- Range query problems (sum, min, max)
- Cumulative frequency tables
- Competitive programming

**Common operations:**
- Range query: O(log n)
- Point update: O(log n)
- Build: O(n) or O(n log n)

**Library recommendations:**
- Python: No standard library, implement
- Most languages: No standard library, implement

**Custom implementation:** Acceptable - well-documented pattern, commonly implemented for specific problems

### LRU/LFU Caches
**Use when:**
- Caching with eviction policies
- Database query caching
- Web page caching

**Common operations:**
- Get: O(1)
- Put: O(1)

**Library recommendations:**
- Python: `functools.lru_cache` (decorator), `cachetools`
- Java: Guava's `Cache`
- JavaScript: `lru-cache` npm package
- C++: No standard library, third-party
- Rust: `lru` crate

**Custom implementation:** Good interview/learning problem (hash map + doubly-linked list)

## Immutable and Persistent Structures

**Use when:**
- Functional programming
- Concurrent programming without locks
- Version control (need history)
- Undo/redo systems

**Library recommendations:**
- Python: `pyrsistent`
- JavaScript: `immutable-js`
- Java: Guava's `Immutable*` collections
- Rust: `im` crate
- Scala/Clojure: Built-in persistent collections

**Custom implementation:** Very complex - use libraries

## Decision Framework

1. **Start with the simplest structure** that meets requirements
2. **Use built-in/standard library first** - battle-tested and optimized
3. **Profile before optimizing** - don't assume you need exotic structures
4. **Consider third-party libraries** for specialized structures
5. **Implement custom only when:**
   - Educational purpose
   - Very simple structure (< 50 lines)
   - Extremely specialized requirements
   - No suitable library exists
