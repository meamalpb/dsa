# frozen_string_literal: true

# tree/medium/binary_tree_right_side_view.rb

# Problem
# https://leetcode.com/problems/binary-tree-right-side-view/

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
def right_side_view(root)
  res = []
  return [] if root.nil?

  q = [root]
  head = 0
  while head < q.length
    right_side = nil
    qlen = q.length - head
    qlen.times do |_i|
      node = q[head]
      head += 1
      next unless node

      right_side = node
      q << node.left if node.left
      q << node.right if node.right
    end
    res.append(right_side.val) if right_side

  end
  res
end
