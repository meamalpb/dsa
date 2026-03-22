# frozen_string_literal: true

# arrays/medium/longest_consecutive_sequence.rb

# Problem
# https://leetcode.com/problems/longest-consecutive-sequence/

# @param {Integer[]} nums
# @return {Integer}

# ----------------
# Approach - 1
# Optimised but still can be improved
# ----------------

# def longest_consecutive(nums)
#   ss = {}
#   result = 0
#   # added this after failing a timeout with 100 0s
#   nums = nums.uniq
#   nums.each do |num|
#     ss[num] = 1
#   end
#   nums.each do |i|
#     next unless ss[i - 1].nil?

#     temp = 0
#     t = i
#     while ss[t]&.positive?
#       temp += 1
#       t += 1
#     end
#     result = [result, temp].max
#   end
#   result
# end

# ----------------
# Approach - 2
# Optimised with set
# ----------------
require 'set'

def longest_consecutive_set(nums)
  ss = nums.to_set
  result = 0
  ss.each do |i|
    next if ss.include?(i - 1)

    temp = 0
    t = i
    while ss.include?(t)
      temp += 1
      t += 1
    end
    result = [result, temp].max
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p longest_consecutive([100, 4, 200, 1, 3, 2])
  p longest_consecutive([0, 3, 7, 2, 5, 8, 4, 6, 0, 1])
  p longest_consecutive([1, 0, 1, 2])

  p longest_consecutive_set([100, 4, 200, 1, 3, 2])
  p longest_consecutive_set([0, 3, 7, 2, 5, 8, 4, 6, 0, 1])
  p longest_consecutive_set([1, 0, 1, 2])
end
