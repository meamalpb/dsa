# frozen_string_literal: true

# heap/medium/task_scheduler.rb

# Problem
# https://leetcode.com/problems/task-scheduler/

require_relative '../../linked_list/helpers/min_heap'

def least_interval(tasks, n)
  heap = MinHeap.new(tasks.tally.values.map(&:-@))
  q = []
  i = 0
  while heap.size.positive? || !q.empty?
    p "heap #{heap.data} q #{q}"
    i += 1
    if heap.size.positive?
      c = 1 + heap.pop
      q << [c, i + n] if c.negative?
    end

    next if q.empty?

    heap.push(q.shift[0]) if q[0][1] == i

  end
  i
end

if __FILE__ == $PROGRAM_NAME
tasks = ["A","A","A","B","B","B"]
 n = 2
p least_interval(tasks, n)

end
