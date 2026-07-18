# frozen_string_literal: true

# two_pointers/easy/reverse_string.rb

# Problem
# https://leetcode.com/problems/reverse-string/

# @param {Character[]} s
# @return {Void} Do not return anything, modify s in-place instead.
def reverse_string(s)
  i = 0
  n = s.length
  while i < (n / 2)
    temp = s[n - i - 1]
    s[n - i - 1] = s[i]
    s[i] = temp
    i += 1
  end
  s
end

if __FILE__ == $PROGRAM_NAME
  p reverse_string(%w[h e l l o])
  p reverse_string(%w[H a n n a h])
end
