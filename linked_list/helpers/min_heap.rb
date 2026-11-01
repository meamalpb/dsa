# frozen_string_literal: true

class MinHeap
  def initialize
    @data = []
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

  def sift_up(i)
    while i.positive?
      parent = (i - 1) / 2
      break if @data[parent] <= @data[i]

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
      smallest = l if l < n && @data[l] < @data[smallest]
      smallest = r if r < n && @data[r] < @data[smallest]
      break if smallest == i

      @data[smallest], @data[i] = @data[i], @data[smallest]
      i = smallest
    end
  end
end
