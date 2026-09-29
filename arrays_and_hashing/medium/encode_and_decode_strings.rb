# frozen_string_literal: true

# arrays_and_hashing/medium/encode_and_decode_strings.rb

# Problem
# https://leetcode.com/problems/encode-and-decode-strings/

def encode(strs)
  r = ''
  strs.each do |s|
    r = r + s.length.to_s + '#' + s
  end
  r
end

def decode(s)
  r = []
  i = 0
  while i < s.length
    j = i
    j += 1 while s[j] != '#'
    c = s[i...j].to_i
    r.append(s[j + 1...j + 1 + c])
    i = j + 1 + c
  end
  r
end

if __FILE__ == $PROGRAM_NAME
  strs = ['we', 'say', ':', 'yes', "!@\#$%^&*()"]
  p decode(encode(strs))
end
