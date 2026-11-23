# frozen_string_literal: true

# backtracking/medium/palindrome_partitioning.rb

# Problem
# https://leetcode.com/problems/palindrome-partitioning/
# @param {String} s
# @return {String[][]}
def partition(s)
  @r = []
  @s = s
  @p = []
  dfs(0)
  @r
end

def dfs(i)
  if i >= @s.length
    @r << @p.clone
    return
  end
  (i...@s.length).each do |j|
    next unless @s[i..j] == @s[i..j].reverse

    @p << @s[i..j]
    dfs(j + 1)
    @p.pop
  end
end

if __FILE__ == $PROGRAM_NAME
  s = 'aab'
  p partition(s)
end
