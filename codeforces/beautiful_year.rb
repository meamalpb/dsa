n = gets.chomp.to_i
i = n + 1
while true
  i0 = i.to_s[0]
  i1 = i.to_s[1]
  i2 = i.to_s[2]
  i3 = i.to_s[3]

  break if [i0, i1, i2, i3].uniq.length == 4

  i += 1
end
puts i
