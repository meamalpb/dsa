# frozen_string_literal: true

module Srs
  # Command dispatch for bin/srs.
  module CLI
    USAGE = <<~TEXT
      usage: bin/srs <command>

        today                show today's problems (slot A = Easy, B = Medium/Hard)
        start <slot>         create the file to work in (new: scaffold, review: name.attempt.rb)
        start <file|slug>    practice a problem you pick, e.g. linked_list/medium/reorder_list.rb:
                             adds it as an extra slot today, graded like any other
        grade <slot> <how>   how = again | hard | good | easy  (`easy` unlocks slot C)
        more [new|old] [easy|medium|hard|all]
                             all done? get an extra problem (slots D, E, …):
                             new (default) = next new problem, old = most overdue review;
                             easy/medium/hard limits the difficulty (all = any, default)
        status               coverage per topic, what's due
        overdue              list every overdue problem, most overdue first
        setup                build srs/problems.yml and seed srs/state.yml (safe to re-run)

      java <command>       the same commands for Java, e.g. `bin/srs java today`: your problems solved in
                           Ruby, practiced again in Java, with its own state (srs/state.java.yml).
                           `bin/srs java start linked_list/medium/reorder_list.rb` makes the Java file
                           for that Ruby file. No `setup` there; it uses the Ruby setup's problems.yml.

      sql <command>        the same commands for LeetCode's Top SQL 50 in PostgreSQL, with its own
                           state (srs/state.sql.yml). Every problem file is already in database/ with
                           its tables and expected results; write your query at the bottom, then:
        sql run <slot|file>  run it on the file's test cases and compare (needs psql + a running
                             server; database `postgres`, or set SRS_PGDATABASE)
    TEXT

    module_function

    def run(argv)
      command, *args = track_and_command(argv)
      case command
      when 'today' then Commands.new.today
      when 'start' then start(args[0].to_s)
      when 'grade' then Commands.new.grade(slot(args[0]), args[1].to_s.downcase)
      when 'more' then Commands.new.more(*more_options(args))
      when 'run' then Commands.new.run(run_target(args[0]))
      when 'status' then Commands.new.status
      when 'overdue' then Commands.new.overdue
      when 'setup' then setup
      when nil, 'help', '-h', '--help' then puts USAGE
      else raise Error, "Unknown command: #{command}\n\n#{USAGE}"
      end
    rescue Error => e
      abort e.message
    end

    TRACKS = { 'java' => JAVA_TRACK, 'sql' => SQL_TRACK }.freeze

    # `java` or `sql` in front switches the track; everything after it is the usual command.
    def track_and_command(argv)
      return argv unless TRACKS.key?(argv.first)

      Srs.track = TRACKS.fetch(argv.first)
      argv.drop(1)
    end

    def setup
      raise Error, 'setup builds problems.yml, which the Java track shares: run `bin/srs setup`.' if Srs.track.java?
      raise Error, 'The SQL track needs no setup: its list is srs/problems.sql.yml.' if Srs.track.sql?

      Setup.new.run
    end

    KINDS = %w[new old].freeze
    DIFFICULTIES = %w[easy medium hard all].freeze

    # `more` words in any order, e.g. `more old easy` or `more medium`: [kind, difficulty or nil].
    def more_options(args)
      words = args.map(&:downcase)
      unknown = words - KINDS - DIFFICULTIES
      kinds = words & KINDS
      diffs = words & DIFFICULTIES
      if unknown.any? || kinds.size > 1 || diffs.size > 1
        raise Error, "more takes new|old and easy|medium|hard|all, one of each at most.\n\n#{USAGE}"
      end

      difficulty = diffs.first
      [kinds.first || 'new', difficulty.nil? || difficulty == 'all' ? nil : difficulty.capitalize]
    end

    def run_target(arg)
      raise Error, "run needs a slot letter or a file.\n\n#{USAGE}" if arg.to_s.empty?

      arg
    end

    # A single letter is a slot; anything longer is a problem's file or slug.
    def start(arg)
      arg.length > 1 ? Commands.new.practice(arg) : Commands.new.start(slot(arg))
    end

    def slot(arg)
      slot = arg.to_s.upcase
      raise Error, "Slot must be a letter like A, B, C, D.\n\n#{USAGE}" unless slot.match?(/\A[A-Z]\z/)

      slot
    end
  end
end
