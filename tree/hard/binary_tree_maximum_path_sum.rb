# frozen_string_literal: true

# tree/hard/binary_tree_maximum_path_sum.rb

# Problem
# https://leetcode.com/problems/binary-tree-maximum-path-sum/
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
def max_path_sum(root)
  @r = root.val
  def dfs(root)
    return 0 if root.nil?

    lmax = [0, dfs(root.left)].max
    rmax = [0, dfs(root.right)].max
    @r = [@r, lmax + root.val + rmax].max
    root.val + [lmax, rmax].max
  end
  dfs(root)
  @r
end
