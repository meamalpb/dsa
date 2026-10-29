package srs

import (
	"encoding/csv"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
)

// The published NeetCode 150 Google Sheet. It never changes, so only setup reads it.

const sheetCSVURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRLw2LeIkVdQ4bcZxGLJQjSfzQtbI7NS94K4hnJeZMLCMAch_Yz2bp3AoqFTGbyGYXQ8MQ7smkmy4ca/pub?output=csv"

// Also matches .../accounts/login/?next=/problems/<slug>/
var sheetSlug = regexp.MustCompile(`/problems/([a-z0-9-]+)`)

// Sheet links LeetCode has since renamed.
var slugFixes = map[string]string{"coin-change-2": "coin-change-ii"}

// Sheet columns: Category, Name, Status, Link, Notes.
const (
	colCategory = 0
	colName     = 1
	colLink     = 3
	colNotes    = 4
)

type SheetRow struct {
	Order    int
	Category string
	Name     string
	Slug     string
	Notes    string
}

func FetchSheetRows() ([]SheetRow, error) {
	body, err := download(sheetCSVURL)
	if err != nil {
		return nil, err
	}
	return ParseSheet(body)
}

// ParseSheet reads the sheet's CSV, header row first.
func ParseSheet(data string) ([]SheetRow, error) {
	reader := csv.NewReader(strings.NewReader(data))
	reader.FieldsPerRecord = -1
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("reading the sheet: %w", err)
	}
	var rows []SheetRow
	for i, record := range records {
		if i == 0 { // header
			continue
		}
		field := func(col int) string {
			if col < len(record) {
				return strings.TrimSpace(record[col])
			}
			return ""
		}
		if field(colName) == "" && field(colLink) == "" { // blank row
			continue
		}
		match := sheetSlug.FindStringSubmatch(field(colLink))
		if match == nil {
			return nil, fmt.Errorf("no LeetCode slug in sheet row %d: %q", i+1, field(colLink))
		}
		slug := match[1]
		if fixed, ok := slugFixes[slug]; ok {
			slug = fixed
		}
		rows = append(rows, SheetRow{
			Order: len(rows) + 1, Category: field(colCategory), Name: field(colName),
			Slug: slug, Notes: field(colNotes),
		})
	}
	return rows, nil
}

func download(url string) (string, error) {
	client := http.Client{Timeout: 30 * time.Second} // follows redirects
	res, err := client.Get(url)
	if err != nil {
		return "", fmt.Errorf("sheet download: %w", err)
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return "", fmt.Errorf("sheet download failed: HTTP %d", res.StatusCode)
	}
	body, err := io.ReadAll(res.Body)
	return string(body), err
}
