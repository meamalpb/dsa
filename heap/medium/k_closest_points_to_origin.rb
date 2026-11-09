# frozen_string_literal: true

# heap/medium/k_closest_points_to_origin.rb

# Problem
# https://leetcode.com/problems/k-closest-points-to-origin/

# frozen_string_literal: true

class MinHeap
  attr_accessor :data

  def initialize(arr = [])
    @data = arr.dup
    heapify
  end

  def push(val)
    @data << val
    sift_up(@data.size - 1)
  end

  def pop
    first = @data[0]
    last = @data.pop
    unless @data.empty?
      @data[0] = last
      sift_down(0)
    end
    first
  end

  def peek
    @data[0]
  end

  def size
    @data.size
  end

  private

  def heapify
    (@data.size / 2 - 1).downto(0) { |i| sift_down(i) }
  end

  def sift_up(i)
    while i.positive?
      parent = (i - 1) / 2
      break if @data[parent][0] <= @data[i][0]

      @data[parent], @data[i] = @data[i], @data[parent]
      i = parent
    end
  end

  def sift_down(i)
    n = @data.size
    loop do
      smallest = i
      l = 2 * i + 1
      r = 2 * i + 2
      smallest = l if l < n && @data[l][0] < @data[smallest][0]
      smallest = r if r < n && @data[r][0] < @data[smallest][0]
      break if smallest == i

      @data[smallest], @data[i] = @data[i], @data[smallest]
      i = smallest
    end
  end
end

# @param {Integer[][]} points
# @param {Integer} k
# @return {Integer[][]}
def k_closest(points, k)
  minh = []
  result = []
  points.each do |i|
    minh << [(i[0]**2 + i[1]**2), i[0], i[1]]
  end

  heap = MinHeap.new(minh)
  (1..k).each do |_i|
    _, x, y = heap.pop
    result << [x, y]
  end
  result
end

def k_closest_simple(points, _k)
  points.sort_by { |x, y| x**2 + y**2 }.take 2
end

if __FILE__ == $PROGRAM_NAME
  points = [[3, 3], [5, -1], [-2, 4]]
  k = 2
  p k_closest(points, k)
  p k_closest_simple(points, k)
end
