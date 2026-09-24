# frozen_string_literal: true

module Srs
  # Prints one day slot for `today` and `grade`.
  class SlotPrinter
    LABELS = { 'new' => 'NEW', 'review' => 'REVIEW', 'early' => 'EARLY' }.freeze

    def initialize(problems, state, today, out)
      @problems = problems
      @state = state
      @today = today
      @out = out
    end

    def show(slot, entry)
      @out.puts
      return @out.puts("#{slot}  nothing eligible in this pool today") unless entry['slug']

      problem = @problems[entry['slug']]
      graded = entry['grade'] ? "  ✓ #{entry['grade']}" : ''
      @out.puts "#{slot}  #{LABELS[entry['kind']].ljust(6)}  #{problem['name']} · #{problem['difficulty']} · " \
                "#{problem['topic']}#{graded}"
      detail = detail(entry)
      @out.puts "   #{detail}" if detail
      @out.puts "   #{problem['link']}"
      @out.puts "   free version: #{problem['alt_link']}" if problem['alt_link']
      @out.puts "   #{file_line(slot, entry, problem['file'])}"
      @out.puts "   notes: #{problem['notes']}" if problem['notes']
    end

    private

    def detail(entry)
      card = @state['problems'][entry['slug']]
      return "next review #{card['next_review']}" if entry['grade']
      return (entry['forced'] ? 'no new problem in 3 days, so this one is required' : nil) if entry['kind'] == 'new'

      due = (card['next_review'] - @today).to_i
      timing = if due.negative? then "#{-due}d overdue"
               elsif due.zero? then 'due today'
               else "due in #{due}d — nothing due in this pool, so reviewing early"
               end
      "last done #{(@today - card['last_reviewed']).to_i}d ago, #{timing}"
    end

    def file_line(slot, entry, file)
      if entry['kind'] == 'new'
        File.exist?(File.join(ROOT, file)) ? file : "#{file}  (run `bin/srs start #{slot}`)"
      else
        attempt = Scaffold.attempt_path(file)
        return "#{attempt}  (original: #{file})" if File.exist?(File.join(ROOT, attempt))

        "#{file}  (run `bin/srs start #{slot}` for a blank attempt)"
      end
    end
  end
end
