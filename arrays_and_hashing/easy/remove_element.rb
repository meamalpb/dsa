# frozen_string_literal: true

# arrays_and_hashing/easy/remove_element.rb

# Problem
# https://leetcode.com/problems/remove-element/

# @param {Integer[]} nums
# @param {Integer} val
# @return {Integer}
def remove_element(nums, val)
  i = 0
  j = 0
  while i < nums.length
    if nums[i] != val
      nums[j] = nums[i]
      j += 1
    end
    i += 1
  end
  j
end

if __FILE__ == $PROGRAM_NAME
  remove_element([3, 2, 2, 3], 3)
  remove_element([0, 1, 2, 2, 3, 0, 4, 2], 2)
end
