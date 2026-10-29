# frozen_string_literal: true

# linked_list/medium/add_two_numbers.rb

# Problem
# https://leetcode.com/problems/add-two-numbers/
# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode} l1
# @param {ListNode} l2
# @return {ListNode}
def add_two_numbers(l1, l2)
  n1 = ''
  n2 = ''
  h1 = l1
  h2 = l2
  while h1
    n1 += h1.val.to_s
    h1 = h1.next
  end
  while h2
    n2 += h2.val.to_s
    h2 = h2.next
  end
  n1 = n1.reverse.to_i
  n2 = n2.reverse.to_i
  r = (n1 + n2).to_s.reverse
  d = ListNode.new(nil)
  h = d
  r.each_char do |i|
    h.next = ListNode.new(i.to_i)
    h = h.next
  end
  d.next
end