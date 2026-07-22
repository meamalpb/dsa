# frozen_string_literal: true

# stack/medium/basic_calculator._iirb

# problem
# https://leetcode.com/problems/basic-calculator-ii/description/
# @param {String} s
# @return {Integer}
def calculate(s)
  stack = []
  num = 0
  sign = '+'

  s.each_char.with_index do |c, i|
    num = num * 10 + (c.ord - '0'.ord) if c >= '0' && c <= '9'
    if (!(c >= '0' && c <= '9') && c != ' ') || i == s.length - 1
      case sign
      when '+'
        stack << num
      when '-'
        stack << -num
      when '*'
        stack << stack.pop * num
      when '/'
        stack << (stack.pop.to_f / num).truncate
      end
      sign = c
      num = 0
    end
  end

  stack.sum
end

if __FILE__ == $PROGRAM_NAME
  p calculate('33+2*2')
  p calculate('3/2 ')
  p calculate('3+5 / 2 ')
end
