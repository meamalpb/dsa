# frozen_string_literal: true

# tree/easy/subtree_of_another_tree.rb

# Problem
# https://leetcode.com/problems/subtree-of-another-tree/
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
# @param {TreeNode} sub_root
# @return {Boolean}
def is_subtree(s, t)
  return true unless t
  return false unless s

  is_same_tree(s, t) || is_subtree(s.left, t) || is_subtree(s.right, t)
end

def is_same_tree(s, t)
  return true if !s && !t

  return is_same_tree(s.left, t.left) && is_same_tree(s.right, t.right) if ( s && t && s.val == t.val)

  false
end
