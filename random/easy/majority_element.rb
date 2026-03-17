# frozen_string_literal: true

# random/easy/majority_element.rb

# Problem
# https://leetcode.com/problems/majority-element/description/

# @param {Integer[]} nums
# @return {Integer}

# --------------------
# Approach - 1
# Normal hashmap counter
# --------------------
def majority_element_normal(nums)
  k = Hash.new(0)
  nums.each do |num|
    k[num] += 1
    return num if k[num] > (nums.length / 2)
  end
end

# --------------------
# Approach - 2
# Boyer-Moore Majority Voting Algorithm
# In the original one, we take the candidate and run a loop
# just counting to make sure that it is infact majority element
# if not there's no majority element
# --------------------
def majority_element_moore(nums)
  candidate = nil
  votes = 0
  nums.each do |num|
    candidate = num if votes.zero?
    if candidate == num
      votes += 1
    else
      votes -= 1
    end
  end
  candidate
end

if __FILE__ == $PROGRAM_NAME
  p majority_element_normal([3, 2, 3])
  p majority_element_normal([2, 2, 1, 1, 1, 2, 2])

  p majority_element_moore([6, 5, 5])
  p majority_element_moore([2, 2, 1, 1, 1, 2, 2])
end
