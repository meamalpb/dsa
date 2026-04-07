# frozen_string_literal: true

# binary_search/easy/binary_search.rb

# Problem
# http://leetcode.com/problems/binary-search/description/

# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search(nums, target)
  l = 0
  r = nums.length - 1
  while l <= r
    mid = (l + r) / 2
    if nums[mid] == target
      return mid
    elsif nums[mid] > target
      r = mid - 1
    else
      l = mid + 1
    end
  end
  -1
end

if __FILE__ == $PROGRAM_NAME
  p search([-1, 0, 3, 5, 9, 12], 9)
  p search([-1, 0, 3, 5, 9, 12], 2)
end
