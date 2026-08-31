# frozen_string_literal: true

# arrays_and_hashing/easy/is_subsequence.rb

# Problem
# https://leetcode.com/problems/is-subsequence/

# @param {String} s
# @param {String} t
# @return {Boolean}
def is_subsequence(s, t)
  n1 = s.length
  n2 = t.length
  i = 0
  j = 0
  while j < n2
    i += 1 if s[i] == t[j]
    break if i == n1

    j += 1
  end
  i == n1
end

if __FILE__ == $PROGRAM_NAME
  puts is_subsequence('abc', 'ahbgdc')
  puts is_subsequence('axc', 'ahbgdc')
end
