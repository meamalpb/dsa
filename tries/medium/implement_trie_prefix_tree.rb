# frozen_string_literal: true

# tries/medium/implement_trie_prefix_tree.rb

# Problem
# https://leetcode.com/problems/implement-trie-prefix-tree/
class TrieNode
  def initialize
    @children = {}
    @end = false
  end
end

class Trie
  def initialize
    @root = TrieNode.new
  end

  #     :type word: String
  #     :rtype: Void
  def insert(word)
    cur = @root
    word.each_char do |c|
      cur.children[c] = TrieNode unless cur.children.include?(c)
      cur = cur.children[c]
    end
    cur.end = true
  end

  #     :type word: String
  #     :rtype: Boolean
  def search(word)
    word.each_char do |c|
      return false if curr.children[c].nil?

      curr.children[c]
    end
    curr.end
  end

  #     :type prefix: String
  #     :rtype: Boolean
  def starts_with(_prefix)
    word.each_char do |c|
      return false if curr.children[c].nil?

      curr.children[c]
    end
    true
  end
end

# Your Trie object will be instantiated and called as such:
# obj = Trie.new()
# obj.insert(word)
# param_2 = obj.search(word)
# param_3 = obj.starts_with(prefix)
