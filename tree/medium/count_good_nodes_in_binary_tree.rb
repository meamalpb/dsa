# frozen_string_literal: true

# tree/medium/count_good_nodes_in_binary_tree.rb

# Problem
# https://leetcode.com/problems/count-good-nodes-in-binary-tree/
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
def good_nodes(root)
  dfs(root, root.val)
end

def dfs(root, max_value)
  res = if root.val >= max_value
          1
        else
          0
        end
  max_value = [root.val, max_value].max
  res += dfs(root.left, max_value)
  res += dfs(root.right, max_value)
  res
end
