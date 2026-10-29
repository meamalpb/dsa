# srs

Spaced repetition for the NeetCode 150 sheet, written in Go, for solving the problems in Go. Each day
it picks 2 problems (1 Easy, 1 Medium/Hard) from reviews that are due plus new problems, schedules
reviews with SM-2, and unlocks topics in NeetCode roadmap order.

Full design and the reasoning behind it: [DESIGN.md](DESIGN.md).
The rules (slots, pace, unlock thresholds, review spacing) are set in [config.yml](config.yml).

## Install

Needs Go 1.23 or newer. From the repo root:

```sh
go build -o bin/srs ./cmd/srs     # then use bin/srs below (bin/ is gitignored)
```

Alternatives: `go run ./cmd/srs today` (no build step, a little slower each time) or
`go install ./cmd/srs` (puts `srs` in `~/go/bin`, so it needs to be on your `PATH`). Rebuild after
pulling changes to the tool.

It finds the repo from wherever you run it, as long as that is somewhere inside it.

## Usage

```sh
bin/srs today            # today's slots A (Easy) and B (Medium/Hard)
bin/srs start A          # new problem → files to fill in; review → a blank attempt under attempts/
bin/srs start linked_list/medium/reorder_list   # practise any problem you pick (folder, file or slug): extra slot today, graded like the others
bin/srs grade A good     # again | hard | good | easy — `easy` unlocks a bonus slot C
bin/srs more [new|old] [easy|medium|hard|all]   # all graded? extra slot D, E, …: new problem (default; `grade` also offers this) or most overdue review, optionally only of one difficulty
bin/srs status           # coverage per topic, what's open/locked, what's due
bin/srs overdue          # every overdue problem, most overdue first, with days late / last done / reps / ease
bin/srs setup            # rebuild problems.yml from the sheet (the repo ships with it built; safe to re-run)
```

A day looks like: `today` → `start A` → solve it → `grade A good` → same for B.
`today` shows the same picks all day, so run it as often as you like.

Grades: `again` couldn't solve it · `hard` solved, but struggled · `good` solved · `easy` trivial.

## Solving a problem

Every problem is its own folder and its own package:

```
arrays_and_hashing/easy/two_sum/two_sum.go        # your solution
arrays_and_hashing/easy/two_sum/two_sum_test.go   # table-driven tests you fill in
```

`start` creates both for a new problem, and prints the command to run them:

```sh
go test ./arrays_and_hashing/easy/two_sum
```

Keep the `// https://leetcode.com/problems/…/` line in the solution file; it's how srs recognises it.

**Reviews** don't touch your solution. `start` copies the problem into `attempts/` (gitignored) with
every function body replaced by `panic("TODO")` and the tests copied over, so the test fails until
you've redone it:

```sh
go test ./attempts/arrays_and_hashing/easy/two_sum
```

After grading you're asked whether to delete the attempt; keep it only if you want to copy a new
approach into your original. Because attempts fail on purpose, `go test ./...` fails while one exists;
run the one package you're working on instead.

**Linked lists and trees:** [`ds`](../ds) has `ListNode`, `TreeNode` and builders, so tests can be
literals: `ds.NewList(1, 2, 3)`, `ds.NewTree(3, 9, 20, ds.Null, ds.Null, 15, 7)`, and `.Slice()` /
`.LevelOrder()` to compare results. Put `type ListNode = ds.ListNode` at the top of your file to keep
LeetCode's signature, and drop it (and the import) when pasting into LeetCode.

## Trying things out safely

```sh
cp srs/state.yml /tmp/try.yml
SRS_STATE=/tmp/try.yml SRS_TODAY=2026-10-01 bin/srs today    # a copy of your history, a pretend date
SRS_CONFIG=/tmp/my.yml SRS_STATE=/tmp/try.yml bin/srs today  # try different settings
go test ./...                                                # tests (the tool's, and any attempts you have open)
```

## Files

| Path | What | Edit by hand? |
|---|---|---|
| `problems.yml` | Facts per problem: topic, difficulty, link, file, notes | No — `setup` regenerates it |
| `config.yml` | Slots, pools, new-problem pace, unlock thresholds, SM-2 spacing | Yes — every setting is listed with a comment |
| `state.yml` | Your review history and schedule | No — only `grade` writes it. **Commit it**, it's the only record |
| `../internal/srs/` | The code (Go standard library plus `gopkg.in/yaml.v3`) | — |

`internal/srs/` at a glance:

- `sheet.go` — reads the published Google Sheet (setup only; the sheet never changes)
- `leetcode.go` — difficulty + premium flag from LeetCode (setup only, 1 request/sec)
- `topics.go` — topic → folder map and the roadmap of prerequisites
- `progress.go` — per-topic coverage and the unlock rules
- `setup.go` — matches local solutions to sheet rows and seeds state
- `config.go` — loads config.yml over the defaults and checks it
- `sm2.go` — the review-interval math
- `scheduler.go` — picks each day's slots
- `scaffold.go` — new-problem files and review attempts
- `commands.go`, `slotprinter.go` — `today` / `start` / `grade` / `status` and their output
- `store.go`, `date.go`, `report.go`, `charts.go`, `cli.go`, `env.go` — YAML I/O and types, dates, tables, charts, command dispatch, finding the repo

## Rules worth knowing

These are the defaults; each number is a setting in config.yml.

- **Matching**: a solution file is linked to a sheet row by its `// https://leetcode.com/problems/<slug>/`
  header. Files without one, or not on the sheet, are ignored.
- **Topics unlock** when every prerequisite topic has 80% of its Easy + Medium problems solved,
  or when you already have a solution in that topic. A topic's Hards wait until 80% of its
  Mediums are solved.
- **A new problem at least every 2 days**, even if reviews are piling up.
- **Premium problems** link to NeetCode's free version.

## Adding things

- A sheet link LeetCode has renamed → add it to `slugFixes` in `sheet.go`, re-run setup.
- A new premium problem → add it to `neetcodeSlugs` in `leetcode.go`.
- Wrote a sheet problem outside srs → make sure it has the URL header, re-run setup to seed it.
