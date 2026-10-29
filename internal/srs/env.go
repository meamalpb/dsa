package srs

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
)

// Env is where the data lives and what day it is.
type Env struct {
	Root         string // the repo root; solution paths are relative to it
	ProblemsPath string
	StatePath    string
	ConfigPath   string
	Today        Date
}

// LoadEnv finds the repo from the current folder (or SRS_ROOT) and applies the overrides
// that let you try things without touching your real history:
//
//	SRS_STATE=/tmp/try.yml SRS_TODAY=2026-10-01 srs today
//	SRS_CONFIG=/tmp/my.yml srs today
func LoadEnv() (Env, error) {
	root := os.Getenv("SRS_ROOT")
	if root == "" {
		wd, err := os.Getwd()
		if err != nil {
			return Env{}, err
		}
		if root, err = findRoot(wd); err != nil {
			return Env{}, err
		}
	}
	env := Env{
		Root:         root,
		ProblemsPath: filepath.Join(root, "srs", "problems.yml"),
		StatePath:    envOr("SRS_STATE", filepath.Join(root, "srs", "state.yml")),
		ConfigPath:   envOr("SRS_CONFIG", filepath.Join(root, "srs", "config.yml")),
		Today:        Today(),
	}
	if value := os.Getenv("SRS_TODAY"); value != "" {
		date, err := ParseDate(value)
		if err != nil {
			return Env{}, fmt.Errorf("SRS_TODAY: %w", err)
		}
		env.Today = date
	}
	return env, nil
}

// findRoot walks up from dir to the folder with go.mod and srs/, like git finds .git.
func findRoot(dir string) (string, error) {
	for {
		if exists(filepath.Join(dir, "go.mod")) && exists(filepath.Join(dir, "srs")) {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", errors.New("can't find the repo: run srs from inside it, or set SRS_ROOT")
		}
		dir = parent
	}
}

func envOr(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}
