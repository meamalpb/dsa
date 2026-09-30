# frozen_string_literal: true

# tree/easy/balanced_binary_tree.rb

# Problem
# https://leetcode.com/problems/balanced-binary-tree/
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
# @return {Boolean}
def is_balanced(root)
  height(root) != -1
end

def height(root)
  return 0 if root.nil?

  left_height = height(root.left)
  right_height = height(root.right)
  return -1 if right_height == -1 || left_height == -1 || (right_height - left_height).abs > 1

  1 + [left_height, right_height].max
end
