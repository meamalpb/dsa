# frozen_string_literal: true

module Srs
  # Command dispatch for bin/srs.
  module CLI
    USAGE = <<~TEXT
      usage: bin/srs <command>

        today                show today's problems (slot A = Easy, B = Medium/Hard)
        start <slot>         create the file to work in (new: scaffold, review: name.attempt.rb)
        grade <slot> <how>   how = again | hard | good | easy  (`easy` unlocks slot C)
        more [new|old]       all done? get an extra problem (slots D, E, …):
                             new (default) = next new problem, old = most overdue review
        status               coverage per topic, what's due
        overdue              list every overdue problem, most overdue first
        setup                build srs/problems.yml and seed srs/state.yml (safe to re-run)
    TEXT

    module_function

    def run(argv)
      command, *args = argv
      case command
      when 'today' then Commands.new.today
      when 'start' then Commands.new.start(slot(args[0]))
      when 'grade' then Commands.new.grade(slot(args[0]), args[1].to_s.downcase)
      when 'more' then Commands.new.more(more_kind(args[0]))
      when 'status' then Commands.new.status
      when 'overdue' then Commands.new.overdue
      when 'setup' then Setup.new.run
      when nil, 'help', '-h', '--help' then puts USAGE
      else raise Error, "Unknown command: #{command}\n\n#{USAGE}"
      end
    rescue Error => e
      abort e.message
    end

    def more_kind(arg)
      kind = (arg || 'new').downcase
      raise Error, "more takes `new` or `old`.\n\n#{USAGE}" unless %w[new old].include?(kind)

      kind
    end

    def slot(arg)
      slot = arg.to_s.upcase
      raise Error, "Slot must be a letter like A, B, C, D.\n\n#{USAGE}" unless slot.match?(/\A[A-Z]\z/)

      slot
    end
  end
end
