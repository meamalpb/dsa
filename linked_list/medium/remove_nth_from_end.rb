# frozen_string_literal: true

# linked_list/medium/remove_nth_from_end.rb

# Problem
# https://leetcode.com/problems/remove-nth-node-from-end-of-list/

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end

require_relative '../helpers/utils'

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode} head
# @param {Integer} n
# @return {ListNode}
def remove_nth_from_end(head, n)
  dummy = ListNode.new(1000)
  dummy.next = head
  l = dummy
  r = head
  while n.positive? && r
    r = r.next
    n -= 1
  end

  while r
    l = l.next
    r = r.next
  end

  l.next = l.next.next

  dummy.next
end

def runner(input, n)
  head = LinkedListUtils.build_list(input)
  result = remove_nth_from_end(head, n)

  p LinkedListUtils.to_array(result)
end

if __FILE__ == $PROGRAM_NAME
  runner([1, 2, 3, 4, 5], 2)
  runner([1, 2], 1)
end
