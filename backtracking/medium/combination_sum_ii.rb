# frozen_string_literal: true

# backtracking/medium/combination_sum_ii.rb

# Problem
# https://leetcode.com/problems/combination-sum-ii/

# @param {Integer[]} candidates
# @param {Integer} target
# @return {Integer[][]}
def combination_sum2(candidates, target)
  @c = candidates.sort
  @t = target
  @r = []
  def dfs(i, subset, total)
    if total == @t
      @r << subset.clone
      return
    end
    return if total > @t || i == @c.length

    subset << @c[i]
    dfs(i + 1, subset, total + @c[i])
    subset.pop
    i += 1
    i += 1 while i < @c.length && @c[i] == @c[i - 1]
    dfs(i, subset, total)
  end
  dfs(0, [], 0)
  @r
end

if __FILE__ == $PROGRAM_NAME
  candidates = [10, 1, 2, 7, 6, 1, 5]
  target = 8
  p combination_sum2(candidates, target)

end
