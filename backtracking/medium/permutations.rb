# frozen_string_literal: true

# backtracking/medium/permutations.rb

# Problem
# https://leetcode.com/problems/permutations/
# @param {Integer[]} nums
# @return {Integer[][]}
def permute(nums)
  @result = []
  solve(nums, 0, nums.length - 1)
  @result
end

def solve(nums, l, r)
  if l == r
    @result.push(nums.clone)
    return
  end

  (l..r).each do |i|
    nums[l], nums[i] = nums[i], nums[l]
    solve(nums, l + 1, r)
    nums[l], nums[i] = nums[i], nums[l]
  end
end

if __FILE__ == $PROGRAM_NAME
  nums = [1, 2, 3]
  p permute(nums)
end
