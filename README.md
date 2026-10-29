# dsa

NeetCode 150 practice in Go, with a spaced-repetition tool that decides what to do each day.

```sh
go build -o bin/srs ./cmd/srs   # once (Go 1.23+)
bin/srs today                   # what to do today
bin/srs start A                 # create the files for slot A
go test ./arrays_and_hashing/easy/contains_duplicate    # run the tests it points you to
bin/srs grade A good            # record how it went
```

How it works and every command: [srs/README.md](srs/README.md). The design and the reasoning
behind it: [srs/DESIGN.md](srs/DESIGN.md).

Solutions live in `<topic>/<difficulty>/<problem>/`, one Go package per problem. Reviews are done on a
blank copy under `attempts/`, so your original solution is never overwritten.
