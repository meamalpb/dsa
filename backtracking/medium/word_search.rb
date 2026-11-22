# frozen_string_literal: true

def exist(board, word)
  @rows = board.length
  @cols = board[0].length
  @word = word
  @board = board

  return false if word.length > rows * cols

  freq = Hash.new(0)
  board.each do |row|
    row.each { |ch| freq[ch] += 1 }
  end

  word.each_char do |ch|
    return false if freq[ch] < word.count(ch)
  end

  # Start from the rarer character
  word = word.reverse if freq[word[0]] > freq[word[-1]]

  rows.times do |r|
    cols.times do |c|
      return true if dfs(r, c, 0)
    end
  end

  false
end

def dfs(r, c, i)
  return true if i == @word.length

  next false if r.negative? || c.negative? || r >= rows || c >= cols
  next false if board[r][c] != word[i]

  ch = board[r][c]
  board[r][c] = nil

  found = dfs(r + 1, c, i + 1) ||
          dfs(r - 1, c, i + 1) ||
          dfs(r, c + 1, i + 1) ||
          dfs(r, c - 1, i + 1)

  board[r][c] = ch
  found
end
