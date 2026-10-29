package srs

import (
	"reflect"
	"testing"
)

var today = DateOf(2026, 9, 23)

type fixture struct {
	t        *testing.T
	problems Problems
	state    *State
	config   Config
}

func newFixture(t *testing.T) *fixture {
	state := DefaultState()
	state.LastNewOn = today.AddDays(-1) // no forced new unless a test says so
	return &fixture{t: t, problems: Problems{}, state: state, config: DefaultConfig()}
}

func (f *fixture) add(slug, topic, difficulty string) {
	f.problems[slug] = &Problem{Name: slug, Topic: topic, Difficulty: difficulty, Order: len(f.problems) + 1}
}

// addAll adds arrays problems named e1.. (Easy) and m1.. (Medium) by prefix.
func (f *fixture) addAll(slugs ...string) {
	for _, slug := range slugs {
		if slug[0] == 'e' {
			f.add(slug, "arrays", "Easy")
		} else {
			f.add(slug, "arrays", "Medium")
		}
	}
}

func (f *fixture) seen(slug string, nextReview Date) {
	f.state.Problems[slug] = &Card{Reps: 1, Ease: 2.5, Interval: 1, LastReviewed: nextReview.AddDays(-1), NextReview: nextReview}
}

func (f *fixture) configure(yaml string) { f.config = mustConfig(f.t, yaml) }

func (f *fixture) scheduler(on Date) *Scheduler {
	return NewScheduler(f.problems, f.state, on, f.config)
}

// picks is slot => {slug, kind}.
func (f *fixture) picks() map[string][2]string {
	picks := map[string][2]string{}
	for slot, e := range f.scheduler(today).Session().Slots {
		picks[slot] = [2]string{e.Slug, e.Kind}
	}
	return picks
}

func (f *fixture) pick(slot string) [2]string { return f.picks()[slot] }

func gradeAll(s *Scheduler) {
	for _, e := range s.Session().Slots {
		e.Grade = "good"
	}
}

func check(t *testing.T, got, want any) {
	t.Helper()
	if !reflect.DeepEqual(got, want) {
		t.Errorf("got %v, want %v", got, want)
	}
}

func TestDueReviewBeatsNew(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "e2")
	f.seen("e1", today)
	check(t, f.pick("A"), [2]string{"e1", "review"})
}

func TestMostOverdueReviewFirst(t *testing.T) {
	f := newFixture(t)
	f.addAll("m1", "m2")
	f.seen("m1", today.AddDays(-1))
	f.seen("m2", today.AddDays(-5))
	check(t, f.pick("B"), [2]string{"m2", "review"})
}

func TestNewProblemInSheetOrderWhenNothingDue(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "e2")
	check(t, f.pick("A"), [2]string{"e1", "new"})
}

func TestForcedNewAfterTwoDaysDespiteDueReviews(t *testing.T) {
	f := newFixture(t)
	f.addAll("m1", "m2", "e1")
	f.seen("m1", today.AddDays(-10))
	f.seen("e1", today.AddDays(-10))
	f.state.LastNewOn = today.AddDays(-2)
	check(t, f.picks(), map[string][2]string{"A": {"e1", "review"}, "B": {"m2", "new"}})
	if !f.scheduler(today).Session().Slots["B"].Forced {
		t.Error("slot B isn't marked forced")
	}
}

func TestNoForcedNewAfterOneDay(t *testing.T) {
	f := newFixture(t)
	f.addAll("m1", "m2")
	f.seen("m1", today.AddDays(-10))
	check(t, f.pick("B"), [2]string{"m1", "review"})
}

func TestForcedNewFallsBackToOtherPool(t *testing.T) {
	f := newFixture(t)
	f.addAll("m1", "e1", "e2")
	f.seen("m1", today.AddDays(-10))
	f.seen("e1", today.AddDays(-10))
	f.state.LastNewOn = 0
	f.state.NextForcedPool = "medium_hard" // no unseen Medium, so the Easy slot takes it
	check(t, f.picks(), map[string][2]string{"A": {"e2", "new"}, "B": {"m1", "review"}})
}

func TestLockedTopicIsSkipped(t *testing.T) {
	f := newFixture(t)
	f.add("t1", "two_pointers", "Medium") // first in sheet order, but locked
	f.add("a1", "arrays", "Medium")
	f.add("a2", "arrays", "Medium")
	f.seen("a1", today.AddDays(10)) // arrays 50% < 80%
	check(t, f.pick("B"), [2]string{"a2", "new"})

	f.seen("a2", today.AddDays(10)) // arrays 100%: two_pointers opens
	f.state.Session = nil
	check(t, f.pick("B"), [2]string{"t1", "new"})
}

func TestTopicOpenWhenAlreadyStarted(t *testing.T) {
	f := newFixture(t)
	f.add("a1", "arrays", "Medium")
	f.add("t1", "two_pointers", "Medium")
	f.add("t2", "two_pointers", "Medium")
	progress := NewProgress(f.problems, f.state, f.config)
	if progress.Open("two_pointers") {
		t.Error("two_pointers open with nothing in arrays seen")
	}
	f.seen("t1", today.AddDays(10)) // arrays still 0%, but two_pointers has a solved problem
	if !progress.Open("two_pointers") {
		t.Error("two_pointers still locked although it was started")
	}
}

func TestHardWaitsForMediums(t *testing.T) {
	f := newFixture(t)
	f.add("h1", "arrays", "Hard")
	f.addAll("m1", "m2")
	check(t, f.pick("B"), [2]string{"m1", "new"})

	f.seen("m1", today.AddDays(10)) // 50% of mediums: hard still locked, m2 next
	f.state.Session = nil
	check(t, f.pick("B"), [2]string{"m2", "new"})

	f.seen("m2", today.AddDays(10))
	f.state.Session = nil
	check(t, f.pick("B"), [2]string{"h1", "new"})
}

func TestEarlyReviewWhenNothingDueOrNew(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "e2")
	f.seen("e1", today.AddDays(9))
	f.seen("e2", today.AddDays(4))
	check(t, f.pick("A"), [2]string{"e2", "early"})
}

func TestEmptySlotWhenPoolHasNothing(t *testing.T) {
	f := newFixture(t)
	f.addAll("m1")
	check(t, f.picks(), map[string][2]string{"A": {"", ""}, "B": {"m1", "new"}})
}

func TestSessionIsStableWithinADayAndRebuiltNextDay(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1")
	first := f.scheduler(today).Session()
	if f.scheduler(today).Session() != first {
		t.Error("the same day built a new session")
	}
	if f.scheduler(today.AddDays(1)).Session() == first {
		t.Error("the next day reused yesterday's session")
	}
}

func TestBonusSlotTakesAnotherEasy(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "e2", "m1")
	s := f.scheduler(today)
	s.Session()
	s.UnlockBonus()
	var got []string
	for _, slot := range []string{"A", "B", "C"} {
		got = append(got, s.Session().Slots[slot].Slug)
	}
	check(t, got, []string{"e1", "m1", "e2"})
}

func TestExtraNewSlotsAfterEverythingGraded(t *testing.T) {
	f := newFixture(t)
	f.add("e1", "arrays", "Easy")
	f.add("m1", "arrays", "Medium")
	f.add("e2", "arrays", "Easy")
	f.add("m2", "arrays", "Medium")
	s := f.scheduler(today)
	gradeAll(s)
	if !s.AllGraded() {
		t.Fatal("not all graded")
	}
	for _, want := range []string{"D", "E"} {
		if slot, _, ok := s.AddExtraNew(""); !ok || slot != want {
			t.Errorf("got slot %q (ok=%v), want %s", slot, ok, want)
		}
	}
	if s.AllGraded() {
		t.Error("new extras count as graded")
	}
	if _, _, ok := s.AddExtraNew(""); ok {
		t.Error("an extra was added with nothing left")
	}
}

func TestChosenProblemGetsAnExtraSlotWithoutWaiting(t *testing.T) {
	f := newFixture(t)
	f.add("e1", "arrays", "Easy")
	f.add("m1", "arrays", "Medium")
	f.add("m2", "linked_list", "Medium")
	f.add("m3", "trees", "Medium")
	f.seen("m2", today.AddDays(30))
	s := f.scheduler(today)
	s.Session()
	if s.AllGraded() {
		t.Fatal("everything graded already")
	}
	slot, entry := s.AddChosen("m2")
	check(t, []string{slot, entry.Slug, entry.Kind}, []string{"D", "m2", "review"})
	if !entry.Chosen {
		t.Error("not marked chosen")
	}
	slot, entry = s.AddChosen("m3")
	check(t, []string{slot, entry.Slug, entry.Kind}, []string{"E", "m3", "new"})
}

func TestChosenProblemAlreadyInSessionKeepsItsSlot(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "m1")
	s := f.scheduler(today)
	s.Session()
	if slot, _ := s.AddChosen("m1"); slot != "B" {
		t.Errorf("slot = %s, want B", slot)
	}
	check(t, s.SlotLetters(), []string{"A", "B"})
}

func TestChosenNewProblemDoesNotShiftExtraRotation(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "m1", "e2", "m2", "e3")
	s := f.scheduler(today)
	gradeAll(s)
	_, chosen := s.AddChosen("e3")
	chosen.Grade = "good"
	if _, entry, _ := s.AddExtraNew(""); entry.Slug != "e2" {
		t.Errorf("extra = %s, want e2", entry.Slug)
	}
}

func TestExtraNewCanBeLimitedToADifficulty(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1", "m1", "m2", "e2")
	s := f.scheduler(today)
	gradeAll(s)
	for _, step := range []struct{ difficulty, want string }{{"Medium", "m2"}, {"Easy", "e2"}} {
		if _, entry, ok := s.AddExtraNew(step.difficulty); !ok || entry.Slug != step.want {
			t.Errorf("%s: got %+v (ok=%v), want %s", step.difficulty, entry, ok, step.want)
		}
	}
	if _, _, ok := s.AddExtraNew("Medium"); ok {
		t.Error("a third Medium was found")
	}
}

func overdueFixture(t *testing.T) *fixture {
	f := newFixture(t)
	f.addAll("e1", "m1", "e2", "m2")
	f.seen("e1", today.AddDays(-1))
	f.seen("m1", today.AddDays(-1))
	f.seen("e2", today.AddDays(-3))
	f.seen("m2", today.AddDays(-9))
	return f
}

func TestExtraReviewCanBeLimitedToADifficulty(t *testing.T) {
	s := overdueFixture(t).scheduler(today)
	s.Session()
	if _, entry, ok := s.AddExtraReview("Easy"); !ok || entry.Slug != "e1" {
		t.Errorf("got %+v, want e1", entry)
	}
	if _, _, ok := s.AddExtraReview("Easy"); ok {
		t.Error("a second easy review was found")
	}
	if _, entry, ok := s.AddExtraReview("Medium"); !ok || entry.Slug != "m1" {
		t.Errorf("got %+v, want m1", entry)
	}
}

func TestExtraReviewTakesMostOverdueFromEitherPool(t *testing.T) {
	s := overdueFixture(t).scheduler(today)
	if s.Session().Slots["A"].Slug != "e2" || s.Session().Slots["B"].Slug != "m2" {
		t.Fatalf("daily slots = %+v", s.Session().Slots)
	}
	slot, entry, ok := s.AddExtraReview("")
	check(t, []any{slot, entry.Slug, entry.Kind, ok}, []any{"D", "e1", "review", true})
	if _, entry, _ := s.AddExtraReview(""); entry.Slug != "m1" {
		t.Errorf("second extra = %s, want m1", entry.Slug)
	}
	if _, _, ok := s.AddExtraReview(""); ok {
		t.Error("a review was found with none due")
	}
}

func TestLearningFirstPutsRecentProblemsBeforeOldBacklog(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  review_order: learning_first\n")
	f.addAll("m1", "m2")
	f.seen("m1", today.AddDays(-190)) // old seed, far more overdue
	f.seen("m2", today.AddDays(-2))   // learned 3 days ago, missed its day-1 review
	check(t, f.pick("B"), [2]string{"m2", "review"})
}

func TestLearningFirstFallsBackToMostOverdue(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  review_order: learning_first\n  learning_days: 7\n")
	f.addAll("m1", "m2")
	f.seen("m1", today.AddDays(-30))
	f.seen("m2", today.AddDays(-90))
	check(t, f.pick("B"), [2]string{"m2", "review"})
}

func TestMoreOldFollowsReviewOrder(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  review_order: learning_first\n")
	f.addAll("e1", "e2", "m1", "m2", "m3")
	f.seen("m1", today.AddDays(-100))
	f.seen("m2", today.AddDays(-150))
	f.seen("m3", today.AddDays(-1))
	s := f.scheduler(today)
	if got := s.Session().Slots["B"].Slug; got != "m3" {
		t.Fatalf("slot B = %s, want m3", got)
	}
	if _, entry, _ := s.AddExtraReview(""); entry.Slug != "m2" {
		t.Errorf("extra review = %s, want m2", entry.Slug)
	}
}

func TestNewEveryDaysIsConfigurable(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  new_every_days: 1\n")
	f.addAll("m1", "m2")
	f.seen("m1", today.AddDays(-10))
	f.state.LastNewOn = today.AddDays(-1)
	check(t, f.pick("B"), [2]string{"m2", "new"})
}

func TestSeveralBonusSlotsThenExtrasAfterThem(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  bonus:\n    max: 2\n")
	f.addAll("e1", "e2", "e3", "e4", "m1")
	s := f.scheduler(today)
	s.Session()
	check(t, s.BonusSlots(), []string{"C", "D"})
	for _, want := range []string{"C", "D"} {
		if slot, _, _ := s.UnlockBonus(); slot != want {
			t.Errorf("unlocked %s, want %s", slot, want)
		}
	}
	if _, _, ok := s.UnlockBonus(); ok {
		t.Error("a third bonus slot opened")
	}
	if s.BonusLeft() {
		t.Error("BonusLeft with all open")
	}
	gradeAll(s)
	if slot, _, _ := s.AddExtraNew(""); slot != "E" {
		t.Errorf("extra slot = %s, want E", slot)
	}
}

func TestBonusPoolAndUnlockGradesAreConfigurable(t *testing.T) {
	f := newFixture(t)
	f.configure(`
pools:
  easy: [Easy]
  medium_hard: [Medium, Hard]
  any: [Easy, Medium, Hard]
session:
  bonus:
    pool: any
    unlock_on: [good, easy]
`)
	f.addAll("e1", "m1", "m2")
	s := f.scheduler(today)
	s.Session()
	if !s.UnlocksBonus("good") || s.UnlocksBonus("hard") {
		t.Error("unlock_on not applied")
	}
	if _, entry, _ := s.UnlockBonus(); entry.Slug != "m2" || entry.Kind != "new" {
		t.Errorf("bonus = %+v, want new m2", entry)
	}
}

func TestNoBonusWhenMaxIsZero(t *testing.T) {
	f := newFixture(t)
	f.configure("session:\n  bonus:\n    max: 0\n")
	f.addAll("e1")
	s := f.scheduler(today)
	s.Session()
	if _, _, ok := s.UnlockBonus(); ok || s.BonusLeft() {
		t.Error("bonus available although max is 0")
	}
}

func TestCustomSlotsAndForcedRotation(t *testing.T) {
	f := newFixture(t)
	f.configure(`
session:
  slots:
    A: easy
    B: medium
    C: hard
pools:
  easy: [Easy]
  medium: [Medium]
  hard: [Hard]
`)
	f.addAll("e1", "m1")
	s := f.scheduler(today)
	s.Session()
	check(t, s.SlotLetters(), []string{"A", "B", "C"})
	check(t, s.BonusSlots(), []string{"D"})
	s.RecordNew("B", &Entry{Forced: true})
	check(t, f.state.NextForcedPool, "hard")
	s.RecordNew("C", &Entry{Forced: true})
	check(t, f.state.NextForcedPool, "easy")
}

func TestRecordNewResetsTheClock(t *testing.T) {
	f := newFixture(t)
	f.addAll("e1")
	s := f.scheduler(today)
	s.Session()
	s.RecordNew("A", &Entry{})
	check(t, f.state.LastNewOn, today)
	check(t, f.state.NextForcedPool, "medium_hard") // not forced: the rotation stays
}

func TestTopicRatioIsConfigurable(t *testing.T) {
	f := newFixture(t)
	f.configure("unlock:\n  topic_ratio: 0.5\n")
	f.add("t1", "two_pointers", "Medium")
	f.addAll("m1")
	f.problems["m2"] = &Problem{Name: "m2", Topic: "arrays", Difficulty: "Medium", Order: 3}
	f.seen("m1", today.AddDays(10)) // arrays 50% — enough at 0.5
	check(t, f.pick("B"), [2]string{"t1", "new"})
}
