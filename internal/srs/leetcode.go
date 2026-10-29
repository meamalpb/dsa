package srs

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"
)

// Difficulty and premium flag from LeetCode's GraphQL endpoint. robots.txt disallows
// /graphql for crawlers, so only setup calls this, once per slug, throttled.

const (
	leetcodeGraphQL = "https://leetcode.com/graphql"
	leetcodeQuery   = `query q($slug: String!) { question(titleSlug: $slug) { difficulty isPaidOnly } }`
	// LeetcodeDelay is the pause between requests.
	LeetcodeDelay = time.Second
)

// Premium problems => NeetCode's free version.
var neetcodeSlugs = map[string]string{
	"encode-and-decode-strings": "string-encode-and-decode",
	"meeting-rooms":             "meeting-schedule",
	"meeting-rooms-ii":          "meeting-schedule-ii",
	"walls-and-gates":           "islands-and-treasure",
	"graph-valid-tree":          "valid-tree",
	"number-of-connected-components-in-an-undirected-graph": "count-connected-components",
	"alien-dictionary": "foreign-dictionary",
}

// FreeLink is NeetCode's free version of a premium problem, or "" if it isn't mapped.
func FreeLink(slug string) string {
	if free, ok := neetcodeSlugs[slug]; ok {
		return "https://neetcode.io/problems/" + free
	}
	return ""
}

type Details struct {
	Difficulty string
	PaidOnly   bool
}

func FetchDetails(slug string) (Details, error) {
	payload, err := json.Marshal(map[string]any{"query": leetcodeQuery, "variables": map[string]string{"slug": slug}})
	if err != nil {
		return Details{}, err
	}
	req, err := http.NewRequest(http.MethodPost, leetcodeGraphQL, bytes.NewReader(payload))
	if err != nil {
		return Details{}, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Referer", "https://leetcode.com")
	client := http.Client{Timeout: 30 * time.Second}
	res, err := client.Do(req)
	if err != nil {
		return Details{}, err
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return Details{}, fmt.Errorf("HTTP %d", res.StatusCode)
	}

	var body struct {
		Data struct {
			Question *struct {
				Difficulty string `json:"difficulty"`
				IsPaidOnly bool   `json:"isPaidOnly"`
			} `json:"question"`
		} `json:"data"`
	}
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		return Details{}, err
	}
	if body.Data.Question == nil {
		return Details{}, errors.New("no such problem")
	}
	return Details{body.Data.Question.Difficulty, body.Data.Question.IsPaidOnly}, nil
}
