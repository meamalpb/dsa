package srs

import (
	"fmt"
	"io"
	"regexp"
	"slices"
	"strings"
)

const usage = `usage: srs <command>

  today                show today's problems (slot A = Easy, B = Medium/Hard)
  start <slot>         create the files to work in (new: scaffold, review: attempts/ copy)
  start <file|slug>    practise a problem you pick, e.g. linked_list/medium/reorder_list/reorder_list.go:
                       adds it as an extra slot today, graded like any other
  grade <slot> <how>   how = again | hard | good | easy  (` + "`easy`" + ` unlocks slot C)
  more [new|old] [easy|medium|hard|all]
                       all done? get an extra problem (slots D, E, …):
                       new (default) = next new problem, old = most overdue review;
                       easy/medium/hard limits the difficulty (all = any, default)
  status               coverage per topic, what's due
  overdue              list every overdue problem, most overdue first
  setup                build srs/problems.yml and seed srs/state.yml (safe to re-run)
`

var slotPattern = regexp.MustCompile(`^[A-Z]$`)

// Run dispatches one srs command. loadEnv is only called for commands that need the repo,
// so `srs help` works anywhere.
func Run(args []string, loadEnv func() (Env, error), in io.Reader, out io.Writer) error {
	if len(args) == 0 {
		fmt.Fprint(out, usage)
		return nil
	}
	command, rest := args[0], args[1:]
	switch command {
	case "help", "-h", "--help":
		fmt.Fprint(out, usage)
		return nil
	case "today", "start", "grade", "more", "status", "overdue", "setup":
	default:
		return fmt.Errorf("unknown command: %s\n\n%s", command, usage)
	}

	env, err := loadEnv()
	if err != nil {
		return err
	}
	if command == "setup" {
		config, err := LoadConfig(env.ConfigPath)
		if err != nil {
			return err
		}
		return Setup{Env: env, Config: config, Out: out}.Run()
	}

	commands, err := NewCommands(env, in, out)
	if err != nil {
		return err
	}
	switch command {
	case "today":
		return commands.Today()
	case "start":
		return start(commands, argAt(rest, 0))
	case "grade":
		slot, err := parseSlot(argAt(rest, 0))
		if err != nil {
			return err
		}
		return commands.Grade(slot, strings.ToLower(argAt(rest, 1)))
	case "more":
		kind, difficulty, err := moreOptions(rest)
		if err != nil {
			return err
		}
		return commands.More(kind, difficulty)
	case "status":
		return commands.Status()
	default: // overdue
		return commands.Overdue()
	}
}

func argAt(args []string, i int) string {
	if i < len(args) {
		return args[i]
	}
	return ""
}

// moreOptions reads the words of `more` in any order, e.g. `more old easy` or `more medium`:
// the kind (new or old) and the difficulty ("Easy", … or "" for any).
func moreOptions(args []string) (kind, difficulty string, err error) {
	kinds := []string{"new", "old"}
	diffs := []string{"easy", "medium", "hard", "all"}
	var gotKinds, gotDiffs []string
	for _, arg := range args {
		word := strings.ToLower(arg)
		switch {
		case slices.Contains(kinds, word):
			gotKinds = append(gotKinds, word)
		case slices.Contains(diffs, word):
			gotDiffs = append(gotDiffs, word)
		default:
			return "", "", fmt.Errorf("more takes new|old and easy|medium|hard|all, one of each at most.\n\n%s", usage)
		}
	}
	if len(gotKinds) > 1 || len(gotDiffs) > 1 {
		return "", "", fmt.Errorf("more takes new|old and easy|medium|hard|all, one of each at most.\n\n%s", usage)
	}
	kind = "new"
	if len(gotKinds) == 1 {
		kind = gotKinds[0]
	}
	if len(gotDiffs) == 1 && gotDiffs[0] != "all" {
		difficulty = strings.ToUpper(gotDiffs[0][:1]) + gotDiffs[0][1:]
	}
	return kind, difficulty, nil
}

// start: a single letter is a slot; anything longer is a problem's file, folder or slug.
func start(commands *Commands, arg string) error {
	if len(arg) > 1 {
		return commands.Practice(arg)
	}
	slot, err := parseSlot(arg)
	if err != nil {
		return err
	}
	return commands.Start(slot)
}

func parseSlot(arg string) (string, error) {
	slot := strings.ToUpper(arg)
	if !slotPattern.MatchString(slot) {
		return "", fmt.Errorf("slot must be a letter like A, B, C, D\n\n%s", usage)
	}
	return slot, nil
}
