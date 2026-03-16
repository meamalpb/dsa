# frozen_string_literal: true

# two_pointers/easy/valid_palindrome.rb

# Problem
# https://leetcode.com/problems/valid-palindrome/description/

def is_palindrome(s)
  s = s.downcase.gsub(/[^a-zA-Z0-9]/, '')
  l = s.length
  i = 0
  while i < l
    return false if s[i] != s[l - i - 1]

    i += 1
  end
  true
end

if __FILE__ == $PROGRAM_NAME
  p is_palindrome('AMA')
  p is_palindrome('AMAL')
  p is_palindrome('A man, a plan, a canal: Panama')
  p is_palindrome('race a car')
  p is_palindrome(' ')
end
