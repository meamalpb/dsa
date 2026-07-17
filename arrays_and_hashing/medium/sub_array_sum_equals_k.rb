# frozen_string_literal: true

# arrays_and_hashing/medium/sub_array_sum_equals_k.rb

# Problem
# https://leetcode.com/problems/subarray-sum-equals-k/

# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer}
def subarray_sum(nums, k)
  result = 0
  dict = Hash.new(0)
  temp = 0
  dict[0] = 1
  nums.each do |n|
    temp += n
    result += dict[temp - k]
    dict[temp] += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p subarray_sum([1, 1, 1], 2)
  p subarray_sum([1, 2, 3], 3)
  p subarray_sum([1, 2, 1, 2, 1], 3)
end
