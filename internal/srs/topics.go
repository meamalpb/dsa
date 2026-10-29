package srs

import "fmt"

// Topic is one stop on NeetCode's roadmap: its folder and the topics that unlock it.
type Topic struct {
	Key     string
	Folder  string
	Prereqs []string
}

// Roadmap is NeetCode's, in the order the sheet lists the topics.
var Roadmap = []Topic{
	{"arrays", "arrays_and_hashing", nil},
	{"two_pointers", "two_pointers", []string{"arrays"}},
	{"sliding_window", "sliding_window", []string{"two_pointers"}},
	{"stack", "stack", []string{"arrays"}},
	{"binary_search", "binary_search", []string{"two_pointers"}},
	{"linked_list", "linked_list", []string{"two_pointers"}},
	{"trees", "trees", []string{"binary_search", "linked_list"}},
	{"tries", "tries", []string{"trees"}},
	{"heap", "heap", []string{"trees"}},
	{"backtracking", "backtracking", []string{"trees"}},
	{"graphs", "graphs", []string{"backtracking"}},
	{"advanced_graphs", "advanced_graphs", []string{"heap", "graphs"}},
	{"dp_1d", "dp_1d", []string{"backtracking"}},
	{"dp_2d", "dp_2d", []string{"graphs", "dp_1d"}},
	{"greedy", "greedy", []string{"heap"}},
	{"intervals", "intervals", []string{"heap"}},
	{"math_geometry", "math_geometry", []string{"graphs", "bit_manipulation"}},
	{"bit_manipulation", "bit_manipulation", []string{"dp_1d"}},
}

// Sheet "Category" column => topic key. "Graph" is the sheet's label for
// Longest Consecutive Sequence, which is an Arrays problem.
var categories = map[string]string{
	"Arrays":                  "arrays",
	"Graph":                   "arrays",
	"Two Pointers":            "two_pointers",
	"Sliding Window":          "sliding_window",
	"Stack":                   "stack",
	"Binary Search":           "binary_search",
	"Linked List":             "linked_list",
	"Trees":                   "trees",
	"Tries":                   "tries",
	"Heap / Priority Queue":   "heap",
	"Backtracking":            "backtracking",
	"Graphs":                  "graphs",
	"Advanced Graphs":         "advanced_graphs",
	"1-D Dynamic Programming": "dp_1d",
	"2-D Dynamic Programming": "dp_2d",
	"Greedy":                  "greedy",
	"Intervals":               "intervals",
	"Math & Geometry":         "math_geometry",
	"Bit Manipulation":        "bit_manipulation",
}

func topicByKey(key string) (Topic, bool) {
	for _, t := range Roadmap {
		if t.Key == key {
			return t, true
		}
	}
	return Topic{}, false
}

func TopicFolder(key string) string {
	t, _ := topicByKey(key)
	return t.Folder
}

func TopicPrereqs(key string) []string {
	t, _ := topicByKey(key)
	return t.Prereqs
}

func TopicForCategory(category string) (string, error) {
	key, ok := categories[category]
	if !ok {
		return "", fmt.Errorf("unknown sheet category: %q", category)
	}
	return key, nil
}

// TopicForFolder is the topic whose folder this is, or "".
func TopicForFolder(folder string) string {
	for _, t := range Roadmap {
		if t.Folder == folder {
			return t.Key
		}
	}
	return ""
}
