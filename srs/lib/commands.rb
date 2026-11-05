# frozen_string_literal: true

module Srs
  # `today`, `start`, `grade`, `status` — DESIGN.md §7–10; `run` for SQL — §14.
  class Commands # rubocop:disable Metrics/ClassLength
    def initialize(today: Srs.today, out: $stdout, input: $stdin)
      @track = Srs.track
      raise Error, 'Run `bin/srs setup` first.' unless File.exist?(@track.problems_path)

      @problems = @track.problems(Store.load(@track.problems_path, {}))
      @state = Store.load(@track.state_path, Store.default_state)
      @scaffold = @track.scaffold(@problems)
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
      if @scheduler.bonus_left?
        @out.puts "\nGrade any of these #{bonus_grades} to unlock another problem (slot #{@scheduler.next_bonus_slot})."
      end
      return unless @scheduler.all_graded?

      @out.puts "\nDone with all of them? `#{@track.command} more` gives you a new problem, `#{@track.command} more old` a due review."
    end

    # Add another problem to today's session (only once everything is graded):
    # kind 'new' = next new problem, 'old' = most overdue review; difficulty ('Easy', …) or nil = any.
    def more(kind = 'new', difficulty = nil, topic = nil)
      @scheduler.session
      raise Error, 'Finish and grade today\'s problems first.' unless @scheduler.all_graded?

      added = if kind == 'old' then @scheduler.add_extra_review(difficulty, topic)
              else @scheduler.add_extra_new(difficulty, topic)
              end
      save
      return @out.puts(none_message(kind, difficulty, topic)) unless added

      @out.puts 'Extra problem:'
      show(*added)
    end

    def none_message(kind, difficulty, topic)
      what = [difficulty, topic && "#{topic} "].compact.join(' ').strip
      what = " #{what}" unless what.empty?
      return "Nothing#{what} is due for review." if kind == 'old'

      locked = topic && !Progress.new(@problems, @state).open?(topic)
      locked ? "#{topic} is locked (needs #{Topics.prereqs(topic).join(' + ')})." : "No new#{what} problem is eligible right now."
    end

    def start(slot)
      entry = slot_entry(slot)
      problem = @problems[entry['slug']]
      file = problem['file']
      if entry['kind'] == 'new'
        created = @scaffold.create_new(file, entry['slug'])
        if @track.sql?
          @out.puts "Write your query at the bottom of #{file}, then: #{@track.command} run #{slot}"
        else
          @out.puts "#{created ? 'Created' : 'Already exists'}: #{file}"
        end
      else
        created = @scaffold.create_attempt(file)
        @out.puts "#{created ? 'Created' : 'Already exists'}: #{@scaffold.attempt_path(file)}"
        @out.puts "(your original stays untouched: #{file})"
      end
      @out.puts problem['link']
      @out.puts "free version: #{problem['alt_link']}" if problem['alt_link']
      save
    end

    # `start <file or slug>`: practice a problem you pick. It gets a slot today (an extra one
    # unless it's already in the session) and is graded like any other.
    def practice(target)
      slug = find_slug(target)
      @scheduler.session
      slot, entry = @scheduler.add_chosen(slug)
      name = @problems[slug]['name']
      raise Error, "#{name} is slot #{slot} today, already graded (#{entry['grade']})." if entry['grade']

      @out.puts "#{name} is slot #{slot} — when done: #{@track.command} grade #{slot} again|hard|good|easy"
      start(slot)
    end

    def grade(slot, grade)
      raise Error, "Grade must be one of: #{Sm2::QUALITY.keys.join(', ')}" unless Sm2::QUALITY.key?(grade)

      entry = slot_entry(slot)
      raise Error, "Slot #{slot} is already graded (#{entry['grade']})." if entry['grade']

      slug = entry['slug']
      entry['grade'] = grade
      @scheduler.record_new(slot, entry) if entry['kind'] == 'new'

      if @track.one_pass?
        @state['problems'][slug] = { 'done_on' => @today }
        @out.puts "#{@problems[slug]['name']}: #{grade} — done"
      else
        card = Sm2.review(@state['problems'][slug] || Sm2.new_card, grade, @today)
        @state['problems'][slug] = card
        @out.puts "#{@problems[slug]['name']}: #{grade} — next review #{card['next_review']} " \
                  "(in #{card['interval']}d, ease #{card['ease']})"
        unlock_bonus if @scheduler.unlocks_bonus?(grade)
      end

      save
      offer_attempt_cleanup(@problems[slug]['file']) unless entry['kind'] == 'new'
      offer_more
    end

    # `sql run <slot|file|slug>`: check a query against its problem file's cases. A slot runs its
    # review attempt when there is one, else the problem's own file.
    def run(target)
      raise Error, '`run` checks SQL queries: bin/srs sql run <slot|file>' unless @track.sql?

      slot = target.match?(/\A[A-Za-z]\z/) ? target.upcase : nil
      file = slot ? slot_file(slot) : run_file(target)
      @out.puts "Running #{file}"
      passed = SqlRunner.new(out: @out).run(File.expand_path(file, ROOT))
      @out.puts "When done: #{@track.command} grade #{slot} again|hard|good|easy" if passed && slot
    end

    def status
      Report.coverage(@problems, @state, @out)
      if @track.one_pass?
        done = @state['problems'].count { |slug, _| @problems.key?(slug) }
        @out.puts "\nDone #{done}/#{@problems.size}"
        return
      end
      cards = @state['problems'].select { |slug, _| @problems.key?(slug) }.values
      due = cards.count { |c| c['next_review'] <= @today }
      week = cards.count { |c| c['next_review'] > @today && c['next_review'] <= @today + 7 }
      last = @state['last_new_on']
      @out.puts "\nSeen #{cards.size}/#{@problems.size} · due now #{due} · due in the next 7 days #{week}"
      @out.puts "Last new problem: #{last ? "#{last} (#{(@today - last).to_i}d ago)" : 'none yet'}"
      days = Charts.activity(@state['problems'].values)
      @out.puts "\nActivity, last #{Srs.config.dig('display', 'heatmap_weeks')} weeks"
      @out.puts Charts.heatmap(days, @today)
      @out.puts Charts.summary(days, @today)
    end

    def overdue
      return @out.puts('No reviews in the Java track — each problem is done once.') if @track.one_pass?

      Report.overdue(@problems, @state, @today, @out)
    end

    private

    def save
      Store.save(@track.state_path, @state)
    end

    def slot_file(slot)
      entry = slot_entry(slot)
      file = @problems[entry['slug']]['file']
      attempt = @scaffold.attempt_path(file)
      entry['kind'] != 'new' && File.exist?(File.join(ROOT, attempt)) ? attempt : file
    end

    # A slug, or any SQL file (relative to here or the repo root, or absolute) — attempts included.
    def run_file(target)
      return @problems[target]['file'] if @problems.key?(target)

      path = [File.expand_path(target), File.join(ROOT, target)].find { |p| File.file?(p) } or
        raise Error, "#{target}: no such file or problem slug."
      path.delete_prefix("#{ROOT}/")
    end

    def slot_entry(slot)
      entry = @scheduler.session['slots'][slot]
      if entry.nil?
        if @scheduler.bonus_slots.include?(slot)
          raise Error, "No slot #{slot} today — grade a problem #{bonus_grades} to unlock it."
        end

        raise Error, "No slot #{slot} today."
      end
      raise Error, "Slot #{slot} is empty today." unless entry['slug']

      entry
    end

    # A slug, or a problem's file (relative to here or the repo root, absolute, or its attempt file).
    # In the Java track the Ruby original works too.
    def find_slug(target)
      return target if @problems.key?(target)

      files = [File.expand_path(target), File.join(ROOT, target)].map do |path|
        @scaffold.original_path(path.delete_prefix("#{ROOT}/"))
      end
      slug, = @problems.find { |_, p| (files & [p['file'], p['ruby_file']]).any? }
      slug or raise Error, "#{target} isn't #{missing_where} — give its file (e.g. #{example_file}) or slug."
    end

    def missing_where
      return 'in the SQL 50 list' if @track.sql?

      @track.java? ? 'solved in Ruby' : 'on the sheet'
    end

    def example_file
      @track.sql? ? 'database/select/easy/big_countries.sql' : 'linked_list/medium/reorder_list.rb'
    end

    def unlock_bonus
      unlocked = @scheduler.unlock_bonus
      return unless unlocked

      @out.puts "\nBonus unlocked:"
      show(*unlocked)
    end

    def bonus_grades
      Array(Srs.config.dig('session', 'bonus', 'unlock_on')).map { |g| "`#{g}`" }.join(' or ')
    end

    def offer_more
      return unless @scheduler.all_graded?

      @out.print "\nAll of today's problems are done. Try a new one? [y/N] "
      more if @in.gets.to_s.strip.downcase.start_with?('y')
    end

    def offer_attempt_cleanup(file)
      attempt = @scaffold.attempt_path(file)
      return unless File.exist?(File.join(ROOT, attempt))

      @out.puts "Compare with your original: #{file}"
      @out.print "Delete #{attempt}? [Y/n] "
      answer = @in.gets.to_s.strip.downcase
      return @out.puts('Kept.') unless answer.empty? || answer.start_with?('y')

      File.delete(File.join(ROOT, attempt))
      @out.puts 'Deleted.'
    end

    def show(slot, entry)
      SlotPrinter.new(@problems, @state, @today, @out, scaffold: @scaffold).show(slot, entry)
    end
  end
end
