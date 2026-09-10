# frozen_string_literal: true

# problem
# http://codeforces.com/problemset/problem/69/A

n = gets.chomp.to_i
a = 0
b = 0
c = 0
while n.positive?
  numbers = gets.chomp.split(' ').map(&:to_i)
  a += numbers[0]
  b += numbers[1]
  c += numbers[2]
  n -= 1
end
if [a, b, c] == [0, 0, 0]
  puts 'YES'
else
  puts 'NO'
end
