# frozen_string_literal: true

# binary_search/medium/koko_eating_bananas.rb

# Problem
# https://leetcode.com/problems/koko-eating-bananas/
# @param {Integer[]} piles
# @param {Integer} h
# @return {Integer}
def min_eating_speed(piles, h)
  l = [piles.sum / h, 1].max
  r = piles.max
  res = r
  piles.length
  while l <= r
    m = (l + r) / 2
    hours = piles.sum { |pile| (pile + m - 1) / m } # ceil(pile / mid)
    if hours > h
      l = m + 1
    else
      res = [res, m].min
      r = m - 1
    end
  end
  res
end

if __FILE__ == $PROGRAM_NAME
  piles = [3, 6, 7, 11]
  h = 8
  p min_eating_speed(piles, h)

  piles = [30, 11, 23, 4, 20]
  h = 5
  p min_eating_speed(piles, h)

  piles = [30, 11, 23, 4, 20]
  h = 6
  p min_eating_speed(piles, h)

end
