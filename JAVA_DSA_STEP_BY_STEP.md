# Java for DSA: Step by Step (about 2 hours)

Everything in Java you need to solve DSA problems comfortably: collections, lambdas, **Java 8 streams**, comparators, and the patterns that use them.
Each step has the same shape:

1. **Goal**: the one thing you learn
2. **Code**: small, copy-paste-able
3. **Why it matters**: where it shows up in DSA problems
4. **Try it**: run it and compare with the expected output

Java 17+ (21 is fine). `JAVA_DSA_CHEATSHEET.md` stays as the quick lookup; this file is the learning path.

> **Rule:** type every "Try it" yourself. Reading Java does not teach it; running it does.

## How to run any snippet (no project needed)

Create `Play.java`, put snippets inside `main`, run `java Play.java` (Java 11+ runs a single file directly).

```java
import java.util.*;
import java.util.stream.*;

public class Play {
    public static void main(String[] args) {
        // paste snippets here
    }
}
```

## Time plan

| Part | Steps | Time |
|---|---|---|
| A. Foundations | 1-2 | 15 min |
| B. Collections | 3-5 | 35 min |
| C. Sorting and heaps | 6-7 | 20 min |
| D. Lambdas and streams | 8-9 | 30 min |
| E. Gotchas and patterns | 10-11 | 20 min |
| **Total** | | **~2 h** |

---

# Part A: Foundations (15 min)

## Step 1: Generics and wrapper types (7 min)

**Goal:** read `Map<Integer, List<String>>` without fear, and know why `int` and `Integer` differ.

Read generics inside-out: `List<List<Integer>>` is "a list, where each item is a list of integers".

```java
List<Integer> a = new ArrayList<>();            // [3, 1, 4]
List<List<Integer>> b = new ArrayList<>();      // [[3, 1], [4], []]  rows can differ in length
Map<Integer, List<Integer>> graph = new HashMap<>();   // node -> neighbours
```

Generics only accept objects, so primitives have **wrapper** types:

| primitive | wrapper |
|---|---|
| `int` | `Integer` |
| `long` | `Long` |
| `char` | `Character` |
| `boolean` | `Boolean` |
| `double` | `Double` |

Java converts automatically (**autoboxing**): `list.add(5)` boxes, `int x = list.get(0)` unboxes.

**Why it matters:** every collection in DSA uses wrappers. Two bugs come from it, covered in Step 10.

**Try it:**

```java
List<Integer> a = new ArrayList<>();
a.add(5);
int x = a.get(0) + 1;
System.out.println(x);          // 6
```

## Step 2: Arrays, Strings, StringBuilder (8 min)

**Goal:** the five lines you type in almost every solution.

```java
int[] a = new int[5];                 // [0,0,0,0,0]
int[][] grid = new int[3][4];         // 3 rows, 4 cols
Arrays.fill(a, -1);
Arrays.sort(a);                       // in place, ascending
System.out.println(Arrays.toString(a));          // [-1, -1, -1, -1, -1]
System.out.println(Arrays.deepToString(grid));   // 2D print

String s = "hello";
char c = s.charAt(1);                 // 'e'
int idx = c - 'a';                    // 4  (char -> 0..25)
char[] cs = s.toCharArray();          // modify, then new String(cs)
String sub = s.substring(1, 3);       // "el"  (end exclusive)
s.equals("hello");                    // true. NEVER use == for strings

StringBuilder sb = new StringBuilder();
sb.append("ab").append('c');
sb.reverse();                         // "cba"
String out = sb.toString();
```

Length is spelled three ways: `arr.length` (field), `list.size()` (method), `str.length()` (method).

**Why it matters:** `c - 'a'` is the frequency-array trick (`int[26]`) for anagram, window, and trie problems. `StringBuilder` avoids O(n^2) string concatenation in loops.

**Try it:** count letters of `"banana"`:

```java
int[] freq = new int[26];
for (char ch : "banana".toCharArray()) freq[ch - 'a']++;
System.out.println(freq[0] + " " + freq[1] + " " + freq['n' - 'a']);   // 3 1 2
```

---

# Part B: Collections (35 min)

## Step 3: Pick the right collection (10 min)

**Goal:** never hesitate over which class to use.

| Need | Declare as | Main methods |
|---|---|---|
| Growable array | `List<Integer> l = new ArrayList<>()` | `add, get(i), set(i,v), remove(i), size, contains` |
| No duplicates, fast lookup | `Set<Integer> s = new HashSet<>()` | `add, contains, remove` (all O(1)) |
| Key to value | `Map<K,V> m = new HashMap<>()` | `put, get, containsKey, remove` |
| Stack (LIFO) | `Deque<Integer> st = new ArrayDeque<>()` | `push, pop, peek` |
| Queue (FIFO) | `Queue<Integer> q = new ArrayDeque<>()` | `offer, poll, peek` |
| Min/max repeatedly | `PriorityQueue<Integer>` | `offer, poll, peek` |
| Sorted set/map | `TreeSet` / `TreeMap` | `first, last, floor, ceiling` |
| Keep insertion order | `LinkedHashMap` / `LinkedHashSet` | same as Map/Set |

Declare with the **interface** on the left (`Queue`, `Map`) and the class on the right (`ArrayDeque`, `HashMap`). It reads cleanly and lets you swap classes.

Do not use `Stack` or `LinkedList`; `ArrayDeque` is faster and is what everyone uses.

**Try it:**

```java
Set<Integer> seen = new HashSet<>();
int[] nums = {1, 2, 3, 1};
boolean dup = false;
for (int n : nums) if (!seen.add(n)) dup = true;   // add() returns false if already present
System.out.println(dup);   // true
```

`seen.add(n)` returning a boolean is the whole "contains duplicate" problem in one line.

## Step 4: Map recipes (15 min)

**Goal:** the four Map patterns that cover most hashing problems.

**Recipe 1: count things**

```java
Map<Character, Integer> count = new HashMap<>();
for (char c : "banana".toCharArray()) {
    count.merge(c, 1, Integer::sum);        // or: count.put(c, count.getOrDefault(c, 0) + 1)
}
System.out.println(count);   // {a=3, b=1, n=2}
```

`merge(key, 1, Integer::sum)` means "if absent put 1, else combine old + 1 using sum".

**Recipe 2: group into lists** (anagrams, graphs)

```java
Map<Integer, List<String>> byLen = new HashMap<>();
for (String w : List.of("a", "bb", "c", "dd", "eee")) {
    byLen.computeIfAbsent(w.length(), k -> new ArrayList<>()).add(w);
}
System.out.println(byLen);   // {1=[a, c], 2=[bb, dd], 3=[eee]}
```

`computeIfAbsent` creates the list the first time you see the key, then returns it so you can `.add`.

**Recipe 3: loop over a map**

```java
for (Map.Entry<Character, Integer> e : count.entrySet()) {
    System.out.println(e.getKey() + " -> " + e.getValue());
}
for (var e : count.entrySet()) { }     // var lets Java infer the type
for (int v : count.values()) { }       // values only
for (char k : count.keySet()) { }      // keys only
```

**Recipe 4: two-sum with a map** (value to index)

```java
int[] nums = {2, 7, 11, 15};  int target = 9;
Map<Integer, Integer> idx = new HashMap<>();
for (int i = 0; i < nums.length; i++) {
    int need = target - nums[i];
    if (idx.containsKey(need)) {
        System.out.println(idx.get(need) + "," + i);   // 0,1
    }
    idx.put(nums[i], i);
}
```

**Why it matters:** these four recipes solve two-sum, group anagrams, top-k frequent, subarray sum, longest substring, and most "have I seen this?" problems.

**Try it:** change Recipe 1 to count words in `"a b a c b a"` (`split(" ")`). Expected: `{a=3, b=2, c=1}`.

## Step 5: Stack, queue, deque (10 min)

**Goal:** use `ArrayDeque` for all three.

```java
Deque<Integer> stack = new ArrayDeque<>();
stack.push(1); stack.push(2);
System.out.println(stack.peek());   // 2   (top)
System.out.println(stack.pop());    // 2
// pop() / peek() on empty: pop throws, peek returns null. Check isEmpty() first.

Queue<Integer> q = new ArrayDeque<>();
q.offer(1); q.offer(2);
System.out.println(q.poll());       // 1   (front)

Deque<Integer> dq = new ArrayDeque<>();   // both ends
dq.addFirst(1); dq.addLast(2);
dq.pollFirst(); dq.pollLast();
```

Valid-parentheses in full, as the model stack problem:

```java
static boolean valid(String s) {
    Deque<Character> st = new ArrayDeque<>();
    for (char c : s.toCharArray()) {
        if (c == '(' || c == '[' || c == '{') st.push(c);
        else {
            if (st.isEmpty()) return false;
            char open = st.pop();
            if ((c == ')' && open != '(') || (c == ']' && open != '[') || (c == '}' && open != '{')) return false;
        }
    }
    return st.isEmpty();
}
```

**Why it matters:** stack gives parentheses, monotonic stack, DFS (iterative), undo. Queue gives BFS and level order. Deque gives sliding window maximum.

**Try it:** `valid("([]{})")` is `true`, `valid("(]")` is `false`.

---

# Part C: Sorting and heaps (20 min)

## Step 6: Comparators (10 min)

**Goal:** sort anything by anything.

A comparator takes two items `a`, `b` and returns negative if `a` goes first, positive if `b` goes first, zero if tied.

```java
List<Integer> l = new ArrayList<>(List.of(3, 1, 2));
l.sort(null);                                   // natural order: [1, 2, 3]
l.sort(Collections.reverseOrder());             // [3, 2, 1]

int[][] pts = {{1, 5}, {3, 2}, {2, 9}};
Arrays.sort(pts, (a, b) -> Integer.compare(a[0], b[0]));    // by first value
Arrays.sort(pts, Comparator.comparingInt(a -> a[1]));       // by second value, shorter
Arrays.sort(pts, (a, b) -> b[1] - a[1]);                    // descending by second

String[] words = {"ccc", "a", "bb"};
Arrays.sort(words, Comparator.comparing(String::length));   // [a, bb, ccc]
Arrays.sort(words, Comparator.comparing(String::length).reversed());
```

Chaining for ties: `Comparator.comparingInt((int[] a) -> a[0]).thenComparingInt(a -> a[1])`.

**Rules:**
- `Arrays.sort(int[])` takes no comparator. Comparators only work on **object** arrays (`int[][]`, `String[]`, `Integer[]`), not `int[]`.
- `a - b` can overflow when values are huge. `Integer.compare(a, b)` is always safe.

**Why it matters:** merge intervals, meeting rooms, k closest points, custom ordering.

**Try it:** sort `{{1,5},{3,2},{2,9}}` by second value, print with `Arrays.deepToString`. Expected `[[3, 2], [1, 5], [2, 9]]`.

## Step 7: PriorityQueue (heap) (10 min)

**Goal:** min-heap, max-heap, and heap-of-k.

```java
PriorityQueue<Integer> minHeap = new PriorityQueue<>();
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());
minHeap.offer(5); minHeap.offer(1); minHeap.offer(3);
System.out.println(minHeap.peek());   // 1
System.out.println(minHeap.poll());   // 1, then next poll gives 3
```

With a comparator, e.g. closest points to origin (`int[]{x, y}`):

```java
PriorityQueue<int[]> pq = new PriorityQueue<>(
    (a, b) -> (a[0]*a[0] + a[1]*a[1]) - (b[0]*b[0] + b[1]*b[1]));
```

**Kth largest = min-heap of size k.** Keep only the k biggest; the smallest of them (the top) is the answer.

```java
static int kthLargest(int[] nums, int k) {
    PriorityQueue<Integer> h = new PriorityQueue<>();
    for (int n : nums) {
        h.offer(n);
        if (h.size() > k) h.poll();    // drop the smallest
    }
    return h.peek();
}
```

Time: O(n log k). Memory: O(k).

**Why it matters:** top-k, kth largest, merge k sorted lists, task scheduler, Dijkstra, median of stream.

**Try it:** `kthLargest(new int[]{3,2,1,5,6,4}, 2)` gives `5`.

---

# Part D: Lambdas and streams (30 min)

## Step 8: Lambdas and method references (10 min)

**Goal:** understand `(a, b) -> a - b` and `Integer::sum`; they are short functions.

```java
// lambda:  (parameters) -> expression
(a, b) -> a + b
x -> x * 2
k -> new ArrayList<>()          // seen in computeIfAbsent
(a, b) -> { return a + b; }     // block form needs return

// method reference: shortcut when the lambda only calls one method
Integer::sum          // same as (a, b) -> a + b
String::length        // same as s -> s.length()
Integer::intValue     // same as i -> i.intValue()
ArrayList::new        // same as () -> new ArrayList<>()
```

Four functional interfaces cover 95% of what you meet:

| Interface | Shape | Example |
|---|---|---|
| `Function<T,R>` | T in, R out | `s -> s.length()` |
| `Predicate<T>` | T in, boolean out | `n -> n % 2 == 0` |
| `Consumer<T>` | T in, nothing out | `x -> System.out.println(x)` |
| `Supplier<T>` | nothing in, T out | `() -> new ArrayList<>()` |

A lambda can read local variables only if they are **effectively final** (never reassigned). That is why you cannot do `count++` on a local inside a lambda; use an array `int[] count = {0}` or a loop.

**Try it:**

```java
Predicate<Integer> even = n -> n % 2 == 0;
Function<String, Integer> len = String::length;
System.out.println(even.test(4) + " " + len.apply("abc"));   // true 3
```

Useful lambda spots on collections:

```java
list.forEach(x -> System.out.println(x));
list.removeIf(x -> x < 0);
map.forEach((k, v) -> System.out.println(k + "=" + v));
map.entrySet().removeIf(e -> e.getValue() == 1);
```

## Step 9: Java 8 streams (20 min)

**Goal:** read and write stream pipelines. Think of a **conveyor belt**: source, then steps, then one final collector.

```
source        ->  intermediate steps (lazy)       ->  terminal step (runs it)
list.stream()     .filter() .map() .sorted()          .collect() .sum() .count()
```

Nothing runs until the terminal step.

### 9a. Core steps

```java
List<Integer> nums = List.of(5, 2, 8, 1, 9, 3);

nums.stream().filter(n -> n > 2).collect(Collectors.toList());       // [5, 8, 9, 3]
nums.stream().map(n -> n * n).collect(Collectors.toList());          // [25, 4, 64, 1, 81, 9]
nums.stream().sorted().collect(Collectors.toList());                 // [1, 2, 3, 5, 8, 9]
nums.stream().sorted(Comparator.reverseOrder()).limit(3).toList();   // [9, 8, 5]
nums.stream().distinct().count();                                    // 6
nums.stream().anyMatch(n -> n > 8);                                  // true
nums.stream().allMatch(n -> n > 0);                                  // true
```

`.toList()` (Java 16+) is shorter than `.collect(Collectors.toList())` but returns an immutable list.

### 9b. Numbers: `IntStream` (no boxing)

```java
int[] arr = {5, 2, 8, 1};
Arrays.stream(arr).sum();                      // 16
Arrays.stream(arr).max().getAsInt();           // 8
Arrays.stream(arr).min().getAsInt();           // 1
Arrays.stream(arr).average().orElse(0);        // 4.0
IntStream.range(0, 5).sum();                   // 0+1+2+3+4 = 10   (end exclusive)
IntStream.rangeClosed(1, 5).sum();             // 15
```

### 9c. The conversions that always trip you up

```java
// List<Integer> -> int[]
int[] a = list.stream().mapToInt(Integer::intValue).toArray();
// int[] -> List<Integer>
List<Integer> l = Arrays.stream(arr).boxed().collect(Collectors.toList());
// String[] / List<String> -> joined string
String csv = String.join(",", list);
// chars of a string
"hello".chars().filter(c -> c == 'l').count();   // 2
// List<List<Integer>> -> int[][]
int[][] g = lists.stream().map(r -> r.stream().mapToInt(i -> i).toArray()).toArray(int[][]::new);
```

Memory hook: **`mapToInt` goes to primitive, `boxed` goes back to objects.**

### 9d. Counting and grouping with `Collectors`

```java
List<String> words = List.of("apple", "bob", "cat", "apple", "bob", "apple");

// frequency map
Map<String, Long> freq = words.stream()
    .collect(Collectors.groupingBy(w -> w, Collectors.counting()));
// {apple=3, bob=2, cat=1}

// group by length
Map<Integer, List<String>> byLen = words.stream()
    .collect(Collectors.groupingBy(String::length));
// {3=[bob, cat, bob], 5=[apple, apple, apple]}

// group anagrams (key = sorted letters)
List<List<String>> groups = new ArrayList<>(
    Stream.of("eat", "tea", "tan", "ate", "nat", "bat")
        .collect(Collectors.groupingBy(w -> {
            char[] c = w.toCharArray(); Arrays.sort(c); return new String(c);
        })).values());
// [[bat], [eat, tea, ate], [tan, nat]]  (order may vary)

// list -> set / map
Set<String> unique = new HashSet<>(words);
Map<String, Integer> lenMap = words.stream().distinct()
    .collect(Collectors.toMap(w -> w, String::length));
```

### 9e. Top-k with a stream (one-liner)

```java
List<Integer> top2 = freq.entrySet().stream()
    .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
    .limit(2)
    .map(Map.Entry::getKey)
    .toList();
// [apple, bob]
```

### 9f. Streams vs loops: when to use which

| Use a stream | Use a plain loop |
|---|---|
| quick conversion (`list` to `int[]`) | anything with early exit or index math |
| sum / max / count over a collection | two pointers, sliding window, DP |
| group / count / sort output for display | hot code where speed counts (streams are slower) |

In interviews and contests: **loops for the algorithm, streams for the conversion and glue.** Do not force a stream where a loop is clearer.

**Try it (in order):**
1. From `{4, 1, 3, 1, 4}` get the sorted distinct list. Expected `[1, 3, 4]`.
2. Sum of squares of even numbers in `1..10`. Expected `220` (`IntStream.rangeClosed(1,10).filter(n -> n%2==0).map(n -> n*n).sum()`).
3. Convert `List.of(3,1,2)` to `int[]` and print with `Arrays.toString`.
4. Count words by first letter for `["apple","avocado","banana"]`. Expected `{a=2, b=1}`.

---

# Part E: Gotchas and patterns (20 min)

## Step 10: Gotchas that cost points (8 min)

1. **`Integer == Integer`** compares references; it works up to 127 then breaks. Use `.equals()` or unbox: `a.equals(b)` or `(int) a == (int) b`. Most common with `map.get(x) == map.get(y)`.
2. **`list.remove(int)` vs `list.remove(Object)`**: `list.remove(1)` removes **index** 1. To remove the **value** 1: `list.remove(Integer.valueOf(1))`.
3. **Overflow:** sums and products go in `long`; `int mid = lo + (hi - lo) / 2`; prefer `Integer.compare` over `a - b`.
4. **Changing a collection while looping over it** throws `ConcurrentModificationException`. Use `removeIf` or an `Iterator`.
5. **`List.of(...)` and `.toList()` are immutable**; wrap with `new ArrayList<>(...)` if you need to modify.
6. **`Arrays.asList(int[])` does not do what you think** (you get a list with one element: the array). Use `Arrays.stream(arr).boxed().toList()`.
7. **`char + int` is an int**: `'a' + 1` is `98`; cast: `(char) ('a' + 1)` is `'b'`.
8. **`new int[n][]` rows are null**, `new int[n][m]` are zero-filled.
9. **Array vs list copy:** `int[] b = a;` shares memory. Copy with `a.clone()` or `Arrays.copyOf(a, a.length)`. Lists: `new ArrayList<>(list)`. When you save a path in backtracking, always `result.add(new ArrayList<>(path))`.
10. **`HashMap` iteration order is not guaranteed.** Use `LinkedHashMap` / `TreeMap` when order matters.

**Try it:** predict the output, then run.

```java
Integer a = 1000, b = 1000;
System.out.println(a == b);          // false
System.out.println(a.equals(b));     // true
List<Integer> l = new ArrayList<>(List.of(10, 20, 1));
l.remove(1);                          // removes index 1 (the 20)
System.out.println(l);                // [10, 1]
```

## Step 11: Pattern templates (12 min)

**Goal:** a skeleton for each major pattern so you only fill in the details.

**Pattern to structure**

| Pattern | Reach for |
|---|---|
| frequency / duplicates / pair sum | `HashMap`, `HashSet` |
| sorted array, pairs | two pointers |
| substring / subarray with a condition | sliding window + map |
| brackets, next greater, undo | `ArrayDeque` as stack |
| shortest path, level order | `ArrayDeque` as queue (BFS) |
| top k, kth, merge k | `PriorityQueue` |
| prefix search | trie |

**Two pointers (sorted array, pair sum)**

```java
int l = 0, r = a.length - 1;
while (l < r) {
    int sum = a[l] + a[r];
    if (sum == target) return new int[]{l, r};
    if (sum < target) l++; else r--;
}
```

**Sliding window (longest substring without repeats)**

```java
Set<Character> win = new HashSet<>();
int l = 0, best = 0;
for (int r = 0; r < s.length(); r++) {
    while (win.contains(s.charAt(r))) win.remove(s.charAt(l++));
    win.add(s.charAt(r));
    best = Math.max(best, r - l + 1);
}
```

**Binary search (first index with a[i] >= x)**

```java
int lo = 0, hi = a.length;           // hi is exclusive
while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (a[mid] >= x) hi = mid; else lo = mid + 1;
}
return lo;
```

**BFS on a graph or grid (shortest steps)**

```java
Queue<int[]> q = new ArrayDeque<>();
boolean[][] seen = new boolean[R][C];
q.offer(new int[]{sr, sc}); seen[sr][sc] = true;
int[][] dirs = {{1,0},{-1,0},{0,1},{0,-1}};
int steps = 0;
while (!q.isEmpty()) {
    for (int size = q.size(); size > 0; size--) {   // one level at a time
        int[] cur = q.poll();
        for (int[] d : dirs) {
            int nr = cur[0] + d[0], nc = cur[1] + d[1];
            if (nr < 0 || nc < 0 || nr >= R || nc >= C || seen[nr][nc]) continue;
            seen[nr][nc] = true;
            q.offer(new int[]{nr, nc});
        }
    }
    steps++;
}
```

**DFS / backtracking (subsets)**

```java
static void dfs(int[] nums, int i, List<Integer> path, List<List<Integer>> out) {
    if (i == nums.length) { out.add(new ArrayList<>(path)); return; }   // copy!
    path.add(nums[i]);        dfs(nums, i + 1, path, out);   // choose
    path.remove(path.size() - 1);                            // un-choose
    dfs(nums, i + 1, path, out);                             // skip
}
```

**Tree traversal**

```java
static int depth(TreeNode n) {
    if (n == null) return 0;
    return 1 + Math.max(depth(n.left), depth(n.right));
}
```

---

# Finish line: 10-minute self test

Close this file and write each from memory:

1. Count characters of a string in a `Map`, two ways (`getOrDefault` and `merge`).
2. Group words by sorted letters using `computeIfAbsent`.
3. Max-heap of `int[]` sorted by second value.
4. Kth largest with a heap of size k.
5. `List<Integer>` to `int[]` and back, using streams.
6. Frequency map with streams (`groupingBy` + `counting`), then top 2 keys.
7. Valid parentheses with `ArrayDeque`.
8. BFS skeleton on a grid.

Anything you could not write is where to re-read. Then go solve 3 problems per pattern; the SRS (`bin/srs`) will keep the patterns fresh.

## What to do next

- Use `JAVA_DSA_CHEATSHEET.md` as the quick lookup while solving.
- When a stream feels confusing, rewrite it as a loop first, then compress.
- Once these 11 steps feel easy, the next layer is: `TreeMap` floor/ceiling, `BitSet`, `Collections.unmodifiableList`, and `record` for small data holders (`record Edge(int to, int w) {}`).
