# frozen_string_literal: true

# stack/easy/valid_parentheses.rb

# Problem
# https://leetcode.com/problems/valid-parentheses/description/

# @param {String} s
# @return {Boolean}
def is_valid(s)
  check = { ')' => '(', ']' => '[', '}' => '{' }
  r = []
  s.each_char do |ss|
    if check.value? ss
      r << ss
    elsif check.key? ss
      return false if r.pop != check[ss]
    end
  end
  r.empty?
end

if __FILE__ == $PROGRAM_NAME
  p is_valid '()'
  p is_valid '()[]{}'
  p is_valid '(]'
  p is_valid '([])'
  p is_valid '([)]'
end
