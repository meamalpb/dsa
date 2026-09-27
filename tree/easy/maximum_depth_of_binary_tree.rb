# frozen_string_literal: true

# tree/easy/maximum_depth_of_binary_tree.rb

# Problem
# https://leetcode.com/problems/maximum-depth-of-binary-tree/

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
def max_depth(root)
  depth(root)
end

def depth(root)
  return 0 if root.nil?

  1 + [depth(root.left), depth(root.right)].max
end
