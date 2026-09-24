# frozen_string_literal: true

module Srs
  # Text charts for `status`. Pure functions: data in, strings out.
  module Charts
    module_function

    BAR_WIDTH = 10
    WEEKS = 26
    GLYPHS = %w[· ░ ▒ █].freeze

    # ratio is 0.0..1.0
    def bar(ratio, width: BAR_WIDTH)
      filled = (ratio.clamp(0.0, 1.0) * width).round
      ('█' * filled) + ('░' * (width - filled))
    end

    # Gradings per day, excluding the `seed` entries created at setup.
    def activity(cards)
      cards.each_with_object(Hash.new(0)) do |card, days|
        card.fetch('history', []).each { |h| days[h['date']] += 1 unless h['grade'] == 'seed' }
      end
    end

    def level(count)
      case count
      when 0 then 0
      when 1 then 1
      when 2..3 then 2
      else 3
      end
    end

    def heatmap(days, today, weeks: WEEKS)
      first = today - ((today.cwday - 1) + (7 * (weeks - 1))) # Monday of the first column
      columns = (0...weeks).map { |w| first + (7 * w) }
      lines = [month_header(columns)]
      %w[Mon _ Wed _ Fri _ Sun].each_with_index do |label, row|
        cells = columns.map do |monday|
          day = monday + row
          day > today ? '  ' : "#{GLYPHS[level(days[day])]} "
        end
        lines << "#{(label == '_' ? '' : label).ljust(4)}#{cells.join}"
      end
      lines.join("\n")
    end

    def month_header(columns)
      line = String.new
      last = nil
      columns.each_with_index do |monday, i|
        next if monday.month == last

        last = monday.month
        next if i.zero? && columns[1].month != monday.month # a stub week, no room for its label
        next if line.length > i * 2 # previous label still overhangs this column

        line << (' ' * ((i * 2) - line.length)) << monday.strftime('%b')
      end
      "    #{line}"
    end

    # [current, longest]. The current streak survives a day with no grading
    # until that day is over, so it is not reset at midnight.
    def streaks(days, today)
      active = days.select { |_, n| n.positive? }.keys.sort
      longest = 0
      run = 0
      prev = nil
      active.each do |d|
        run = prev && d == prev + 1 ? run + 1 : 1
        longest = [longest, run].max
        prev = d
      end

      day = days[today].positive? ? today : today - 1
      current = 0
      while days[day].positive?
        current += 1
        day -= 1
      end
      [current, longest]
    end

    def summary(days, today)
      current, longest = streaks(days, today)
      total = days.values.sum
      "streak #{current}d · longest #{longest}d · #{total} gradings · #{days.count { |_, n| n.positive? }} active days"
    end
  end
end
