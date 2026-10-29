package srs

import (
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
)

// Files created by `start` — DESIGN.md §8.
//
// Every problem is its own package in its own folder, e.g.
//
//	arrays_and_hashing/easy/two_sum/two_sum.go
//	arrays_and_hashing/easy/two_sum/two_sum_test.go
//
// and a review attempt is a copy of that folder under attempts/, so it can't clash
// with the original.

const attemptsDir = "attempts"

// banner matches the section comments in a solution file ("// ---", "// Approach 1 …")
// that an attempt leaves out.
var banner = regexp.MustCompile(`(?im)^//[ \t]*(-{3,}|approach\b).*\n`)

// AttemptPath is where the attempt for a solution file lives (gitignored).
func AttemptPath(file string) string {
	return path.Join(attemptsDir, file)
}

// TestPath is the test file that goes with a solution file.
func TestPath(file string) string {
	return strings.TrimSuffix(file, ".go") + "_test.go"
}

// Scaffold creates the files `start` hands out, under Root.
type Scaffold struct {
	Root string
}

// CreateNew writes the solution file and its test file for a problem the user hasn't
// seen. It returns false if the solution file already exists, and leaves both alone.
func (s Scaffold) CreateNew(file, slug string) (bool, error) {
	created, err := s.writeUnlessExists(file, newSource(file, slug))
	if err != nil || !created {
		return false, err
	}
	_, err = s.writeUnlessExists(TestPath(file), testSkeleton)
	return true, err
}

// CreateAttempt copies the solved problem into attempts/ with every solution body
// replaced by a stub, keeping the tests. The original is never modified. It returns
// false if the attempt already exists.
func (s Scaffold) CreateAttempt(file string) (bool, error) {
	original, err := os.ReadFile(filepath.Join(s.Root, file))
	if err != nil {
		return false, fmt.Errorf("can't read %s to make an attempt from it: %w", file, err)
	}
	source, err := AttemptSource(string(original))
	if err != nil {
		source = headerOnly(string(original))
	}
	created, err := s.writeUnlessExists(AttemptPath(file), source)
	if err != nil || !created {
		return false, err
	}

	tests, err := os.ReadFile(filepath.Join(s.Root, TestPath(file)))
	if err != nil {
		tests = []byte(testSkeleton)
	}
	_, err = s.writeUnlessExists(TestPath(AttemptPath(file)), string(tests))
	return true, err
}

// RemoveAttempt deletes the attempt folder, and any parent folders (up to attempts/) it leaves empty.
func (s Scaffold) RemoveAttempt(file string) error {
	dir := filepath.Join(s.Root, filepath.FromSlash(path.Dir(AttemptPath(file))))
	if err := os.RemoveAll(dir); err != nil {
		return err
	}
	stop := filepath.Join(s.Root, attemptsDir)
	for parent := filepath.Dir(dir); strings.HasPrefix(parent, stop); parent = filepath.Dir(parent) {
		if os.Remove(parent) != nil || parent == stop { // stops at the first folder that isn't empty
			break
		}
	}
	return nil
}

func (s Scaffold) writeUnlessExists(file, content string) (bool, error) {
	full := filepath.Join(s.Root, filepath.FromSlash(file))
	if exists(full) {
		return false, nil
	}
	if err := os.MkdirAll(filepath.Dir(full), 0o755); err != nil {
		return false, err
	}
	return true, os.WriteFile(full, []byte(content), 0o644)
}

func newSource(file, slug string) string {
	return fmt.Sprintf(`// %s
//
// Problem
// https://leetcode.com/problems/%s/

package solution
`, file, slug)
}

const testSkeleton = `package solution

import "testing"

func TestSolution(t *testing.T) {
	tests := []struct {
		name string
		// inputs and the expected result go here
	}{
		// {name: "example 1"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// call your function and compare with t.Errorf
		})
	}
}
`

// AttemptSource keeps everything in a solution file that isn't the answer: header,
// package clause, the imports the signatures still need, constants and variables, and
// every function with its body replaced by a panic so the file still compiles and the
// tests have something to call. A type that has methods (a design problem like MinStack)
// loses its fields, since those are the answer too.
//
// It edits the source text at positions from go/parser rather than printing the syntax
// tree back, which would misplace the comments that sat inside the bodies it removes.
func AttemptSource(src string) (string, error) {
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "", src, parser.ParseComments)
	if err != nil {
		return "", err
	}
	offset := func(pos token.Pos) int { return fset.Position(pos).Offset }

	withMethods := map[string]bool{}
	for _, decl := range file.Decls {
		if fn, ok := decl.(*ast.FuncDecl); ok && fn.Recv != nil && len(fn.Recv.List) > 0 {
			withMethods[receiverType(fn.Recv.List[0].Type)] = true
		}
	}

	type edit struct {
		start, end int
		text       string
	}
	var edits []edit
	removed := map[ast.Node]bool{} // parts of the tree that no longer exist in the output
	for _, decl := range file.Decls {
		switch decl := decl.(type) {
		case *ast.FuncDecl:
			if decl.Body != nil {
				edits = append(edits, edit{offset(decl.Body.Lbrace), offset(decl.Body.Rbrace) + 1, "{\n\tpanic(\"TODO\")\n}"})
				removed[decl.Body] = true
			}
		case *ast.GenDecl:
			for _, spec := range decl.Specs {
				if ts, ok := spec.(*ast.TypeSpec); ok {
					if st, ok := ts.Type.(*ast.StructType); ok && withMethods[ts.Name.Name] {
						edits = append(edits, edit{offset(st.Fields.Opening), offset(st.Fields.Closing) + 1, "{}"})
						removed[st.Fields] = true
					}
				}
			}
		}
	}

	// Imports only the removed code used would stop the stub from compiling.
	used := map[string]bool{}
	ast.Inspect(file, func(n ast.Node) bool {
		if removed[n] {
			return false
		}
		if sel, ok := n.(*ast.SelectorExpr); ok {
			if id, ok := sel.X.(*ast.Ident); ok {
				used[id.Name] = true
			}
		}
		return true
	})
	for _, decl := range file.Decls {
		gen, ok := decl.(*ast.GenDecl)
		if !ok || gen.Tok != token.IMPORT {
			continue
		}
		var unused []*ast.ImportSpec
		for _, spec := range gen.Specs {
			if imp := spec.(*ast.ImportSpec); !used[importName(imp)] && importName(imp) != "_" && importName(imp) != "." {
				unused = append(unused, imp)
			}
		}
		switch {
		case len(unused) == len(gen.Specs):
			edits = append(edits, edit{offset(gen.Pos()), offset(gen.End()), ""})
		default:
			for _, imp := range unused {
				edits = append(edits, edit{offset(imp.Pos()), offset(imp.End()), ""})
			}
		}
	}

	slices.SortFunc(edits, func(a, b edit) int { return b.start - a.start }) // back to front keeps offsets valid
	out := src
	for _, e := range edits {
		out = out[:e.start] + e.text + out[e.end:]
	}
	out = banner.ReplaceAllString(out, "")
	formatted, err := format.Source([]byte(out))
	if err != nil {
		return "", err
	}
	return string(formatted), nil
}

// receiverType is the type name of a method receiver: T for both (t T) and (t *T).
func receiverType(expr ast.Expr) string {
	switch t := expr.(type) {
	case *ast.StarExpr:
		return receiverType(t.X)
	case *ast.IndexExpr: // generic receiver, T[K]
		return receiverType(t.X)
	case *ast.Ident:
		return t.Name
	}
	return ""
}

// importName is the name an import is used by in the file.
func importName(imp *ast.ImportSpec) string {
	if imp.Name != nil {
		return imp.Name.Name
	}
	parts := strings.Split(strings.Trim(imp.Path.Value, `"`), "/")
	name := parts[len(parts)-1]
	if len(parts) > 1 && regexp.MustCompile(`^v\d+$`).MatchString(name) { // math/rand/v2 is used as rand
		name = parts[len(parts)-2]
	}
	return name
}

// headerOnly is the fallback when a file doesn't parse: everything up to and including
// its package clause.
func headerOnly(src string) string {
	lines := strings.SplitAfter(src, "\n")
	for i, line := range lines {
		if strings.HasPrefix(line, "package ") {
			return strings.Join(lines[:i+1], "")
		}
	}
	return "package solution\n"
}
