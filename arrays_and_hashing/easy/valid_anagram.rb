# frozen_string_literal: true

# arrays/easy/valid_anagram.rb

# Problem
# https://leetcode.com/problems/valid-anagram/description/

# @param {String} s
# @param {String} t
# @return {Boolean}
def is_anagram(string, target)
  return false if string.length != target.length

  char_count = Hash.new(0)

  string.each_char do |character|
    char_count[character] += 1
  end
  target.each_char do |character|
    return false unless char_count[character]&.positive?

    char_count[character] -= 1
  end
  #   char_count.values.uniq == [0]
  char_count.values.all?(&:zero?)
end

if __FILE__ == $PROGRAM_NAME
  puts is_anagram('anagram', 'nagaram')
  puts is_anagram('anagrame', 'nagawram')
end
