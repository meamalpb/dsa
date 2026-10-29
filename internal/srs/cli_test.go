package srs

import (
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestMoreOptions(t *testing.T) {
	tests := []struct {
		args       []string
		kind, diff string
		wantErr    bool
	}{
		{nil, "new", "", false},
		{[]string{"old"}, "old", "", false},
		{[]string{"medium"}, "new", "Medium", false},
		{[]string{"old", "easy"}, "old", "Easy", false},
		{[]string{"HARD", "Old"}, "old", "Hard", false},
		{[]string{"all"}, "new", "", false},
		{[]string{"new", "old"}, "", "", true},
		{[]string{"easy", "hard"}, "", "", true},
		{[]string{"sideways"}, "", "", true},
	}
	for _, tt := range tests {
		kind, diff, err := moreOptions(tt.args)
		if (err != nil) != tt.wantErr || kind != tt.kind || diff != tt.diff {
			t.Errorf("moreOptions(%v) = %q, %q, %v; want %q, %q, error=%v", tt.args, kind, diff, err, tt.kind, tt.diff, tt.wantErr)
		}
	}
}

func TestParseSlot(t *testing.T) {
	for in, want := range map[string]string{"a": "A", "C": "C"} {
		if got, err := parseSlot(in); err != nil || got != want {
			t.Errorf("parseSlot(%q) = %q, %v", in, got, err)
		}
	}
	for _, bad := range []string{"", "AB", "1", "-"} {
		if _, err := parseSlot(bad); err == nil {
			t.Errorf("parseSlot(%q) accepted", bad)
		}
	}
}

func TestHelpAndUnknownCommandNeedNoRepo(t *testing.T) {
	noRepo := func() (Env, error) { return Env{}, errors.New("not in the repo") }
	var out strings.Builder
	for _, args := range [][]string{nil, {"help"}, {"--help"}} {
		out.Reset()
		if err := Run(args, noRepo, strings.NewReader(""), &out); err != nil || !strings.Contains(out.String(), "usage: srs") {
			t.Errorf("Run(%v) = %v, output %q", args, err, out.String())
		}
	}
	if err := Run([]string{"frobnicate"}, noRepo, strings.NewReader(""), &out); err == nil || !strings.Contains(err.Error(), "unknown command") {
		t.Errorf("unknown command: %v", err)
	}
	if err := Run([]string{"today"}, noRepo, strings.NewReader(""), &out); err == nil || !strings.Contains(err.Error(), "not in the repo") {
		t.Errorf("a repo command outside the repo: %v", err)
	}
}

func TestFindRootWalksUp(t *testing.T) {
	root := t.TempDir()
	os.WriteFile(filepath.Join(root, "go.mod"), []byte("module x\n"), 0o644)
	os.MkdirAll(filepath.Join(root, "srs"), 0o755)
	deep := filepath.Join(root, "trees", "easy", "x")
	os.MkdirAll(deep, 0o755)
	got, err := findRoot(deep)
	if err != nil {
		t.Fatal(err)
	}
	if want, _ := filepath.EvalSymlinks(root); got != root && got != want {
		t.Errorf("findRoot = %s, want %s", got, root)
	}
	if _, err := findRoot(t.TempDir()); err == nil {
		t.Error("found a repo in an empty folder")
	}
}

// --- a whole day through Run, the way main calls it ---

type repo struct {
	t    *testing.T
	root string
}

func newRepo(t *testing.T) *repo {
	root := t.TempDir()
	os.MkdirAll(filepath.Join(root, "srs"), 0o755)
	os.WriteFile(filepath.Join(root, "go.mod"), []byte("module x\n"), 0o644)
	problems := Problems{}
	for i, p := range []struct{ slug, difficulty string }{{"e1", "Easy"}, {"m1", "Medium"}, {"e2", "Easy"}, {"m2", "Medium"}} {
		problems[p.slug] = &Problem{
			Name: strings.ToUpper(p.slug), Topic: "arrays", Difficulty: p.difficulty, Order: i + 1,
			Link: "https://leetcode.com/problems/" + p.slug + "/", File: SolutionPath("arrays", p.difficulty, p.slug),
		}
	}
	if err := SaveProblems(filepath.Join(root, "srs", "problems.yml"), problems); err != nil {
		t.Fatal(err)
	}
	return &repo{t, root}
}

func (r *repo) run(day Date, stdin string, args ...string) (string, error) {
	r.t.Helper()
	env := Env{
		Root: r.root, ProblemsPath: filepath.Join(r.root, "srs", "problems.yml"),
		StatePath: filepath.Join(r.root, "srs", "state.yml"), ConfigPath: filepath.Join(r.root, "srs", "config.yml"), Today: day,
	}
	var out strings.Builder
	err := Run(args, func() (Env, error) { return env, nil }, strings.NewReader(stdin), &out)
	return out.String(), err
}

func (r *repo) mustRun(day Date, stdin string, args ...string) string {
	r.t.Helper()
	out, err := r.run(day, stdin, args...)
	if err != nil {
		r.t.Fatalf("srs %v: %v\n%s", args, err, out)
	}
	return out
}

func TestTwoDaysThroughTheCLI(t *testing.T) {
	r := newRepo(t)
	day1 := DateOf(2026, 10, 1)

	out := r.mustRun(day1, "", "today")
	for _, want := range []string{"2026-10-01 — 2 problems", "A  NEW", "B  NEW", "no new problem in 2 days", "Grade any of these `easy`"} {
		if !strings.Contains(out, want) {
			t.Errorf("today lacks %q:\n%s", want, out)
		}
	}
	if again := r.mustRun(day1, "", "today"); again != out {
		t.Errorf("today changed within the day:\n%s\nvs\n%s", out, again)
	}

	out = r.mustRun(day1, "", "start", "a")
	for _, want := range []string{"Created: arrays_and_hashing/easy/e1/e1.go", "go test ./arrays_and_hashing/easy/e1", "https://leetcode.com/problems/e1/"} {
		if !strings.Contains(out, want) {
			t.Errorf("start lacks %q:\n%s", want, out)
		}
	}
	for _, f := range []string{"arrays_and_hashing/easy/e1/e1.go", "arrays_and_hashing/easy/e1/e1_test.go"} {
		if !exists(filepath.Join(r.root, f)) {
			t.Errorf("%s wasn't created", f)
		}
	}
	if out = r.mustRun(day1, "", "start", "A"); !strings.Contains(out, "Already exists") {
		t.Errorf("second start: %s", out)
	}

	// `easy` unlocks bonus slot C, which has no easy problem left but e2.
	out = r.mustRun(day1, "", "grade", "A", "easy")
	for _, want := range []string{"E1: easy — next review 2026-10-02 (in 1d, ease 2.6)", "Bonus unlocked:", "C  NEW", "E2"} {
		if !strings.Contains(out, want) {
			t.Errorf("grade lacks %q:\n%s", want, out)
		}
	}
	if _, err := r.run(day1, "", "grade", "A", "good"); err == nil || !strings.Contains(err.Error(), "already graded") {
		t.Errorf("grading twice: %v", err)
	}
	if _, err := r.run(day1, "", "grade", "A", "meh"); err == nil || !strings.Contains(err.Error(), "again, hard, good, easy") {
		t.Errorf("bad grade: %v", err)
	}
	if _, err := r.run(day1, "", "grade", "Z", "good"); err == nil || !strings.Contains(err.Error(), "no slot Z") {
		t.Errorf("unknown slot: %v", err)
	}
	if _, err := r.run(day1, "", "more"); err == nil || !strings.Contains(err.Error(), "grade today's problems first") {
		t.Errorf("more before finishing: %v", err)
	}

	r.mustRun(day1, "", "grade", "B", "good")
	out = r.mustRun(day1, "n\n", "grade", "C", "hard")
	if !strings.Contains(out, "Try a new one? [y/N]") {
		t.Errorf("no offer of more after the last grade:\n%s", out)
	}

	// Day two: the three problems are due again, and the solved ones can be attempted.
	day2 := day1.AddDays(1)
	solved := "// https://leetcode.com/problems/e1/\n\npackage solution\n\nfunc e1() int {\n\treturn 1\n}\n"
	os.WriteFile(filepath.Join(r.root, "arrays_and_hashing/easy/e1/e1.go"), []byte(solved), 0o644)

	out = r.mustRun(day2, "", "today")
	if !strings.Contains(out, "REVIEW") || !strings.Contains(out, "due today") {
		t.Errorf("day two has no due review:\n%s", out)
	}
	out = r.mustRun(day2, "", "start", "A")
	if !strings.Contains(out, "Created: attempts/arrays_and_hashing/easy/e1/e1.go") || !strings.Contains(out, "your original stays untouched") {
		t.Errorf("review start:\n%s", out)
	}
	attempt, _ := os.ReadFile(filepath.Join(r.root, "attempts/arrays_and_hashing/easy/e1/e1.go"))
	if !strings.Contains(string(attempt), `panic("TODO")`) || strings.Contains(string(attempt), "return 1") {
		t.Errorf("attempt isn't a blank stub:\n%s", attempt)
	}
	if original, _ := os.ReadFile(filepath.Join(r.root, "arrays_and_hashing/easy/e1/e1.go")); string(original) != solved {
		t.Error("the original changed")
	}

	out = r.mustRun(day2, "y\nn\n", "grade", "A", "good")
	if !strings.Contains(out, "Delete attempts/arrays_and_hashing/easy/e1? [Y/n]") || !strings.Contains(out, "Deleted.") {
		t.Errorf("no cleanup offer:\n%s", out)
	}
	if exists(filepath.Join(r.root, "attempts")) {
		t.Error("the attempt wasn't deleted")
	}

	for _, cmd := range []string{"status", "overdue"} {
		if out = r.mustRun(day2, "", cmd); out == "" {
			t.Errorf("%s printed nothing", cmd)
		}
	}
	if out = r.mustRun(day2, "", "status"); !strings.Contains(out, "Seen 3/4") || !strings.Contains(out, "streak") {
		t.Errorf("status:\n%s", out)
	}
}

func TestPracticeAProblemYouPick(t *testing.T) {
	day := DateOf(2026, 10, 1)
	for _, target := range []string{"m2", "arrays_and_hashing/easy/e2/e2.go", "arrays_and_hashing/easy/e2"} {
		r := newRepo(t)
		r.mustRun(day, "", "today")
		out, err := r.run(day, "", "start", target)
		if err != nil || !strings.Contains(out, "is slot D") || !strings.Contains(out, "Created:") {
			t.Errorf("start %s: %v\n%s", target, err, out)
		}
	}
	r := newRepo(t)
	if _, err := r.run(day, "", "start", "no-such-problem"); err == nil || !strings.Contains(err.Error(), "isn't on the sheet") {
		t.Errorf("unknown target: %v", err)
	}
}

func TestMoreAndOverdueThroughTheCLI(t *testing.T) {
	r := newRepo(t)
	day := DateOf(2026, 10, 1)
	r.mustRun(day, "", "today")
	r.mustRun(day, "", "grade", "A", "good")
	r.mustRun(day, "n\n", "grade", "B", "good")
	out := r.mustRun(day, "", "more", "medium")
	if !strings.Contains(out, "Extra problem:") || !strings.Contains(out, "M2") {
		t.Errorf("more medium:\n%s", out)
	}
	r.mustRun(day, "", "grade", "D", "good") // C is reserved for the bonus slot, so extras start at D
	if out = r.mustRun(day, "", "more", "old"); !strings.Contains(out, "Nothing is due for review.") {
		t.Errorf("more old with nothing due:\n%s", out)
	}
	if out = r.mustRun(day.AddDays(30), "", "overdue"); !strings.Contains(out, "Overdue (3):") {
		t.Errorf("overdue after a month:\n%s", out)
	}
}
