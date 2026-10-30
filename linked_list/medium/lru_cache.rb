# frozen_string_literal: true

# linked_list/medium/lru_cache.rb

# Problem
# https://leetcode.com/problems/lru-cache/
class DLinkedList
  attr_accessor :key, :val, :prev, :next

  def initialize(key, val)
    @key = key
    @val = val
    @prev = nil
    @next = nil
  end
end

class LRUCache
  #     :type capacity: Integer
  def initialize(capacity)
    @capacity = capacity
    @size = 0
    @cache = {}
    @head = DLinkedList.new(nil, nil)
    @tail = DLinkedList.new(nil, nil)
    @head.next = @tail
    @tail.prev = @head
  end

  #     :type key: Integer
  #     :rtype: Integer
  def get(key)
    value = -1
    node = @cache[key]
    if node
      value = node.val
      remove_node(node)
      add_node(node)
    end
    value
  end

  #     :type key: Integer
  #     :type value: Integer
  #     :rtype: Void
  def put(key, value)
    if @cache[key]
      remove_node(@cache[key])
    else
      @size += 1
    end
    node = DLinkedList.new(key, value)
    add_node(node)
    @cache[key] = node
    return unless @size > @capacity

    temp = @tail.prev
    @cache.delete(temp.key)
    remove_node(temp)
    @size -= 1
  end

  def add_node(node)
    f = @head.next
    node.next = f
    f.prev = node
    @head.next = node
    node.prev = @head
  end

  def remove_node(node)
    f = node.prev
    n = node.next
    f.next = n
    n.prev = f
  end
end

# Your LRUCache object will be instantiated and called as such:
# obj = LRUCache.new(capacity)
# param_1 = obj.get(key)
# obj.put(key, value)
