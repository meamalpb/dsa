# frozen_string_literal: true

# arrays/medium/top_k_frequent.rb

# Problem
# https://leetcode.com/problems/top-k-frequent-elements/

# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer[]}
def top_k_frequent(nums, k)
  kk = Hash.new(0)
  nums.each do |num|
    kk[num] += 1
  end
  main_array = Array.new(nums.length + 1) { [] }
  kk.each do |kd, i|
    main_array[i].append kd
  end
  main_array.flatten.last(k)
end

if __FILE__ == $PROGRAM_NAME
  p top_k_frequent([1, 1, 1, 2, 2, 3], 2)
  p top_k_frequent([1], 1)
end
