# frozen_string_literal: true

# dp_1d/easy/climbing_stairs.rb

# Problem
# https://leetcode.com/problems/climbing-stairs/
# @param {Integer} n
# @return {Integer}
def climb_stairs(n)
  l1 = 1
  l2 = 1
  (0..n - 2).each do |_i|
    t = l1
    l1 += l2
    l2 = t
  end
  l1
end

if __FILE__ == $PROGRAM_NAME
  n = 2
  p climb_stairs(n)
end
