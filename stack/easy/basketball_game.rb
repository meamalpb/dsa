# frozen_string_literal: true

# stack/easy/basketball_game.rb

# Problem
# https://leetcode.com/problems/baseball-game/

# @param {String[]} operations
# @return {Integer}
def cal_points(operations)
  stack = []
  operations.each do |i|
    case i
    when 'C'
      stack.pop
    when '+'
      stack << stack[-1] + stack[-2]
    when 'D'
      stack << stack[-1] * 2
    else
      stack << i.to_i
    end
  end
  stack.sum
end

if __FILE__ == $PROGRAM_NAME
  p cal_points(['5', '-2', '4', 'C', 'D', '9', '+', '+'])
  p cal_points(['5', '2', 'C', 'D', '+'])
  p cal_points(%w[1 C])
end
