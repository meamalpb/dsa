# frozen_string_literal: true

# two_pointers/medium/two_integer_sum.rb

# Problem
# https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/description/
# @param {Integer[]} numbers
# @param {Integer} target
# @return {Integer[]}
def two_sum(nums, target)
  l = 0
  r = nums.length - 1
  while l < r
    sum = nums[l] + nums[r]
    if sum == target
      return [l + 1, r + 1]
    elsif sum < target
      l += 1
    else
      r -= 1
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p two_sum([2, 7, 11, 15], 9)
  p two_sum([2, 3, 4], 6)
  p two_sum([-1, 0], -1)
end
