# frozen_string_literal: true

# linked_list/hard/merge_k_sorted_lists.rb

# Problem
# https://leetcode.com/problems/merge-k-sorted-lists/

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode[]} lists
# @return {ListNode}
def merge_k_lists(lists)
  return lists[0] if lists.length < 2

  while lists.length != 1
    i = 0
    n = lists.length
    merged_lists = []
    while i < n
      l1 = lists[i]
      l2 = lists[i + 1]
      merged_list = merge_list(l1, l2)
      merged_lists << merged_list
      i += 2
    end
    lists = merged_lists
  end
  lists[0]
end

def merge_list(l1, l2)
  dummy = ListNode.new(0)
  tail = dummy
  while l1 && l2
    if l1.val < l2.val
      tail.next = l1
      l1 = l1.next
    else
      tail.next = l2
      l2 = l2.next
    end
    tail = tail.next
  end
  tail.next = l1 if l1
  tail.next = l2 if l2
  dummy.next
end

if __FILE__ == $PROGRAM_NAME
  # tests go here
end
