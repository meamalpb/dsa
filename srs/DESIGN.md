# SRS — spaced repetition for the NeetCode 150 sheet

Status: **built** (2026-09-23). Usage lives in [README.md](README.md).

## 1. What it does

A Ruby CLI (`bin/srs`, stdlib only — Ruby 3.1.6, `csv`/`yaml`/`minitest` all available) that
tells you which 2–3 LeetCode problems to do today, mixing reviews of problems you've already
solved with new ones, using SM-2 scheduling and a topic roadmap so new problems arrive in a
sensible order.

```
bin/srs setup            # one-time (re-runnable), builds the data files
bin/srs today            # show today's slots A, B (and C if unlocked)
bin/srs start A          # create the file to work in for slot A
bin/srs grade A good     # record how it went: again | hard | good | easy
bin/srs status           # coverage per topic, open/locked topics, due counts
```

## 2. Files

```
bin/srs                  # entry point
srs/DESIGN.md            # this file
srs/problems.yml         # facts about each problem — generated, rebuildable
srs/state.yml            # your review history — precious, never regenerated
srs/lib/*.rb             # setup, sm2, scheduler, scaffold, commands, cli, …
srs/test/*_test.rb       # minitest — run with `ruby srs/test/run_all.rb`
```

Both YAML files are committed (state.yml is your only record of reviews, so it should be backed
up in git). `.gitignore` gets `*.attempt.rb`.

### problems.yml — one entry per sheet row, keyed by LeetCode slug

```yaml
two-sum:
  name: Two Sum
  topic: arrays                 # see §4; derived from file location if a file exists
  difficulty: Easy              # from LeetCode, fetched once at setup
  paid_only: false
  link: https://leetcode.com/problems/two-sum/
  alt_link: null                # NeetCode link for premium problems
  file: arrays_and_hashing/easy/two_sum.rb
  order: 3                      # row position in the sheet
  notes: "use hash map to instantly check for difference value..."
```

### state.yml

```yaml
problems:
  two-sum:
    reps: 1
    ease: 2.5
    interval: 1
    last_reviewed: 2026-03-14
    next_review: 2026-03-15
    history:
      - { date: 2026-03-14, grade: seed }
last_new_on: 2026-09-20         # date a *new* problem was last graded
next_forced_pool: medium_hard   # alternates easy / medium_hard
session:                        # today's picks, so `today` is stable
  date: 2026-09-23
  bonus_unlocked: false
  slots:
    A: { slug: two-sum, kind: review, grade: null }
    B: { slug: valid-sudoku, kind: new, grade: null }
```

A problem is **seen** if it has an entry under `problems:` in state.yml.

## 3. Setup (`bin/srs setup`)

1. **Fetch the sheet once** as CSV from the published URL. The sheet is static, so this is the
   only time it's read. Slug = the `/problems/<slug>/` part of the Link (this also handles the
   `accounts/login/?next=/problems/encode-and-decode-strings/` link).
2. **Map local solutions**: scan every `.rb` outside `codeforces/` and `random/` for the
   `# https://leetcode.com/problems/<slug>/` header. Files whose slug isn't on the sheet are
   ignored (13 of them: `is_subsequence`, `baseball-game`, `asteroid_collision`, …).
3. **Fetch difficulty + premium flag** for each slug via LeetCode's GraphQL, 1 request/second.
   robots.txt disallows `/graphql` for crawlers, so this happens only at setup and only for
   slugs missing from problems.yml — `today`/`start`/`grade` never touch the network.
4. **Premium problems** (Encode and Decode Strings, Meeting Rooms I/II, Walls and Gates,
   Graph Valid Tree, Number of Connected Components, Alien Dictionary — confirmed by the flag)
   get an `alt_link` to NeetCode's free version. NeetCode slugs don't follow LeetCode's, so
   the 7 are mapped by hand in `Leetcode::NEETCODE_SLUGS`.
   One sheet link is out of date (`coin-change-2`, now `coin-change-ii`); `Sheet::SLUG_FIXES`
   corrects it.
5. **Create missing folders** `<topic_folder>/<easy|medium|hard>/` for every problem that
   needs one.
6. **Seed state.yml** for every matched file:
   `reps: 1, ease: 2.5, interval: 1, last_reviewed: <date the file was first committed>`,
   so all of them start overdue and come back oldest-first. First commit, not last: a later
   commit may just be a cleanup (like adding a header). Existing entries are never touched.
7. **Print** the match list and the coverage table (§4) and stop, so you can check them.

Re-running setup is safe: it only adds what's missing.

### Header audit (done 2026-09-23, before setup)

- Every solution file outside `codeforces/` has a `# https://leetcode.com/problems/<slug>/`
  header, and each slug was checked against LeetCode: it exists, and LeetCode's Ruby method
  name is defined in the file. No wrong links.
- Headers were added to `tree/easy/invert_binary_tree.rb`,
  `tree/medium/lowest_common_ancestor.rb` (the BST version, #235 — the code relies on BST
  ordering), `tree/easy/preorder_traversal.rb` and `tree/easy/postorder_traversal.rb`.
- Setup relies only on the URL line. The path comment above it isn't read, so stale ones
  (e.g. `# arrays/easy/two_sum.rb` in `arrays_and_hashing/`) don't matter.

### What the match currently looks like (before difficulty fetch)

| Topic | Solved / on sheet |
|---|---|
| Arrays | 7 / 9 (incl. Longest Consecutive Sequence, see §4) |
| Two Pointers | 4 / 5 |
| Sliding Window | 5 / 6 |
| Stack | 3 / 7 |
| Binary Search | 4 / 7 |
| Linked List | 5 / 11 |
| Trees | 4 / 15 |
| Intervals | 0 / 5 (Merge Intervals counts under Arrays, see §4) |
| Everything else | 0 |

## 4. Topics and folders

| Sheet category | Topic key | Folder |
|---|---|---|
| Arrays (and `Graph`*) | arrays | `arrays_and_hashing/` |
| Two Pointers | two_pointers | `two_pointers/` |
| Sliding Window | sliding_window | `sliding_window/` |
| Stack | stack | `stack/` |
| Binary Search | binary_search | `binary_search/` |
| Linked List | linked_list | `linked_list/` |
| Trees | trees | `tree/` (existing name kept) |
| Tries | tries | `tries/` |
| Heap / Priority Queue | heap | `heap/` |
| Backtracking | backtracking | `backtracking/` |
| Graphs | graphs | `graphs/` |
| Advanced Graphs | advanced_graphs | `advanced_graphs/` |
| 1-D Dynamic Programming | dp_1d | `dp_1d/` |
| 2-D Dynamic Programming | dp_2d | `dp_2d/` |
| Greedy | greedy | `greedy/` |
| Intervals | intervals | `intervals/` |
| Math & Geometry | math_geometry | `math_geometry/` |
| Bit Manipulation | bit_manipulation | `bit_manipulation/` |

\* The sheet files Longest Consecutive Sequence under "Graph"; it's an Arrays problem in
NeetCode's list and your file is in `arrays_and_hashing/`.

**File location wins**: if a solution file exists, the problem's topic is the topic of the
folder it lives in (so `merge_intervals.rb` counts toward Arrays, not Intervals). Otherwise
the sheet category decides.

New file path: `<folder>/<difficulty>/<slug with - → _>.rb`,
e.g. `graphs/medium/number_of_islands.rb`.

## 5. Scheduling: SM-2

Grades map to SM-2 quality `q`: `again`=1, `hard`=3, `good`=4, `easy`=5.

On each grade:

```
ease = max(1.3, ease + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
if q < 3:  reps = 0; interval = 1
else:      reps += 1
           interval = 1 if reps == 1
                      6 if reps == 2
                      round(interval * ease) otherwise
last_reviewed = today; next_review = today + interval
```

A new problem starts at `reps: 0, ease: 2.5` before its first grade.
Intervals count from the day you actually did it, so missing days just leaves things overdue.

Example:

| Day | Grade | Ease | Next in |
|---|---|---|---|
| 0 | good | 2.50 | 1 |
| 1 | good | 2.50 | 6 |
| 7 | hard | 2.36 | 14 |
| 21 | again | 1.82 | 1 (reps reset) |

## 6. Progression: which new problems are eligible

**Roadmap** (NeetCode's), topic → topics it unlocks:

```
arrays          → two_pointers, stack
two_pointers    → binary_search, sliding_window, linked_list
binary_search + linked_list   → trees
trees           → tries, heap, backtracking
backtracking    → graphs, dp_1d
heap            → intervals, greedy
heap + graphs   → advanced_graphs
graphs + dp_1d  → dp_2d
dp_1d           → bit_manipulation
graphs + bit_manipulation     → math_geometry
```

**A topic is open** if any of:
- it has no prerequisites (arrays), or
- every prerequisite topic has **≥ 80% of its Easy + Medium problems seen** (Hards don't count), or
- you already have a solved file in it.

**A new problem is eligible** if its topic is open, it's unseen, it isn't already in today's
session, and — if it's Hard — at least 80% of its topic's Mediums are seen.

**Order among eligible new problems**: topics in sheet order (which follows the roadmap), then
row order within the topic. Effectively: finish the earliest open topic before moving on.

With today's data: Tries/Heap/Backtracking stay locked until Trees reaches 80%, so the next
new problems come from Arrays (Valid Sudoku, Encode and Decode Strings), then the Hards of
Two Pointers and Sliding Window (their Mediums are all seen), then Stack, Binary Search,
Linked List and Trees. The easy pool has nothing unseen before Trees, so slot A's first new
problems will be Trees easies.

## 7. Daily slots (`bin/srs today`)

Pools: **easy** = LeetCode Easy; **medium_hard** = Medium + Hard.

| Slot | Pool | When |
|---|---|---|
| A | easy | always |
| B | medium_hard | always |
| C | easy | only after any slot today is graded `easy` (max once per day) |

Each slot is filled by the first rule that gives a problem:

1. **Forced new** — if `today - last_new_on >= 2` and no new problem is in today's session yet:
   the slot whose pool is `next_forced_pool` takes the next eligible new problem (if that pool
   has none, the other slot tries). `next_forced_pool` flips when that new problem is graded.
   *Not for slot C.*
2. **Due review** — the problem in this pool with the most days overdue (`next_review <= today`);
   ties → sheet order.
3. **New** — the next eligible new problem in this pool (§6).
4. **Early review** — the problem in this pool with the nearest `next_review`.
5. Otherwise the slot is empty.

The session is saved in state.yml, so running `today` again the same day shows the same picks.
When the date changes, a fresh session is built; ungraded slots from yesterday simply drop
(a due review is still due tomorrow; an unseen problem is still unseen).

Output:

```
2026-09-23 — 2 problems (grade one `easy` to unlock a 3rd)

A  REVIEW  Contains Duplicate · Easy · arrays       last done 193d ago, 192d overdue
   https://leetcode.com/problems/contains-duplicate/
   arrays_and_hashing/easy/contains_duplicate.rb
   notes: hashset to get unique values in array, to check for duplicates easily

B  NEW     Valid Sudoku · Medium · arrays
   https://leetcode.com/problems/valid-sudoku/
   arrays_and_hashing/medium/valid_sudoku.rb  (run `srs start B`)
```

## 8. Working a slot (`bin/srs start A`)

**New problem** → create the file (if it doesn't already exist from an abandoned start):

```ruby
# frozen_string_literal: true

# graphs/medium/number_of_islands.rb

# Problem
# https://leetcode.com/problems/number-of-islands/

if __FILE__ == $PROGRAM_NAME
end
```

**Review** → create `<name>.attempt.rb` **next to** the original (same folder, so
`require_relative '../helpers/utils'` still works). The original is never modified.
The attempt file is built from the original by keeping:

- everything before the first top-level `def` / `class` / `module` (header, link,
  `require_relative`, commented `TreeNode`/`ListNode` definitions, `@param`/`@return` hints),
  minus `# Approach …` banners and `# ----` separator lines;
- an **empty stub** for each top-level `def`/`class` (same signature, empty body), so the test
  block still has something to call;
- any top-level `def runner…` helper and the `if __FILE__ == $PROGRAM_NAME … end` block with
  your test cases.

This relies on your files being rubocop-formatted (top-level `def`/`end` at column 0). If a
file doesn't fit, fallback: header + test block only.

Example — `contains_duplicate.attempt.rb`:

```ruby
# frozen_string_literal: true

# arrays/easy/contains_duplicate.rb

# Problem
# https://leetcode.com/problems/contains-duplicate/description/

# @param {Integer[]} nums
# @return {Boolean}

def contains_duplicate(nums)
end

def contains_duplicate_uniq(nums)
end

if __FILE__ == $PROGRAM_NAME
  puts contains_duplicate([1, 2, 3])
  ...
end
```

`start` also prints the link and the file path.

## 9. Grading (`bin/srs grade A good`)

1. Apply SM-2 (§5), append to `history`, save.
2. If it was a new problem: set `last_new_on = today`, flip `next_forced_pool` if this was the
   forced pick.
3. If the grade is `easy` and the bonus isn't unlocked yet: unlock slot C and fill it (§7).
4. For reviews: print the original's path to compare against, then ask
   `delete attempt file? [Y/n]`. Keep it only if you want to copy a new approach into the
   original yourself.
5. Print the next review date.

Grading a slot twice, or grading an empty/locked slot, is refused.

## 10. `bin/srs status`

Per topic: seen / total, Easy+Medium % seen, open or locked. Plus: due today, overdue backlog,
days since last new problem.

## 11. Build order (each step stops for your review)

1. `setup` — produces problems.yml + seeded state.yml, prints matches and coverage.
2. SM-2 + slot picking, with minitest covering the formula, the forced-new rule, the unlock
   rule and Hard gating.
3. `today`, `start`, `grade`, `status`, and the `.gitignore` line.
