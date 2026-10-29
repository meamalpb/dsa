package srs

import (
	"errors"
	"fmt"
	"os"
	"slices"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config holds the tunable rules: config.yml over these defaults — DESIGN.md §12.
// A missing file, or a setting left out of it, means the default.
type Config struct {
	Session SessionConfig
	Pools   map[string][]string
	Unlock  UnlockConfig
	Sm2     Sm2Config
	Display DisplayConfig
}

type Slot struct {
	Letter string
	Pool   string
}

type SessionConfig struct {
	Slots        []Slot // sorted by letter
	Bonus        BonusConfig
	NewEveryDays int
	ReviewOrder  string
	LearningDays int
}

type BonusConfig struct {
	Pool     string
	UnlockOn []string
	Max      int
}

type UnlockConfig struct {
	TopicRatio  float64
	TopicCounts []string
	HardRatio   float64
}

type Sm2Config struct {
	FirstIntervals [2]int
	StartEase      float64
	MinEase        float64
	MaxInterval    int // 0 = no limit
}

type DisplayConfig struct {
	HeatmapWeeks int
}

const (
	ReviewMostOverdue   = "most_overdue"
	ReviewLearningFirst = "learning_first"
)

var (
	difficulties = []string{"Easy", "Medium", "Hard"}
	grades       = []string{"again", "hard", "good", "easy"}
)

func DefaultConfig() Config {
	return Config{
		Session: SessionConfig{
			Slots:        []Slot{{"A", "easy"}, {"B", "medium_hard"}},
			Bonus:        BonusConfig{Pool: "easy", UnlockOn: []string{"easy"}, Max: 1},
			NewEveryDays: 2,
			ReviewOrder:  ReviewMostOverdue,
			LearningDays: 14,
		},
		Pools: map[string][]string{"easy": {"Easy"}, "medium_hard": {"Medium", "Hard"}},
		Unlock: UnlockConfig{
			TopicRatio:  0.8,
			TopicCounts: []string{"Easy", "Medium"},
			HardRatio:   0.8,
		},
		Sm2:     Sm2Config{FirstIntervals: [2]int{1, 6}, StartEase: 2.5, MinEase: 1.3},
		Display: DisplayConfig{HeatmapWeeks: 26},
	}
}

// What config.yml may contain: nested maps are sections, nil is a setting.
// Only used to name an unknown setting by its full path.
var settingNames = map[string]any{
	"session": map[string]any{
		"slots":          nil,
		"bonus":          map[string]any{"pool": nil, "unlock_on": nil, "max": nil},
		"new_every_days": nil,
		"review_order":   nil,
		"learning_days":  nil,
	},
	"pools":   nil,
	"unlock":  map[string]any{"topic_ratio": nil, "topic_counts": nil, "hard_ratio": nil},
	"sm2":     map[string]any{"first_intervals": nil, "start_ease": nil, "min_ease": nil, "max_interval": nil},
	"display": map[string]any{"heatmap_weeks": nil},
}

// The same shape as Config with every setting optional: nil = not in the file.
type overrides struct {
	Session *struct {
		Slots *slotList `yaml:"slots"`
		Bonus *struct {
			Pool     *string   `yaml:"pool"`
			UnlockOn *[]string `yaml:"unlock_on"`
			Max      *int      `yaml:"max"`
		} `yaml:"bonus"`
		NewEveryDays *int    `yaml:"new_every_days"`
		ReviewOrder  *string `yaml:"review_order"`
		LearningDays *int    `yaml:"learning_days"`
	} `yaml:"session"`
	Pools  map[string][]string `yaml:"pools"`
	Unlock *struct {
		TopicRatio  *float64  `yaml:"topic_ratio"`
		TopicCounts *[]string `yaml:"topic_counts"`
		HardRatio   *float64  `yaml:"hard_ratio"`
	} `yaml:"unlock"`
	Sm2 *struct {
		FirstIntervals *[]int   `yaml:"first_intervals"`
		StartEase      *float64 `yaml:"start_ease"`
		MinEase        *float64 `yaml:"min_ease"`
		MaxInterval    *int     `yaml:"max_interval"`
	} `yaml:"sm2"`
	Display *struct {
		HeatmapWeeks *int `yaml:"heatmap_weeks"`
	} `yaml:"display"`
}

// slotList reads `slots:` as a map of letter => pool.
type slotList []Slot

func (s *slotList) UnmarshalYAML(n *yaml.Node) error {
	if n.Kind != yaml.MappingNode {
		return fmt.Errorf("line %d: slots should be a map of letter: pool", n.Line)
	}
	for i := 0; i+1 < len(n.Content); i += 2 {
		*s = append(*s, Slot{Letter: n.Content[i].Value, Pool: n.Content[i+1].Value})
	}
	return nil
}

// LoadConfig reads path; a missing file means the defaults.
func LoadConfig(path string) (Config, error) {
	data, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return DefaultConfig(), nil
	}
	if err != nil {
		return Config{}, err
	}
	return ParseConfig(data, path)
}

// ParseConfig applies the settings in data over the defaults. source names the
// file in error messages.
func ParseConfig(data []byte, source string) (Config, error) {
	var root yaml.Node
	if err := yaml.Unmarshal(data, &root); err != nil {
		return Config{}, fmt.Errorf("%s: %w", source, err)
	}
	if root.Kind == 0 { // empty file
		return DefaultConfig(), nil
	}
	if err := checkSettings(root.Content[0], settingNames, nil, source); err != nil {
		return Config{}, err
	}
	var o overrides
	if err := root.Decode(&o); err != nil {
		return Config{}, fmt.Errorf("%s: %w", source, err)
	}
	config := o.applyTo(DefaultConfig())
	if problems := config.errors(); len(problems) > 0 {
		return Config{}, fmt.Errorf("%s:\n  %s", source, strings.Join(problems, "\n  "))
	}
	return config, nil
}

// checkSettings refuses setting names it doesn't know, so a typo can't be silently ignored.
func checkSettings(node *yaml.Node, known map[string]any, path []string, source string) error {
	if node.Kind == yaml.ScalarNode && node.Tag == "!!null" { // `session:` with nothing under it
		return nil
	}
	if node.Kind != yaml.MappingNode {
		return fmt.Errorf("%s: `%s` should be a map of settings", source, strings.Join(path, "."))
	}
	for i := 0; i+1 < len(node.Content); i += 2 {
		key := node.Content[i].Value
		here := append(slices.Clone(path), key)
		sub, ok := known[key]
		if !ok {
			return fmt.Errorf("%s: unknown setting `%s`", source, strings.Join(here, "."))
		}
		if section, isSection := sub.(map[string]any); isSection {
			if err := checkSettings(node.Content[i+1], section, here, source); err != nil {
				return err
			}
		}
	}
	return nil
}

func (o overrides) applyTo(c Config) Config {
	if s := o.Session; s != nil {
		if s.Slots != nil {
			c.Session.Slots = slices.Clone(*s.Slots)
			slices.SortFunc(c.Session.Slots, func(a, b Slot) int { return strings.Compare(a.Letter, b.Letter) })
		}
		if b := s.Bonus; b != nil {
			set(&c.Session.Bonus.Pool, b.Pool)
			set(&c.Session.Bonus.UnlockOn, b.UnlockOn)
			set(&c.Session.Bonus.Max, b.Max)
		}
		set(&c.Session.NewEveryDays, s.NewEveryDays)
		set(&c.Session.ReviewOrder, s.ReviewOrder)
		set(&c.Session.LearningDays, s.LearningDays)
	}
	if o.Pools != nil {
		c.Pools = o.Pools
	}
	if u := o.Unlock; u != nil {
		set(&c.Unlock.TopicRatio, u.TopicRatio)
		set(&c.Unlock.TopicCounts, u.TopicCounts)
		set(&c.Unlock.HardRatio, u.HardRatio)
	}
	if m := o.Sm2; m != nil {
		if m.FirstIntervals != nil {
			// Wrong length is reported by errors(); keep the first two numbers to compare.
			c.Sm2.FirstIntervals = [2]int{}
			copy(c.Sm2.FirstIntervals[:], *m.FirstIntervals)
			if len(*m.FirstIntervals) != 2 {
				c.Sm2.FirstIntervals = [2]int{-1, -1}
			}
		}
		set(&c.Sm2.StartEase, m.StartEase)
		set(&c.Sm2.MinEase, m.MinEase)
		if m.MaxInterval != nil {
			c.Sm2.MaxInterval = *m.MaxInterval
			if c.Sm2.MaxInterval < 1 {
				c.Sm2.MaxInterval = -1 // reported by errors()
			}
		}
	}
	if d := o.Display; d != nil {
		set(&c.Display.HeatmapWeeks, d.HeatmapWeeks)
	}
	return c
}

func set[T any](dst *T, src *T) {
	if src != nil {
		*dst = *src
	}
}

// errors lists every problem with the settings, so one run reports them all.
func (c Config) errors() []string {
	var errs []string
	add := func(format string, args ...any) { errs = append(errs, fmt.Sprintf(format, args...)) }

	for name, diffs := range c.Pools {
		if len(diffs) == 0 || !subset(diffs, difficulties) {
			add("pools.%s must list difficulties from %s", name, strings.Join(difficulties, ", "))
		}
	}
	if len(c.Session.Slots) == 0 {
		add("session.slots needs at least one slot")
	}
	for _, slot := range c.Session.Slots {
		if len(slot.Letter) != 1 || slot.Letter[0] < 'A' || slot.Letter[0] > 'Z' {
			add("session.slots: `%s` must be one capital letter", slot.Letter)
		}
		if _, ok := c.Pools[slot.Pool]; !ok {
			add("session.slots.%s: no pool named `%s`", slot.Letter, slot.Pool)
		}
	}
	bonus := c.Session.Bonus
	if _, ok := c.Pools[bonus.Pool]; !ok {
		add("session.bonus.pool: no pool named `%s`", bonus.Pool)
	}
	if !subset(bonus.UnlockOn, grades) {
		add("session.bonus.unlock_on must list grades from %s", strings.Join(grades, ", "))
	}
	if bonus.Max < 0 {
		add("session.bonus.max must be 0 or more")
	}
	if c.Session.NewEveryDays < 1 {
		add("session.new_every_days must be 1 or more")
	}
	if c.Session.ReviewOrder != ReviewMostOverdue && c.Session.ReviewOrder != ReviewLearningFirst {
		add("session.review_order must be one of %s, %s", ReviewMostOverdue, ReviewLearningFirst)
	}
	if c.Session.LearningDays < 1 {
		add("session.learning_days must be 1 or more")
	}
	if r := c.Unlock.TopicRatio; r < 0 || r > 1 {
		add("unlock.topic_ratio must be between 0 and 1")
	}
	if r := c.Unlock.HardRatio; r < 0 || r > 1 {
		add("unlock.hard_ratio must be between 0 and 1")
	}
	if !subset(c.Unlock.TopicCounts, difficulties) {
		add("unlock.topic_counts must list difficulties from %s", strings.Join(difficulties, ", "))
	}
	if first := c.Sm2.FirstIntervals; first[0] < 1 || first[1] < 1 {
		add("sm2.first_intervals must be two whole numbers of days, like [1, 6]")
	}
	if c.Sm2.MinEase <= 1 {
		add("sm2.min_ease must be a number above 1")
	}
	if c.Sm2.StartEase < c.Sm2.MinEase {
		add("sm2.start_ease must be at least sm2.min_ease")
	}
	if c.Sm2.MaxInterval < 0 {
		add("sm2.max_interval must be empty or 1 or more")
	}
	if c.Display.HeatmapWeeks < 1 {
		add("display.heatmap_weeks must be 1 or more")
	}
	return errs
}

// subset reports whether every item is one of allowed.
func subset(items, allowed []string) bool {
	for _, item := range items {
		if !slices.Contains(allowed, item) {
			return false
		}
	}
	return true
}

// DailyLetters are the letters of the daily slots, in order.
func (c Config) DailyLetters() []string {
	letters := make([]string, len(c.Session.Slots))
	for i, s := range c.Session.Slots {
		letters[i] = s.Letter
	}
	return letters
}

// PoolOfSlot is the pool a daily slot draws from.
func (c Config) PoolOfSlot(letter string) string {
	for _, s := range c.Session.Slots {
		if s.Letter == letter {
			return s.Pool
		}
	}
	return ""
}

// SlotOfPool is the first daily slot drawing from pool.
func (c Config) SlotOfPool(pool string) string {
	for _, s := range c.Session.Slots {
		if s.Pool == pool {
			return s.Letter
		}
	}
	return ""
}
