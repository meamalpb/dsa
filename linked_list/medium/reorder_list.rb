# frozen_string_literal: true

# linked_list/medium/reorder_list.rb

# Problem
# https://leetcode.com/problems/reorder-list/description/

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
# @return {Void} Do not return anything, modify head in-place instead.
def reorder_list(head)
    slow = head
    fast = head.next
    while fast && fast.next
        slow = slow.next
        fast = fast.next.next 
    end

    reverse_head = slow.next
    slow.next=nil
    previous = nil
    while reverse_head
        temp = reverse_head.next
        reverse_head.next = previous
        previous = reverse_head
        reverse_head = temp
    end
    reverse_head = previous
    new_head = head
    while new_head && reverse_head
        temp1 = new_head.next
        temp2 = reverse_head.next

        new_head.next = reverse_head
        reverse_head.next = temp1
        new_head= temp1
        reverse_head = temp2
    end
    head
end


def runner(input)
  head = LinkedListUtils.build_list(input)
  result = reorder_list(head)

  p LinkedListUtils.to_array(result)
end

if __FILE__ == $PROGRAM_NAME
  runner([1, 2, 3, 4, 5])
  runner([1, 2, 3, 4])
end
