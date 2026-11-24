# frozen_string_literal: true

# dp_1d/medium/house_robber_ii.rb

# Problem
# https://leetcode.com/problems/house-robber-ii/
# @param {Integer[]} nums
# @return {Integer}
def rob(nums)
  return nums.max if nums.length < 3

  l1 = 0
  l2 = 0
  n1 = 0
  n2 = 0
  (1..nums.length - 1).each do |i|
    temp1 = [nums[i - 1] + l1, l2].max
    l1 = l2
    l2 = temp1
    temp2 = [nums[i] + n1, n2].max
    n1 = n2
    n2 = temp2
  end
  [l2, n2].max
end

if __FILE__ == $PROGRAM_NAME
  nums = [2, 3, 2]
  p rob(nums)
  # tests go here
end
