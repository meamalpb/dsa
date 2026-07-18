# frozen_string_literal: true

# two_pointers/easy/valid_palindrome_2.rb

# Problem
# https://leetcode.com/problems/valid-palindrome-ii/

# @param {String} s
# @return {Boolean}
def valid_palindrome(s)
  left = 0
  right = s.length - 1
  f = false
  while left < right
    if s[left] != s[right]
      return false if f == true

      k = if left.zero?
            s[left + 1..]
          else
            s[..left - 1] + s[left + 1..]
          end
      return true if k == k.reverse

      k = s[..right - 1] + s[right + 1..]
      return true if k == k.reverse

      return false

    else
      left += 1
      right -= 1
    end
  end
  true
end

if __FILE__ == $PROGRAM_NAME
  p valid_palindrome('abca')
  p valid_palindrome('aba')
  p valid_palindrome('abc')
  p valid_palindrome('acbbba')
end
