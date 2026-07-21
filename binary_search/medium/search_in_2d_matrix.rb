# frozen_string_literal: true

# binary_search/medium/search_in_2d_matrix.rb

# Problem
# https://leetcode.com/problems/search-a-2d-matrix/

# @param {Integer[][]} matrix
# @param {Integer} target
# @return {Boolean}
def search_matrix(matrix, target)
  x = matrix[0].length
  y = matrix.length
  l = 0
  r = y - 1
  t = nil
  while l <= r
    m = (l + r) / 2
    if matrix[m][0] == target
      return true
    elsif matrix[m][0] > target
      r = m - 1
    elsif matrix[m][0] < target
      if matrix[m][x - 1] >= target
        t = m
        break
      else
        l = m + 1
      end
    end
  end
  return false if t.nil?

  left = 0
  right = x - 1

  while left <= right
    mid = (left + right) / 2
    if matrix[t][mid] == target
      return true
    elsif matrix[t][mid] > target
      right = mid - 1
    else
      left = mid + 1
    end
  end
  false
end

if __FILE__ == $PROGRAM_NAME
  p search_matrix([[1, 3, 5, 7], [10, 11, 16, 20], [23, 30, 34, 60]], 3)
  p search_matrix([[1, 3, 5, 7], [10, 11, 16, 20], [23, 30, 34, 60]], 13)
end
