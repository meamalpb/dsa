# frozen_string_literal: true

module Srs
  # SM-2 scheduling — DESIGN.md §5.
  module Sm2
    QUALITY = { 'again' => 1, 'hard' => 3, 'good' => 4, 'easy' => 5 }.freeze
    MIN_EASE = 1.3

    module_function

    def new_card
      { 'reps' => 0, 'ease' => 2.5, 'interval' => 0, 'history' => [] }
    end

    # Returns the updated card; doesn't modify the one passed in.
    def review(card, grade, today)
      q = QUALITY.fetch(grade)
      ease = [MIN_EASE, card['ease'] + 0.1 - ((5 - q) * (0.08 + ((5 - q) * 0.02)))].max.round(2)
      reps, interval = q < 3 ? [0, 1] : next_interval(card['reps'] + 1, card['interval'], ease)

      card.merge(
        'reps' => reps, 'ease' => ease, 'interval' => interval,
        'last_reviewed' => today, 'next_review' => today + interval,
        'history' => card.fetch('history', []) + [{ 'date' => today, 'grade' => grade }]
      )
    end

    def next_interval(reps, previous, ease)
      case reps
      when 1 then [reps, 1]
      when 2 then [reps, 6]
      else [reps, (previous * ease).round]
      end
    end
  end
end
