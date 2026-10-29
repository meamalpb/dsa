package srs

import "testing"

var day0 = DateOf(2026, 1, 1)

// The worked example in DESIGN.md §5.
func TestSm2DesignExample(t *testing.T) {
	cfg := DefaultConfig().Sm2
	card := NewCard(cfg)
	steps := []struct {
		day      int
		grade    string
		ease     float64
		interval int
	}{{0, "good", 2.5, 1}, {1, "good", 2.5, 6}, {7, "hard", 2.36, 14}, {21, "again", 1.82, 1}}
	for _, s := range steps {
		card = Review(card, s.grade, day0.AddDays(s.day), cfg)
		if card.Ease != s.ease || card.Interval != s.interval || card.NextReview != day0.AddDays(s.day+s.interval) {
			t.Errorf("day %d %s: got ease %v interval %d next %v, want ease %v interval %d",
				s.day, s.grade, card.Ease, card.Interval, card.NextReview, s.ease, s.interval)
		}
	}
	if card.Reps != 0 {
		t.Errorf("reps = %d after again, want 0", card.Reps)
	}
	if len(card.History) != 4 {
		t.Errorf("history has %d entries, want 4", len(card.History))
	}
}

func TestSm2ThirdSuccessMultipliesByEase(t *testing.T) {
	card := Card{Reps: 2, Ease: 2.5, Interval: 6}
	if got := Review(card, "good", day0, DefaultConfig().Sm2).Interval; got != 15 {
		t.Errorf("interval = %d, want 15", got)
	}
}

func TestSm2EasyRaisesEase(t *testing.T) {
	cfg := DefaultConfig().Sm2
	if got := Review(NewCard(cfg), "easy", day0, cfg).Ease; got != 2.6 {
		t.Errorf("ease = %v, want 2.6", got)
	}
}

func TestSm2EaseNeverBelowMinimum(t *testing.T) {
	cfg := DefaultConfig().Sm2
	card := Review(Card{Reps: 5, Ease: 1.4, Interval: 30}, "again", day0, cfg)
	if card.Ease != 1.3 || card.Interval != 1 {
		t.Errorf("got ease %v interval %d, want 1.3 and 1", card.Ease, card.Interval)
	}
}

func TestSm2FirstIntervalsAreConfigurable(t *testing.T) {
	cfg := mustConfig(t, "sm2:\n  first_intervals: [2, 4]\n").Sm2
	card := Review(NewCard(cfg), "good", day0, cfg)
	if card.Interval != 2 {
		t.Errorf("first interval = %d, want 2", card.Interval)
	}
	card = Review(card, "good", day0.AddDays(2), cfg)
	if card.Interval != 4 {
		t.Errorf("second interval = %d, want 4", card.Interval)
	}
	if got := Review(card, "again", day0.AddDays(6), cfg).Interval; got != 2 {
		t.Errorf("interval after again = %d, want 2", got)
	}
}

func TestSm2MaxIntervalCapsGrowth(t *testing.T) {
	cfg := mustConfig(t, "sm2:\n  max_interval: 30\n").Sm2
	card := Review(Card{Reps: 4, Ease: 2.5, Interval: 38}, "easy", day0, cfg)
	if card.Interval != 30 || card.NextReview != day0.AddDays(30) {
		t.Errorf("got interval %d next %v, want 30 days", card.Interval, card.NextReview)
	}
}

func TestSm2StartEaseIsConfigurable(t *testing.T) {
	cfg := mustConfig(t, "sm2:\n  start_ease: 2.0\n").Sm2
	if got := NewCard(cfg).Ease; got != 2.0 {
		t.Errorf("ease = %v, want 2.0", got)
	}
}

func TestSm2DoesNotModifyInput(t *testing.T) {
	cfg := DefaultConfig().Sm2
	card := NewCard(cfg)
	Review(card, "good", day0, cfg)
	if card.Reps != 0 || len(card.History) != 0 || card.Interval != 0 {
		t.Errorf("input card changed: %+v", card)
	}
}

func TestFormatFloat(t *testing.T) {
	for in, want := range map[float64]string{2.5: "2.5", 2: "2.0", 1.3: "1.3", 2.36: "2.36"} {
		if got := formatFloat(in); got != want {
			t.Errorf("formatFloat(%v) = %q, want %q", in, got, want)
		}
	}
}
