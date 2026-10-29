# SRS — spaced repetition for the NeetCode 150 sheet

Status: **built** — Go port of the original Ruby tool (still on the `master` branch). Usage lives in
[README.md](README.md).

## 1. What it does

A Go CLI (`srs`; the standard library plus `gopkg.in/yaml.v3`, Go 1.23+) that tells you which
2–3 LeetCode problems to do today, mixing reviews of problems you've already solved with new ones,
using SM-2 scheduling and a topic roadmap so new problems arrive in a sensible order. You solve them
in Go.

```
srs setup            # rebuild the data files (problems.yml ships with the repo, so only if you need to)
srs today            # show today's slots A, B (and C if unlocked)
srs start A          # create the files to work in for slot A
srs grade A good     # record how it went: again | hard | good | easy
srs status           # coverage per topic, open/locked topics, due counts
```

## 2. Files

```
cmd/srs/main.go          # entry point
internal/srs/*.go        # the tool: setup, sm2, scheduler, scaffold, commands, cli, …
internal/srs/*_test.go   # its tests — run with `go test ./...`
ds/                      # ListNode / TreeNode and helpers for your own problems (§8)
srs/DESIGN.md            # this file
srs/config.yml           # tunable rules (§12) — optional, defaults built in
srs/problems.yml         # facts about each problem — generated, rebuildable
srs/state.yml            # your review history — precious, never regenerated
<topic>/<difficulty>/<problem>/   # your solutions, one folder per problem (§4, §8)
attempts/                # blank copies for reviews (gitignored, §8)
```

Both YAML files are committed (state.yml is your only record of reviews, so it should be backed
up in git). `.gitignore` has `attempts/` and `bin/`.

### problems.yml — one entry per sheet row, keyed by LeetCode slug

```yaml
two-sum:
  name: Two Sum
  topic: arrays                 # see §4; derived from file location if a file exists
  difficulty: Easy              # from LeetCode, fetched once at setup
  paid_only: false
  link: https://leetcode.com/problems/two-sum/
  file: arrays_and_hashing/easy/two_sum/two_sum.go
  order: 3                      # row position in the sheet
  notes: "use hash map to instantly check for difference value..."
```

Premium problems also have an `alt_link` (NeetCode's free version).

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
      - date: 2026-03-14
        grade: good
last_new_on: 2026-09-20         # date a *new* problem was last graded
next_forced_pool: medium_hard   # alternates easy / medium_hard
session:                        # today's picks, so `today` is stable
  date: 2026-09-23
  slots:
    A: { slug: two-sum, kind: review }
    B: { slug: valid-sudoku, kind: new }
```

A problem is **seen** if it has an entry under `problems:` in state.yml.

## 3. Setup (`srs setup`)

`problems.yml` is committed, so a fresh clone is ready to use and never needs this. Run it to rebuild
the file, or to count solutions you wrote outside srs.

1. **Fetch the sheet once** as CSV from the published URL. The sheet is static, so this is the
   only time it's read. Slug = the `/problems/<slug>/` part of the Link (this also handles the
   `accounts/login/?next=/problems/encode-and-decode-strings/` link).
2. **Map local solutions**: scan every `.go` file (not `_test.go`) inside the topic folders for the
   `// https://leetcode.com/problems/<slug>/` header. Files whose slug isn't on the sheet are ignored.
3. **Fetch difficulty + premium flag** for each slug via LeetCode's GraphQL, 1 request/second.
   robots.txt disallows `/graphql` for crawlers, so this happens only at setup and only for
   slugs missing from problems.yml — `today`/`start`/`grade` never touch the network.
4. **Premium problems** (Encode and Decode Strings, Meeting Rooms I/II, Walls and Gates,
   Graph Valid Tree, Number of Connected Components, Alien Dictionary — confirmed by the flag)
   get an `alt_link` to NeetCode's free version. NeetCode slugs don't follow LeetCode's, so
   the 7 are mapped by hand in `neetcodeSlugs` (`leetcode.go`).
   One sheet link is out of date (`coin-change-2`, now `coin-change-ii`); `slugFixes`
   (`sheet.go`) corrects it.
5. **Seed state.yml** for every matched file that contains a `func`:
   `reps: 1, ease: 2.5, interval: 1, last_reviewed: <date the file was first committed>`,
   so all of them start overdue and come back oldest-first. First commit, not last: a later
   commit may just be a cleanup. A file with no `func` is an unsolved `srs start` scaffold and is
   skipped. Existing entries are never touched.
6. **Print** the match list and the coverage table (§4) and stop, so you can check them.

Re-running setup is safe: it only adds what's missing. Folders aren't created here; `start` makes
them when it needs them.

## 4. Topics and folders

| Sheet category | Topic key | Folder |
|---|---|---|
| Arrays (and `Graph`*) | arrays | `arrays_and_hashing/` |
| Two Pointers | two_pointers | `two_pointers/` |
| Sliding Window | sliding_window | `sliding_window/` |
| Stack | stack | `stack/` |
| Binary Search | binary_search | `binary_search/` |
| Linked List | linked_list | `linked_list/` |
| Trees | trees | `trees/` |
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
NeetCode's list.

**File location wins**: if a solution file exists, the problem's topic is the topic of the
folder it lives in. Otherwise the sheet category decides.

New file path: `<folder>/<difficulty>/<slug with - → _>/<slug with - → _>.go`,
e.g. `graphs/medium/number_of_islands/number_of_islands.go`. Every problem gets its own folder
because every problem is its own Go package (§8).

## 5. Scheduling: SM-2

Numbers below are the defaults; `first_intervals`, `start_ease`, `min_ease` and `max_interval`
are set in config.yml (§12).

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

The 80% thresholds and "Easy + Medium" are the defaults for `unlock.*` in config.yml (§12).
The roadmap itself stays in `topics.go`.

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

## 7. Daily slots (`srs today`)

The slots, pools, bonus rule, the 2-day forced-new rule and the review order below are the
defaults from config.yml (§12).

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

Once every slot is graded, `srs more` adds extra slots D, E, …: `more` / `more new` takes the
next eligible new problem (alternating pools), `more old` takes the most overdue due review from
either pool — a way to clear a review backlog without giving up the daily new problem.
Either form takes an optional difficulty (`easy`, `medium`, `hard`; `all` = any, the default), in any
order: `more old easy`, `more medium`. Hard still waits for the topic's hard-unlock.

The session is saved in state.yml, so running `today` again the same day shows the same picks.
When the date changes, a fresh session is built; ungraded slots from yesterday simply drop
(a due review is still due tomorrow; an unseen problem is still unseen).

Output:

```
2026-09-23 — 2 problems (grade one `easy` to unlock a 3rd)

A  REVIEW  Contains Duplicate · Easy · arrays
   last done 6d ago, 5d overdue
   https://leetcode.com/problems/contains-duplicate/
   attempts/arrays_and_hashing/easy/contains_duplicate/contains_duplicate.go  (original: arrays_and_hashing/easy/contains_duplicate/contains_duplicate.go)  → go test ./attempts/arrays_and_hashing/easy/contains_duplicate
   notes: hashset to get unique values in array, to check for duplicates easily

B  NEW     Valid Sudoku · Medium · arrays
   https://leetcode.com/problems/valid-sudoku/
   arrays_and_hashing/medium/valid_sudoku/valid_sudoku.go  (run `srs start B`)
```

## 8. Working a slot (`srs start A`)

Every problem is its own package in its own folder, always named `solution`:

```
arrays_and_hashing/easy/two_sum/two_sum.go        # the solution
arrays_and_hashing/easy/two_sum/two_sum_test.go   # table-driven tests
```

One package per problem keeps names from clashing (two problems can both have a `dfs`), and `solution`
for all of them sidesteps folder names that aren't valid package names, like `3sum`. Run a problem with
`go test ./arrays_and_hashing/easy/two_sum`.

**New problem** → create both files (only if the solution file doesn't already exist from an
abandoned start):

```go
// graphs/medium/number_of_islands/number_of_islands.go
//
// Problem
// https://leetcode.com/problems/number-of-islands/

package solution
```

plus a `_test.go` with an empty table-driven `TestSolution` to fill in. Setup finds your solution
by that URL line, so keep it.

**Review** → copy the problem into `attempts/<same path>/` (gitignored). The original is never modified.
The attempt keeps everything that isn't the answer:

- the header comment, `package`, the imports the remaining code still needs, and any `const`/`var`;
- **every function with its body replaced by `panic("TODO")`** — same signature, so it compiles and the
  tests have something to call;
- **a type that has methods** (a design problem like `MinStack`, `Trie`) loses its fields, since the
  fields are the answer; plain types such as a `ListNode` you defined yourself are kept;
- the `_test.go`, copied unchanged — it fails with the `TODO` panic until you solve it;
- not the `// ---` and `// Approach …` section comments.

`go/parser` gives the positions and the text is edited in place, rather than printing the syntax tree back
out, because that misplaces comments that sat inside removed bodies. If the original doesn't parse
(say you're mid-edit), the fallback is just its header and `package` line.

`start` prints the link and the `go test` command for the folder.

**A problem you pick** → `srs start <file, folder or slug>` (e.g.
`linked_list/medium/reorder_list/reorder_list.go`, `linked_list/medium/reorder_list`, its attempt, an
absolute path, or `reorder-list`). A single letter is still a slot. The problem gets the next extra slot
today (or keeps its slot if it's already in the session), skipping the usual rules: no waiting for the
day's slots to be graded, no unlock or due-date checks. Then it's started like any slot — attempt if
you've seen it, scaffold if not — and `grade` treats it like any other (SM-2 updates, and a new one
resets the new-problem clock). Picked problems don't shift the pool rotation of `more`.

**Linked lists and trees** → `import "dsa/ds"` for `ds.ListNode`, `ds.TreeNode` and builders:
`ds.NewList(1, 2, 3)`, `ds.NewTree(3, 9, 20, ds.Null, ds.Null, 15, 7)`, and `.Slice()` /
`.LevelOrder()` to read them back for comparing. Put `type ListNode = ds.ListNode` at the top of the
file to keep LeetCode's signature, and drop it (and the import) when you paste into LeetCode.

## 9. Grading (`srs grade A good`)

1. Apply SM-2 (§5), append to `history`, save.
2. If it was a new problem: set `last_new_on = today`, flip `next_forced_pool` if this was the
   forced pick.
3. If the grade is `easy` and the bonus isn't unlocked yet: unlock slot C and fill it (§7).
4. For reviews: print the original's path to compare against, then ask
   `Delete attempts/<folder>? [Y/n]`. Keep it only if you want to copy a new approach into the
   original yourself.
5. Print the next review date.

Grading a slot twice, or grading an empty/locked slot, is refused.

## 10. `srs status`

Per topic: seen / total, Easy+Medium % seen, open or locked. Plus: due today, overdue backlog,
days since last new problem.

`srs overdue` lists the backlog itself — one row per card whose `next_review` has passed,
sorted oldest-due-first, with topic, difficulty, days overdue, last reviewed date, reps, and ease.

## 11. Trying things out safely

The environment variables below let you experiment without touching your real history. `SRS_ROOT`
overrides where the repo is found (normally: walk up from the current folder to the one with `go.mod` and
`srs/`, like git finds `.git`).

```sh
cp srs/state.yml /tmp/try.yml
SRS_STATE=/tmp/try.yml SRS_TODAY=2026-10-01 srs today    # a copy of your history, a pretend date
SRS_CONFIG=/tmp/my.yml SRS_STATE=/tmp/try.yml srs today  # try different settings
go test ./...                                            # the tests
```

The tests cover SM-2 (including the worked example in §5), the scheduler rules, config validation, the
attempt generator (the stubs are type-checked, and one test runs the real `go test` on an attempt and its
original), the YAML round-trip, and a two-day run through the CLI.

## 12. Configuration (`srs/config.yml`)

The rules above that are a matter of taste live in `srs/config.yml`. The file is optional: a
missing file or a missing setting means the default, and the committed file lists every default
with a comment. Unknown settings and bad values stop the command with a message naming each one,
so a typo can't be silently ignored. `SRS_CONFIG=path` points at another file for trying things.

| Setting | Default | Meaning |
|---|---|---|
| `session.slots` | `{A: easy, B: medium_hard}` | daily slots, letter → pool. Replaced whole, not merged. |
| `session.bonus.pool` | `easy` | pool the bonus slots draw from |
| `session.bonus.unlock_on` | `[easy]` | grades that open the next bonus slot |
| `session.bonus.max` | `1` | bonus slots per day; they take the letters after the daily slots (C, D, …), extras from `more` come after those |
| `session.new_every_days` | `2` | force a new problem after this many days without one; the forced pick rotates through the daily slots' pools |
| `session.review_order` | `most_overdue` | or `learning_first`: due problems last done within `learning_days` go before older ones (also for `more old`) |
| `session.learning_days` | `14` | window for `learning_first` |
| `pools` | `{easy: [Easy], medium_hard: [Medium, Hard]}` | pool → LeetCode difficulty labels. Replaced whole. |
| `unlock.topic_ratio` | `0.8` | share of each prerequisite topic that must be seen |
| `unlock.topic_counts` | `[Easy, Medium]` | difficulties counted for `topic_ratio` |
| `unlock.hard_ratio` | `0.8` | share of a topic's Mediums seen before its Hards open |
| `sm2.first_intervals` | `[1, 6]` | days to the 1st and 2nd review; `again` restarts at the first. Grade-independent (an `easy`→4-day first step was tried and dropped). |
| `sm2.start_ease` | `2.5` | ease of a new or seeded problem |
| `sm2.min_ease` | `1.3` | ease floor |
| `sm2.max_interval` | none | cap on any interval, in days |
| `display.heatmap_weeks` | `26` | weeks shown by `status` |

Changing a setting affects only future picks and grades; intervals already in state.yml stay as
they were until that problem is next graded. The session already built for today is kept, so
slot changes show up tomorrow.

Not configurable: the grade → quality mapping (§5), the roadmap (`topics.go`), and the
setup-time sheet and LeetCode settings.
