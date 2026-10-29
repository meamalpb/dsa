package srs

import (
	"reflect"
	"strings"
	"testing"
)

// mustConfig builds a config from YAML settings, failing the test if they're refused.
func mustConfig(t *testing.T, yaml string) Config {
	t.Helper()
	config, err := ParseConfig([]byte(yaml), "test")
	if err != nil {
		t.Fatalf("config refused: %v", err)
	}
	return config
}

func TestConfigMissingFileMeansDefaults(t *testing.T) {
	got, err := LoadConfig("/nonexistent/config.yml")
	if err != nil || !reflect.DeepEqual(got, DefaultConfig()) {
		t.Errorf("got %+v, %v; want the defaults", got, err)
	}
}

func TestConfigEmptyFileMeansDefaults(t *testing.T) {
	for _, content := range []string{"", "# only comments\n"} {
		if got := mustConfig(t, content); !reflect.DeepEqual(got, DefaultConfig()) {
			t.Errorf("%q: got %+v, want the defaults", content, got)
		}
	}
}

func TestConfigSettingsLeftOutKeepTheirDefault(t *testing.T) {
	c := mustConfig(t, "session:\n  new_every_days: 3\n  bonus:\n    max: 2\n")
	if c.Session.NewEveryDays != 3 || c.Session.Bonus.Max != 2 {
		t.Errorf("settings not applied: %+v", c.Session)
	}
	if c.Session.Bonus.Pool != "easy" || c.Session.ReviewOrder != ReviewMostOverdue || c.Unlock.TopicRatio != 0.8 {
		t.Errorf("left-out settings lost their default: %+v", c)
	}
}

func TestConfigSlotsAndPoolsAreReplacedWhole(t *testing.T) {
	c := mustConfig(t, "session:\n  slots:\n    A: medium_hard\n")
	if want := []Slot{{"A", "medium_hard"}}; !reflect.DeepEqual(c.Session.Slots, want) {
		t.Errorf("slots = %v, want %v", c.Session.Slots, want)
	}
	c = mustConfig(t, "pools:\n  easy: [Easy]\n  medium_hard: [Medium]\n")
	if len(c.Pools) != 2 || len(c.Pools["medium_hard"]) != 1 {
		t.Errorf("pools = %v", c.Pools)
	}
}

func TestConfigSlotsAreSortedByLetter(t *testing.T) {
	c := mustConfig(t, "session:\n  slots:\n    B: medium_hard\n    A: easy\n")
	if c.Session.Slots[0].Letter != "A" {
		t.Errorf("slots = %v, want A first", c.Session.Slots)
	}
}

func TestConfigMaxIntervalEmptyMeansNoLimit(t *testing.T) {
	if got := mustConfig(t, "sm2:\n  max_interval:\n").Sm2.MaxInterval; got != 0 {
		t.Errorf("max_interval = %d, want 0 (none)", got)
	}
}

// The repo's own config.yml must stay valid.
func TestYourConfigFileIsValid(t *testing.T) {
	if _, err := LoadConfig("../../srs/config.yml"); err != nil {
		t.Error(err)
	}
}

func TestConfigUnknownSettingIsRefused(t *testing.T) {
	_, err := ParseConfig([]byte("session:\n  new_evry_days: 3\n"), "test")
	if err == nil || !strings.Contains(err.Error(), "session.new_evry_days") {
		t.Errorf("error = %v, want one naming session.new_evry_days", err)
	}
	_, err = ParseConfig([]byte("sessoin: {}\n"), "test")
	if err == nil || !strings.Contains(err.Error(), "sessoin") {
		t.Errorf("error = %v, want one naming sessoin", err)
	}
}

func TestConfigBadValuesAreAllReported(t *testing.T) {
	_, err := ParseConfig([]byte(`
session:
  slots:
    A: hardish
  review_order: random
unlock:
  topic_ratio: 80
sm2:
  first_intervals: [1]
  max_interval: 0
`), "test")
	if err == nil {
		t.Fatal("bad values accepted")
	}
	for _, key := range []string{"session.slots.A", "session.review_order", "unlock.topic_ratio", "sm2.first_intervals", "sm2.max_interval"} {
		if !strings.Contains(err.Error(), key) {
			t.Errorf("error doesn't mention %s: %v", key, err)
		}
	}
}

func TestConfigWrongTypeIsRefused(t *testing.T) {
	if _, err := ParseConfig([]byte("session:\n  new_every_days: soon\n"), "test"); err == nil {
		t.Error("a word where a number belongs was accepted")
	}
}
