# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/srs'

class SchedulerTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  TODAY = Date.new(2026, 9, 23)

  def setup
    @problems = {}
    @state = Srs::Store.default_state
    @state['last_new_on'] = TODAY - 1 # no forced new unless a test says so
  end

  def add(slug, topic, difficulty)
    @problems[slug] = { 'name' => slug, 'topic' => topic, 'difficulty' => difficulty, 'order' => @problems.size + 1 }
  end

  def seen(slug, next_review)
    @state['problems'][slug] = { 'reps' => 1, 'ease' => 2.5, 'interval' => 1,
                                 'last_reviewed' => next_review - 1, 'next_review' => next_review }
  end

  def slots(today = TODAY)
    Srs::Scheduler.new(@problems, @state, today).session['slots']
  end

  def picks(today = TODAY)
    slots(today).transform_values { |e| [e['slug'], e['kind']] }
  end

  def test_due_review_beats_new
    add('e1', 'arrays', 'Easy')
    add('e2', 'arrays', 'Easy')
    seen('e1', TODAY)
    assert_equal %w[e1 review], picks['A']
  end

  def test_most_overdue_review_first
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 1)
    seen('m2', TODAY - 5)
    assert_equal %w[m2 review], picks['B']
  end

  def test_new_problem_in_sheet_order_when_nothing_due
    add('e1', 'arrays', 'Easy')
    add('e2', 'arrays', 'Easy')
    assert_equal %w[e1 new], picks['A']
  end

  def test_forced_new_after_three_days_despite_due_reviews
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    add('e1', 'arrays', 'Easy')
    seen('m1', TODAY - 10)
    seen('e1', TODAY - 10)
    @state['last_new_on'] = TODAY - 3
    assert_equal({ 'A' => %w[e1 review], 'B' => %w[m2 new] }, picks)
    assert slots['B']['forced']
  end

  def test_no_forced_new_after_two_days
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 10)
    @state['last_new_on'] = TODAY - 2
    assert_equal %w[m1 review], picks['B']
  end

  def test_forced_new_falls_back_to_other_pool
    add('m1', 'arrays', 'Medium')
    add('e1', 'arrays', 'Easy')
    add('e2', 'arrays', 'Easy')
    seen('m1', TODAY - 10)
    seen('e1', TODAY - 10)
    @state['last_new_on'] = nil
    @state['next_forced_pool'] = 'medium_hard' # no unseen Medium, so Easy slot takes it
    assert_equal({ 'A' => %w[e2 new], 'B' => %w[m1 review] }, picks)
  end

  def test_locked_topic_is_skipped
    add('t1', 'two_pointers', 'Medium') # first in sheet order, but locked
    add('a1', 'arrays', 'Medium')
    add('a2', 'arrays', 'Medium')
    seen('a1', TODAY + 10) # arrays 50% < 80%
    assert_equal %w[a2 new], picks['B']

    seen('a2', TODAY + 10) # arrays 100%: two_pointers opens
    @state['session'] = nil
    assert_equal %w[t1 new], picks['B']
  end

  def test_topic_open_when_already_started
    add('a1', 'arrays', 'Medium')
    add('t1', 'two_pointers', 'Medium')
    add('t2', 'two_pointers', 'Medium')
    progress = Srs::Progress.new(@problems, @state)
    refute progress.open?('two_pointers')

    seen('t1', TODAY + 10) # arrays still 0%, but two_pointers has a solved problem
    assert progress.open?('two_pointers')
  end

  def test_hard_waits_for_mediums
    add('h1', 'arrays', 'Hard')
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    assert_equal %w[m1 new], picks['B']

    seen('m1', TODAY + 10) # 50% of mediums: hard still locked, m2 next
    @state['session'] = nil
    assert_equal %w[m2 new], picks['B']

    seen('m2', TODAY + 10)
    @state['session'] = nil
    assert_equal %w[h1 new], picks['B']
  end

  def test_early_review_when_nothing_due_or_new
    add('e1', 'arrays', 'Easy')
    add('e2', 'arrays', 'Easy')
    seen('e1', TODAY + 9)
    seen('e2', TODAY + 4)
    assert_equal %w[e2 early], picks['A']
  end

  def test_empty_slot_when_pool_has_nothing
    add('m1', 'arrays', 'Medium')
    assert_equal({ 'A' => [nil, nil], 'B' => %w[m1 new] }, picks)
  end

  def test_session_is_stable_within_a_day_and_rebuilt_next_day
    add('e1', 'arrays', 'Easy')
    first = slots
    assert_same first, slots
    refute_same first, slots(TODAY + 1)
  end

  def test_bonus_slot_takes_another_easy
    add('e1', 'arrays', 'Easy')
    add('e2', 'arrays', 'Easy')
    add('m1', 'arrays', 'Medium')
    scheduler = Srs::Scheduler.new(@problems, @state, TODAY)
    scheduler.session
    scheduler.unlock_bonus
    assert_equal(%w[e1 m1 e2], scheduler.session['slots'].values_at('A', 'B', 'C').map { |e| e['slug'] })
  end
end
