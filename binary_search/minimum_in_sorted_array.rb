# frozen_string_literal: true

# binary_search/easy/minimum_in_sorted_array.rb

# Problem
# https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/description/

# @param {Integer[]} nums
# @return {Integer}
def find_min(nums)
  l = 0
  r = nums.length - 1

  return nums.first if r.zero?

  while l <= r
    mid = (l + r) / 2
    if nums[l] <= nums[r]
      return nums[l] if nums[mid] <= nums[r]

      l = mid + 1

    elsif nums[mid] > nums[r]
      l = mid + 1
    else
      r = mid
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p find_min([3, 4, 5, 1, 2])
  p find_min([4, 5, 6, 7, 0, 1, 2])
  p find_min([11, 13, 15, 17])
  p find_min([1])
  p find_min([2, 1])
  p find_min([3, 1, 2])
end
