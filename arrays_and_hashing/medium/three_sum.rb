# frozen_string_literal: true

# arrays/medium/three_sum.rb

# Problem
# https://leetcode.com/problems/3sum/

# @param {Integer[]} nums
# @return {Integer[][]}
def three_sum(nums)
  nums.sort!
  result = []
  nums.each_with_index do |num1, i|
    # if next left element is also same we skip it to remove duplicates
    next if i.positive? && nums[i] == nums[i - 1]
    return result if num1.positive?

    left = i + 1
    right = nums.length - 1
    while left < right
      value = num1 + nums[left] + nums[right]
      if value.negative?
        left += 1
      elsif value.positive?
        right -= 1
      else
        result << [num1, nums[left], nums[right]]
        left += 1
        # if next left element is also same we skip it to remove duplicates
        left += 1 while left < right && nums[left] == nums[left - 1]
      end
    end
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p three_sum([-1, 0, 1, 2, -1, -4])
  p three_sum([0, 1, 1])
  p three_sum([0, 0, 0, 0])
  p three_sum([-1, 0, 1, 0])
end
