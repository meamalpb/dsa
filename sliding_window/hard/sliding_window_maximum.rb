# frozen_string_literal: true

# sliding_window/hard/sliding_window_maximum.rb

# Problem
# https://leetcode.com/problems/sliding-window-maximum/

def max_sliding_window(nums, k)
  left = 0
  right = 0
  q = []
  qv = 0
  result = []
  n = nums.length

  while right < n
    q.pop while q.length > qv && nums[q.last] < nums[right]
    q << right

    if right - left + 1 == k
      qv += 1 if q[qv] < left
      result << nums[q[qv]]
      left += 1
    end

    right += 1
  end

  result
end

if __FILE__ == $PROGRAM_NAME
  nums = [1, 3, -1, -3, 5, 3, 6, 7]
  k = 3

  p max_sliding_window(nums, k)
end
