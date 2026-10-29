# frozen_string_literal: true

# stack/hard/largest_rectangle_in_histogram.rb

# Problem
# https://leetcode.com/problems/largest-rectangle-in-histogram/
# @param {Integer[]} heights
# @return {Integer}
def largest_rectangle_area(heights)
  res = 0
  stack = []
  heights.each_with_index do |h, i|
    start = i
    while !stack.empty? && stack[-1][1] > h
      index, height = stack.pop
      res = [res, (height * (i - index))].max
      start = index
    end
    stack << [start, h]
  end

  stack.each do |k|
    res = [res, k[1] * (heights.length - k[0])].max
  end
  res
end

if __FILE__ == $PROGRAM_NAME
  heights = [2, 1, 5, 6, 2, 3]
  p largest_rectangle_area(heights)
  heights = [2, 4]
  p largest_rectangle_area(heights)
end
