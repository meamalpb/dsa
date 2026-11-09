# frozen_string_literal: true

# heap/medium/kth_largest_element_in_an_array.rb

# Problem
# https://leetcode.com/problems/kth-largest-element-in-an-array/
# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer}

require_relative '../../linked_list/helpers/min_heap'

def find_kth_largest(nums, k)
  heap = MinHeap.new(nums.map { |x| x * -1 })
  (1...k).each { heap.pop }
  heap.peek * -1
end

def find_kth_largest_simple(nums, k)
  nums.sort[-k]
end

if __FILE__ == $PROGRAM_NAME
  nums = [3, 2, 1, 5, 6, 4]
  k = 2
  p find_kth_largest(nums, k)
  p find_kth_largest_simple(nums, k)
end
