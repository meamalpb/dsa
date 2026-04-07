# frozen_string_literal: true

require_relative 'list_node'

module LinkedListUtils
  module_function

  # array -> linked list
  def build_list(arr)
    return nil if arr.empty?

    head = ListNode.new(arr[0])
    current = head

    arr[1..].each do |val|
      current.next = ListNode.new(val)
      current = current.next
    end

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
