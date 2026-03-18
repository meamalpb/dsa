# frozen_string_literal: true

# random/easy/array_concatenation.rb

# Problem
# https://leetcode.com/problems/concatenation-of-array/

# @param {Integer[]} nums
# @return {Integer[]}
def get_concatenation(nums)
  nums + nums
end

if __FILE__ == $PROGRAM_NAME
  p get_concatenation([1, 2, 1])
  p get_concatenation([1, 3, 2, 1])
end
