# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/srs'

class SchedulerTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  TODAY = Date.new(2026, 9, 23)

  def setup
    Srs.config = Srs::Config.build({}) # defaults, whatever srs/config.yml says
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

  def configure(overrides)
    Srs.config = Srs::Config.build(overrides)
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

  def test_forced_new_after_two_days_despite_due_reviews
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    add('e1', 'arrays', 'Easy')
    seen('m1', TODAY - 10)
    seen('e1', TODAY - 10)
    @state['last_new_on'] = TODAY - 2
    assert_equal({ 'A' => %w[e1 review], 'B' => %w[m2 new] }, picks)
    assert slots['B']['forced']
  end

  def test_no_forced_new_after_one_day
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 10)
    @state['last_new_on'] = TODAY - 1
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

  def test_extra_new_slots_after_everything_graded
    add('e1', 'arrays', 'Easy')
    add('m1', 'arrays', 'Medium')
    add('e2', 'arrays', 'Easy')
    add('m2', 'arrays', 'Medium')
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    sched.session['slots'].each_value { |e| e['grade'] = 'good' }
    assert sched.all_graded?
    assert_equal 'D', sched.add_extra_new.first
    assert_equal 'E', sched.add_extra_new.first
    refute sched.all_graded?
    assert_nil sched.add_extra_new
  end

  def test_extra_review_takes_most_overdue_from_either_pool
    add('e1', 'arrays', 'Easy')
    add('m1', 'arrays', 'Medium')
    add('e2', 'arrays', 'Easy')
    add('m2', 'arrays', 'Medium')
    seen('e1', TODAY - 1)
    seen('m1', TODAY - 1)
    seen('e2', TODAY - 3)
    seen('m2', TODAY - 9)
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    assert_equal %w[e2 m2], sched.session['slots'].values_at('A', 'B').map { |e| e['slug'] }
    assert_equal ['D', 'e1', 'review'], sched.add_extra_review.then { |s, e| [s, e['slug'], e['kind']] }
    assert_equal 'm1', sched.add_extra_review[1]['slug']
    assert_nil sched.add_extra_review
  end

  def test_learning_first_puts_recent_problems_before_old_backlog
    configure('session' => { 'review_order' => 'learning_first' })
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 190) # old seed, far more overdue
    seen('m2', TODAY - 2)   # learned 3 days ago, missed its day-1 review
    assert_equal %w[m2 review], picks['B']
  end

  def test_learning_first_falls_back_to_most_overdue
    configure('session' => { 'review_order' => 'learning_first', 'learning_days' => 7 })
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 30)
    seen('m2', TODAY - 90)
    assert_equal %w[m2 review], picks['B']
  end

  def test_more_old_follows_review_order
    configure('session' => { 'review_order' => 'learning_first' })
    %w[e1 e2 m1 m2 m3].each { |s| add(s, 'arrays', s.start_with?('e') ? 'Easy' : 'Medium') }
    seen('m1', TODAY - 100)
    seen('m2', TODAY - 150)
    seen('m3', TODAY - 1)
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    assert_equal 'm3', sched.session['slots']['B']['slug']
    assert_equal 'm2', sched.add_extra_review[1]['slug']
  end

  def test_new_every_days_is_configurable
    configure('session' => { 'new_every_days' => 1 })
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    seen('m1', TODAY - 10)
    @state['last_new_on'] = TODAY - 1
    assert_equal %w[m2 new], picks['B']
  end

  def test_several_bonus_slots_then_extras_after_them
    configure('session' => { 'bonus' => { 'max' => 2 } })
    %w[e1 e2 e3 e4 m1].each { |s| add(s, 'arrays', s.start_with?('e') ? 'Easy' : 'Medium') }
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    sched.session
    assert_equal %w[C D], sched.bonus_slots
    assert_equal 'C', sched.unlock_bonus.first
    assert_equal 'D', sched.unlock_bonus.first
    assert_nil sched.unlock_bonus
    refute sched.bonus_left?
    sched.session['slots'].each_value { |e| e['grade'] = 'good' }
    assert_equal 'E', sched.add_extra_new.first
  end

  def test_bonus_pool_and_unlock_grades_are_configurable
    configure('pools' => { 'easy' => %w[Easy], 'medium_hard' => %w[Medium Hard], 'any' => %w[Easy Medium Hard] },
              'session' => { 'bonus' => { 'pool' => 'any', 'unlock_on' => %w[good easy] } })
    add('e1', 'arrays', 'Easy')
    add('m1', 'arrays', 'Medium')
    add('m2', 'arrays', 'Medium')
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    sched.session
    assert sched.unlocks_bonus?('good')
    refute sched.unlocks_bonus?('hard')
    assert_equal %w[m2 new], sched.unlock_bonus[1].values_at('slug', 'kind')
  end

  def test_no_bonus_when_max_is_zero
    configure('session' => { 'bonus' => { 'max' => 0 } })
    add('e1', 'arrays', 'Easy')
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    sched.session
    assert_nil sched.unlock_bonus
    refute sched.bonus_left?
  end

  def test_custom_slots_and_forced_rotation
    configure('session' => { 'slots' => { 'A' => 'easy', 'B' => 'medium', 'C' => 'hard' } },
              'pools' => { 'easy' => %w[Easy], 'medium' => %w[Medium], 'hard' => %w[Hard] })
    add('e1', 'arrays', 'Easy')
    add('m1', 'arrays', 'Medium')
    sched = Srs::Scheduler.new(@problems, @state, TODAY)
    assert_equal %w[A B C], sched.session['slots'].keys
    assert_equal %w[D], sched.bonus_slots
    sched.record_new('B', { 'forced' => true })
    assert_equal 'hard', @state['next_forced_pool']
    sched.record_new('C', { 'forced' => true })
    assert_equal 'easy', @state['next_forced_pool']
  end

  def test_topic_ratio_is_configurable
    configure('unlock' => { 'topic_ratio' => 0.5 })
    add('t1', 'two_pointers', 'Medium')
    add('a1', 'arrays', 'Medium')
    add('a2', 'arrays', 'Medium')
    seen('a1', TODAY + 10) # arrays 50% — enough at 0.5
    assert_equal %w[t1 new], picks['B']
  end
end
