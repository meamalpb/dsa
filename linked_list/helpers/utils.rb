# frozen_string_literal: true

require_relative 'list_node'

module LinkedListUtils
  module_function

  # array -> linked list
  def build_list(arr, cycle_pos: nil)
    return nil if arr.empty?

    cycle_head = nil
    head = ListNode.new(arr[0])
    current = head
    index = 0
    arr[1..].each do |val|
      cycle_head = current if index == cycle_pos
      current.next = ListNode.new(val)
      current = current.next
    end
    current.next = cycle_head
    head
  end

  # linked list -> array
  def to_array(head)
    result = []
    current = head

    while current
      result << current.val
      current = current.next
    end

    result
  end

  # pretty print (optional)
  def print_list(head)
    values = to_array(head)
    puts values.join(' -> ')
  end
end
