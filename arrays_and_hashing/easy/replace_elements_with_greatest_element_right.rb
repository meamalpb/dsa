# frozen_string_literal: true

# arrays_and_hashing/easy/replace_elements_with_greatest_element_right.rb

# Problem
# https://leetcode.com/problems/replace-elements-with-greatest-element-on-right-side/

# @param {Integer[]} arr
# @return {Integer[]}
def replace_elements(arr)
  l = arr.length - 1
  max = -1
  while l >= 0
    k = arr[l]
    arr[l] = max
    max = [max, k].max
    l -= 1
  end
  arr
end

if __FILE__ == $PROGRAM_NAME
  p replace_elements([17, 18, 5, 4, 6, 1])
  p replace_elements([400])
end
