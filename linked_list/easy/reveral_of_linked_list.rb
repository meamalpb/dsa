# frozen_string_literal: true

# linked_list/easy/reveral_of_linked_list.rb

# Problem
# https://leetcode.com/problems/reverse-linked-list/description/

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end

require_relative '../helpers/utils'

# @param {ListNode} head
# @return {ListNode}
def reverse_list(head)
  current = head
  previous = nil
  until current.nil?
    temp = current.next
    current.next = previous
    previous = current
    current = temp
  end
  previous
end

def runner(input)
  head = LinkedListUtils.build_list(input)
  result = reverse_list(head)

  p LinkedListUtils.to_array(result) # [5,4,3,2,1]
end

if __FILE__ == $PROGRAM_NAME
  runner([1, 2, 3, 4, 5])
  runner([1, 2])
  runner([1])
end
