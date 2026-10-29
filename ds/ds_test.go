package ds

import (
	"slices"
	"testing"
)

func TestListRoundTrip(t *testing.T) {
	for _, vals := range [][]int{nil, {1}, {1, 2, 3}, {5, -2, 0, 5}} {
		if got := NewList(vals...).Slice(); !slices.Equal(got, vals) {
			t.Errorf("NewList(%v).Slice() = %v", vals, got)
		}
	}
	if NewList() != nil {
		t.Error("the empty list isn't nil")
	}
}

func TestListString(t *testing.T) {
	if got := NewList(1, 2, 3).String(); got != "1 -> 2 -> 3" {
		t.Errorf("String = %q", got)
	}
	if got := NewList().String(); got != "empty list" {
		t.Errorf("String of nil = %q", got)
	}
}

func TestListAt(t *testing.T) {
	l := NewList(10, 20, 30)
	if l.At(2).Val != 30 || l.At(0) != l || l.At(3) != nil {
		t.Error("At returned the wrong node")
	}
	var empty *ListNode
	if empty.At(0) != nil {
		t.Error("At on the empty list isn't nil")
	}
}

func TestListWithCycle(t *testing.T) {
	l := NewListWithCycle(1, 3, 2, 0, -4)
	if tail := l.At(3); tail.Next != l.At(1) {
		t.Error("the tail doesn't point back to index 1")
	}
	if got := l.Slice(); !slices.Equal(got, []int{3, 2, 0, -4}) {
		t.Errorf("Slice of a cyclic list = %v; it should stop after one lap", got)
	}
	for _, pos := range []int{-1, 9} {
		if NewListWithCycle(pos, 1, 2).At(1).Next != nil {
			t.Errorf("pos %d made a cycle", pos)
		}
	}
	one := NewListWithCycle(0, 7)
	if one.Next != one {
		t.Error("a single node with pos 0 should point at itself")
	}
}

func TestTreeRoundTrip(t *testing.T) {
	tests := [][]int{
		nil,
		{1},
		{1, 2, 3},
		{3, 9, 20, Null, Null, 15, 7},
		{1, Null, 2, Null, 3},
		{5, 4, 8, 11, Null, 13, 4, 7, 2, Null, Null, Null, 1},
	}
	for _, vals := range tests {
		if got := NewTree(vals...).LevelOrder(); !slices.Equal(got, vals) {
			t.Errorf("NewTree(%v).LevelOrder() = %v", vals, got)
		}
	}
}

func TestTreeShape(t *testing.T) {
	root := NewTree(3, 9, 20, Null, Null, 15, 7)
	if root.Val != 3 || root.Left.Val != 9 || root.Right.Val != 20 ||
		root.Right.Left.Val != 15 || root.Right.Right.Val != 7 || root.Left.Left != nil || root.Left.Right != nil {
		t.Errorf("wrong shape: %v", root)
	}
}

func TestTreeTrailingNullsAreIgnored(t *testing.T) {
	if got := NewTree(1, 2, Null, Null, Null).LevelOrder(); !slices.Equal(got, []int{1, 2}) {
		t.Errorf("LevelOrder = %v", got)
	}
	if NewTree(Null, 1, 2) != nil {
		t.Error("a Null root should give the empty tree")
	}
}

func TestTreeString(t *testing.T) {
	if got := NewTree(3, 9, 20, Null, Null, 15, 7).String(); got != "[3 9 20 null null 15 7]" {
		t.Errorf("String = %q", got)
	}
	if got := (*TreeNode)(nil).String(); got != "[]" {
		t.Errorf("String of nil = %q", got)
	}
}
