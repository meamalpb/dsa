package srs

import (
	"go/ast"
	"go/importer"
	"go/parser"
	"go/token"
	"go/types"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

const solvedContainsDuplicate = `// arrays_and_hashing/easy/contains_duplicate/contains_duplicate.go
//
// Problem
// https://leetcode.com/problems/contains-duplicate/

package solution

import (
	"sort"
	"strings"
)

// --------------------------
// Approach 1 - hash lookup
// --------------------------

// containsDuplicate uses a set, O(n).
func containsDuplicate(nums []int) bool {
	seen := map[int]struct{}{}
	for _, n := range nums {
		// have we met it?
		if _, ok := seen[n]; ok {
			return true
		}
		seen[n] = struct{}{}
	}
	return false
}

// Approach 2 - sort
func containsDuplicateSort(nums []int) bool {
	sort.Ints(nums)
	_ = strings.ToLower("x")
	return false
}
`

// assertCompiles type-checks src, which is what makes a stub usable: tests can call
// it and the go tool doesn't refuse it for an unused import or a missing return.
func assertCompiles(t *testing.T, src string) {
	t.Helper()
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "stub.go", src, 0)
	if err != nil {
		t.Fatalf("stub doesn't parse: %v\n%s", err, src)
	}
	conf := types.Config{Importer: importer.ForCompiler(fset, "source", nil)}
	if _, err := conf.Check("solution", fset, []*ast.File{file}, nil); err != nil {
		t.Errorf("stub doesn't compile: %v\n%s", err, src)
	}
}

func TestAttemptSourceStripsSolutionsKeepsHeader(t *testing.T) {
	want := `// arrays_and_hashing/easy/contains_duplicate/contains_duplicate.go
//
// Problem
// https://leetcode.com/problems/contains-duplicate/

package solution

// containsDuplicate uses a set, O(n).
func containsDuplicate(nums []int) bool {
	panic("TODO")
}

func containsDuplicateSort(nums []int) bool {
	panic("TODO")
}
`
	got, err := AttemptSource(solvedContainsDuplicate)
	if err != nil {
		t.Fatal(err)
	}
	if got != want {
		t.Errorf("got:\n%s\nwant:\n%s", got, want)
	}
	assertCompiles(t, got)
}

func TestAttemptSourceEmptiesDesignTypesButKeepsPlainOnes(t *testing.T) {
	src := `// https://leetcode.com/problems/min-stack/
package solution

import (
	"fmt"
	"math"
	"sort"
)

type ListNode struct {
	Val  int
	Next *ListNode
}

type MinStack struct {
	data []int
	mins []int // running minimum
}

func Constructor() MinStack {
	return MinStack{math.MaxInt}
}

func (s *MinStack) Push(v int) { s.data = append(s.data, v) }

func (s *MinStack) Dump(w fmt.Stringer) string {
	sort.Ints(s.data)
	return w.String()
}

const mod = 1_000_000_007

var cache = map[int]int{}
`
	want := `// https://leetcode.com/problems/min-stack/
package solution

import (
	"fmt"
)

type ListNode struct {
	Val  int
	Next *ListNode
}

type MinStack struct{}

func Constructor() MinStack {
	panic("TODO")
}

func (s *MinStack) Push(v int) {
	panic("TODO")
}

func (s *MinStack) Dump(w fmt.Stringer) string {
	panic("TODO")
}

const mod = 1_000_000_007

var cache = map[int]int{}
`
	got, err := AttemptSource(src)
	if err != nil {
		t.Fatal(err)
	}
	if got != want {
		t.Errorf("got:\n%s\nwant:\n%s", got, want)
	}
	assertCompiles(t, got)
}

func TestAttemptSourceKeepsImportsTheSignaturesNeed(t *testing.T) {
	got, err := AttemptSource("package solution\n\nimport \"strings\"\nimport \"sort\"\n\nfunc f(b *strings.Builder) { sort.Ints(nil) }\n")
	if err != nil {
		t.Fatal(err)
	}
	want := "package solution\n\nimport \"strings\"\n\nfunc f(b *strings.Builder) {\n\tpanic(\"TODO\")\n}\n"
	if got != want {
		t.Errorf("got:\n%s\nwant:\n%s", got, want)
	}
	assertCompiles(t, got)
}

func TestAttemptSourceKeepsBlankAndDotImports(t *testing.T) {
	got, err := AttemptSource("package solution\n\nimport (\n\t_ \"embed\"\n\t\"math/rand/v2\"\n)\n\nfunc f() int { return rand.IntN(3) }\n")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(got, `_ "embed"`) || strings.Contains(got, "rand") {
		t.Errorf("got:\n%s", got)
	}
}

func TestAttemptSourceRefusesBrokenCode(t *testing.T) {
	if _, err := AttemptSource("package solution\n\nfunc broken( {\n"); err == nil {
		t.Error("a file that doesn't parse was accepted; the caller needs the error to fall back")
	}
}

func TestHeaderOnlyFallback(t *testing.T) {
	src := "// https://leetcode.com/problems/x/\n\npackage solution\n\nfunc broken( {\n"
	want := "// https://leetcode.com/problems/x/\n\npackage solution\n"
	if got := headerOnly(src); got != want {
		t.Errorf("got %q, want %q", got, want)
	}
	if got := headerOnly("garbage"); got != "package solution\n" {
		t.Errorf("no package clause: got %q", got)
	}
}

func TestPaths(t *testing.T) {
	file := "trees/easy/invert_binary_tree/invert_binary_tree.go"
	if got, want := AttemptPath(file), "attempts/trees/easy/invert_binary_tree/invert_binary_tree.go"; got != want {
		t.Errorf("AttemptPath = %q, want %q", got, want)
	}
	if got, want := TestPath(file), "trees/easy/invert_binary_tree/invert_binary_tree_test.go"; got != want {
		t.Errorf("TestPath = %q, want %q", got, want)
	}
	if got, want := SolutionPath("trees", "Easy", "invert-binary-tree"), file; got != want {
		t.Errorf("SolutionPath = %q, want %q", got, want)
	}
	if got, want := SolutionPath("two_pointers", "Medium", "3sum"), "two_pointers/medium/3sum/3sum.go"; got != want {
		t.Errorf("SolutionPath = %q, want %q", got, want)
	}
}

func TestNewSourceCompilesAndPasses(t *testing.T) {
	src := newSource("trees/easy/x/x.go", "x")
	if !strings.Contains(src, "https://leetcode.com/problems/x/") {
		t.Errorf("scaffold lacks the problem link:\n%s", src)
	}
	assertCompiles(t, src)
	assertCompiles(t, testSkeleton)
}

func TestCreateNewMakesSolutionAndTestsOnce(t *testing.T) {
	s := Scaffold{Root: t.TempDir()}
	file := "arrays_and_hashing/easy/two_sum/two_sum.go"
	created, err := s.CreateNew(file, "two-sum")
	if err != nil || !created {
		t.Fatalf("CreateNew = %v, %v", created, err)
	}
	for _, f := range []string{file, TestPath(file)} {
		if !exists(filepath.Join(s.Root, f)) {
			t.Errorf("%s wasn't created", f)
		}
	}

	os.WriteFile(filepath.Join(s.Root, file), []byte("package solution\n// mine\n"), 0o644)
	created, err = s.CreateNew(file, "two-sum")
	if err != nil || created {
		t.Errorf("second CreateNew = %v, %v; want false, nil", created, err)
	}
	if got, _ := os.ReadFile(filepath.Join(s.Root, file)); !strings.Contains(string(got), "// mine") {
		t.Error("an existing solution was overwritten")
	}
}

// An attempt must fail until it's solved, the original must keep passing, and neither
// may touch the other — checked with the real go tool.
func TestAttemptEndToEndWithGoTest(t *testing.T) {
	if _, err := exec.LookPath("go"); err != nil {
		t.Skip("go tool not on PATH")
	}
	root := t.TempDir()
	write := func(name, content string) {
		path := filepath.Join(root, filepath.FromSlash(name))
		os.MkdirAll(filepath.Dir(path), 0o755)
		if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	file := "arrays_and_hashing/easy/two_sum/two_sum.go"
	original := "// https://leetcode.com/problems/two-sum/\n\npackage solution\n\n" +
		"// --- Approach 1\nfunc twoSum(nums []int, target int) []int {\n\tseen := map[int]int{}\n" +
		"\tfor i, n := range nums {\n\t\tif j, ok := seen[target-n]; ok {\n\t\t\treturn []int{j, i}\n\t\t}\n\t\tseen[n] = i\n\t}\n\treturn nil\n}\n"
	tests := "package solution\n\nimport (\n\t\"reflect\"\n\t\"testing\"\n)\n\nfunc TestTwoSum(t *testing.T) {\n" +
		"\tif got := twoSum([]int{2, 7, 11}, 9); !reflect.DeepEqual(got, []int{0, 1}) {\n\t\tt.Errorf(\"got %v\", got)\n\t}\n}\n"
	write("go.mod", "module probe\n\ngo 1.23\n")
	write(file, original)
	write(TestPath(file), tests)

	s := Scaffold{Root: root}
	if created, err := s.CreateAttempt(file); err != nil || !created {
		t.Fatalf("CreateAttempt = %v, %v", created, err)
	}
	if got, _ := os.ReadFile(filepath.Join(root, file)); string(got) != original {
		t.Error("the original was modified")
	}
	if got, _ := os.ReadFile(filepath.Join(root, TestPath(AttemptPath(file)))); string(got) != tests {
		t.Error("the attempt's tests aren't a copy of the original's")
	}

	goTest := func(pkg string) (string, error) {
		cmd := exec.Command("go", "test", pkg)
		cmd.Dir = root
		out, err := cmd.CombinedOutput()
		return string(out), err
	}
	if out, err := goTest("./arrays_and_hashing/easy/two_sum"); err != nil {
		t.Errorf("the original should pass: %v\n%s", err, out)
	}
	if out, err := goTest("./attempts/arrays_and_hashing/easy/two_sum"); err == nil || !strings.Contains(out, "TODO") {
		t.Errorf("the blank attempt should fail with the TODO panic, got err=%v\n%s", err, out)
	}

	if created, _ := s.CreateAttempt(file); created {
		t.Error("a second CreateAttempt overwrote the first")
	}
	if err := s.RemoveAttempt(file); err != nil {
		t.Fatal(err)
	}
	if exists(filepath.Join(root, "attempts")) {
		t.Error("RemoveAttempt left empty folders behind")
	}
	if !exists(filepath.Join(root, file)) {
		t.Error("RemoveAttempt touched the original")
	}
}

func TestCreateAttemptWithoutOriginalSaysSo(t *testing.T) {
	_, err := Scaffold{Root: t.TempDir()}.CreateAttempt("trees/easy/x/x.go")
	if err == nil || !strings.Contains(err.Error(), "trees/easy/x/x.go") {
		t.Errorf("error = %v, want one naming the missing file", err)
	}
}
