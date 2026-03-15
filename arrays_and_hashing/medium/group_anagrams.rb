# frozen_string_literal: true

# arrays/medium/group_anagram.rb

# Problem
# https://leetcode.com/problems/group-anagrams/description/

# --------------
# Approach - 1
# Sorting the string and keeping the sorted string as key
# and actual strings as array of strings as value
# --------------
def group_anagrams_sorting(strs)
  h = {}
  strs.each do |i|
    if h.key?(i.chars.sort.join(''))
      h[i.chars.sort.join('')] << i
    else
      h[i.chars.sort.join('')] = [i]
    end
  end
  h.values
end

# --------------
# Approach - 2
# Make a counter hash and keep it as key
# and actual strings as array of strings as value
# --------------

def group_anagrams(strs)
  h = Hash.new { |h, key| h[key] = [] }
  strs.each do |string|
    temp_hash = Hash.new(0)
    string.each_char do |char|
      temp_hash[char] += 1
    end
    h[temp_hash].append(string)
  end
  h.values
end

# --------------
# Approach - 3
# Make a counter hash and make an array of 26 elements keeping it as key
# and actual strings as array of strings as value
# --------------

def group_anagrams_const_space(strs)
  h = Hash.new { |h, key| h[key] = [] }
  strs.each do |string|
    char_count_array = Array.new(26, 0)
    string.each_char do |char|
      char_count_array[char.ord - 97] += 1
    end
    h[char_count_array].append(string)
  end
  h.values
end

if __FILE__ == $PROGRAM_NAME
  p group_anagrams(%w[eat tea tan ate nat bat])
  p group_anagrams_sorting(%w[eat tea tan ate nat bat])
  p group_anagrams_const_space(%w[eat tea tan ate nat bat])
end
