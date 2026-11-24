# frozen_string_literal: true

# backtracking/hard/n_queens.rb

# Problem
# https://leetcode.com/problems/n-queens/

require 'set'
def solve_n_queens(n)
  @cols = Set.new
  @pdiag = Set.new
  @ndiag = Set.new

  @res = []
  @n = n
  @board = Array.new(n) { Array.new(n, '.') }
  backtrack(0)
  @res
end

def backtrack(i)
  return @res << @board.map { |k| k.join('') } if i == @n

  (0...@n).each do |c|
    next if @cols.include?(c) || @pdiag.include?(i + c) || @ndiag.include?(i - c)

    @cols.add c
    @pdiag.add i + c
    @ndiag.add i - c
    @board[i][c] = 'Q'
    backtrack(i + 1)
    @cols.delete c
    @pdiag.delete i + c
    @ndiag.delete i - c
    @board[i][c] = '.'
  end
end

if __FILE__ == $PROGRAM_NAME
  n = 4
  p n_queens(n)
end
