# frozen_string_literal: true

module Srs
  # Command dispatch for bin/srs.
  module CLI
    USAGE = <<~TEXT
      usage: bin/srs <command>

        today                show today's problems (slot A = Easy, B = Medium/Hard)
        start <slot>         create the file to work in (new: scaffold, review: name.attempt.rb)
        grade <slot> <how>   how = again | hard | good | easy  (`easy` unlocks slot C)
        more                 all done? get an extra new problem (slots D, E, …)
        status               coverage per topic, what's due
        setup                build srs/problems.yml and seed srs/state.yml (safe to re-run)
    TEXT

    module_function

    def run(argv)
      command, *args = argv
      case command
      when 'today' then Commands.new.today
      when 'start' then Commands.new.start(slot(args[0]))
      when 'grade' then Commands.new.grade(slot(args[0]), args[1].to_s.downcase)
      when 'more' then Commands.new.more
      when 'status' then Commands.new.status
      when 'setup' then Setup.new.run
      when nil, 'help', '-h', '--help' then puts USAGE
      else raise Error, "Unknown command: #{command}\n\n#{USAGE}"
      end
    rescue Error => e
      abort e.message
    end

    def slot(arg)
      slot = arg.to_s.upcase
      raise Error, "Slot must be a letter like A, B, C, D.\n\n#{USAGE}" unless slot.match?(/\A[A-Z]\z/)

      slot
    end
  end
end
