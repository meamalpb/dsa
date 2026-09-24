# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/srs'

class ChartsTest < Minitest::Test
  TODAY = Date.new(2026, 9, 24) # a Thursday

  def days(*offsets)
    offsets.each_with_object(Hash.new(0)) { |o, h| h[TODAY - o] += 1 }
  end

  def test_bar
    assert_equal '░░░░░░░░░░', Srs::Charts.bar(0.0)
    assert_equal '█████░░░░░', Srs::Charts.bar(0.5)
    assert_equal '██████████', Srs::Charts.bar(1.0)
    assert_equal '██████████', Srs::Charts.bar(1.7)
  end

  def test_activity_skips_seed_entries
    cards = [{ 'history' => [{ 'date' => TODAY, 'grade' => 'seed' }, { 'date' => TODAY, 'grade' => 'good' }] },
             { 'history' => [{ 'date' => TODAY, 'grade' => 'easy' }] }]
    assert_equal({ TODAY => 2 }, Srs::Charts.activity(cards))
  end

  def test_levels
    assert_equal [0, 1, 2, 2, 3, 3], [0, 1, 2, 3, 4, 9].map { |n| Srs::Charts.level(n) }
  end

  def test_streak_counts_back_from_today
    assert_equal [3, 3], Srs::Charts.streaks(days(0, 1, 2), TODAY)
  end

  def test_streak_survives_until_the_day_is_over
    assert_equal [2, 2], Srs::Charts.streaks(days(1, 2), TODAY)
  end

  def test_streak_broken_after_a_missed_day
    assert_equal [0, 2], Srs::Charts.streaks(days(2, 3), TODAY)
  end

  def test_longest_streak_can_be_in_the_past
    assert_equal [1, 4], Srs::Charts.streaks(days(0, 10, 11, 12, 13), TODAY)
  end

  def test_heatmap_shape
    busy = { TODAY => 4 }
    lines = Srs::Charts.heatmap(busy, TODAY).split("\n")
    assert_equal 8, lines.size # month header + Mon..Sun
    assert_match(/\AMon /, lines[1])
    assert_match(/\ASun /, lines[7])
    assert_equal '█', lines[4].rstrip[-1] # Thursday row: today is the last cell
  end

  def test_heatmap_leaves_future_days_blank
    lines = Srs::Charts.heatmap(Hash.new(0), TODAY).split("\n")
    assert_equal '·', lines[4].rstrip[-1]
    assert_operator lines[5].rstrip.length, :<, lines[4].rstrip.length # Fri is after today, so the last column stops at Thu
  end
end
