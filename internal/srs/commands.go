package srs

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"path"
	"path/filepath"
	"slices"
	"strings"
)

// Commands implements `today`, `start`, `grade`, `more`, `status` and `overdue` — DESIGN.md §7–10.
type Commands struct {
	env       Env
	config    Config
	problems  Problems
	state     *State
	scheduler *Scheduler
	scaffold  Scaffold
	out       io.Writer
	in        *bufio.Reader
}

func NewCommands(env Env, in io.Reader, out io.Writer) (*Commands, error) {
	config, err := LoadConfig(env.ConfigPath)
	if err != nil {
		return nil, err
	}
	problems, err := LoadProblems(env.ProblemsPath)
	if errors.Is(err, os.ErrNotExist) {
		return nil, errors.New("run `srs setup` first")
	}
	if err != nil {
		return nil, err
	}
	state, err := LoadState(env.StatePath)
	if err != nil {
		return nil, err
	}
	return &Commands{
		env: env, config: config, problems: problems, state: state,
		scheduler: NewScheduler(problems, state, env.Today, config),
		scaffold:  Scaffold{Root: env.Root},
		out:       out, in: bufio.NewReader(in),
	}, nil
}

func (c *Commands) Today() error {
	session := c.scheduler.Session()
	if err := c.save(); err != nil {
		return err
	}
	fmt.Fprintf(c.out, "%s — %d problems\n", c.env.Today, len(session.Slots))
	for _, slot := range c.scheduler.SlotLetters() {
		c.show(slot, session.Slots[slot])
	}
	if c.scheduler.BonusLeft() {
		fmt.Fprintf(c.out, "\nGrade any of these %s to unlock another problem (slot %s).\n",
			c.bonusGrades(), c.scheduler.NextBonusSlot())
	}
	if c.scheduler.AllGraded() {
		fmt.Fprintln(c.out, "\nDone with all of them? `srs more` gives you a new problem, `srs more old` a due review.")
	}
	return nil
}

// More adds another problem to today's session (only once everything is graded):
// kind "new" = next new problem, "old" = most overdue review; difficulty ("Easy", …) or "" = any.
func (c *Commands) More(kind, difficulty string) error {
	c.scheduler.Session()
	if !c.scheduler.AllGraded() {
		return errors.New("finish and grade today's problems first")
	}
	var slot string
	var entry *Entry
	var added bool
	if kind == "old" {
		slot, entry, added = c.scheduler.AddExtraReview(difficulty)
	} else {
		slot, entry, added = c.scheduler.AddExtraNew(difficulty)
	}
	if err := c.save(); err != nil {
		return err
	}
	if !added {
		what := ""
		if difficulty != "" {
			what = " " + difficulty
		}
		if kind == "old" {
			fmt.Fprintf(c.out, "Nothing%s is due for review.\n", what)
		} else {
			fmt.Fprintf(c.out, "No new%s problem is eligible right now.\n", what)
		}
		return nil
	}
	fmt.Fprintln(c.out, "Extra problem:")
	c.show(slot, entry)
	return nil
}

// Start creates the file to work in for a slot: a scaffold for a new problem, an
// attempt copy for a review.
func (c *Commands) Start(slot string) error {
	entry, err := c.slotEntry(slot)
	if err != nil {
		return err
	}
	problem := c.problems[entry.Slug]
	file := problem.File
	if entry.Kind == KindNew {
		created, err := c.scaffold.CreateNew(file, entry.Slug)
		if err != nil {
			return err
		}
		fmt.Fprintf(c.out, "%s: %s\n", createdWord(created), file)
		fmt.Fprintf(c.out, "test it with: go test ./%s\n", path.Dir(file))
	} else {
		attempt := AttemptPath(file)
		created, err := c.scaffold.CreateAttempt(file)
		if err != nil {
			return err
		}
		fmt.Fprintf(c.out, "%s: %s\n", createdWord(created), attempt)
		fmt.Fprintf(c.out, "(your original stays untouched: %s)\n", file)
		fmt.Fprintf(c.out, "test it with: go test ./%s\n", path.Dir(attempt))
	}
	fmt.Fprintln(c.out, problem.Link)
	if problem.AltLink != "" {
		fmt.Fprintf(c.out, "free version: %s\n", problem.AltLink)
	}
	return c.save()
}

func createdWord(created bool) string {
	if created {
		return "Created"
	}
	return "Already exists"
}

// Practice is `start <file or slug>`: practise a problem you pick. It gets a slot today
// (an extra one unless it's already in the session) and is graded like any other.
func (c *Commands) Practice(target string) error {
	slug, err := c.findSlug(target)
	if err != nil {
		return err
	}
	c.scheduler.Session()
	slot, entry := c.scheduler.AddChosen(slug)
	name := c.problems[slug].Name
	if entry.Grade != "" {
		return fmt.Errorf("%s is slot %s today, already graded (%s)", name, slot, entry.Grade)
	}
	fmt.Fprintf(c.out, "%s is slot %s — when done: srs grade %s again|hard|good|easy\n", name, slot, slot)
	return c.Start(slot)
}

func (c *Commands) Grade(slot, grade string) error {
	if !ValidGrade(grade) {
		return fmt.Errorf("grade must be one of: %s", GradeList())
	}
	entry, err := c.slotEntry(slot)
	if err != nil {
		return err
	}
	if entry.Grade != "" {
		return fmt.Errorf("slot %s is already graded (%s)", slot, entry.Grade)
	}

	card := NewCard(c.config.Sm2)
	if existing, ok := c.state.Problems[entry.Slug]; ok {
		card = *existing
	}
	reviewed := Review(card, grade, c.env.Today, c.config.Sm2)
	c.state.Problems[entry.Slug] = &reviewed
	entry.Grade = grade
	if entry.Kind == KindNew {
		c.scheduler.RecordNew(slot, entry)
	}
	fmt.Fprintf(c.out, "%s: %s — next review %s (in %dd, ease %s)\n", c.problems[entry.Slug].Name, grade,
		reviewed.NextReview, reviewed.Interval, formatFloat(reviewed.Ease))
	if c.scheduler.UnlocksBonus(grade) {
		c.unlockBonus()
	}
	if err := c.save(); err != nil {
		return err
	}
	if entry.Kind != KindNew {
		if err := c.offerAttemptCleanup(c.problems[entry.Slug].File); err != nil {
			return err
		}
	}
	return c.offerMore()
}

func (c *Commands) Status() error {
	Coverage(c.problems, c.state, c.config, c.out)
	var cards []*Card
	for slug, card := range c.state.Problems {
		if _, ok := c.problems[slug]; ok {
			cards = append(cards, card)
		}
	}
	due, week := 0, 0
	for _, card := range cards {
		switch {
		case card.NextReview <= c.env.Today:
			due++
		case card.NextReview <= c.env.Today.AddDays(7):
			week++
		}
	}
	fmt.Fprintf(c.out, "\nSeen %d/%d · due now %d · due in the next 7 days %d\n", len(cards), len(c.problems), due, week)
	last := "none yet"
	if !c.state.LastNewOn.IsZero() {
		last = fmt.Sprintf("%s (%dd ago)", c.state.LastNewOn, c.env.Today.Sub(c.state.LastNewOn))
	}
	fmt.Fprintf(c.out, "Last new problem: %s\n", last)

	days := Activity(c.state.Problems)
	fmt.Fprintf(c.out, "\nActivity, last %d weeks\n", c.config.Display.HeatmapWeeks)
	fmt.Fprintln(c.out, Heatmap(days, c.env.Today, c.config.Display.HeatmapWeeks))
	fmt.Fprintln(c.out, Summary(days, c.env.Today))
	return nil
}

func (c *Commands) Overdue() error {
	Overdue(c.problems, c.state, c.env.Today, c.out)
	return nil
}

func (c *Commands) save() error {
	return SaveState(c.env.StatePath, c.state)
}

func (c *Commands) slotEntry(slot string) (*Entry, error) {
	entry := c.scheduler.Session().Slots[slot]
	if entry == nil {
		if slices.Contains(c.scheduler.BonusSlots(), slot) {
			return nil, fmt.Errorf("no slot %s today — grade a problem %s to unlock it", slot, c.bonusGrades())
		}
		return nil, fmt.Errorf("no slot %s today", slot)
	}
	if entry.Empty() {
		return nil, fmt.Errorf("slot %s is empty today", slot)
	}
	return entry, nil
}

// findSlug takes a slug, or a problem's folder or file (relative to here or the repo root,
// absolute, or inside attempts/).
func (c *Commands) findSlug(target string) (string, error) {
	if _, ok := c.problems[target]; ok {
		return target, nil
	}
	var candidates []string
	for _, p := range []string{target, filepath.Join(c.env.Root, target)} {
		abs, err := filepath.Abs(p)
		if err != nil {
			continue
		}
		rel, err := filepath.Rel(c.env.Root, abs)
		if err != nil {
			continue
		}
		rel = strings.TrimPrefix(filepath.ToSlash(rel), attemptsDir+"/")
		rel = strings.TrimSuffix(rel, "_test.go")
		candidates = append(candidates, rel, rel+".go")
	}
	for _, slug := range c.problems.Slugs() {
		file := c.problems[slug].File
		if slices.Contains(candidates, file) || slices.Contains(candidates, path.Dir(file)) {
			return slug, nil
		}
	}
	return "", fmt.Errorf("%s isn't on the sheet — give its file (e.g. linked_list/medium/reorder_list/reorder_list.go) or slug", target)
}

func (c *Commands) unlockBonus() {
	if slot, entry, ok := c.scheduler.UnlockBonus(); ok {
		fmt.Fprintln(c.out, "\nBonus unlocked:")
		c.show(slot, entry)
	}
}

func (c *Commands) bonusGrades() string {
	var quoted []string
	for _, g := range c.config.Session.Bonus.UnlockOn {
		quoted = append(quoted, "`"+g+"`")
	}
	return strings.Join(quoted, " or ")
}

func (c *Commands) offerMore() error {
	if !c.scheduler.AllGraded() {
		return nil
	}
	fmt.Fprint(c.out, "\nAll of today's problems are done. Try a new one? [y/N] ")
	if strings.HasPrefix(strings.ToLower(c.readLine()), "y") {
		return c.More("new", "")
	}
	return nil
}

func (c *Commands) offerAttemptCleanup(file string) error {
	attempt := AttemptPath(file)
	if !exists(filepath.Join(c.env.Root, filepath.FromSlash(attempt))) {
		return nil
	}
	fmt.Fprintf(c.out, "Compare with your original: %s\n", file)
	fmt.Fprintf(c.out, "Delete %s? [Y/n] ", path.Dir(attempt))
	answer := strings.ToLower(c.readLine())
	if answer != "" && !strings.HasPrefix(answer, "y") {
		fmt.Fprintln(c.out, "Kept.")
		return nil
	}
	if err := c.scaffold.RemoveAttempt(file); err != nil {
		return err
	}
	fmt.Fprintln(c.out, "Deleted.")
	return nil
}

// readLine reads one line of the user's answer; no input at all reads as an empty answer.
func (c *Commands) readLine() string {
	line, _ := c.in.ReadString('\n')
	return strings.TrimSpace(line)
}

func (c *Commands) show(slot string, entry *Entry) {
	SlotPrinter{
		Root: c.env.Root, Problems: c.problems, State: c.state, Config: c.config,
		Today: c.env.Today, Out: c.out,
	}.Show(slot, entry)
}
