# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/srs'

class Sm2Test < Minitest::Test
  DAY0 = Date.new(2026, 1, 1)

  # The worked example in DESIGN.md §5.
  def test_design_example
    card = Srs::Sm2.new_card
    [[0, 'good', 2.5, 1], [1, 'good', 2.5, 6], [7, 'hard', 2.36, 14], [21, 'again', 1.82, 1]]
      .each do |day, grade, ease, interval|
        card = Srs::Sm2.review(card, grade, DAY0 + day)
        assert_equal [ease, interval, DAY0 + day + interval], [card['ease'], card['interval'], card['next_review']],
                     "day #{day} #{grade}"
      end
    assert_equal 0, card['reps']
    assert_equal 4, card['history'].size
  end

  def test_third_success_multiplies_by_ease
    card = { 'reps' => 2, 'ease' => 2.5, 'interval' => 6 }
    assert_equal 15, Srs::Sm2.review(card, 'good', DAY0)['interval']
  end

  def test_easy_raises_ease
    assert_equal 2.6, Srs::Sm2.review(Srs::Sm2.new_card, 'easy', DAY0)['ease']
  end

  def test_ease_never_below_minimum
    card = { 'reps' => 5, 'ease' => 1.4, 'interval' => 30 }
    card = Srs::Sm2.review(card, 'again', DAY0)
    assert_equal Srs::Sm2::MIN_EASE, card['ease']
    assert_equal 1, card['interval']
  end

  def test_does_not_modify_input
    card = Srs::Sm2.new_card
    Srs::Sm2.review(card, 'good', DAY0)
    assert_equal Srs::Sm2.new_card, card
  end
end
