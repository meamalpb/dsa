# frozen_string_literal: true

# arrays/easy/contains_duplicate.rb

# Problem
# https://leetcode.com/problems/contains-duplicate/description/

# @param {Integer[]} nums
# @return {Boolean}

# --------------------------
# Approach 1 - hash lookup
# --------------------------
def contains_duplicate(nums)
  dup = {}
  nums.each do |num|
    return true if dup.key? num

    dup[num] = 0
  end
  false
end

# --------------------------
# Approach 2 - Array length uniq
# --------------------------
def contains_duplicate_uniq(nums)
  nums.uniq.length != nums.length
end

if __FILE__ == $PROGRAM_NAME
  puts contains_duplicate([1, 2, 3])
  puts contains_duplicate([1, 1, 3])

  puts contains_duplicate_uniq([1, 2, 3])
  puts contains_duplicate_uniq([1, 1, 3])

end
