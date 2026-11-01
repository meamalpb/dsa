# frozen_string_literal: true

# linked_list/hard/reverse_nodes_in_k_group.rb

# Problem
# https://leetcode.com/problems/reverse-nodes-in-k-group/
# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode} head
# @param {Integer} k
# @return {ListNode}
def reverse_k_group(head, k)
  dummy = ListNode.new
  tail = dummy
  tail.next = head
  i = 0
  slow = head
  fast = head
  while fast
    fast = fast.next
    i += 1
    next unless i % k == 0

    l_node = reverse_list(slow, fast)
    tail.next = l_node
    slow.next = fast
    tail = slow
    slow = fast
  end
  dummy.next
end

def reverse_list(slow, fast)
  previous = nil
  while slow != fast
    temp = slow.next
    slow.next = previous
    previous = slow
    slow = temp
  end
  previous
end
