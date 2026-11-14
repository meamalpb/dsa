# frozen_string_literal: true

# heap/hard/find_median_from_data_stream.rb

# Problem
# https://leetcode.com/problems/find-median-from-data-stream/

require_relative '../../linked_list/helpers/min_heap'

class MedianFinder
  attr_accessor :small, :large

  def initialize
    @small = MinHeap.new
    @large = MinHeap.new
  end

  #     :type num: Integer
  #     :rtype: Void
  def add_num(num)
    if small.peek && num <= -small.peek
      small.push(-num)
    else
      large.push num
    end

    if large.size > small.size + 1
      small.push(-large.pop)
    elsif small.size > large.size + 1
      large.push(-small.pop)
    end
  end

  #     :rtype: Float
  def find_median
    if large.size > small.size
      large.peek
    elsif large.size < small.size
      small.peek * -1
    else
      (large.peek + small.peek * -1.0) / 2
    end
  end
end
