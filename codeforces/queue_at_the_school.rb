# frozen_string_literal: true

# problem
# http://codeforces.com/problemset/problem/266/B

firstarguments = gets.chomp.split(' ')
n = firstarguments.first.to_i
time = firstarguments.last.to_i
positions = gets.chomp

(0..time - 1).each do |_k|
  k = []

  (0..n).each do |i|
    next if i == n - 1

    c1 = positions[i]
    c2 = positions[i + 1]
    k.append([i, i + 1]) if c1 == 'B' && c2 == 'G'
  end
  k.each do |l|
    positions[l.first] = 'G'
    positions[l.last] = 'B'
  end
end
puts positions
