# frozen_string_literal: true

# sliding_window/hard/minimum_window_substring.rb

# Problem
# https://leetcode.com/problems/minimum-window-substring/description/

# @param {String} s
# @param {String} t
# @return {String}
def min_window(s, t)
  need = {}
  window = Hash.new(0)
  left = 0
  right = 0
  n = s.length
  result_count = 99_999
  result = ''

  t.each_char do |tt|
    if need[tt]
      need[tt] += 1
    else
      need[tt] = 1
    end
  end
  required = need.count
  formed = 0

  while right < n
    if need[s[right]]
      window[s[right]] += 1
      formed += 1 if window[s[right]] == need[s[right]]
    end

    while formed == required
      if result_count > right - left + 1
        result = s[left..right]
        result_count = right - left + 1
      end

      window[s[left]] -= 1
      formed -= 1 if need[s[left]] && window[s[left]] < need[s[left]]

      left += 1
    end
    right += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p min_window('ADOBECODEBANC', 'ABC')
  p min_window('a', 'a')
  p min_window('ab', 'b')
  p min_window('cabwefgewcwaefgcf', 'cae')
end
