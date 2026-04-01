# frozen_string_literal: true

# sliding_window/medium/longest_repeating_character_replacement.rb

# Problem
# https://leetcode.com/problems/longest-repeating-character-replacement/description/

# @param {String} s
# @param {Integer} k
# @return {Integer}
def character_replacement(s, k)
  left = 0
  right = 0
  kk = {}
  result = 0
  while right < s.length
    if kk.include? s[right]
      kk[s[right]] += 1
    else
      kk[s[right]] = 1
    end
    max_repeat = kk.values.max
    if (right - left + 1) - max_repeat <= k
      result = [result, right - left + 1].max
    else
      kk[s[left]] -= 1
      left += 1
    end
    right += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p character_replacement('ABAB', 2)
  p character_replacement('AABABBA', 1)
  p character_replacement('AABA', 0)
end
