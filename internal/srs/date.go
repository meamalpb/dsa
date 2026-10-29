package srs

import (
	"fmt"
	"time"

	"gopkg.in/yaml.v3"
)

// Date is a calendar day, stored as days since 1970-01-01, so adding days is
// plain addition and dates compare and key maps directly. The zero Date means "not set".
type Date int

const dateLayout = "2006-01-02"

func DateOf(year int, month time.Month, day int) Date {
	return Date(time.Date(year, month, day, 0, 0, 0, 0, time.UTC).Unix() / 86400)
}

func Today() Date {
	year, month, day := time.Now().Date()
	return DateOf(year, month, day)
}

func ParseDate(s string) (Date, error) {
	t, err := time.Parse(dateLayout, s)
	if err != nil {
		return 0, fmt.Errorf("bad date %q (want YYYY-MM-DD)", s)
	}
	return Date(t.Unix() / 86400), nil
}

func (d Date) Time() time.Time    { return time.Unix(int64(d)*86400, 0).UTC() }
func (d Date) String() string     { return d.Time().Format(dateLayout) }
func (d Date) AddDays(n int) Date { return d + Date(n) }
func (d Date) IsZero() bool       { return d == 0 }

// Sub is the number of days from o to d.
func (d Date) Sub(o Date) int { return int(d - o) }

// ISOWeekday is 1 for Monday through 7 for Sunday.
func (d Date) ISOWeekday() int {
	if wd := d.Time().Weekday(); wd != time.Sunday {
		return int(wd)
	}
	return 7
}

// MarshalYAML writes a plain 2026-03-14 rather than a full timestamp.
func (d Date) MarshalYAML() (any, error) {
	if d.IsZero() {
		return nil, nil
	}
	return &yaml.Node{Kind: yaml.ScalarNode, Tag: "!!timestamp", Value: d.String()}, nil
}

func (d *Date) UnmarshalYAML(n *yaml.Node) error {
	if n.Tag == "!!null" || n.Value == "" {
		*d = 0
		return nil
	}
	value := n.Value
	if len(value) > len(dateLayout) {
		value = value[:len(dateLayout)]
	}
	parsed, err := ParseDate(value)
	if err != nil {
		return fmt.Errorf("line %d: %w", n.Line, err)
	}
	*d = parsed
	return nil
}
