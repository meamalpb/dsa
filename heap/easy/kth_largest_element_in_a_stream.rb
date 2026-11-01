# frozen_string_literal: true

# heap/easy/kth_largest_element_in_a_stream.rb

# Problem
# https://leetcode.com/problems/kth-largest-element-in-a-stream/
require_relative '../../linked_list/helpers/min_heap'

class KthLargest
  #     :type k: Integer
  #     :type nums: Integer[]
  def initialize(k, nums)
    @k = k
    @heap = MinHeap.new
    nums.each { |n| add(n) }
  end

  #     :type val: Integer
  #     :rtype: Integer
  def add(val)
    if @heap.size < @k
      @heap.push(val)
    elsif val > @heap.peek
      @heap.pop
      @heap.push(val)
    end
    @heap.peek
  end
end

# Your KthLargest object will be instantiated and called as such:
# obj = KthLargest.new(k, nums)
# param_1 = obj.add(val)
