# frozen_string_literal: true

# backtracking/medium/letter_combinations_of_a_phone_number.rb

# Problem
# https://leetcode.com/problems/letter-combinations-of-a-phone-number/
# @param {String} digits
# @return {String[]}
def letter_combinations(digits)
  @k = {
    2 => 'abc',
    3 => 'def',
    4 => 'ghi',
    5 => 'jkl',
    6 => 'mno',
    7 => 'pqrs',
    8 => 'tuv',
    9 => 'wxyz'
  }
  @digits = digits
  @r = []
  dfs(0, '')
  @r
end

def dfs(i, s)
  if i == @digits.length
    @r << s.clone
    return
  end
  @k[@digits[i].to_i].each_char do |c|
    dfs(i + 1, s + c)
  end
end

if __FILE__ == $PROGRAM_NAME
  digits = '23'
  p letter_combinations(digits)
  # tests go here
end
