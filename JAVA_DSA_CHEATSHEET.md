# Java DSA Cheat Sheet

## 1. Reading generics: `List<List<Integer>>`

Read it inside-out: **"a List, where each item is a List of Integers."**

```java
List<Integer>        // [3, 1, 4]
List<List<Integer>>  // [[3, 1], [4], []]   <- a list of lists (2D, but rows can differ in length)
Map<Integer, List<Integer>>  // key -> list of values (adjacency list for graphs)
```

Why it's used for "bucket sort": index = frequency, value = the numbers with that frequency.

```java
// buckets[2] = [7, 9]  means 7 and 9 each appeared 2 times
List<List<Integer>> buckets = new ArrayList<>();
for (int i = 0; i <= nums.length; i++) buckets.add(new ArrayList<>()); // n+1 !
buckets.get(freq).add(num);
```

Why not an array? Java can't create generic arrays (`new List<Integer>[n]` is an error).
Workarounds: `List<List<Integer>>` (preferred) or `List<Integer>[] b = new List[n+1];` (warning, but works).

> Bug in TopKFrequent.java: buckets has `nums.length` slots, but a frequency can equal
> `nums.length` (e.g. `[1,1,1]`) -> `IndexOutOfBounds`. Use `i <= nums.length`.

## 2. Map and Map.Entry

A `Map.Entry<K,V>` is one key-value pair. `entrySet()` gives all pairs so you can loop over a map.

```java
Map<Integer, Integer> map = new HashMap<>();

for (Map.Entry<Integer, Integer> e : map.entrySet()) {
    int key = e.getKey();
    int val = e.getValue();
}

for (int key : map.keySet())     { }   // keys only
for (int val : map.values())     { }   // values only
```

Shortcut: `for (var e : map.entrySet())` — `var` lets Java infer the type.

### Map operations you'll use constantly

| Task | Code |
|---|---|
| Count occurrences | `map.put(x, map.getOrDefault(x, 0) + 1)` or `map.merge(x, 1, Integer::sum)` |
| Group into lists | `map.computeIfAbsent(key, k -> new ArrayList<>()).add(x)` |
| Exists? | `map.containsKey(x)` |
| Get or default | `map.getOrDefault(x, 0)` |
| Remove | `map.remove(x)` |
| Size | `map.size()` |
| Insertion order | `LinkedHashMap` |
| Sorted by key | `TreeMap` (O(log n)) |

## 3. Collections quick reference

| Need | Use | Key methods |
|---|---|---|
| Dynamic array | `ArrayList<Integer>` | `add, get(i), set(i,v), remove(i), size()` |
| Set (no dups) | `HashSet<Integer>` | `add, contains, remove` (O(1)) |
| Stack | `Deque<Integer> s = new ArrayDeque<>()` | `push, pop, peek` |
| Queue | `Queue<Integer> q = new ArrayDeque<>()` | `offer, poll, peek` |
| Deque | `ArrayDeque` | `addFirst, addLast, pollFirst, pollLast` |
| Min-heap | `PriorityQueue<Integer>` | `offer, poll, peek` |
| Max-heap | `new PriorityQueue<>(Collections.reverseOrder())` | same |
| Sorted set/map | `TreeSet` / `TreeMap` | `floor, ceiling, first, last` |

Don't use `Stack` or `LinkedList` for stack/queue; `ArrayDeque` is the standard choice.

## 4. Arrays

```java
int[] a = new int[n];               // zeros
int[] b = {1, 2, 3};
int[][] grid = new int[r][c];
Arrays.fill(a, -1);
Arrays.sort(a);                     // ascending, in place
Arrays.sort(arr2d, (x, y) -> x[0] - y[0]);   // sort rows (use Integer.compare to avoid overflow)
Arrays.toString(a);  Arrays.deepToString(grid);
int[] copy = Arrays.copyOf(a, n);   int[] part = Arrays.copyOfRange(a, i, j);
a.length            // array: field, no ()
list.size()         // List: method
str.length()        // String: method
```

## 5. Strings

```java
char[] cs = s.toCharArray();
String t = new String(cs);          // or String.valueOf(cs)
s.charAt(i);   s.substring(i, j);   // j exclusive
int idx = s.charAt(i) - 'a';        // char -> 0..25
StringBuilder sb = new StringBuilder(); sb.append(x); sb.reverse(); sb.toString();
s.equals(t)                         // NEVER ==
String.join(",", list);   s.split(" ");
```

## 6. Conversions (the annoying part)

```java
// List<Integer> -> int[]
int[] arr = list.stream().mapToInt(Integer::intValue).toArray();
// int[] -> List<Integer>
List<Integer> l = Arrays.stream(arr).boxed().collect(Collectors.toList());
// quick list
List<Integer> l2 = Arrays.asList(1, 2, 3);   // or List.of(1,2,3) (immutable)
// copy a list
new ArrayList<>(list)
```

## 7. Comparators and sorting objects

```java
list.sort((a, b) -> a - b);                       // ascending (overflow risk on big values)
list.sort(Integer::compare);
list.sort(Comparator.comparingInt(a -> a[1]));    // sort int[] by 2nd element
Collections.sort(list);   Collections.reverse(list);

// Heap by frequency (top K frequent alt. solution, O(n log k))
PriorityQueue<Integer> pq = new PriorityQueue<>((a, b) -> map.get(a) - map.get(b));
for (int key : map.keySet()) { pq.offer(key); if (pq.size() > k) pq.poll(); }
```

## 8. Gotchas

- `Integer == Integer` compares references (breaks above 127). Use `.equals()` or unbox to `int`.
- `list.remove(int)` removes by **index**; `list.remove(Integer.valueOf(x))` removes by **value**.
- Generics need wrapper types: `List<int>` is illegal -> `List<Integer>`.
- Integer overflow: use `long` for sums/products; `mid = lo + (hi - lo) / 2`.
- Modifying a collection while iterating it throws `ConcurrentModificationException`.
- `Math.floorMod(a, m)` for non-negative modulo.
- `Integer.MAX_VALUE` / `Integer.MIN_VALUE` as sentinels.

## 9. Pattern -> data structure

| Pattern | Reach for |
|---|---|
| Count / frequency / duplicates | `HashMap`, `HashSet` |
| Group by key (anagrams) | `Map<String, List<String>>` |
| Top K | bucket sort (`List<List<Integer>>`) or min-heap of size k |
| Matching brackets, undo, monotonic | `ArrayDeque` as stack |
| BFS / level order | `ArrayDeque` as queue |
| Sorted array, pairs | two pointers |
| Subarray / substring window | sliding window + map/set |
| Graph | `Map<Integer, List<Integer>>` adjacency list + visited set |
| Prefix lookups | Trie (`Node[26]` or `Map<Character, Node>`) |
| Min/max repeatedly | `PriorityQueue` |

## 10. Complexity quick table

| Op | ArrayList | HashMap/Set | TreeMap/Set | PriorityQueue | ArrayDeque |
|---|---|---|---|---|---|
| Access by index | O(1) | - | - | - | - |
| Search | O(n) | O(1) | O(log n) | O(n) | O(n) |
| Insert | O(1) end / O(n) mid | O(1) | O(log n) | O(log n) | O(1) ends |
| Remove | O(n) | O(1) | O(log n) | O(log n) top | O(1) ends |
| Peek min/max | - | - | O(log n) | O(1) | O(1) ends |
