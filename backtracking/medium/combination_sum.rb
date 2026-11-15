# frozen_string_literal: true

# backtracking/medium/combination_sum.rb

# Problem
# https://leetcode.com/problems/combination-sum/

def combination_sum(candidates, target)
  @r = []
  @target = target
  @c = candidates
  def dfs(i, subset, total)
    if @target == total
      @r.append(subset.clone) 
      return
    end

    return if i == @c.length || total > @target

    subset.append(@c[i])
    dfs(i, subset, total + @c[i])
    subset.pop
    dfs(i + 1, subset, total)
  end

  dfs(0, [], 0)
  @r.uniq
end
if __FILE__ == $PROGRAM_NAME
  candidates = [2, 3, 6, 7]
  target = 7
  p combination_sum(candidates, target)
end
