# frozen_string_literal: true

# random/easy/palindrome_number.rb

# Problem
# https://leetcode.com/problems/palindrome-number/

# @param {Integer} x
# @return {Boolean}
def is_palindrome(x)
  return false if x.negative?

  return true if x < 10

  r = 0
  temp = x
  while temp != 0
    r = r * 10 + temp % 10
    temp /= 10
  end
  r == x
end

if __FILE__ == $PROGRAM_NAME
  p is_palindrome(121)
  p is_palindrome(-121)
  p is_palindrome(10)
end
