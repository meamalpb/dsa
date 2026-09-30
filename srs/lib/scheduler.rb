# frozen_string_literal: true

module Srs
  # Picks today's problems — DESIGN.md §7. Slots, pools and pacing come from srs/config.yml (§12).
  class Scheduler # rubocop:disable Metrics/ClassLength
    def initialize(problems, state, today, config: Srs.config)
      @problems = problems
      @state = state
      @today = today
      @config = config
      @progress = Progress.new(problems, state, config: config)
    end

    # Today's session, built on first call of the day and then reused as-is.
    def session
      current = @state['session']
      return current if current && current['date'] == @today

      @state['session'] = { 'date' => @today, 'slots' => {} }
      force_new if new_problem_overdue?
      daily_slots.each { |slot, pool| slots[slot] ||= pick(pool) }
      @state['session']
    end

    # Letters of the bonus slots, in unlock order: the ones right after the daily slots.
    def bonus_slots
      first = daily_slots.keys.max.succ
      Array.new(bonus['max']) { |i| (first.ord + i).chr }
    end

    # The bonus slot the next unlock would open, or nil when they're all open today.
    def next_bonus_slot
      bonus_slots.find { |slot| !slots.key?(slot) }
    end

    def bonus_left?
      !next_bonus_slot.nil?
    end

    def unlocks_bonus?(grade)
      Array(bonus['unlock_on']).include?(grade)
    end

    # Opens the next bonus slot, if any are left today. Returns [slot, entry] or nil.
    def unlock_bonus
      slot = next_bonus_slot
      return unless slot

      slots[slot] = pick(bonus['pool'])
      [slot, slots[slot]]
    end

    # Extra new problem (`more` / `more new`, slots after the bonus ones) once everything else is
    # done. Rotates through the daily pools, falling back to the next one. Returns [slot, entry] or nil.
    def add_extra_new
      rotation = forced_pools.rotate(extra_count)
      slug = rotation.lazy.filter_map { |pool| next_new(pool) }.first
      return unless slug

      add_extra(entry(slug, 'new'))
    end

    # Extra review (`more old`): the first due review from any pool, in review_order.
    # Returns [slot, entry] or nil when nothing is due.
    def add_extra_review
      slug = first_due(@state['problems'].select { |s, _| @problems.key?(s) && !picked?(s) })
      add_extra(entry(slug, 'review')) if slug
    end

    def all_graded?
      slots.values.all? { |e| e['grade'] || e['slug'].nil? }
    end

    def new_problem_overdue?
      last = @state['last_new_on']
      last.nil? || (@today - last) >= @config.dig('session', 'new_every_days')
    end

    # A graded new problem resets the new-problem clock; a forced one also hands the
    # next forced pick to the next pool.
    def record_new(slot, entry)
      @state['last_new_on'] = @today
      @state['next_forced_pool'] = next_pool(daily_slots[slot]) if entry['forced']
    end

    private

    def daily_slots
      @config.dig('session', 'slots')
    end

    def bonus
      @config.dig('session', 'bonus')
    end

    def slots
      @state['session']['slots']
    end

    # Pools that take turns for the forced new problem, in slot order.
    def forced_pools
      daily_slots.values.uniq
    end

    def next_pool(pool)
      pools = forced_pools
      pools[((pools.index(pool) || -1) + 1) % pools.size]
    end

    def add_extra(extra)
      slot = ([slots.keys.max] + bonus_slots + daily_slots.keys).compact.max.succ
      slots[slot] = extra
      [slot, extra]
    end

    def extra_count
      reserved = daily_slots.keys + bonus_slots
      slots.count { |k, e| !reserved.include?(k) && e['kind'] == 'new' }
    end

    # Rule 1: put a new problem in the slot for next_forced_pool, or the next pool's slot if
    # that pool has nothing eligible.
    def force_new
      pools = forced_pools
      start = pools.index(@state['next_forced_pool']) || 0
      pool, slug = pools.rotate(start).lazy.map { |p| [p, next_new(p)] }.find { |_, s| s }
      slots[daily_slots.key(pool)] = entry(slug, 'new', forced: true) if slug
    end

    # Rules 2–5: due review, new problem, early review, empty.
    def pick(pool)
      if (slug = first_due(reviews(pool))) then entry(slug, 'review')
      elsif (slug = next_new(pool)) then entry(slug, 'new')
      elsif (slug = earliest(reviews(pool))) then entry(slug, 'early')
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
      @config.dig('pools', pool).include?(@problems.dig(slug, 'difficulty'))
    end

    def reviews(pool)
      @state['problems'].select { |slug, _| @problems.key?(slug) && in_pool?(slug, pool) && !picked?(slug) }
    end

    # most_overdue: earliest next_review first. learning_first: problems last done within
    # learning_days come before older ones, so a fresh problem's early reviews aren't stuck
    # behind a months-old backlog.
    def first_due(cards)
      due = cards.select { |_, card| card['next_review'] <= @today }
      return earliest(due) unless @config.dig('session', 'review_order') == 'learning_first'

      since = @today - @config.dig('session', 'learning_days')
      learning = due.select { |_, card| card['last_reviewed'] && card['last_reviewed'] >= since }
      earliest(learning) || earliest(due)
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
