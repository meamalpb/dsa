# frozen_string_literal: true

# tree/medium/valid_bst.rb

# problem
# https://leetcode.com/problems/validate-binary-search-tree/description/

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
def is_valid_bst(root)
  def valid(root, left, right)
    return true if root.nil?
    return false if root.val <= left || root.val >= right

    valid(root.left, left, root.val) &&
      valid(root.right, root.val, right)
  end
  valid(root, -Float::INFINITY, Float::INFINITY)
end
