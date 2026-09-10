# frozen_string_literal: true

# problem
# http://codeforces.com/problemset/problem/263/A


matrix = Array.new(5, Array.new(5, 0))
i = 0
f = 0
s = 0
5.times do
  k = gets.chomp.split(' ').map(&:to_i)
  (0..5).each do |j|
    matrix[i][j] = k[j]
    if k[j] == 1
      f = i
      s = j
    end
  end
  i += 1
end
puts (2 - f).abs + (2 - s).abs
