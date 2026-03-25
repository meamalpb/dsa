# frozen_string_literal: true

# sliding_window/easy/buy_sell_stocks.rb

# Problem
# https://leetcode.com/problems/best-time-to-buy-and-sell-stock/

# @param {Integer[]} prices
# @return {Integer}
def max_profit(prices)
  result = 0
  min = 1_000_000
  prices.each do |price|
    min = [price, min].min
    result = [result, price - min].max
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p max_profit([7, 1, 5, 3, 6, 4])
  p max_profit([7, 6, 4, 3, 1])
end
