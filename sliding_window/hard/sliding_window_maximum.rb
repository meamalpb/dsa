# frozen_string_literal: true

# sliding_window/hard/sliding_window_maximum.rb

# Problem
# https://leetcode.com/problems/sliding-window-maximum/

def max_sliding_window(nums, k)
  head = 0
  q = []
  result = []
  nums.each_with_index do |num, i|
    head += 1 if head < q.length && q[head] <= i - k
    q.pop while q.length > head && nums[q[-1]] <= num
    q << i
    result << nums[q[head]] if i >= k - 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  nums = [1, 3, -1, -3, 5, 3, 6, 7]
  k = 3

  p max_sliding_window(nums, k)
end
