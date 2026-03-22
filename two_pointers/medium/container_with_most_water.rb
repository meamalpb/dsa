# frozen_string_literal: true

# two_pointers/medium/container_with_most_water.rb

# Problem
# https://leetcode.com/problems/container-with-most-water/description/

# @param {Integer[]} height
# @return {Integer}
def max_area(height)
  l = 0
  r = height.length - 1
  result = 0
  while l < r
    temp_max_height = [height[l], height[r]].min * (r - l)
    result = [result, temp_max_height].max
    if height[l] < height[r]
      l += 1
    else
      r -= 1
    end
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p max_area([1, 8, 6, 2, 5, 4, 8, 3, 7])
  p max_area([1, 1])
  p max_area([1, 2, 4, 3])
  p max_area([3, 6, 1])
end
