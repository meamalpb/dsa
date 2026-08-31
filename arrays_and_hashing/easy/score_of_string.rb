# frozen_string_literal: true

# arrays_and_hashing/easy/score_of_string.rb

# Problem
# https://leetcode.com/problems/score-of-a-string/

# @param {String} s
# @return {Integer}
def score_of_string(s)
  n = s.length - 1
  i = 0
  result = 0
  while i < n
    result += (s[i].ord - s[i + 1].ord).abs
    i += 1
  end
  result
end

if __FILE__ == $PROGRAM_NAME
  p score_of_string('hello')
  p score_of_string('zaz')
end
