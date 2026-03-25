# frozen_string_literal: true

# sliding_window/medium/longest_substring_without_repeating_characters.rb

# Problem
# https://leetcode.com/problems/longest-substring-without-repeating-characters/description/

# @param {String} s
# @return {Integer}
def length_of_longest_substring(s)
  left = 0
  result = 0
  k = {}
  i = 0
  s.each_char do |ss|
    if k.key?(ss) && k[ss] >= left
      left = k[ss] + 1
      k[ss] = i
    else
      k[ss] = i
      result = [i - left + 1, result].max
    end
    i += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p length_of_longest_substring('abcabcbb')
  p length_of_longest_substring('bbbbb')
  p length_of_longest_substring('pwwkew')
  p length_of_longest_substring('tmmzuxt')
end
