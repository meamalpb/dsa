# frozen_string_literal: true

# linked_list/medium/find_the_duplicate_number.rb

# Problem
# https://leetcode.com/problems/find-the-duplicate-number/

# @param {Integer[]} nums
# @return {Integer}
def find_duplicate(nums)
  fast = 0
  slow = 0
  while true
    slow = nums[slow]
    fast = nums[nums[fast]]
    break if slow == fast
  end
  slow2 = 0
  until slow == slow2
    slow = nums[slow]
    slow2 = nums[slow2]
  end
  slow
end
