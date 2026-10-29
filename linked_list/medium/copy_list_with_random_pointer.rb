# frozen_string_literal: true

# linked_list/medium/copy_list_with_random_pointer.rb

# Problem
# https://leetcode.com/problems/copy-list-with-random-pointer/
# Definition for Node.
# class Node
#     attr_accessor :val, :next, :random
#     def initialize(val = 0)
#         @val = val
#		  @next = nil
#		  @random = nil
#     end
# end

# @param {Node} node
# @return {Node}
def copyRandomList(head)
  d = {}
  cur = head
  while cur
    d[cur] = Node(cur.val)
    cur = cur.next
  end
  cur = head
  while cur
    d[cur].next = d[cur.next]
    d[cur].random = d[cur.random]
    cur = cur.next
  end
  d[head]
end
