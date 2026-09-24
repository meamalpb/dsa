# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/srs'

class ScaffoldTest < Minitest::Test
  def test_strips_solutions_keeps_header_and_tests
    source = <<~RUBY
      # frozen_string_literal: true

      # Problem
      # https://leetcode.com/problems/contains-duplicate/

      # @param {Integer[]} nums
      # @return {Boolean}

      # --------------------------
      # Approach 1 - hash lookup
      # --------------------------
      def contains_duplicate(nums)
        nums.uniq.length != nums.length
      end

      # --------------------------
      # Approach 2 - sort
      # --------------------------
      def contains_duplicate_sort(nums)
        nums.sort.each_cons(2).any? { |a, b| a == b }
      end

      if __FILE__ == $PROGRAM_NAME
        puts contains_duplicate([1, 1])
      end
    RUBY

    assert_equal <<~RUBY, Srs::Scaffold.attempt_source(source)
      # frozen_string_literal: true

      # Problem
      # https://leetcode.com/problems/contains-duplicate/

      # @param {Integer[]} nums
      # @return {Boolean}

      def contains_duplicate(nums)
      end

      def contains_duplicate_sort(nums)
      end

      if __FILE__ == $PROGRAM_NAME
        puts contains_duplicate([1, 1])
      end
    RUBY
  end

  def test_keeps_runner_and_helpers_after_it
    source = <<~RUBY
      require_relative '../helpers/utils'

      class Solver
        def go
          1
        end
      end

      def runner(input)
        p Solver.new.go
      end

      def pp(h)
        p h
      end
    RUBY

    assert_equal <<~RUBY, Srs::Scaffold.attempt_source(source)
      require_relative '../helpers/utils'

      class Solver
      end

      def runner(input)
        p Solver.new.go
      end

      def pp(h)
        p h
      end
    RUBY
  end

  def test_unclosed_block_raises_so_caller_falls_back
    assert_raises(ArgumentError) { Srs::Scaffold.attempt_source("def x\n  1\n") }
  end

  def test_fallback_keeps_header_and_tests
    source = "# frozen_string_literal: true\n# https://leetcode.com/problems/x/\ndef x\n" \
             "if __FILE__ == $PROGRAM_NAME\n  x\nend\n"
    assert_equal "# frozen_string_literal: true\n# https://leetcode.com/problems/x/\n\n" \
                 "if __FILE__ == $PROGRAM_NAME\n  x\nend\n", Srs::Scaffold.header_and_tests(source)
  end

  def test_attempt_path
    assert_equal 'tree/easy/x.attempt.rb', Srs::Scaffold.attempt_path('tree/easy/x.rb')
  end
end
