# frozen_string_literal: true

# tree/medium/kth_smallest_element_in_a_bst.rb

# Problem
# https://leetcode.com/problems/kth-smallest-element-in-a-bst/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val = 0, left = nil, right = nil)
#         @val = val
#         @left = left
#         @right = right
#     end
# end
# @param {TreeNode} root
# @param {Integer} k
# @return {Integer}
def kth_smallest(root, k)
  curr = root
  n = 0
  stack = []
  while curr || !stack.empty?
    while curr
      stack << curr
      curr = curr.left
    end
    curr = stack.pop
    n += 1
    return curr.val if n == k

    curr = curr.right
  end
end
