# frozen_string_literal: true

# tree/easy/diameter_of_binary_tree.rb

# Problem
# https://leetcode.com/problems/diameter-of-binary-tree/
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
# @return {Integer}
def diameter_of_binary_tree(root)
  @r = 0
  def dfs(root)
    return 0 if root.nil?

    left = dfs(root.left)
    right = dfs(root.right)
    @r = [@r, left + right].max
    1 + [left, right].max
  end
  dfs(root)
  @r
end
