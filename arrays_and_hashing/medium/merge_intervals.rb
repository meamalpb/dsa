# frozen_string_literal: true

# arrays_and_hashing/medium/merge_intervals.rb

# Problem
# https://leetcode.com/problems/merge-intervals/

def merge(intervals)
  intervals.sort_by! { |interval| interval[0] }
  result = [intervals.first]
  intervals.each do |interval|
    if result[-1][1] >= interval[0]
      temp = [result[-1][0], [result[-1][1], interval[1]].max]
      result[-1] = temp
    else
      result << interval
    end
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p merge([[1, 3], [2, 6], [8, 10], [15, 18]])
  p merge([[1, 4], [4, 5]])
  p merge([[4, 7], [1, 4]])
end
