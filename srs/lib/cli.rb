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
    TEXT

    module_function

    def run(argv)
      command, *args = argv
      case command
      when 'today' then Commands.new.today
      when 'start' then start(args[0].to_s)
      when 'grade' then Commands.new.grade(slot(args[0]), args[1].to_s.downcase)
      when 'more' then Commands.new.more(*more_options(args))
      when 'status' then Commands.new.status
      when 'overdue' then Commands.new.overdue
      when 'setup' then Setup.new.run
      when nil, 'help', '-h', '--help' then puts USAGE
      else raise Error, "Unknown command: #{command}\n\n#{USAGE}"
      end
    rescue Error => e
      abort e.message
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
