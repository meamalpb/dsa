package srs

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

var kindLabels = map[string]string{KindNew: "NEW", KindReview: "REVIEW", KindEarly: "EARLY"}

// SlotPrinter prints one day slot for `today` and `grade`.
type SlotPrinter struct {
	Root     string
	Problems Problems
	State    *State
	Config   Config
	Today    Date
	Out      io.Writer
}

func (sp SlotPrinter) Show(slot string, entry *Entry) {
	fmt.Fprintln(sp.Out)
	if entry.Empty() {
		fmt.Fprintf(sp.Out, "%s  nothing eligible in this pool today\n", slot)
		return
	}
	problem := sp.Problems[entry.Slug]
	graded := ""
	if entry.Grade != "" {
		graded = "  ✓ " + entry.Grade
	}
	fmt.Fprintf(sp.Out, "%s  %s  %s · %s · %s%s\n", slot, ljust(kindLabels[entry.Kind], 6), problem.Name,
		problem.Difficulty, problem.Topic, graded)
	if detail := sp.detail(entry); detail != "" {
		fmt.Fprintf(sp.Out, "   %s\n", detail)
	}
	fmt.Fprintf(sp.Out, "   %s\n", problem.Link)
	if problem.AltLink != "" {
		fmt.Fprintf(sp.Out, "   free version: %s\n", problem.AltLink)
	}
	fmt.Fprintf(sp.Out, "   %s\n", sp.fileLine(slot, entry, problem.File))
	if problem.Notes != "" {
		fmt.Fprintf(sp.Out, "   notes: %s\n", problem.Notes)
	}
}

func (sp SlotPrinter) detail(entry *Entry) string {
	card := sp.State.Problems[entry.Slug]
	if entry.Grade != "" {
		return "next review " + card.NextReview.String()
	}
	if entry.Kind == KindNew {
		if entry.Forced {
			days := sp.Config.Session.NewEveryDays
			unit := "days"
			if days == 1 {
				unit = "day"
			}
			return fmt.Sprintf("no new problem in %d %s, so this one is required", days, unit)
		}
		return ""
	}
	due := card.NextReview.Sub(sp.Today)
	var timing string
	switch {
	case due < 0:
		timing = fmt.Sprintf("%dd overdue", -due)
	case due == 0:
		timing = "due today"
	case entry.Chosen:
		timing = fmt.Sprintf("due in %dd — picked by you", due)
	default:
		timing = fmt.Sprintf("due in %dd — nothing due in this pool, so reviewing early", due)
	}
	return fmt.Sprintf("last done %dd ago, %s", sp.Today.Sub(card.LastReviewed), timing)
}

func (sp SlotPrinter) fileLine(slot string, entry *Entry, file string) string {
	if entry.Kind == KindNew {
		if exists(filepath.Join(sp.Root, file)) {
			return file + "  " + testHint(file)
		}
		return fmt.Sprintf("%s  (run `srs start %s`)", file, slot)
	}
	attempt := AttemptPath(file)
	if exists(filepath.Join(sp.Root, attempt)) {
		return fmt.Sprintf("%s  (original: %s)  %s", attempt, file, testHint(attempt))
	}
	return fmt.Sprintf("%s  (run `srs start %s` for a blank attempt)", file, slot)
}

// testHint is the command that runs the tests of the problem whose solution is file.
func testHint(file string) string {
	return "→ go test ./" + strings.TrimSuffix(filepath.ToSlash(filepath.Dir(file)), "/")
}

func exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}
