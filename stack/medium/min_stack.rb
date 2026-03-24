# frozen_string_literal: true

# stack/medium/min_stack.rb

# Problem
# https://leetcode.com/problems/min-stack/description/

# Implementation of minstack
class MinStack
  attr_accessor :n, :min

  def initialize
    @n = []
    @min = []
  end

  def push(val)
    n << val
    min << val if min.last.nil? || min.last >= val
    nil
  end

  def pop
    min.pop if n.pop == min.last
  end

  def top
    n.last
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_min
    min.last
  end
  # rubocop:enable Naming/AccessorMethodName
end

if __FILE__ == $PROGRAM_NAME
  obj = MinStack.new
  p obj.push(33)
  p obj.get_min
  p obj.push(3)
  p obj.pop
  p obj.top
  p obj.get_min
end
