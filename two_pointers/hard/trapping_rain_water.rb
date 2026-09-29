# frozen_string_literal: true

# two_pointers/hard/trapping_rain_water.rb

# Problem
# https://leetcode.com/problems/trapping-rain-water/
# @param {Integer[]} height
# @return {Integer}
def trap(height)
  return 0 if height.empty?

  l = 0
  res = 0
  r = height.length - 1
  left_max = height[l]
  right_max = height[r]
  while l < r
    if left_max < right_max
      l += 1
      left_max = [left_max, height[l]].max
      res += left_max - height[l]
    else
      r -= 1
      right_max = [right_max, height[r]].max
      res += right_max - height[r]
    end
  end
  res
end

if __FILE__ == $PROGRAM_NAME
  p trap([0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1])
  p trap([4, 2, 0, 3, 2, 5])
end
