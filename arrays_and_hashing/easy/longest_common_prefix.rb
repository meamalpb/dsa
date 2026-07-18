# frozen_string_literal: true

# arrays_and_hashing/easy/longest_common_prefix.rb

# Problem
# https://leetcode.com/problems/longest-common-prefix/

# @param {String[]} strs
# @return {String}
def longest_common_prefix(strs)
  (0..strs[0].length - 1).each do |i|
    strs[1..].each do |string|
      next unless string[i] != strs[0][i]
      return '' if i.zero?

      return strs[0][0..i - 1]
    end
  end
  strs[0]
end

if __FILE__ == $PROGRAM_NAME
  puts longest_common_prefix(%w[flower flow flight])
  puts longest_common_prefix(%w[dog racecar car])
end
