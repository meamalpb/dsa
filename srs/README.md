# srs

Spaced repetition for the NeetCode 150 sheet. Each day it picks 2 problems (1 Easy, 1 Medium/Hard)
from reviews that are due plus new problems, schedules reviews with SM-2, and unlocks topics
in NeetCode roadmap order.

Full design and the reasoning behind it: [DESIGN.md](DESIGN.md).

## Usage

```sh
bin/srs today            # today's slots A (Easy) and B (Medium/Hard)
bin/srs start A          # new problem → scaffold file; review → name.attempt.rb next to the original
bin/srs grade A good     # again | hard | good | easy — `easy` unlocks a bonus slot C
bin/srs more              # all graded? get an extra new problem (slots D, E, …); `grade` also offers this
bin/srs status           # coverage per topic, what's open/locked, what's due
bin/srs setup            # one-time: build problems.yml, seed state.yml (safe to re-run)
```

A day looks like: `today` → `start A` → solve it → `grade A good` → same for B.
`today` shows the same picks all day, so run it as often as you like.

Grades: `again` couldn't solve it · `hard` solved, but struggled · `good` solved · `easy` trivial.

Review attempts live in `*.attempt.rb` (gitignored). After grading, you're asked whether to
delete it; keep it only if you want to copy a new approach into your original.

## Trying things out safely

```sh
cp srs/state.yml /tmp/try.yml
SRS_STATE=/tmp/try.yml SRS_TODAY=2026-10-01 bin/srs today   # a copy of your history, a pretend date
ruby srs/test/run_all.rb                                     # tests
```

## Files

| Path | What | Edit by hand? |
|---|---|---|
| `problems.yml` | Facts per problem: topic, difficulty, link, file, notes | No — setup regenerates it |
| `state.yml` | Your review history and schedule | No — only `grade` writes it. **Commit it**, it's the only record |
| `lib/` | The code (Ruby stdlib only) | — |

`lib/` at a glance:

- `sheet.rb` — reads the published Google Sheet (setup only; the sheet never changes)
- `leetcode.rb` — difficulty + premium flag from LeetCode (setup only, 1 request/sec)
- `topics.rb` — topic → folder map and the roadmap of prerequisites
- `progress.rb` — per-topic coverage and the unlock rules
- `setup.rb` — matches local solutions to sheet rows and seeds state
- `sm2.rb` — the review-interval math
- `scheduler.rb` — picks each day's slots
- `scaffold.rb` — new-problem files and review attempt files
- `commands.rb`, `slot_printer.rb` — `today` / `start` / `grade` / `status` and their output
- `store.rb`, `report.rb`, `cli.rb` — YAML I/O, tables, command dispatch

## Rules worth knowing

- **Matching**: a solution file is linked to a sheet row by its `# https://leetcode.com/problems/<slug>/`
  header. Files without one, or not on the sheet, are ignored.
- **Topics unlock** when every prerequisite topic has 80% of its Easy + Medium problems solved,
  or when you already have a solution in that topic. A topic's Hards wait until 80% of its
  Mediums are solved.
- **A new problem at least every 3 days**, even if reviews are piling up.
- **Premium problems** link to NeetCode's free version.

## Adding things

- A sheet link LeetCode has renamed → add it to `Sheet::SLUG_FIXES`, re-run setup.
- A new premium problem → add it to `Leetcode::NEETCODE_SLUGS`.
- Wrote a sheet problem outside srs → make sure it has the URL header, re-run setup to seed it.
