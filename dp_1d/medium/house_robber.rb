# frozen_string_literal: true

# dp_1d/medium/house_robber.rb

# Problem
# https://leetcode.com/problems/house-robber/
def rob(nums)
  l1 = 0
  l2 = 0

  nums.each do |i|
    temp = [i + l1, l2].max
    l1 = l2
    l2 = temp
  end
  l2
end

if __FILE__ == $PROGRAM_NAME
  # tests go here
  nums = [1, 2, 3, 1]
  p rob(nums)
end
