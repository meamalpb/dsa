package srs

import (
	"fmt"
	"io"
	"slices"
	"strings"
)

// Tables shared by `setup` and `status`.

// Coverage prints one row per topic: how much is seen and whether it's open.
func Coverage(problems Problems, state *State, config Config, out io.Writer) {
	progress := NewProgress(problems, state, config)
	var initials []string
	for _, d := range config.Unlock.TopicCounts {
		initials = append(initials, d[:1])
	}
	counted := strings.Join(initials, "+") + " seen"
	fmt.Fprintf(out, "\n%s %s  %s   %s  E / M / H     Status\n",
		ljust("Topic", 17), rjust("Seen", 7), rjust(counted, 8), ljust("Progress", BarWidth))
	for _, topic := range Roadmap {
		all := progress.InTopic(topic.Key, nil)
		seen := fmt.Sprintf("%d/%d", countIf(all, progress.Seen), len(all))
		var counts []string
		for _, d := range difficulties {
			counts = append(counts, fmt.Sprint(len(progress.InTopic(topic.Key, []string{d}))))
		}
		pct := fmt.Sprintf("%d%%", int(roundTo(progress.CoreRatio(topic.Key)*100, 0)))
		status := "open"
		if !progress.Open(topic.Key) {
			status = "locked (needs " + strings.Join(topic.Prereqs, " + ") + ")"
		}
		fmt.Fprintf(out, "%s %s  %s   %s  %s %s\n", ljust(topic.Key, 17), rjust(seen, 7), rjust(pct, 8),
			Bar(progress.CoreRatio(topic.Key)), ljust(strings.Join(counts, " / "), 13), status)
	}
}

// Overdue prints every problem whose next_review has passed, most overdue first.
func Overdue(problems Problems, state *State, today Date, out io.Writer) {
	var slugs []string
	for slug, card := range state.Problems {
		if _, ok := problems[slug]; ok && card.NextReview <= today {
			slugs = append(slugs, slug)
		}
	}
	if len(slugs) == 0 {
		fmt.Fprintln(out, "\nNothing overdue.")
		return
	}
	slices.SortFunc(slugs, func(a, b string) int {
		if ca, cb := state.Problems[a], state.Problems[b]; ca.NextReview != cb.NextReview {
			return int(ca.NextReview - cb.NextReview)
		}
		return problems[a].Order - problems[b].Order
	})
	width := 0
	for _, slug := range slugs {
		width = max(width, len([]rune(problems[slug].Name)))
	}
	fmt.Fprintf(out, "\nOverdue (%d):\n", len(slugs))
	fmt.Fprintf(out, "%s %s %s %s  Last done   Reps  Ease\n",
		ljust("Problem", width), ljust("Topic", 14), ljust("Diff", 7), rjust("Overdue", 7))
	for _, slug := range slugs {
		p, card := problems[slug], state.Problems[slug]
		fmt.Fprintf(out, "%s %s %s %s  %s  %s  %s\n", ljust(p.Name, width), ljust(p.Topic, 14),
			ljust(p.Difficulty, 7), rjust(fmt.Sprintf("%dd", today.Sub(card.NextReview)), 7),
			card.LastReviewed, rjust(fmt.Sprint(card.Reps), 4), formatFloat(card.Ease))
	}
}

// Premium lists the problems that need a LeetCode subscription and where their free version is.
func Premium(problems Problems, out io.Writer) {
	var paid []string
	for _, slug := range problems.Slugs() {
		if problems[slug].PaidOnly {
			paid = append(paid, slug)
		}
	}
	if len(paid) == 0 {
		return
	}
	fmt.Fprintf(out, "\nPremium problems (%d):\n", len(paid))
	for _, slug := range paid {
		p := problems[slug]
		link := p.AltLink
		if link == "" {
			link = "NO FREE LINK for " + slug
		}
		fmt.Fprintf(out, "  %s %s\n", ljust(p.Name, 45), link)
	}
}

func countIf(items []string, pred func(string) bool) int {
	n := 0
	for _, item := range items {
		if pred(item) {
			n++
		}
	}
	return n
}
