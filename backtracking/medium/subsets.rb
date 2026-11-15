# frozen_string_literal: true

# backtracking/medium/subsets.rb

# Problem
# https://leetcode.com/problems/subsets/

# @param {Integer[]} nums
# @return {Integer[][]}
def subsets(nums)
  @r = []
  @subset = []
  @nums = nums
  def dfs(i)
    return @r.append(@subset.clone) if i == @nums.length

    @subset.append(@nums[i])
    dfs(i + 1)
    @subset.pop
    dfs(i + 1)
  end

  dfs(0)
  @r
end

if __FILE__ == $PROGRAM_NAME
  nums = [1, 2, 3]
  p subsets(nums)
end
