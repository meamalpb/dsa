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
    elsif nums[mid] > nums[r]
      if target > nums[mid]
        l = mid + 1
      elsif nums[l] <= target
        r = mid - 1
      else
        l = mid + 1
      end
    elsif nums[r] >= target
      if nums[mid] > target
        r = mid - 1
      else
        l = mid + 1
      end
    else
      r = mid - 1
    end
  end
  -1
end

def standard_template(nums, target)
  l = 0
  r = nums.length - 1

  while l <= r
    mid = (l + r) / 2

    return mid if nums[mid] == target

    # Left half is sorted
    if nums[l] <= nums[mid]
      if nums[l] <= target && target < nums[mid]
        r = mid - 1
      else
        l = mid + 1
      end
    elsif nums[mid] < target && target <= nums[r]
      # Right half is sorted
      l = mid + 1
    else
      r = mid - 1
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p search([4, 5, 6, 7, 0, 1, 2], 0)
  p search([4, 5, 6, 7, 0, 1, 2], 3)
  p search([1], 0)
  p search([5, 1, 3], 5)
  p search([1, 3], 3)

  p standard_template([4, 5, 6, 7, 0, 1, 2], 0)
  p standard_template([4, 5, 6, 7, 0, 1, 2], 3)
  p standard_template([1], 0)
  p standard_template([5, 1, 3], 5)
  p standard_template([1, 3], 3)

end
