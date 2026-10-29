package srs

import (
	"fmt"
	"slices"
	"strings"
	"unicode/utf8"
)

// Text charts for `status`. Pure functions: data in, strings out.

const BarWidth = 10

var glyphs = []string{"·", "░", "▒", "█"}

// Bar draws ratio (0.0..1.0) as a row of BarWidth cells.
func Bar(ratio float64) string {
	ratio = min(max(ratio, 0), 1)
	filled := int(roundTo(ratio*BarWidth, 0))
	return strings.Repeat("█", filled) + strings.Repeat("░", BarWidth-filled)
}

// Activity counts gradings per day, excluding the `seed` entries created at setup.
func Activity(cards map[string]*Card) map[Date]int {
	days := map[Date]int{}
	for _, card := range cards {
		for _, h := range card.History {
			if h.Grade != "seed" {
				days[h.Date]++
			}
		}
	}
	return days
}

func activityLevel(count int) int {
	switch {
	case count <= 0:
		return 0
	case count == 1:
		return 1
	case count <= 3:
		return 2
	default:
		return 3
	}
}

// Heatmap draws the last `weeks` weeks, one column per week, Monday to Sunday down.
func Heatmap(days map[Date]int, today Date, weeks int) string {
	first := today.AddDays(-((today.ISOWeekday() - 1) + 7*(weeks-1))) // Monday of the first column
	columns := make([]Date, weeks)
	for w := range columns {
		columns[w] = first.AddDays(7 * w)
	}
	lines := []string{monthHeader(columns)}
	for row, label := range []string{"Mon", "", "Wed", "", "Fri", "", "Sun"} {
		var cells strings.Builder
		for _, monday := range columns {
			if day := monday.AddDays(row); day > today {
				cells.WriteString("  ")
			} else {
				cells.WriteString(glyphs[activityLevel(days[day])] + " ")
			}
		}
		lines = append(lines, ljust(label, 4)+cells.String())
	}
	return strings.Join(lines, "\n")
}

func monthHeader(columns []Date) string {
	var line string
	last := -1
	for i, monday := range columns {
		month := int(monday.Time().Month())
		if month == last {
			continue
		}
		last = month
		if i == 0 && len(columns) > 1 && int(columns[1].Time().Month()) != month {
			continue // a stub week, no room for its label
		}
		if utf8.RuneCountInString(line) > i*2 {
			continue // previous label still overhangs this column
		}
		line += strings.Repeat(" ", i*2-utf8.RuneCountInString(line)) + monday.Time().Format("Jan")
	}
	return "    " + line
}

// Streaks returns the current and longest run of active days. The current streak
// survives a day with no grading until that day is over, so it is not reset at midnight.
func Streaks(days map[Date]int, today Date) (current, longest int) {
	var active []Date
	for day, n := range days {
		if n > 0 {
			active = append(active, day)
		}
	}
	slices.Sort(active)
	run := 0
	for i, day := range active {
		if i > 0 && day == active[i-1]+1 {
			run++
		} else {
			run = 1
		}
		longest = max(longest, run)
	}

	day := today
	if days[today] <= 0 {
		day = today.AddDays(-1)
	}
	for days[day] > 0 {
		current++
		day = day.AddDays(-1)
	}
	return current, longest
}

func Summary(days map[Date]int, today Date) string {
	current, longest := Streaks(days, today)
	total, active := 0, 0
	for _, n := range days {
		total += n
		if n > 0 {
			active++
		}
	}
	return fmt.Sprintf("streak %dd · longest %dd · %d gradings · %d active days", current, longest, total, active)
}

// ljust and rjust pad by characters rather than bytes.
func ljust(s string, width int) string {
	if pad := width - utf8.RuneCountInString(s); pad > 0 {
		return s + strings.Repeat(" ", pad)
	}
	return s
}

func rjust(s string, width int) string {
	if pad := width - utf8.RuneCountInString(s); pad > 0 {
		return strings.Repeat(" ", pad) + s
	}
	return s
}
