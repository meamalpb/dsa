// Command srs is the spaced-repetition CLI over the NeetCode 150: see srs/README.md.
package main

import (
	"fmt"
	"os"

	"dsa/internal/srs"
)

func main() {
	if err := srs.Run(os.Args[1:], srs.LoadEnv, os.Stdin, os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
