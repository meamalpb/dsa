# frozen_string_literal: true

# arrays/easy/two_sum.rb

# Problem
# https://leetcode.com/problems/two-sum/description/

def two_sum(nums, target)
  seen = {}
  i = 0
  l = nums.length

  while i < l
    return [i, seen[target - nums[i]]] if seen.key?(target - nums[i])

    seen[nums[i]] = i
    i += 1
  end
  false
end

if __FILE__ == $PROGRAM_NAME
  p two_sum([1, 2, 3], 3)
  p two_sum([1, 1, 3], 3)
end
