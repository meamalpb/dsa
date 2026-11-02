# frozen_string_literal: true

module Srs
  # Files for `sql start` — DESIGN.md §14. Every problem file already exists (tables, cases and
  # expected results, with an empty spot for the query), so a new problem needs nothing.
  # A review attempt is the same file with the query cut off: name.attempt.sql (gitignored).
  module SqlScaffold
    module_function

    def attempt_path(file)
      file.sub(/\.sql\z/, '.attempt.sql')
    end

    # What a path given to `start` or `run` means: the problem's own file, not its attempt.
    def original_path(file)
      file.sub(/\.attempt\.sql\z/, '.sql')
    end

    # Returns false: the file is part of the repo, there's nothing to create.
    def create_new(file, _slug)
      return false if File.exist?(File.join(ROOT, file))

      raise Error, "#{file} is missing — bring it back with `git checkout -- #{file}`."
    end

    def create_attempt(file)
      original = File.read(File.join(ROOT, file))
      Scaffold.write_unless_exists(attempt_path(file)) { blank(original) }
    end

    # Everything up to and including the query marker line.
    def blank(source)
      marker = source.lines.index { |line| line.match?(SqlRunner::MARKER) } or
        raise Error, 'no `-- Your query below this line` marker in the problem file'
      "#{source.lines[0..marker].join}\n"
    end
  end
end
