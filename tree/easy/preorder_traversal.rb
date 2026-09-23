# frozen_string_literal: true

# tree/easy/preorder_traversal.rb

# Problem
# https://leetcode.com/problems/binary-tree-preorder-traversal/description/

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
# @return {Integer[]}
def preorder_traversal(root)
  res = []
  def preorder(root, res)
    return if root.nil?

    res << root.val

    preorder(root.left, res)
    preorder(root.right, res)
  end
  preorder(root, res)
  res
end
