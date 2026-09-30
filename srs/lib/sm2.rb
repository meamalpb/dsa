# frozen_string_literal: true

module Srs
  # SM-2 scheduling — DESIGN.md §5. Intervals and ease limits come from srs/config.yml (sm2).
  module Sm2
    QUALITY = { 'again' => 1, 'hard' => 3, 'good' => 4, 'easy' => 5 }.freeze

    module_function

    def new_card(sm2 = Srs.config['sm2'])
      { 'reps' => 0, 'ease' => sm2['start_ease'], 'interval' => 0, 'history' => [] }
    end

    # Returns the updated card; doesn't modify the one passed in.
    def review(card, grade, today, sm2 = Srs.config['sm2'])
      q = QUALITY.fetch(grade)
      ease = [sm2['min_ease'], card['ease'] + 0.1 - ((5 - q) * (0.08 + ((5 - q) * 0.02)))].max.round(2)
      reps, interval = if q < 3 then [0, sm2['first_intervals'][0]]
                       else next_interval(card['reps'] + 1, card['interval'], ease, sm2)
                       end
      interval = [interval, sm2['max_interval']].min if sm2['max_interval']

      card.merge(
        'reps' => reps, 'ease' => ease, 'interval' => interval,
        'last_reviewed' => today, 'next_review' => today + interval,
        'history' => card.fetch('history', []) + [{ 'date' => today, 'grade' => grade }]
      )
    end

    def next_interval(reps, previous, ease, sm2 = Srs.config['sm2'])
      first, second = sm2['first_intervals']
      case reps
      when 1 then [reps, first]
      when 2 then [reps, second]
      else [reps, (previous * ease).round]
      end
    end
  end
end
