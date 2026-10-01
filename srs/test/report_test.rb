# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require_relative '../lib/srs'

class ReportTest < Minitest::Test
  TODAY = Date.new(2026, 10, 2)

  def setup
    @problems = {
      'e1' => { 'name' => 'Easy One', 'topic' => 'arrays', 'difficulty' => 'Easy' },
      'm1' => { 'name' => 'Medium One', 'topic' => 'trees', 'difficulty' => 'Medium' },
      'future' => { 'name' => 'Not Due Yet', 'topic' => 'arrays', 'difficulty' => 'Easy' }
    }
    @state = Srs::Store.default_state
  end

  def card(next_review, reps: 1, ease: 2.5)
    { 'reps' => reps, 'ease' => ease, 'interval' => 1, 'last_reviewed' => next_review - 1, 'next_review' => next_review }
  end

  def run_overdue
    out = StringIO.new
    Srs::Report.overdue(@problems, @state, TODAY, out)
    out.string
  end

  def test_lists_overdue_problems_most_overdue_first
    @state['problems']['e1'] = card(TODAY - 1)
    @state['problems']['m1'] = card(TODAY - 10)
    @state['problems']['future'] = card(TODAY + 5)

    output = run_overdue
    assert_match(/Overdue \(2\):/, output)
    assert_operator output.index('Medium One'), :<, output.index('Easy One')
    refute_includes output, 'Not Due Yet'
  end

  def test_problem_due_today_counts_as_overdue
    @state['problems']['e1'] = card(TODAY)
    assert_match(/Overdue \(1\):/, run_overdue)
  end

  def test_card_without_matching_problem_is_ignored
    @state['problems']['deleted-from-sheet'] = card(TODAY - 3)
    assert_match(/Nothing overdue\./, run_overdue)
  end

  def test_nothing_overdue
    @state['problems']['future'] = card(TODAY + 5)
    assert_match(/Nothing overdue\./, run_overdue)
  end
end
