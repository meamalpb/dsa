# frozen_string_literal: true

# tree/easy/invert_binary_tree.rb

# Problem
# https://leetcode.com/problems/invert-binary-tree/description/

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
# @return {TreeNode}
def invert_tree(root)
  def invert(root)
    return if root.nil?

    temp = root.left
    root.left = root.right
    root.right = temp
    invert(root.left)
    invert(root.right)
  end
  invert(root)
  root
end
