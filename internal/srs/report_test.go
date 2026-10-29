package srs

import (
	"strings"
	"testing"
)

var reportToday = DateOf(2026, 10, 2)

func reportFixture() (Problems, *State) {
	problems := Problems{
		"e1":     {Name: "Easy One", Topic: "arrays", Difficulty: "Easy", Order: 1},
		"m1":     {Name: "Medium One", Topic: "trees", Difficulty: "Medium", Order: 2},
		"future": {Name: "Not Due Yet", Topic: "arrays", Difficulty: "Easy", Order: 3},
	}
	return problems, DefaultState()
}

func dueCard(nextReview Date) *Card {
	return &Card{Reps: 1, Ease: 2.5, Interval: 1, LastReviewed: nextReview.AddDays(-1), NextReview: nextReview}
}

func overdueOutput(problems Problems, state *State) string {
	var out strings.Builder
	Overdue(problems, state, reportToday, &out)
	return out.String()
}

func TestOverdueListsMostOverdueFirst(t *testing.T) {
	problems, state := reportFixture()
	state.Problems["e1"] = dueCard(reportToday.AddDays(-1))
	state.Problems["m1"] = dueCard(reportToday.AddDays(-10))
	state.Problems["future"] = dueCard(reportToday.AddDays(5))

	out := overdueOutput(problems, state)
	if !strings.Contains(out, "Overdue (2):") {
		t.Errorf("no count of 2 in:\n%s", out)
	}
	if strings.Index(out, "Medium One") > strings.Index(out, "Easy One") {
		t.Errorf("most overdue isn't first:\n%s", out)
	}
	if strings.Contains(out, "Not Due Yet") {
		t.Errorf("a problem that isn't due is listed:\n%s", out)
	}
}

func TestOverdueProblemDueTodayCounts(t *testing.T) {
	problems, state := reportFixture()
	state.Problems["e1"] = dueCard(reportToday)
	if out := overdueOutput(problems, state); !strings.Contains(out, "Overdue (1):") {
		t.Errorf("due today isn't listed:\n%s", out)
	}
}

func TestOverdueIgnoresCardWithoutProblem(t *testing.T) {
	problems, state := reportFixture()
	state.Problems["deleted-from-sheet"] = dueCard(reportToday.AddDays(-3))
	if out := overdueOutput(problems, state); !strings.Contains(out, "Nothing overdue.") {
		t.Errorf("got:\n%s", out)
	}
}

func TestOverdueNothingOverdue(t *testing.T) {
	problems, state := reportFixture()
	state.Problems["future"] = dueCard(reportToday.AddDays(5))
	if out := overdueOutput(problems, state); !strings.Contains(out, "Nothing overdue.") {
		t.Errorf("got:\n%s", out)
	}
}

func TestCoverageShowsLockedTopicsAndPrereqs(t *testing.T) {
	problems, state := reportFixture()
	var out strings.Builder
	Coverage(problems, state, DefaultConfig(), &out)
	text := out.String()
	// Topics with no problems count as covered, so only two_pointers (behind arrays, 0% seen) is locked here.
	for _, want := range []string{"arrays", "open", "two_pointers", "locked (needs arrays)"} {
		if !strings.Contains(text, want) {
			t.Errorf("coverage lacks %q:\n%s", want, text)
		}
	}
}
