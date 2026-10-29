package srs

import (
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

func TestDateArithmeticAndFormatting(t *testing.T) {
	d := DateOf(2026, 2, 27)
	if got := d.AddDays(3).String(); got != "2026-03-02" {
		t.Errorf("2026-02-27 + 3 = %s", got)
	}
	if got := d.AddDays(3).Sub(d); got != 3 {
		t.Errorf("difference = %d, want 3", got)
	}
	for date, want := range map[string]int{"2026-09-21": 1, "2026-09-24": 4, "2026-09-27": 7} {
		parsed, err := ParseDate(date)
		if err != nil || parsed.ISOWeekday() != want {
			t.Errorf("%s: weekday %d (%v), want %d", date, parsed.ISOWeekday(), err, want)
		}
	}
	if _, err := ParseDate("23/09/2026"); err == nil {
		t.Error("a date in another format was accepted")
	}
}

func TestStateRoundTripWritesPlainDates(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.yml")
	state := DefaultState()
	state.LastNewOn = DateOf(2026, 10, 21)
	state.Problems["two-sum"] = &Card{
		Reps: 2, Ease: 2.36, Interval: 6, LastReviewed: DateOf(2026, 10, 21), NextReview: DateOf(2026, 10, 27),
		History: []HistoryEntry{{DateOf(2026, 10, 20), "seed"}, {DateOf(2026, 10, 21), "good"}},
	}
	state.Session = &Session{Date: DateOf(2026, 10, 21), Slots: map[string]*Entry{
		"A": {Slug: "two-sum", Kind: KindReview, Grade: "good"},
		"B": {}, // nothing eligible
	}}
	if err := SaveState(path, state); err != nil {
		t.Fatal(err)
	}

	raw, _ := os.ReadFile(path)
	for _, want := range []string{"last_new_on: 2026-10-21\n", "last_reviewed: 2026-10-21\n", "- date: 2026-10-20\n", "ease: 2.36\n"} {
		if !strings.Contains(string(raw), want) {
			t.Errorf("state.yml lacks %q:\n%s", want, raw)
		}
	}
	if strings.Contains(string(raw), "'2026") || strings.Contains(string(raw), "T00:00") {
		t.Errorf("dates aren't written plainly:\n%s", raw)
	}

	loaded, err := LoadState(path)
	if err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(loaded, state) {
		t.Errorf("round trip changed the state:\n got %+v\nwant %+v", loaded, state)
	}
	if exists(path + ".tmp") {
		t.Error("the temp file was left behind")
	}
}

// A state.yml as the Ruby version wrote it (a `---` header, empty values for nil).
func TestLoadStateReadsTheRubyFormat(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.yml")
	os.WriteFile(path, []byte(`---
problems:
  contains-duplicate:
    reps: 4
    ease: 2.8
    interval: 45
    last_reviewed: 2026-10-21
    next_review: 2026-12-05
    history:
    - date: 2026-03-14
      grade: seed
    - date: 2026-10-21
      grade: easy
last_new_on: 2026-10-21
next_forced_pool: easy
session:
  date: 2026-10-21
  slots:
    A:
      slug: contains-duplicate
      kind: review
      forced: false
      grade:
    B:
      slug:
      kind:
      forced: false
      grade:
`), 0o644)
	state, err := LoadState(path)
	if err != nil {
		t.Fatal(err)
	}
	card := state.Problems["contains-duplicate"]
	if card.Reps != 4 || card.Ease != 2.8 || card.NextReview != DateOf(2026, 12, 5) || len(card.History) != 2 {
		t.Errorf("card = %+v", card)
	}
	if state.LastNewOn != DateOf(2026, 10, 21) || state.NextForcedPool != "easy" {
		t.Errorf("state = %+v", state)
	}
	if a, b := state.Session.Slots["A"], state.Session.Slots["B"]; a.Grade != "" || a.Slug == "" || !b.Empty() {
		t.Errorf("slots = %+v %+v", a, b)
	}
}

func TestLoadStateMissingFileGivesFreshState(t *testing.T) {
	state, err := LoadState(filepath.Join(t.TempDir(), "nope.yml"))
	if err != nil || len(state.Problems) != 0 || state.NextForcedPool != "medium_hard" {
		t.Errorf("got %+v, %v", state, err)
	}
}

func TestSaveProblemsKeepsSheetOrder(t *testing.T) {
	path := filepath.Join(t.TempDir(), "problems.yml")
	problems := Problems{
		"zebra": {Name: "Z", Topic: "arrays", Difficulty: "Easy", Order: 1, Link: "l"},
		"apple": {Name: "A", Topic: "arrays", Difficulty: "Hard", Order: 2, Link: "l", PaidOnly: true, AltLink: "free", Notes: "note: with colon"},
		"3sum":  {Name: "3", Topic: "arrays", Difficulty: "Medium", Order: 3, Link: "l"},
	}
	if err := SaveProblems(path, problems); err != nil {
		t.Fatal(err)
	}
	raw, _ := os.ReadFile(path)
	if strings.Index(string(raw), "zebra:") > strings.Index(string(raw), "apple:") {
		t.Errorf("not in sheet order:\n%s", raw)
	}
	if strings.Contains(string(raw), "alt_link: \"\"") {
		t.Errorf("empty alt_link written:\n%s", raw)
	}
	loaded, err := LoadProblems(path)
	if err != nil || !reflect.DeepEqual(loaded, problems) {
		t.Errorf("round trip changed the problems: %v\n%+v", err, loaded)
	}
}

func TestLoadProblemsMissingFileIsAnError(t *testing.T) {
	if _, err := LoadProblems(filepath.Join(t.TempDir(), "nope.yml")); !os.IsNotExist(err) {
		t.Errorf("error = %v, want not-exist", err)
	}
}

// The committed problems.yml must be complete and consistent.
func TestCommittedProblemsAreSane(t *testing.T) {
	problems, err := LoadProblems("../../srs/problems.yml")
	if err != nil {
		t.Fatal(err)
	}
	if len(problems) != 150 {
		t.Errorf("%d problems, want 150", len(problems))
	}
	files := map[string]string{}
	for slug, p := range problems {
		if p.Difficulty != "Easy" && p.Difficulty != "Medium" && p.Difficulty != "Hard" {
			t.Errorf("%s: difficulty %q", slug, p.Difficulty)
		}
		if TopicFolder(p.Topic) == "" {
			t.Errorf("%s: unknown topic %q", slug, p.Topic)
		}
		if want := SolutionPath(p.Topic, p.Difficulty, slug); p.File != want {
			t.Errorf("%s: file %q, want %q", slug, p.File, want)
		}
		if other, dup := files[p.File]; dup {
			t.Errorf("%s and %s share %s", slug, other, p.File)
		}
		files[p.File] = slug
		if p.PaidOnly && p.AltLink == "" {
			t.Errorf("%s is premium with no free link", slug)
		}
		if !strings.HasSuffix(p.File, ".go") || strings.Contains(p.File, ".rb") {
			t.Errorf("%s: file %q isn't a Go file", slug, p.File)
		}
	}
}
