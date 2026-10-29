package srs

import (
	"slices"
)

// Entry kinds.
const (
	KindNew    = "new"
	KindReview = "review"
	KindEarly  = "early"
)

// Scheduler picks today's problems — DESIGN.md §7. Slots, pools and pacing come from config.yml (§12).
type Scheduler struct {
	problems Problems
	state    *State
	today    Date
	config   Config
	progress *Progress
}

func NewScheduler(problems Problems, state *State, today Date, config Config) *Scheduler {
	return &Scheduler{problems, state, today, config, NewProgress(problems, state, config)}
}

// Session is today's session, built on the first call of the day and then reused as-is.
func (s *Scheduler) Session() *Session {
	if cur := s.state.Session; cur != nil && cur.Date == s.today {
		return cur
	}
	s.state.Session = &Session{Date: s.today, Slots: map[string]*Entry{}}
	if s.NewProblemOverdue() {
		s.forceNew()
	}
	for _, slot := range s.config.Session.Slots {
		if _, taken := s.slots()[slot.Letter]; !taken {
			s.slots()[slot.Letter] = s.pick(slot.Pool)
		}
	}
	return s.state.Session
}

// SlotLetters lists the session's slots in order.
func (s *Scheduler) SlotLetters() []string {
	letters := make([]string, 0, len(s.slots()))
	for letter := range s.slots() {
		letters = append(letters, letter)
	}
	slices.Sort(letters)
	return letters
}

// BonusSlots are the letters of the bonus slots, in unlock order: the ones right after the daily slots.
func (s *Scheduler) BonusSlots() []string {
	first := s.lastDailyLetter() + 1
	letters := make([]string, s.bonus().Max)
	for i := range letters {
		letters[i] = string(first + rune(i))
	}
	return letters
}

// NextBonusSlot is the bonus slot the next unlock would open, or "" when they're all open today.
func (s *Scheduler) NextBonusSlot() string {
	for _, letter := range s.BonusSlots() {
		if _, open := s.slots()[letter]; !open {
			return letter
		}
	}
	return ""
}

func (s *Scheduler) BonusLeft() bool { return s.NextBonusSlot() != "" }

func (s *Scheduler) UnlocksBonus(grade string) bool {
	return slices.Contains(s.bonus().UnlockOn, grade)
}

// UnlockBonus opens the next bonus slot, if any are left today.
func (s *Scheduler) UnlockBonus() (string, *Entry, bool) {
	letter := s.NextBonusSlot()
	if letter == "" {
		return "", nil, false
	}
	s.slots()[letter] = s.pick(s.bonus().Pool)
	return letter, s.slots()[letter], true
}

// AddExtraNew adds a new problem (`more` / `more new`, slots after the bonus ones) once
// everything else is done. It rotates through the daily pools, falling back to the next one.
// difficulty (e.g. "Easy") limits the pick to that difficulty; "" = any.
func (s *Scheduler) AddExtraNew(difficulty string) (string, *Entry, bool) {
	for _, pool := range rotate(s.forcedPools(), s.extraCount()) {
		if slug := s.nextNew(pool, difficulty); slug != "" {
			letter, entry := s.addExtra(newEntry(slug, KindNew, false))
			return letter, entry, true
		}
	}
	return "", nil, false
}

// AddExtraReview adds `more old`: the first due review from any pool (or only of
// difficulty), in review_order. False when nothing is due.
func (s *Scheduler) AddExtraReview(difficulty string) (string, *Entry, bool) {
	var cards []string
	for slug := range s.state.Problems {
		problem, ok := s.problems[slug]
		if ok && !s.picked(slug) && (difficulty == "" || problem.Difficulty == difficulty) {
			cards = append(cards, slug)
		}
	}
	slug := s.firstDue(cards)
	if slug == "" {
		return "", nil, false
	}
	letter, entry := s.addExtra(newEntry(slug, KindReview, false))
	return letter, entry, true
}

// AddChosen adds a problem the user picked (`start <file>`), outside the daily rules: no
// unlock or due-date checks. It reuses its slot if it's already in today's session, else
// adds an extra one.
func (s *Scheduler) AddChosen(slug string) (string, *Entry) {
	for _, letter := range s.SlotLetters() {
		if entry := s.slots()[letter]; entry.Slug == slug {
			return letter, entry
		}
	}
	kind := KindNew
	if s.progress.Seen(slug) {
		kind = KindReview
	}
	entry := newEntry(slug, kind, false)
	entry.Chosen = true
	return s.addExtra(entry)
}

// AllGraded reports whether every slot with a problem has been graded.
func (s *Scheduler) AllGraded() bool {
	for _, entry := range s.slots() {
		if entry.Grade == "" && !entry.Empty() {
			return false
		}
	}
	return true
}

func (s *Scheduler) NewProblemOverdue() bool {
	last := s.state.LastNewOn
	return last.IsZero() || s.today.Sub(last) >= s.config.Session.NewEveryDays
}

// RecordNew: a graded new problem resets the new-problem clock; a forced one also
// hands the next forced pick to the next pool.
func (s *Scheduler) RecordNew(slot string, entry *Entry) {
	s.state.LastNewOn = s.today
	if entry.Forced {
		s.state.NextForcedPool = s.nextPool(s.config.PoolOfSlot(slot))
	}
}

func (s *Scheduler) bonus() BonusConfig { return s.config.Session.Bonus }

func (s *Scheduler) slots() map[string]*Entry { return s.state.Session.Slots }

func (s *Scheduler) lastDailyLetter() rune {
	letters := s.config.DailyLetters()
	return rune(slices.Max(letters)[0])
}

// forcedPools are the pools that take turns for the forced new problem, in slot order.
func (s *Scheduler) forcedPools() []string {
	var pools []string
	for _, slot := range s.config.Session.Slots {
		if !slices.Contains(pools, slot.Pool) {
			pools = append(pools, slot.Pool)
		}
	}
	return pools
}

func (s *Scheduler) nextPool(pool string) string {
	pools := s.forcedPools()
	i := slices.Index(pools, pool) // -1 when unknown, which starts at the first pool
	return pools[(i+1)%len(pools)]
}

func (s *Scheduler) addExtra(extra *Entry) (string, *Entry) {
	highest := s.lastDailyLetter()
	for _, letter := range s.BonusSlots() {
		highest = max(highest, rune(letter[0]))
	}
	for letter := range s.slots() {
		highest = max(highest, rune(letter[0]))
	}
	letter := string(highest + 1)
	s.slots()[letter] = extra
	return letter, extra
}

// extraCount is how many extra new problems `more` has added, so it knows which pool is next.
func (s *Scheduler) extraCount() int {
	reserved := append(s.config.DailyLetters(), s.BonusSlots()...)
	count := 0
	for letter, entry := range s.slots() {
		if !slices.Contains(reserved, letter) && entry.Kind == KindNew && !entry.Chosen {
			count++
		}
	}
	return count
}

// forceNew is rule 1: put a new problem in the slot for next_forced_pool, or the next
// pool's slot if that pool has nothing eligible.
func (s *Scheduler) forceNew() {
	pools := s.forcedPools()
	start := max(slices.Index(pools, s.state.NextForcedPool), 0)
	for _, pool := range rotate(pools, start) {
		if slug := s.nextNew(pool, ""); slug != "" {
			s.slots()[s.config.SlotOfPool(pool)] = newEntry(slug, KindNew, true)
			return
		}
	}
}

// pick is rules 2–5: due review, new problem, early review, empty.
func (s *Scheduler) pick(pool string) *Entry {
	if slug := s.firstDue(s.reviews(pool)); slug != "" {
		return newEntry(slug, KindReview, false)
	}
	if slug := s.nextNew(pool, ""); slug != "" {
		return newEntry(slug, KindNew, false)
	}
	if slug := s.earliest(s.reviews(pool)); slug != "" {
		return newEntry(slug, KindEarly, false)
	}
	return &Entry{}
}

func newEntry(slug, kind string, forced bool) *Entry {
	return &Entry{Slug: slug, Kind: kind, Forced: forced}
}

func (s *Scheduler) picked(slug string) bool {
	for _, entry := range s.slots() {
		if entry.Slug == slug {
			return true
		}
	}
	return false
}

func (s *Scheduler) inPool(slug, pool string) bool {
	return slices.Contains(s.config.Pools[pool], s.problems[slug].Difficulty)
}

// reviews are the seen problems of the pool that aren't already in today's session.
func (s *Scheduler) reviews(pool string) []string {
	var slugs []string
	for slug := range s.state.Problems {
		if _, ok := s.problems[slug]; ok && s.inPool(slug, pool) && !s.picked(slug) {
			slugs = append(slugs, slug)
		}
	}
	return slugs
}

// firstDue: most_overdue takes the earliest next_review. learning_first takes problems last
// done within learning_days before older ones, so a fresh problem's early reviews aren't
// stuck behind a months-old backlog.
func (s *Scheduler) firstDue(slugs []string) string {
	var due []string
	for _, slug := range slugs {
		if s.state.Problems[slug].NextReview <= s.today {
			due = append(due, slug)
		}
	}
	if s.config.Session.ReviewOrder != ReviewLearningFirst {
		return s.earliest(due)
	}
	since := s.today.AddDays(-s.config.Session.LearningDays)
	var learning []string
	for _, slug := range due {
		if last := s.state.Problems[slug].LastReviewed; !last.IsZero() && last >= since {
			learning = append(learning, slug)
		}
	}
	if slug := s.earliest(learning); slug != "" {
		return slug
	}
	return s.earliest(due)
}

// earliest is the slug with the nearest next_review, ties in sheet order; "" for none.
func (s *Scheduler) earliest(slugs []string) string {
	best := ""
	for _, slug := range slugs {
		if best == "" || s.dueBefore(slug, best) {
			best = slug
		}
	}
	return best
}

func (s *Scheduler) dueBefore(a, b string) bool {
	ca, cb := s.state.Problems[a], s.state.Problems[b]
	if ca.NextReview != cb.NextReview {
		return ca.NextReview < cb.NextReview
	}
	return s.problems[a].Order < s.problems[b].Order
}

// nextNew is the first eligible unseen problem of the pool in sheet order, or "".
func (s *Scheduler) nextNew(pool, difficulty string) string {
	for _, slug := range s.problems.Slugs() {
		problem := s.problems[slug]
		if (difficulty == "" || problem.Difficulty == difficulty) && s.eligibleNew(slug, problem, pool) {
			return slug
		}
	}
	return ""
}

func (s *Scheduler) eligibleNew(slug string, problem *Problem, pool string) bool {
	return !s.progress.Seen(slug) && !s.picked(slug) && s.inPool(slug, pool) && s.progress.Open(problem.Topic) &&
		(problem.Difficulty != "Hard" || s.progress.HardsUnlocked(problem.Topic))
}

// rotate returns items starting at index n (wrapping), without modifying items.
func rotate[T any](items []T, n int) []T {
	if len(items) == 0 {
		return items
	}
	n = ((n % len(items)) + len(items)) % len(items)
	return append(slices.Clone(items[n:]), items[:n]...)
}
