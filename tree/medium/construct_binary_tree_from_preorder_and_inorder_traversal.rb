# frozen_string_literal: true

# tree/medium/construct_binary_tree_from_preorder_and_inorder_traversal.rb

# Problem
# https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val = 0, left = nil, right = nil)
#         @val = val
#         @left = left
#         @right = right
#     end
# end
# @param {Integer[]} preorder
# @param {Integer[]} inorder
# @return {TreeNode}
def build_tree(preorder, inorder)
  return nil if preorder.empty? || inorder.empty?

  root = TreeNode.new(preorder[0])
  mid = inorder.index(root.val)
  root.left = build_tree(preorder[1..mid], inorder[0...mid])
  root.right = build_tree(preorder[mid + 1..], inorder[mid + 1..])
  root
end
