# frozen_string_literal: true

# Definition for a binary tree node.

# tree/easy/inorder_traversal.rb

# Problem
# https://leetcode.com/problems/binary-tree-inorder-traversal/

# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val = 0, left = nil, right = nil)
#         @val = val
#         @left = left
#         @right = right
#     end
# end
# @param {TreeNode} root
# @return {Integer[]}
def inorder_traversal(root)
  res = []
  def inorder(root, res)
    return if root.nil?

    inorder(root.left, res)
    res << root.val
    inorder(root.right, res)
  end
  inorder(root, res)
  res
end
