package srs

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

var (
	fileSlug = regexp.MustCompile(`leetcode\.com/problems/([a-z0-9-]+)`)
	hasFunc  = regexp.MustCompile(`(?m)^func `)
)

// Setup is `srs setup` — DESIGN.md §3. Safe to re-run: it only fills in what's missing
// and never changes an existing state.yml entry.
type Setup struct {
	Env    Env
	Config Config
	Out    io.Writer
}

func (s Setup) Run() error {
	rows, err := FetchSheetRows()
	if err != nil {
		return err
	}
	files, err := s.localFiles()
	if err != nil {
		return err
	}
	old, err := LoadProblems(s.Env.ProblemsPath)
	if err != nil && !os.IsNotExist(err) {
		return err
	}

	problems := Problems{}
	for _, row := range rows {
		problem, err := buildProblem(row, files[row.Slug], old[row.Slug])
		if err != nil {
			return err
		}
		problems[row.Slug] = problem
	}
	s.fetchDetails(problems)
	for slug, problem := range problems {
		fillLinksAndPath(slug, problem)
	}
	if err := SaveProblems(s.Env.ProblemsPath, problems); err != nil {
		return err
	}

	state, err := LoadState(s.Env.StatePath)
	if err != nil {
		return err
	}
	seeded := s.seed(state, problems, files)
	if err := SaveState(s.Env.StatePath, state); err != nil {
		return err
	}
	s.report(problems, state, files, seeded)
	return nil
}

// localFiles maps slug => repo-relative path for every solution file in a topic folder
// that has a LeetCode header. Tests and attempts are not solutions.
func (s Setup) localFiles() (map[string]string, error) {
	files := map[string]string{}
	for _, topic := range Roadmap {
		dir := filepath.Join(s.Env.Root, topic.Folder)
		err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
			if err != nil {
				if os.IsNotExist(err) {
					return filepath.SkipDir
				}
				return err
			}
			if d.IsDir() || !strings.HasSuffix(p, ".go") || strings.HasSuffix(p, "_test.go") {
				return nil
			}
			content, err := os.ReadFile(p)
			if err != nil {
				return err
			}
			match := fileSlug.FindSubmatch(content)
			if match == nil {
				return nil
			}
			rel, err := filepath.Rel(s.Env.Root, p)
			if err != nil {
				return err
			}
			rel = filepath.ToSlash(rel)
			slug := string(match[1])
			if first, dup := files[slug]; dup {
				fmt.Fprintf(os.Stderr, "  two files for %s: %s and %s (using the first)\n", slug, first, rel)
				return nil
			}
			files[slug] = rel
			return nil
		})
		if err != nil {
			return nil, err
		}
	}
	return files, nil
}

func buildProblem(row SheetRow, file string, old *Problem) (*Problem, error) {
	// File location wins over the sheet's category.
	topic := ""
	if file != "" {
		topic = TopicForFolder(strings.SplitN(file, "/", 2)[0])
	}
	if topic == "" {
		var err error
		if topic, err = TopicForCategory(row.Category); err != nil {
			return nil, err
		}
	}
	problem := &Problem{
		Name: row.Name, Topic: topic, Link: "https://leetcode.com/problems/" + row.Slug + "/",
		File: file, Order: row.Order, Notes: row.Notes,
	}
	if old != nil {
		problem.Difficulty, problem.PaidOnly = old.Difficulty, old.PaidOnly
	}
	return problem, nil
}

// fetchDetails asks LeetCode for the difficulty of every problem that doesn't have one yet.
func (s Setup) fetchDetails(problems Problems) {
	var missing []string
	for _, slug := range problems.Slugs() {
		if problems[slug].Difficulty == "" {
			missing = append(missing, slug)
		}
	}
	if len(missing) == 0 {
		return
	}
	fmt.Fprintf(s.Out, "Fetching difficulty for %d problems (~%ds)...\n", len(missing), len(missing)*int(LeetcodeDelay/time.Second))
	for i, slug := range missing {
		if i > 0 {
			time.Sleep(LeetcodeDelay)
		}
		details, err := FetchDetails(slug)
		if err != nil {
			fmt.Fprintf(s.Out, "\n  %s: %v — re-run setup to retry\n", slug, err)
			continue
		}
		problems[slug].Difficulty, problems[slug].PaidOnly = details.Difficulty, details.PaidOnly
		fmt.Fprint(s.Out, ".")
	}
	fmt.Fprintln(s.Out)
}

func fillLinksAndPath(slug string, problem *Problem) {
	if problem.PaidOnly {
		problem.AltLink = FreeLink(slug)
	}
	if problem.File != "" || problem.Difficulty == "" {
		return
	}
	problem.File = SolutionPath(problem.Topic, problem.Difficulty, slug)
}

// SolutionPath is where a problem's solution file goes: <topic folder>/<difficulty>/<slug_with_underscores>/<same>.go
func SolutionPath(topic, difficulty, slug string) string {
	name := strings.ReplaceAll(slug, "-", "_")
	return path.Join(TopicFolder(topic), strings.ToLower(difficulty), name, name+".go")
}

// seed counts matched files as solved once, on the date they were first committed
// (later commits may only be cleanups). A file with no func is an unsolved `srs start`
// scaffold, not a solution.
func (s Setup) seed(state *State, problems Problems, files map[string]string) []string {
	var seeded []string
	for _, slug := range problems.Slugs() {
		file, ok := files[slug]
		if !ok {
			continue
		}
		if _, known := state.Problems[slug]; known {
			continue
		}
		content, err := os.ReadFile(filepath.Join(s.Env.Root, file))
		if err != nil || !hasFunc.Match(content) {
			continue
		}
		date := s.firstCommitDate(file)
		first := s.Config.Sm2.FirstIntervals[0]
		state.Problems[slug] = &Card{
			Reps: 1, Ease: s.Config.Sm2.StartEase, Interval: first,
			LastReviewed: date, NextReview: date.AddDays(first),
			History: []HistoryEntry{{Date: date, Grade: "seed"}},
		}
		seeded = append(seeded, slug)
	}
	return seeded
}

func (s Setup) firstCommitDate(file string) Date {
	out, err := exec.Command("git", "-C", s.Env.Root, "log", "--follow", "--diff-filter=A", "--format=%cs", "--", file).Output()
	dates := strings.Fields(string(out))
	if err != nil || len(dates) == 0 {
		return s.Env.Today
	}
	date, err := ParseDate(dates[len(dates)-1])
	if err != nil {
		return s.Env.Today
	}
	return date
}

func (s Setup) report(problems Problems, state *State, files map[string]string, seeded []string) {
	var matched []string
	for _, slug := range problems.Slugs() {
		if _, ok := files[slug]; ok {
			matched = append(matched, slug)
		}
	}
	fmt.Fprintf(s.Out, "\nMatched %d local files to sheet rows:\n", len(matched))
	for _, slug := range matched {
		fmt.Fprintf(s.Out, "  %s %s %s\n", ljust(problems[slug].Topic, 15), ljust(problems[slug].Name, 45), files[slug])
	}

	var ignored []string
	for slug, file := range files {
		if _, ok := problems[slug]; !ok {
			ignored = append(ignored, path.Base(file))
		}
	}
	sort.Strings(ignored)
	if len(ignored) > 0 {
		fmt.Fprintf(s.Out, "\nIgnored %d files not on the sheet: %s\n", len(ignored), strings.Join(ignored, ", "))
	}
	if len(seeded) > 0 {
		fmt.Fprintf(s.Out, "\nSeeded %d problems into state.yml.\n", len(seeded))
	}

	Premium(problems, s.Out)
	Coverage(problems, state, s.Config, s.Out)
}
