# frozen_string_literal: true

# stack/medium/daily_temperatures.rb

# Problem
# https://leetcode.com/problems/daily-temperatures/description/

# @param {Integer[]} temperatures
# @return {Integer[]}
def daily_temperatures(temperatures)
  unsolved = []
  result = [0] * temperatures.length
  temperatures.each_with_index do |n, i|
    # p unsolved
    while !unsolved.empty? && n > unsolved.last[:val]
      j = unsolved.pop[:index]
      result[j] = i - j
    end
    unsolved << { val: n, index: i }
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p daily_temperatures([73, 74, 75, 71, 69, 72, 76, 73])
  p daily_temperatures([30, 40, 50, 60])
  p daily_temperatures([30, 60, 90])
end
