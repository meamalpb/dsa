# frozen_string_literal: true

# tree/medium/level_order_traversal.rb

# Problem
# https://leetcode.com/problems/binary-tree-level-order-traversal/

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
# @return {Integer[][]}
def level_order(root)
  queue = [root]
  result = []
  return [] if root.nil?

  while queue.any?
    l = queue.length
    levels = []

    (0..l - 1).each do
      node = queue.shift
      next unless node

      levels.append(node.val)
      queue.append(node.left)
      queue.append(node.right)
    end
    result << levels if levels
  end
  result
end
