package srs

import (
	"strings"
	"testing"
)

var chartToday = DateOf(2026, 9, 24) // a Thursday

func daysAgo(offsets ...int) map[Date]int {
	days := map[Date]int{}
	for _, o := range offsets {
		days[chartToday.AddDays(-o)]++
	}
	return days
}

func TestBar(t *testing.T) {
	for ratio, want := range map[float64]string{0: "░░░░░░░░░░", 0.5: "█████░░░░░", 1: "██████████", 1.7: "██████████"} {
		if got := Bar(ratio); got != want {
			t.Errorf("Bar(%v) = %q, want %q", ratio, got, want)
		}
	}
}

func TestActivitySkipsSeedEntries(t *testing.T) {
	cards := map[string]*Card{
		"a": {History: []HistoryEntry{{chartToday, "seed"}, {chartToday, "good"}}},
		"b": {History: []HistoryEntry{{chartToday, "easy"}}},
	}
	if got := Activity(cards); len(got) != 1 || got[chartToday] != 2 {
		t.Errorf("activity = %v, want 2 gradings today", got)
	}
}

func TestActivityLevels(t *testing.T) {
	var got []int
	for _, n := range []int{0, 1, 2, 3, 4, 9} {
		got = append(got, activityLevel(n))
	}
	if want := []int{0, 1, 2, 2, 3, 3}; !equalInts(got, want) {
		t.Errorf("levels = %v, want %v", got, want)
	}
}

func equalInts(a, b []int) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

func TestStreaks(t *testing.T) {
	tests := []struct {
		name             string
		days             map[Date]int
		current, longest int
	}{
		{"counts back from today", daysAgo(0, 1, 2), 3, 3},
		{"survives until the day is over", daysAgo(1, 2), 2, 2},
		{"broken after a missed day", daysAgo(2, 3), 0, 2},
		{"longest can be in the past", daysAgo(0, 10, 11, 12, 13), 1, 4},
		{"no activity", daysAgo(), 0, 0},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			current, longest := Streaks(tt.days, chartToday)
			if current != tt.current || longest != tt.longest {
				t.Errorf("got %d, %d; want %d, %d", current, longest, tt.current, tt.longest)
			}
		})
	}
}

func lastRune(s string) string {
	runes := []rune(strings.TrimRight(s, " "))
	return string(runes[len(runes)-1])
}

func TestHeatmapShape(t *testing.T) {
	lines := strings.Split(Heatmap(map[Date]int{chartToday: 4}, chartToday, 26), "\n")
	if len(lines) != 8 { // month header + Mon..Sun
		t.Fatalf("%d lines, want 8", len(lines))
	}
	if !strings.HasPrefix(lines[1], "Mon ") || !strings.HasPrefix(lines[7], "Sun ") {
		t.Errorf("row labels wrong: %q ... %q", lines[1], lines[7])
	}
	if got := lastRune(lines[4]); got != "█" { // Thursday row: today is the last cell
		t.Errorf("today's cell = %q, want █", got)
	}
}

func TestHeatmapLeavesFutureDaysBlank(t *testing.T) {
	lines := strings.Split(Heatmap(map[Date]int{}, chartToday, 26), "\n")
	if got := lastRune(lines[4]); got != "·" {
		t.Errorf("today's cell = %q, want ·", got)
	}
	// Fri is after today, so the last column stops at Thu.
	if len([]rune(strings.TrimRight(lines[5], " "))) >= len([]rune(strings.TrimRight(lines[4], " "))) {
		t.Errorf("Friday row isn't shorter than Thursday's:\n%s\n%s", lines[4], lines[5])
	}
}

func TestHeatmapMonthLabels(t *testing.T) {
	header := strings.Split(Heatmap(nil, chartToday, 26), "\n")[0]
	for _, month := range []string{"Apr", "May", "Jun", "Jul", "Aug", "Sep"} {
		if !strings.Contains(header, month) {
			t.Errorf("header %q lacks %s", header, month)
		}
	}
}

func TestSummary(t *testing.T) {
	days := daysAgo(0, 0, 1)
	want := "streak 2d · longest 2d · 3 gradings · 2 active days"
	if got := Summary(days, chartToday); got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}
