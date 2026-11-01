# frozen_string_literal: true

# heap/easy/last_stone_weight.rb

# Problem
# https://leetcode.com/problems/last-stone-weight/

require_relative '../../linked_list/helpers/min_heap'

def last_stone_weight(stones)
  ss = MinHeap.new(stones.map(&:-@))
  while ss.size > 1
    f = ss.pop
    s = ss.pop
    ss.push((f - s).abs * -1) if (f - s).abs.positive?
    p ss.data
  end
  ss.pop&.abs || 0
end

if __FILE__ == $PROGRAM_NAME
  stones = [3, 7, 2]
  p last_stone_weight(stones)
end
