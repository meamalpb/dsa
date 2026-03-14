# frozen_string_literal: true

# arrays/easy/two_sum.rb

# Problem
# https://leetcode.com/problems/two-sum/description/

def two_sum(nums, target)
  seen = {}
  i = 0
  l = nums.length

  while i < l
    complement = target - nums[i]
    return [i, seen[complement]] if seen.key? complement

    seen[nums[i]] = i
    i += 1
  end
  false
end
