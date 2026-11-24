# frozen_string_literal: true

# dp_1d/easy/min_cost_climbing_stairs.rb

# Problem
# https://leetcode.com/problems/min-cost-climbing-stairs/
# @param {Integer[]} cost
# @return {Integer}
def min_cost_climbing_stairs(cost)
  l1 = 0
  l2 = 0
  r = cost.length - 1
  while r >= 0
    current = cost[r] + [l1, l2].min
    l1 = l2
    l2 = current
    r -= 1
  end
  [l1, l2].min
end

if __FILE__ == $PROGRAM_NAME
  cost = [10, 15, 20]
  p min_cost_climbing_stairs(cost)
  cost = [1, 100, 1, 1, 1, 100, 1, 1, 100, 1]
  p min_cost_climbing_stairs(cost)

end
