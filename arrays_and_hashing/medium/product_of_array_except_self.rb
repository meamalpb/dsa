# frozen_string_literal: true

# arrays/medium/product_of_array_except_self.rb

# Problem
# https://leetcode.com/problems/product-of-array-except-self/description/

# @param {Integer[]} nums
# @return {Integer[]}
def product_except_self(nums)
  prefix = Array.new(nums.length, 1)
  suffix = Array.new(nums.length, 1)
  l = nums.length
  result = []
  i = 1
  while i < l
    prefix[i] = prefix[i - 1] * nums[i - 1]
    suffix[l - i - 1] = suffix[l - i] * nums[l - i]
    i += 1
  end
  i = 0
  while i < l
    result.append(prefix[i] * suffix[i])
    i += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p product_except_self([1, 2, 3, 4])
  p product_except_self([-1, 1, 0, -3, 3])
end
