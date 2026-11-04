# frozen_string_literal: true

# tree/hard/serialize_and_deserialize_binary_tree.rb

# Problem
# https://leetcode.com/problems/serialize-and-deserialize-binary-tree/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# frozen_string_literal: true

# tree/hard/serialize_and_deserialize_binary_tree.rb

# Problem
# https://leetcode.com/problems/serialize-and-deserialize-binary-tree/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# Encodes a tree to a single string.
#
# @param {TreeNode} root
# @return {string}
def serialize(root)
  @a = []
  def dfs(root)
    if root.nil?
      @a.append('N')
    else
      @a.append(root.val)
      dfs(root.left)
      dfs(root.right)
    end
  end
  dfs(root)
  @a.join(',')
end

# Decodes your encoded data to tree.
#
# @param {string} data
# @return {TreeNode}
def deserialize(data)
  @data = data.split(',')
  @i = 0
  def dfs
    if @data[@i] == 'N'
      @i += 1
      nil
    else
      node = TreeNode.new(@data[@i].to_i)
      @i += 1
      node.left = dfs
      node.right = dfs
      node
    end
  end
  dfs
end
