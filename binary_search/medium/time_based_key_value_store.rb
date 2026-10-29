# frozen_string_literal: true

# binary_search/medium/time_based_key_value_store.rb

# Problem
# https://leetcode.com/problems/time-based-key-value-store/

class TimeMap
  def initialize
    @store = {}
  end

  #     :type key: String
  #     :type value: String
  #     :type timestamp: Integer
  #     :rtype: Void
  def set(key, value, timestamp)
    @store[key] ||= []
    @store[key].unshift([timestamp, value])
  end

  #     :type key: String
  #     :type timestamp: Integer
  #     :rtype: String
  def get(key, timestamp)
    timestamps = @store[key]
    return '' if timestamps.nil?

    store_value = timestamps.bsearch { |store_timestamp, _value| store_timestamp <= timestamp }
    return '' if store_value.nil?

    store_value[1]
  end
end

# Your TimeMap object will be instantiated and called as such:
# obj = TimeMap.new()
# obj.set(key, value, timestamp)
# param_2 = obj.get(key, timestamp)
