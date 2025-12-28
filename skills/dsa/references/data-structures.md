# Structural Patterns

This section catalogs patterns for organizing and accessing data. Each pattern represents a proven approach to structuring information for efficient access and modification.

---

## Sequential Access Patterns

### Dynamic Array

**Intent**

Provide indexed access to a sequence of elements with efficient append operations, while automatically managing storage capacity.

**Motivation**

Consider building a log of user actions in an application. Actions arrive sequentially and must be stored for later analysis. You need to append new actions efficiently and access any action by its position. A fixed-size array would require predicting the final size; a linked list would sacrifice random access. The dynamic array provides both capabilities.

**Applicability**

Use Dynamic Array when:
- Elements are accessed primarily by position (index)
- Order of elements matters
- Appending to the end is the dominant modification
- You need predictable memory locality for iteration performance

Avoid when:
- Frequent insertions or deletions occur at arbitrary positions
- The collection size is known and fixed at creation time
- Memory fragmentation from reallocation is unacceptable

**Structure**

A contiguous block of memory with tracked size and capacity. When size exceeds capacity, a larger block is allocated and elements are copied. Typical growth factor is 1.5x to 2x.

**Consequences**

Benefits:
- Constant-time indexed access
- Amortized constant-time append
- Excellent cache locality for sequential access
- Memory-efficient for dense data

Liabilities:
- Linear-time insertion/deletion at arbitrary positions
- Reallocation causes occasional linear-time operations
- May waste memory when capacity exceeds size
- Not suitable for very large individual elements

**Implementation Notes**

Standard libraries universally provide this pattern. Custom implementation is rarely justified.

**Related Patterns**

- *Linked List*: When frequent mid-sequence modifications dominate
- *Deque*: When both ends require efficient operations
- *Hash Table*: When key-based access is needed instead of positional

---

### Linked List

**Intent**

Enable constant-time insertion and deletion at any known position in a sequence, at the cost of sequential-only traversal.

**Motivation**

Consider implementing an undo/redo system where operations can be inserted or removed at the current cursor position. Users navigate back and forth, and each undo/redo modifies the sequence at the current point. A dynamic array would require shifting all subsequent elements; the linked list allows modification at the cursor in constant time.

**Applicability**

Use Linked List when:
- Insertions and deletions at known positions dominate access patterns
- You already have a reference to the modification point
- Memory allocation per element is acceptable
- Random access by index is not required

Avoid when:
- Indexed access is needed
- Cache locality matters for performance
- Memory overhead per element is a concern
- The list is traversed more often than modified

**Structure**

Nodes containing data and pointer(s) to adjacent nodes. Singly-linked lists have only forward pointers; doubly-linked lists support bidirectional traversal.

**Consequences**

Benefits:
- Constant-time insert/delete at known positions
- No reallocation or element shifting
- Memory allocated per element, no wasted capacity
- Natural representation for certain recursive structures

Liabilities:
- Linear-time access by position
- Poor cache locality during traversal
- Memory overhead for pointers (significant for small elements)
- Cannot traverse backward without doubly-linked structure

**Implementation Notes**

Use language-provided implementations. The Deque pattern (below) often subsumes linked list use cases with better performance.

**Related Patterns**

- *Dynamic Array*: When indexed access dominates
- *Deque*: Often a better choice for end-modification patterns
- *Skip List*: When sorted order with fast search is needed

---

### Deque (Double-Ended Queue)

**Intent**

Support efficient insertion and removal at both ends of a sequence while maintaining indexed access.

**Motivation**

Consider a sliding window algorithm processing a stream of data. Elements enter at one end and exit at the other. Both operations must be fast, and you may need to examine elements at any position within the window. The deque provides efficient operations at both ends while preserving random access.

**Applicability**

Use Deque when:
- Both ends of the sequence require efficient modification
- You need to implement queue, stack, or sliding window semantics
- Random access is also required
- The "middle" of the sequence is rarely modified

Avoid when:
- Only one end is ever modified (use Dynamic Array or Stack)
- Middle insertions are common (consider other structures)
- Memory layout constraints require strict contiguity

**Structure**

Typically implemented as a sequence of fixed-size blocks with pointers, allowing efficient growth at both ends without moving existing elements.

**Consequences**

Benefits:
- Constant-time operations at both ends
- Indexed access (often constant-time)
- Good cache locality within blocks
- No element shifting for end operations

Liabilities:
- Slightly more complex than simple dynamic array
- May have small constant-factor overhead
- Mid-sequence operations still linear
- Memory layout less predictable than array

**Implementation Notes**

Standard library implementations are well-optimized. Preferred over manual linked list implementations for most queue and deque use cases.

**Related Patterns**

- *Queue/Stack*: Deque implements both patterns efficiently
- *Sliding Window*: Natural implementation substrate
- *Dynamic Array*: When only one end needs modification

---

## Key-Based Access Patterns

### Hash Table

**Intent**

Provide expected constant-time insertion, deletion, and lookup by key, without maintaining any ordering.

**Motivation**

Consider implementing a symbol table for a compiler. Identifiers must be looked up frequently during parsing and code generation. The number of identifiers is unknown in advance, and lookup speed is critical. A sorted structure would give logarithmic lookup; the hash table provides expected constant-time access.

**Applicability**

Use Hash Table when:
- Fast lookup by key is the primary requirement
- Keys are hashable (most primitive types, strings, immutable composites)
- No ordering requirements exist
- Expected case performance is acceptable (worst case is rare)

Avoid when:
- Ordered traversal is required
- Range queries are needed
- Keys cannot be hashed effectively
- Worst-case guarantees are essential
- Memory overhead is critical

**Structure**

An array of buckets indexed by hash values. Collisions handled by chaining (lists at each bucket) or open addressing (probing for empty slots). Load factor triggers resizing.

**Consequences**

Benefits:
- Expected O(1) insert, delete, lookup
- Efficient for sparse key spaces
- Flexible key types (anything hashable)
- Simple conceptual model

Liabilities:
- No ordering guarantees
- Worst-case O(n) operations (rare with good hash)
- Hash function quality affects performance
- Resizing causes occasional O(n) operations
- Poor cache locality in some implementations

**Implementation Notes**

Always use standard library implementations. Hash function design is subtle and language-provided implementations are highly optimized. Consider ordered variants (linked hash tables) when insertion order matters.

**Related Patterns**

- *Balanced Tree*: When ordered access is required
- *Hash Set*: When only membership (not key-value mapping) is needed
- *Bloom Filter*: When approximate membership is sufficient

---

### Hash Set

**Intent**

Track membership in a collection with expected constant-time test, add, and remove operations.

**Motivation**

Consider detecting duplicate entries in a stream of data. For each element, you must quickly determine whether it has been seen before. A sorted list would require logarithmic search; scanning an unsorted list would be linear. The hash set provides expected constant-time membership testing.

**Applicability**

Use Hash Set when:
- Membership testing is the primary operation
- Deduplication is needed
- Set operations (union, intersection, difference) are required
- No value needs to be associated with each element

Avoid when:
- Elements have associated values (use Hash Table)
- Ordered iteration is needed
- Range queries are required
- Approximate answers would suffice (consider Bloom Filter)

**Structure**

A hash table where only keys are stored (or keys map to a trivial value).

**Consequences**

Benefits:
- Expected O(1) membership test
- Efficient set operations
- Natural deduplication
- Space-efficient compared to hash table with values

Liabilities:
- Same as Hash Table: no ordering, hash quality dependency
- Cannot store duplicate elements
- Cannot associate data with elements

**Implementation Notes**

Standard library implementations are universal. Some languages distinguish mutable and immutable sets.

**Related Patterns**

- *Hash Table*: When values must be associated with keys
- *Balanced Tree Set*: When ordered iteration is needed
- *Bloom Filter*: For space-efficient approximate membership

---

## Ordered Access Patterns

### Balanced Binary Search Tree

**Intent**

Maintain a collection in sorted order with logarithmic-time insertion, deletion, and lookup, supporting ordered traversal and range queries.

**Motivation**

Consider a reservation system that must find all bookings within a time range. Entries are added and removed dynamically, and queries specify arbitrary start and end times. A hash table cannot answer range queries; an unsorted list would require full scans. The balanced tree maintains order while supporting efficient modification and range access.

**Applicability**

Use Balanced BST when:
- Sorted order must be maintained
- Range queries are required (find all elements between X and Y)
- Minimum/maximum access is needed
- Ordered iteration is frequent
- Logarithmic worst-case is required

Avoid when:
- Only point queries are needed (hash table is faster)
- Data is static (sorted array may suffice)
- Elements cannot be ordered
- Simpler structure would suffice

**Structure**

Binary tree where each node's left descendants are smaller and right descendants are larger. Self-balancing variants (Red-Black, AVL, B-trees) maintain height invariants to guarantee logarithmic operations.

**Consequences**

Benefits:
- Guaranteed O(log n) insert, delete, lookup
- O(log n) min/max access
- Efficient range queries
- Ordered iteration in O(n)
- Predictable worst-case performance

Liabilities:
- Slower than hash table for point queries
- More complex implementation
- Higher memory overhead per element
- Requires comparable elements

**Implementation Notes**

Standard libraries provide ordered map/set implementations backed by balanced trees. Custom implementation of self-balancing trees is complex and rarely justified.

**Related Patterns**

- *Hash Table*: Faster when ordering not needed
- *Heap*: When only min or max extraction is needed
- *Skip List*: Probabilistic alternative with simpler implementation

---

### Heap (Priority Queue)

**Intent**

Efficiently track the minimum (or maximum) element in a dynamic collection, supporting insertion and extraction of the extreme element.

**Motivation**

Consider scheduling tasks by priority. Tasks arrive continuously, and the system must always process the highest-priority task next. Keeping a sorted list would make insertion expensive; a hash table wouldn't identify the maximum. The heap provides efficient insertion while always knowing the highest-priority element.

**Applicability**

Use Heap when:
- Repeatedly extracting minimum or maximum element
- Implementing priority-based scheduling
- Finding k largest/smallest elements
- Implementing algorithms requiring priority queues (Dijkstra, Huffman)

Avoid when:
- Arbitrary element access is needed
- Searching for non-extreme elements is common
- Both minimum and maximum are needed simultaneously (use two heaps)
- Sorted traversal is required

**Structure**

A complete binary tree satisfying the heap property: each node is less than (min-heap) or greater than (max-heap) its children. Typically stored in an array using index arithmetic for parent/child relationships.

**Consequences**

Benefits:
- O(log n) insert and extract-min/max
- O(1) peek at minimum/maximum
- O(n) heap construction from unsorted array
- Memory-efficient array representation
- Simple implementation

Liabilities:
- No efficient arbitrary element access or search
- No efficient decrease-key without augmentation
- Only one extreme is efficiently accessible
- Not suitable for sorted iteration

**Implementation Notes**

Standard libraries provide priority queue implementations. When both minimum and maximum are needed, maintain two heaps or use a different structure.

**Related Patterns**

- *Balanced BST*: When arbitrary access and range queries are needed
- *Two-Heap Pattern*: For median finding or partitioned access
- *Fibonacci Heap*: For algorithms requiring efficient decrease-key

---

## Graph Patterns

### Adjacency List

**Intent**

Represent a graph as a collection of neighbor lists, optimizing for sparse graphs and edge iteration.

**Motivation**

Consider modeling a social network where users have connections. Most users connect to a small fraction of all users (the graph is sparse). Storing a full matrix of all possible connections would waste enormous space. The adjacency list stores only existing edges, with space proportional to the actual connections.

**Applicability**

Use Adjacency List when:
- The graph is sparse (edges << vertices²)
- Iterating over neighbors is the primary operation
- Memory efficiency matters
- Edge insertion/deletion is common

Avoid when:
- The graph is dense (edges approach vertices²)
- Constant-time edge existence queries are critical
- Matrix operations on the graph are needed

**Structure**

Each vertex maintains a collection (list, set, or map) of its adjacent vertices. Optionally stores edge weights or other attributes.

**Consequences**

Benefits:
- Space: O(V + E), efficient for sparse graphs
- Neighbor iteration: O(degree)
- Edge addition: O(1)
- Works well with standard graph algorithms

Liabilities:
- Edge existence check: O(degree) or O(log degree) with sorted/set storage
- Not suitable for matrix-based algorithms
- More complex to implement than adjacency matrix

**Implementation Notes**

Graph libraries provide optimized implementations with algorithm support. For simple cases, a hash table mapping vertices to neighbor collections suffices.

**Related Patterns**

- *Adjacency Matrix*: For dense graphs or matrix algorithms
- *Edge List*: For algorithms processing all edges
- *Incidence Matrix*: For hypergraph representations

---

### Adjacency Matrix

**Intent**

Represent a graph as a matrix enabling constant-time edge queries and matrix-based algorithms.

**Motivation**

Consider computing shortest paths between all pairs of vertices using the Floyd-Warshall algorithm. The algorithm performs matrix operations on edge weights. An adjacency list would require repeated neighbor lookups; the matrix representation aligns naturally with the algorithm's structure.

**Applicability**

Use Adjacency Matrix when:
- The graph is dense
- Edge existence queries are frequent
- Matrix-based algorithms are used (Floyd-Warshall, spectral methods)
- The vertex set is fixed and indexed

Avoid when:
- The graph is sparse (wastes space)
- The vertex set changes dynamically
- Memory is constrained
- Only neighbor iteration is needed

**Structure**

A V×V matrix where entry (i,j) indicates edge presence (or weight) between vertices i and j. For unweighted graphs, a boolean or bit matrix. For weighted graphs, numeric values (with infinity for non-edges).

**Consequences**

Benefits:
- O(1) edge existence check
- Natural for matrix algorithms
- Simple implementation
- Efficient for dense graphs

Liabilities:
- O(V²) space regardless of edge count
- O(V) time to enumerate neighbors
- Adding vertices requires matrix resizing
- Inefficient for sparse graphs

**Implementation Notes**

For large sparse graphs, consider sparse matrix libraries rather than dense arrays. Some algorithms can use either representation.

**Related Patterns**

- *Adjacency List*: For sparse graphs
- *Sparse Matrix*: For large sparse graphs needing matrix operations

---

## Specialized Patterns

### Trie (Prefix Tree)

**Intent**

Enable efficient prefix-based operations on a collection of strings, including prefix search, autocomplete, and longest common prefix.

**Motivation**

Consider implementing autocomplete for a search box. As the user types each character, the system must quickly find all words sharing that prefix. A hash table would require checking every entry; a sorted list would require binary search plus linear scan for matches. The trie organizes strings by shared prefixes, enabling efficient prefix operations.

**Applicability**

Use Trie when:
- Prefix-based queries dominate (autocomplete, spell-check)
- Finding all strings with a given prefix
- Longest common prefix operations
- IP routing (CIDR matching)
- Dictionary with prefix operations

Avoid when:
- Only exact match lookup is needed (hash table is simpler)
- Strings share few prefixes
- Memory overhead is a concern
- The alphabet is very large

**Structure**

A tree where each edge represents a character and paths from root represent prefixes. Nodes may be marked as word endings. Variations include compressed tries (radix trees) and ternary search tries.

**Consequences**

Benefits:
- O(m) lookup, insert, delete (m = string length)
- O(m) prefix search initialization
- Efficient enumeration of all strings with prefix
- Naturally supports longest common prefix

Liabilities:
- High memory overhead (especially for sparse tries)
- Alphabet size affects branching factor
- More complex than hash table for simple lookups
- Cache-unfriendly for random access

**Implementation Notes**

Libraries exist for production use. Compressed variants (Patricia tries) significantly reduce memory overhead. Consider trade-offs between branching factor and depth.

**Related Patterns**

- *Hash Table*: For exact-match-only lookups
- *Balanced BST*: For ordered string operations without prefix focus
- *Radix Tree*: Compressed trie variant for space efficiency

---

### Union-Find (Disjoint Set)

**Intent**

Efficiently track a partition of elements into disjoint sets, supporting set merging and membership queries.

**Motivation**

Consider implementing Kruskal's algorithm for minimum spanning trees. The algorithm processes edges in weight order, adding an edge only if it connects vertices in different components. Each decision requires knowing whether two vertices are in the same set, and each edge addition merges two sets. Naive approaches would require O(n) per operation; union-find provides near-constant time.

**Applicability**

Use Union-Find when:
- Tracking connected components in a dynamic graph
- Implementing Kruskal's MST algorithm
- Detecting cycles during edge addition
- Any scenario requiring dynamic equivalence classes

Avoid when:
- Sets must be split (union-find only supports merging)
- Enumeration of set members is needed
- Set intersections or differences are required
- Single static partition suffices (use array of labels)

**Structure**

A forest of trees where each tree represents a set. Each element points to its parent; roots identify sets. Path compression and union-by-rank optimizations yield near-constant amortized time.

**Consequences**

Benefits:
- Near-O(1) union and find operations (amortized)
- Simple implementation (~25 lines)
- Extremely efficient for connectivity problems
- Low memory overhead

Liabilities:
- Cannot split sets
- Cannot enumerate set members efficiently
- Amortized bounds (individual operations may be slower)
- Only tracks partition, not set contents

**Implementation Notes**

Simple enough for custom implementation. Apply both path compression and union-by-rank for optimal performance. Some graph libraries include this pattern.

**Related Patterns**

- *Graph Traversal*: Alternative for static connectivity
- *Hash Map of Sets*: When set enumeration is needed
- *Persistent Union-Find*: For functional/immutable variants

---

### Bloom Filter

**Intent**

Provide space-efficient probabilistic membership testing, allowing false positives but no false negatives.

**Motivation**

Consider a web crawler avoiding revisiting URLs. Billions of URLs have been seen, and storage is limited. Storing all URLs exactly would require too much memory. A bloom filter can answer "possibly seen" or "definitely not seen" using far less space, accepting occasional redundant visits to previously-crawled URLs.

**Applicability**

Use Bloom Filter when:
- Memory constraints preclude exact storage
- False positives are acceptable
- False negatives are unacceptable
- Membership testing is the primary operation
- The "negative" case is common and should be fast

Avoid when:
- False positives are unacceptable
- Elements must be enumerated or deleted
- The set is small enough for exact storage
- Deletion is required (consider counting bloom filter)

**Structure**

A bit array of m bits with k independent hash functions. Insertion sets k bits; query checks k bits. False positives occur when all k bits happen to be set by other elements.

**Consequences**

Benefits:
- Constant-time insert and query
- Dramatically lower space than exact storage
- No false negatives guaranteed
- Tunable false positive rate

Liabilities:
- False positives occur with predictable probability
- Cannot delete elements (standard variant)
- Cannot enumerate elements
- Cannot retrieve original values
- Requires careful parameter tuning

**Implementation Notes**

Use established libraries with proper parameter calculation. False positive rate depends on bit array size, hash count, and element count. Many variants exist (counting, scalable, cuckoo filters).

**Related Patterns**

- *Hash Set*: For exact membership without false positives
- *Cuckoo Filter*: Supports deletion with similar space efficiency
- *Count-Min Sketch*: For approximate frequency counting

---

### Segment Tree

**Intent**

Enable efficient range queries and point updates on an array, supporting operations like range sum, range minimum, or range maximum.

**Motivation**

Consider tracking cumulative sales across time intervals. The underlying data changes (new sales), and queries ask for totals over arbitrary date ranges. Naive range sums require O(n) per query; precomputed prefix sums can't handle updates efficiently. The segment tree provides logarithmic time for both updates and queries.

**Applicability**

Use Segment Tree when:
- Range queries on associative operations (sum, min, max, GCD)
- Point updates are interleaved with queries
- Multiple different ranges are queried
- The array is too large for O(n) per operation

Avoid when:
- Only point queries are needed
- Only prefix sums/queries are needed (use Fenwick tree)
- The array is static (precomputation may suffice)
- Updates are batched (can rebuild between batches)

**Structure**

A binary tree where leaves represent array elements and internal nodes represent combined values over ranges. Each node covers a range and stores the aggregate for that range.

**Consequences**

Benefits:
- O(log n) range queries
- O(log n) point updates
- O(n) space and construction
- Supports various associative operations
- Can be extended for range updates (lazy propagation)

Liabilities:
- More complex than simple arrays
- Higher constant factors than Fenwick tree
- Implementation is non-trivial
- Overkill for static data or simple operations

**Implementation Notes**

Implementation is moderately complex. For sum-only queries with point updates, Fenwick trees are simpler. Consider libraries for complex variants (lazy propagation, 2D segment trees).

**Related Patterns**

- *Fenwick Tree*: Simpler for prefix/range sums
- *Sparse Table*: For static range minimum queries
- *Prefix Sum Array*: For static range sums

---

## Pattern Selection Guide

### By Primary Operation

| Dominant Need | First Choice | Alternative |
|---------------|--------------|-------------|
| Indexed access | Dynamic Array | — |
| Key lookup | Hash Table | Balanced BST (if ordered) |
| Sorted order | Balanced BST | Skip List |
| Priority extraction | Heap | Balanced BST |
| Membership test | Hash Set | Bloom Filter (approximate) |
| Prefix operations | Trie | — |
| Dynamic connectivity | Union-Find | — |
| Range queries | Segment Tree | Fenwick Tree |

### By Constraint

| Constraint | Favors | Avoid |
|------------|--------|-------|
| Memory-constrained | Bloom Filter, Fenwick Tree | Hash Table (high overhead) |
| Worst-case guarantees | Balanced BST | Hash Table |
| Simplicity | Hash Table, Dynamic Array | Segment Tree, Balanced BST |
| Cache efficiency | Dynamic Array | Linked List |
| Sparse data | Adjacency List, Hash Table | Adjacency Matrix |

### By Problem Domain

| Domain | Common Patterns |
|--------|-----------------|
| Text processing | Trie, Hash Table |
| Graph algorithms | Adjacency List, Union-Find, Heap |
| Time series | Segment Tree, Fenwick Tree |
| Caching | Hash Table, LRU structure |
| Scheduling | Heap, Balanced BST |
| Network analysis | Adjacency List, Bloom Filter |
