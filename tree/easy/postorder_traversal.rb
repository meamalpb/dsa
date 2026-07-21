# frozen_string_literal: true

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
def postorder_traversal(root)
  res = []
  def postorder(root, res)
    return if root.nil?

    postorder(root.left, res)
    postorder(root.right, res)
    res << root.val
  end
  postorder(root, res)
  res
end
