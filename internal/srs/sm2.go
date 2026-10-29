package srs

import (
	"fmt"
	"math"
	"slices"
	"strings"
)

// Quality maps a grade to its SM-2 quality — DESIGN.md §5.
var Quality = map[string]int{"again": 1, "hard": 3, "good": 4, "easy": 5}

func GradeList() string { return strings.Join(grades, ", ") }

func ValidGrade(grade string) bool {
	_, ok := Quality[grade]
	return ok
}

// NewCard is what a problem starts as before its first grade.
func NewCard(c Sm2Config) Card {
	return Card{Ease: c.StartEase}
}

// Review returns the card after grading it today; the card passed in isn't modified.
func Review(card Card, grade string, today Date, c Sm2Config) Card {
	q := float64(Quality[grade])
	ease := roundTo(math.Max(c.MinEase, card.Ease+0.1-(5-q)*(0.08+(5-q)*0.02)), 2)

	reps, interval := 0, c.FirstIntervals[0]
	if q >= 3 {
		reps, interval = nextInterval(card.Reps+1, card.Interval, ease, c)
	}
	if c.MaxInterval > 0 {
		interval = min(interval, c.MaxInterval)
	}

	card.Reps, card.Ease, card.Interval = reps, ease, interval
	card.LastReviewed, card.NextReview = today, today.AddDays(interval)
	card.History = append(slices.Clone(card.History), HistoryEntry{Date: today, Grade: grade})
	return card
}

func nextInterval(reps, previous int, ease float64, c Sm2Config) (int, int) {
	switch reps {
	case 1:
		return reps, c.FirstIntervals[0]
	case 2:
		return reps, c.FirstIntervals[1]
	default:
		return reps, int(math.Round(float64(previous) * ease))
	}
}

func roundTo(x float64, places int) float64 {
	scale := math.Pow(10, float64(places))
	return math.Round(x*scale) / scale
}

// formatFloat prints 2.5 as 2.5 and 2 as 2.0, the way the data files and reports show ease.
func formatFloat(f float64) string {
	s := fmt.Sprintf("%g", f)
	if !strings.ContainsAny(s, ".e") {
		s += ".0"
	}
	return s
}
