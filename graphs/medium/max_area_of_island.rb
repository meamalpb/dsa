# frozen_string_literal: true

# graphs/medium/max_area_of_island.rb

# Problem
# https://leetcode.com/problems/max-area-of-island/
# @param {Integer[][]} grid
# @return {Integer}
def max_area_of_island(grid)
  return 0 if grid.empty?

  rows = grid.length
  cols = grid[0].length
  maxarea = 0

  dfs = lambda { |r, c|
    q = []
    n = 1
    grid[r][c] = '0'
    q << [r, c]
    until q.empty?
      row, col = q.pop
      directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
      directions.each do |i, j|
        r = row + i
        c = col + j
        next unless r.between?(0, rows - 1) && c.between?(0, cols - 1) && grid[r][c] == 1

        grid[r][c] = '0'
        n += 1
        q << [r, c]
      end
    end
    maxarea = [n, maxarea].max
  }

  (0...rows).each do |r|
    (0...cols).each do |c|
      dfs.call(r, c) if grid[r][c] == 1
    end
  end
  maxarea
end

if __FILE__ == $PROGRAM_NAME
  grid = [[0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
          [0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0]]
  p max_area_of_island(grid)
end
