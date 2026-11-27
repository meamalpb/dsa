# Definition for a Node.
# class Node
#     attr_accessor :val, :neighbors
#     def initialize(val = 0, neighbors = nil)
#		  @val = val
#		  neighbors = [] if neighbors.nil?
#         @neighbors = neighbors
#     end
# end

# @param {Node} node
# @return {Node}
def cloneGraph(node)
  return nil if node.nil?

  clones = {}
  deepclone(node, clones)
end

def deepclone(node, clones)
  return clones[node] if clones[node]

  cnode = Node.new(node.val)
  clones[node] = cnode
  cnode.val = node.val
  node.neighbors.each do |i|
    cnode.neighbors << deepclone(i, clones)
  end
  cnode
end
