# frozen_string_literal: true

# linked_list/easy/merge_two_lists.rb

# Problem
# https://leetcode.com/problems/merge-two-sorted-lists/

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end

require_relative '../helpers/utils'

# @param {ListNode} list1
# @param {ListNode} list2
# @return {ListNode}
def merge_two_lists(list1, list2)
  h = ListNode.new(nil)
  temp = h
  while list1 && list2
    if list1.val > list2.val
      temp.next = list2
      temp = temp.next
      list2 = list2.next
    else
      temp.next = list1
      temp = temp.next
      list1 = list1.next
    end
  end
  temp.next = list1 if list1
  temp.next = list2 if list2
  h.next
end

def runner(input1, input2)
  head1 = LinkedListUtils.build_list(input1)
  head2 = LinkedListUtils.build_list(input2)
  result = merge_two_lists(head1, head2)

  p LinkedListUtils.to_array(result) # [5,4,3,2,1]
end

def pp(h)
  p LinkedListUtils.to_array(h)
end

if __FILE__ == $PROGRAM_NAME
  runner([1, 2, 4], [1, 3, 4])
  runner([], [])
  runner([], [0])
  runner([1, 255], [0, 2, 23, 34])
end
