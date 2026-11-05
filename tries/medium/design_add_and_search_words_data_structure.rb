# frozen_string_literal: true

# tries/medium/design_add_and_search_words_data_structure.rb

# Problem
# https://leetcode.com/problems/design-add-and-search-words-data-structure/
class TrieNode
  attr_accessor :children, :endword

  def initialize
    @children = {}
    @endword = false
  end
end

class WordDictionary
  def initialize
    @root = TrieNode.new
  end

  #     :type word: String
  #     :rtype: Void
  def add_word(word)
    cur = @root
    word.each_char do |c|
      cur.children[c] = TrieNode.new if cur.children[c].nil?
      cur = cur.children[c]
    end
    cur.endword = true
  end

  #     :type word: String
  #     :rtype: Boolean
  def search(word)
    dfs(word, 0, @root)
  end

  def dfs(word, j, root)
    return root.endword if j == word.length

    c = word[j]
    if c == '.'
      root.children.each_value do |kid|
        return true if dfs(word, j + 1, kid)
      end
      false
    else
      kid = root.children[c]
      !kid.nil? && dfs(word, j + 1, kid)
    end
  end
end

# Your WordDictionary object will be instantiated and called as such:
# obj = WordDictionary.new()
# obj.add_word(word)
# param_2 = obj.search(word)
