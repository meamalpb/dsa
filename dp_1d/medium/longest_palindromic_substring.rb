# frozen_string_literal: true

# dp_1d/medium/longest_palindromic_substring.rb

# Problem
# https://leetcode.com/problems/longest-palindromic-substring/
# @param {String} s
# @return {String}
def longest_palindrome(s)
  res = ''
  (0..s.length-1).each do |i|
    l = i
    r = i
    while l >= 0 && r < s.length && s[l] == s[r]
      res = s[l..r] if r - l + 1 > res.length
      l -= 1
      r += 1
    end
    l = i
    r = i + 1
    while l >= 0 && r < s.length && s[l] == s[r]
      res = s[l..r] if r - l + 1 > res.length
      l -= 1
      r += 1
    end
  end
  res
end

if __FILE__ == $PROGRAM_NAME
s = "babad"
p longest_palindrome(s)
end
