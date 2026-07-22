# frozen_string_literal: true

# sliding_window/medium/string_permutations.rb

# Problem
# https://leetcode.com/problems/permutation-in-string/

# @param {String} s1
# @param {String} s2
# @return {Boolean}
def check_inclusion(s1, s2)
  need = Hash.new(0)
  window = Hash.new(0)
  left = 0
  right = 0

  s1.each_char do |s|
    need[s] += 1
  end

  while right <= s2.length - 1
    window[s2[right]] += 1
    while right - left + 1 > s1.length
      window[s2[left]] -= 1
      window.delete(s2[left]) if window[s2[left]].zero?
      left += 1
    end
    return true if window == need

    right += 1
  end
  false
end

if __FILE__ == $PROGRAM_NAME
  p check_inclusion('ab', 'eidbaooo')
  p check_inclusion('ab', 'eidboaoo')
  p check_inclusion('hello', 'ooolleoooleh')
end
