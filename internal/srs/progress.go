package srs

import "slices"

// Progress is per-topic coverage and the unlock rules from DESIGN.md §6; thresholds come from config.
type Progress struct {
	problems Problems
	state    *State
	unlock   UnlockConfig
}

func NewProgress(problems Problems, state *State, config Config) *Progress {
	return &Progress{problems: problems, state: state, unlock: config.Unlock}
}

func (p *Progress) Seen(slug string) bool {
	_, ok := p.state.Problems[slug]
	return ok
}

// InTopic lists the topic's problems in sheet order; difficulties nil means all.
func (p *Progress) InTopic(topic string, difficulties []string) []string {
	var slugs []string
	for _, slug := range p.problems.Slugs() {
		problem := p.problems[slug]
		if problem.Topic == topic && (difficulties == nil || slices.Contains(difficulties, problem.Difficulty)) {
			slugs = append(slugs, slug)
		}
	}
	return slugs
}

// Ratio is the share of the topic's problems at these difficulties that have been seen.
// A topic with no such problems counts as complete.
func (p *Progress) Ratio(topic string, difficulties []string) float64 {
	slugs := p.InTopic(topic, difficulties)
	if len(slugs) == 0 {
		return 1
	}
	seen := 0
	for _, slug := range slugs {
		if p.Seen(slug) {
			seen++
		}
	}
	return float64(seen) / float64(len(slugs))
}

// CoreRatio is the coverage that counts toward unlocking the next topics (Easy + Medium by default).
func (p *Progress) CoreRatio(topic string) float64 {
	return p.Ratio(topic, p.unlock.TopicCounts)
}

// Open reports whether new problems from the topic may be picked: its prerequisites
// are covered, or the user already has a problem in it.
func (p *Progress) Open(topic string) bool {
	allCovered := true
	for _, pre := range TopicPrereqs(topic) {
		if p.CoreRatio(pre) < p.unlock.TopicRatio {
			allCovered = false
		}
	}
	if allCovered {
		return true
	}
	return slices.ContainsFunc(p.InTopic(topic, nil), p.Seen)
}

func (p *Progress) HardsUnlocked(topic string) bool {
	return p.Ratio(topic, []string{"Medium"}) >= p.unlock.HardRatio
}
