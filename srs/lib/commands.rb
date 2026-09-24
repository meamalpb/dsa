# frozen_string_literal: true

module Srs
  # `today`, `start`, `grade`, `status` — DESIGN.md §7–10.
  class Commands
    def initialize(today: Srs.today, out: $stdout, input: $stdin)
      raise Error, 'Run `bin/srs setup` first.' unless File.exist?(PROBLEMS_PATH)

      @problems = Store.load(PROBLEMS_PATH, {})
      @state = Store.load(STATE_PATH, Store.default_state)
      @today = today
      @out = out
      @in = input
      @scheduler = Scheduler.new(@problems, @state, today)
    end

    def today
      session = @scheduler.session
      save
      @out.puts "#{@today} — #{session['slots'].size} problems"
      session['slots'].sort.each { |slot, entry| show(slot, entry) }
      @out.puts "\nGrade any of these `easy` to unlock a 3rd problem (slot C)." unless session['bonus_unlocked']
      @out.puts "\nDone with all of them? `bin/srs more` gives you a new problem." if @scheduler.all_graded?
    end

    # Add another new problem to today's session (only once everything is graded).
    def more
      @scheduler.session
      raise Error, 'Finish and grade today\'s problems first.' unless @scheduler.all_graded?

      added = @scheduler.add_extra_new
      save
      return @out.puts('No new problem is eligible right now.') unless added

      @out.puts 'Extra problem:'
      show(*added)
    end

    def start(slot)
      entry = slot_entry(slot)
      problem = @problems[entry['slug']]
      file = problem['file']
      if entry['kind'] == 'new'
        created = Scaffold.create_new(file, entry['slug'])
        @out.puts "#{created ? 'Created' : 'Already exists'}: #{file}"
      else
        created = Scaffold.create_attempt(file)
        @out.puts "#{created ? 'Created' : 'Already exists'}: #{Scaffold.attempt_path(file)}"
        @out.puts "(your original stays untouched: #{file})"
      end
      @out.puts problem['link']
      @out.puts "free version: #{problem['alt_link']}" if problem['alt_link']
      save
    end

    def grade(slot, grade)
      raise Error, "Grade must be one of: #{Sm2::QUALITY.keys.join(', ')}" unless Sm2::QUALITY.key?(grade)

      entry = slot_entry(slot)
      raise Error, "Slot #{slot} is already graded (#{entry['grade']})." if entry['grade']

      slug = entry['slug']
      card = Sm2.review(@state['problems'][slug] || Sm2.new_card, grade, @today)
      @state['problems'][slug] = card
      entry['grade'] = grade
      record_new(slot, entry) if entry['kind'] == 'new'
      @out.puts "#{@problems[slug]['name']}: #{grade} — next review #{card['next_review']} " \
                "(in #{card['interval']}d, ease #{card['ease']})"
      unlock_bonus if grade == 'easy'
      save
      offer_attempt_cleanup(@problems[slug]['file']) unless entry['kind'] == 'new'
      offer_more
    end

    def status
      Report.coverage(@problems, @state, @out)
      cards = @state['problems'].select { |slug, _| @problems.key?(slug) }.values
      due = cards.count { |c| c['next_review'] <= @today }
      week = cards.count { |c| c['next_review'] > @today && c['next_review'] <= @today + 7 }
      last = @state['last_new_on']
      @out.puts "\nSeen #{cards.size}/#{@problems.size} · due now #{due} · due in the next 7 days #{week}"
      @out.puts "Last new problem: #{last ? "#{last} (#{(@today - last).to_i}d ago)" : 'none yet'}"
      days = Charts.activity(@state['problems'].values)
      @out.puts "\nActivity, last #{Charts::WEEKS} weeks"
      @out.puts Charts.heatmap(days, @today)
      @out.puts Charts.summary(days, @today)
    end

    private

    def save
      Store.save(STATE_PATH, @state)
    end

    def slot_entry(slot)
      entry = @scheduler.session['slots'][slot]
      if entry.nil?
        raise Error, 'No slot C today — grade a problem `easy` to unlock it.' if slot == 'C'

        raise Error, "No slot #{slot} today."
      end
      raise Error, "Slot #{slot} is empty today." unless entry['slug']

      entry
    end

    # A graded new problem resets the 3-day clock; a forced one also hands the
    # next forced pick to the other pool.
    def record_new(slot, entry)
      @state['last_new_on'] = @today
      @state['next_forced_pool'] = Scheduler.other_pool(Scheduler::SLOT_POOLS[slot]) if entry['forced']
    end

    def unlock_bonus
      return if @state['session']['bonus_unlocked']

      @scheduler.unlock_bonus
      @out.puts "\nBonus unlocked:"
      show('C', @state['session']['slots']['C'])
    end

    def offer_more
      return unless @scheduler.all_graded?

      @out.print "\nAll of today's problems are done. Try a new one? [y/N] "
      more if @in.gets.to_s.strip.downcase.start_with?('y')
    end

    def offer_attempt_cleanup(file)
      attempt = Scaffold.attempt_path(file)
      return unless File.exist?(File.join(ROOT, attempt))

      @out.puts "Compare with your original: #{file}"
      @out.print "Delete #{attempt}? [Y/n] "
      answer = @in.gets.to_s.strip.downcase
      return @out.puts('Kept.') unless answer.empty? || answer.start_with?('y')

      File.delete(File.join(ROOT, attempt))
      @out.puts 'Deleted.'
    end

    def show(slot, entry)
      SlotPrinter.new(@problems, @state, @today, @out).show(slot, entry)
    end
  end
end
