# frozen_string_literal: true

# linked_list/medium/implement_linked_list.rb

# Problem
# https://leetcode.com/problems/design-linked-list/

class Node
  attr_accessor :val, :next

  def initialize(val)
    @val = val
    @next = nil
  end
end

class MyLinkedList
  def initialize
    @head = Node.new(nil)
  end

  def get(index)
    i = 0
    current = @head
    while i < index
      current = current&.next
      i += 1
    end
    current&.val || -1
  end

  def add_at_head(val)
    if @head.val.nil?
      @head.val = val
    else
      new_one = Node.new(val)
      new_one.next = @head
      @head = new_one
    end
  end

  def add_at_tail(val)
    if @head.val.nil?
      @head.val = val
    else
      current = @head
      current = current.next until current.next.nil?
      new_one = Node.new(val)
      current.next = new_one
    end
  end

  def add_at_index(index, val)
    if index.zero?
      add_at_head(val)
    else
      i = 0
      current = @head
      while i < index - 1
        current = current&.next
        i += 1
      end
      if current
        new_one = Node.new(val)
        new_one.next = current.next
        current.next = new_one
      end
    end
  end

  def delete_at_index(index)
    if index.zero?
      @head = @head.next
    else
      i = 0
      current = @head
      while i < index - 1 && current
        current = current.next
        i += 1
      end
      current.next = current.next&.next if current
    end
  end
end

obj = MyLinkedList.new
obj.get(0)
obj.add_at_head(1)
obj.add_at_tail(2)
obj.add_at_index(1, 3)
obj.get(1)
obj.delete_at_index(1)

obj = MyLinkedList.new
obj.add_at_tail(1)
obj.get(0)

obj = MyLinkedList.new
obj.add_at_head(4)
obj.get(1)
