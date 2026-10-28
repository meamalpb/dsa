# frozen_string_literal: true

# stack/medium/car_fleet.rb

# Problem
# https://leetcode.com/problems/car-fleet/

# @param {Integer} target
# @param {Integer[]} position
# @param {Integer[]} speed
# @return {Integer}
def car_fleet(t, position, speed)
  n = position.length
  i = 0
  cars = []
  result = []
  while i < n
    cars << [position[i], speed[i]]
    i += 1
  end
  cars = cars.sort_by { |c| c[0] * -1 }
  cars.each do |c|
    ttr = (t - c[0]) / (c[1] * 1.0)
    result << ttr if result.empty? || result[-1] < ttr
  end

  result.length
end

if __FILE__ == $PROGRAM_NAME
  target = 12
  position = [10, 8, 0, 5, 3]
  speed = [2, 4, 1, 1, 3]
  p car_fleet(target, position, speed)
end
