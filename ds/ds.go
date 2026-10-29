// Package ds has the node types LeetCode hands you for linked-list and tree problems,
// with helpers to build them from plain values and read them back, so a problem's
// tests can be written as literals:
//
//	got := reverseList(ds.NewList(1, 2, 3))
//	want := []int{3, 2, 1}
//	if !slices.Equal(got.Slice(), want) { ... }
//
// LeetCode writes signatures with its own ListNode and TreeNode. To keep yours looking
// the same, alias them at the top of the solution file:
//
//	type ListNode = ds.ListNode
//
// and delete the alias (and the import) when you paste the function into LeetCode.
package ds

import (
	"fmt"
	"math"
	"strings"
)

// ListNode is a node of a singly linked list.
type ListNode struct {
	Val  int
	Next *ListNode
}

// NewList builds a list holding vals in order. No values gives nil, the empty list.
func NewList(vals ...int) *ListNode {
	return NewListWithCycle(-1, vals...)
}

// NewListWithCycle builds a list whose last node points back to the node at index pos,
// as in LeetCode's linked-list-cycle examples. A pos of -1, or past the end, means no cycle.
func NewListWithCycle(pos int, vals ...int) *ListNode {
	var head, tail, cycleStart *ListNode
	for i, v := range vals {
		node := &ListNode{Val: v}
		if head == nil {
			head = node
		} else {
			tail.Next = node
		}
		tail = node
		if i == pos {
			cycleStart = node
		}
	}
	if tail != nil {
		tail.Next = cycleStart
	}
	return head
}

// At returns the node at index i, or nil if the list is shorter.
func (l *ListNode) At(i int) *ListNode {
	for ; l != nil && i > 0; i-- {
		l = l.Next
	}
	return l
}

// Slice returns the values in order. It stops if the list loops back on itself.
func (l *ListNode) Slice() []int {
	var vals []int
	seen := map[*ListNode]bool{}
	for ; l != nil && !seen[l]; l = l.Next {
		seen[l] = true
		vals = append(vals, l.Val)
	}
	return vals
}

// String prints the list as 1 -> 2 -> 3, for test failure messages.
func (l *ListNode) String() string {
	vals := l.Slice()
	if len(vals) == 0 {
		return "empty list"
	}
	parts := make([]string, len(vals))
	for i, v := range vals {
		parts[i] = fmt.Sprint(v)
	}
	return strings.Join(parts, " -> ")
}

// TreeNode is a node of a binary tree.
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

// Null stands for a missing node in the level-order lists of NewTree and LevelOrder,
// where LeetCode writes null.
const Null = math.MinInt

// NewTree builds a tree from LeetCode's level-order notation: [3,9,20,null,null,15,7] is
//
//	ds.NewTree(3, 9, 20, ds.Null, ds.Null, 15, 7)
//
// No values, or Null first, gives nil, the empty tree.
func NewTree(vals ...int) *TreeNode {
	if len(vals) == 0 || vals[0] == Null {
		return nil
	}
	root := &TreeNode{Val: vals[0]}
	queue := []*TreeNode{root}
	next := 1
	child := func() *TreeNode {
		defer func() { next++ }()
		if next >= len(vals) || vals[next] == Null {
			return nil
		}
		node := &TreeNode{Val: vals[next]}
		queue = append(queue, node)
		return node
	}
	for len(queue) > 0 && next < len(vals) {
		parent := queue[0]
		queue = queue[1:]
		parent.Left = child()
		parent.Right = child()
	}
	return root
}

// LevelOrder is NewTree's inverse: the values level by level, Null for a missing node,
// without trailing Nulls. Handy for comparing a returned tree with an expected one.
func (t *TreeNode) LevelOrder() []int {
	if t == nil {
		return nil
	}
	var vals []int
	queue := []*TreeNode{t}
	for len(queue) > 0 {
		node := queue[0]
		queue = queue[1:]
		if node == nil {
			vals = append(vals, Null)
			continue
		}
		vals = append(vals, node.Val)
		queue = append(queue, node.Left, node.Right)
	}
	for len(vals) > 0 && vals[len(vals)-1] == Null {
		vals = vals[:len(vals)-1]
	}
	return vals
}

// String prints the tree in LeetCode's notation, [3 9 20 null null 15 7], for test failure messages.
func (t *TreeNode) String() string {
	vals := t.LevelOrder()
	parts := make([]string, len(vals))
	for i, v := range vals {
		if v == Null {
			parts[i] = "null"
		} else {
			parts[i] = fmt.Sprint(v)
		}
	}
	return "[" + strings.Join(parts, " ") + "]"
}
