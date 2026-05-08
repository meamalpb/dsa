# frozen_string_literal: true

# linked_list/easy/linked_list_cycle.rb

# Problem
# https://leetcode.com/problems/linked-list-cycle/description/

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
#     def initialize(val)
#         @val = val
#         @next = nil
#     end
# end

# @param {ListNode} head
# @return {Boolean}
# rubocop:disable Naming/MethodName
def hasCycle(head)
  f = head
  return false if f.nil?

  s = head.next
  return false if s.nil?

  while f && s&.next
    return true if f == s

    f = f.next
    s = s.next.next
  end
  false
end
# rubocop:enable Naming/MethodName

def runner(input_arr, pos)
  cycle_pos = pos == -1 ? nil : pos

  head = LinkedListUtils.build_list(input_arr, cycle_pos: cycle_pos)

  result = hasCycle(head)
  puts result
end

if __FILE__ == $PROGRAM_NAME
  runner([3, 2, 0, -4], 1) # true
  runner([1, 2], 0)        # true
  runner([1], -1)          # false
  runner([], -1)           # false
end
