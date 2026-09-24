# frozen_string_literal: true

module Srs
  # Picks today's problems — DESIGN.md §7.
  class Scheduler
    POOLS = { 'easy' => %w[Easy], 'medium_hard' => %w[Medium Hard] }.freeze
    SLOT_POOLS = { 'A' => 'easy', 'B' => 'medium_hard', 'C' => 'easy' }.freeze
    FORCE_NEW_AFTER = 3 # days

    def self.other_pool(pool)
      (POOLS.keys - [pool]).first
    end

    def initialize(problems, state, today)
      @problems = problems
      @state = state
      @today = today
      @progress = Progress.new(problems, state)
    end

    # Today's session, built on first call of the day and then reused as-is.
    def session
      current = @state['session']
      return current if current && current['date'] == @today

      @state['session'] = { 'date' => @today, 'bonus_unlocked' => false, 'slots' => {} }
      force_new if new_problem_overdue?
      %w[A B].each { |slot| slots[slot] ||= pick(slot) }
      @state['session']
    end

    def unlock_bonus
      session['bonus_unlocked'] = true
      slots['C'] ||= pick('C')
    end

    def new_problem_overdue?
      last = @state['last_new_on']
      last.nil? || (@today - last) >= FORCE_NEW_AFTER
    end

    private

    def slots
      @state['session']['slots']
    end

    # Rule 1: put a new problem in next_forced_pool's slot, or the other one if
    # that pool has nothing eligible.
    def force_new
      first = @state['next_forced_pool']
      pool, slug = [first, self.class.other_pool(first)].lazy.map { |p| [p, next_new(p)] }.find { |_, s| s }
      slots[SLOT_POOLS.key(pool)] = entry(slug, 'new', forced: true) if slug
    end

    # Rules 2–5: due review, new problem, early review, empty.
    def pick(slot)
      pool = SLOT_POOLS.fetch(slot)
      if (slug = due_review(pool)) then entry(slug, 'review')
      elsif (slug = next_new(pool)) then entry(slug, 'new')
      elsif (slug = early_review(pool)) then entry(slug, 'early')
      else entry(nil, nil)
      end
    end

    def entry(slug, kind, forced: false)
      { 'slug' => slug, 'kind' => kind, 'forced' => forced, 'grade' => nil }
    end

    def picked?(slug)
      slots.values.any? { |e| e['slug'] == slug }
    end

    def in_pool?(slug, pool)
      POOLS.fetch(pool).include?(@problems.dig(slug, 'difficulty'))
    end

    def reviews(pool)
      @state['problems'].select { |slug, _| @problems.key?(slug) && in_pool?(slug, pool) && !picked?(slug) }
    end

    # Earliest next_review first = most overdue first.
    def due_review(pool)
      earliest(reviews(pool).select { |_, card| card['next_review'] <= @today })
    end

    def early_review(pool)
      earliest(reviews(pool))
    end

    def earliest(cards)
      cards.min_by { |slug, card| [card['next_review'], @problems[slug]['order']] }&.first
    end

    def next_new(pool)
      @problems.select { |slug, p| eligible_new?(slug, p, pool) }.min_by { |_, p| p['order'] }&.first
    end

    def eligible_new?(slug, problem, pool)
      topic = problem['topic']
      !@progress.seen?(slug) && !picked?(slug) && in_pool?(slug, pool) && @progress.open?(topic) &&
        (problem['difficulty'] != 'Hard' || @progress.hards_unlocked?(topic))
    end
  end
end
