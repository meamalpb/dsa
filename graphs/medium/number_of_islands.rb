# frozen_string_literal: true

# graphs/medium/number_of_islands.rb

# Problem
# https://leetcode.com/problems/number-of-islands/
def num_islands(grid)
  return 0 if grid.empty?

  rows = grid.length
  cols = grid[0].length
  island = 0
  dfs = lambda { |r, c|
    q = []
    grid[r][c] = '0'
    q << [r, c]
    until q.empty?
      row, col = q.pop
      directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
      directions.each do |i, j|
        r = row + i
        c = col + j
        if r.between?(0, rows - 1) && c.between?(0, cols - 1) && grid[r][c] == '1'
          grid[r][c] = '0'
          q << [r, c]
        end
      end
    end
  }

  (0...rows).each do |r|
    (0...cols).each do |c|
      if grid[r][c] == '1'
        dfs.call(r, c)
        island += 1
      end
    end
  end
  island
end

if __FILE__ == $PROGRAM_NAME
  grid = [%w[1 1 1 1 0], %w[1 1 0 1 0], %w[1 1 0 0 0], %w[0 0 0 0 0]]
  p num_islands(grid)
  grid = [%w[1 1 0 0 0], %w[1 1 0 0 0], %w[0 0 1 0 0], %w[0 0 0 1 1]]
  p num_islands(grid)
end
