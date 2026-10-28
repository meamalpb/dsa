# frozen_string_literal: true

# stack/medium/generate_parentheses.rb

# Problem
# https://leetcode.com/problems/generate-parentheses/

# @param {Integer} n
# @return {String[]}

def generate_parenthesis(n)
  @n = n
  @res = []
  @stack = []
  def backtrack(open, close)
    p @stack
    if (open == close) && (open == @n)
      @res.append(@stack.join(''))
      return nil
    end

    if open < @n
      @stack << '('
      backtrack(open + 1, close)
      @stack.pop
    end

    return unless close < open

    @stack << ')'
    backtrack(open, close + 1)
    @stack.pop
  end
  backtrack(0, 0)
  @res
end

if __FILE__ == $PROGRAM_NAME
  p generate_parenthesis(3)
  p generate_parenthesis(2)
end
