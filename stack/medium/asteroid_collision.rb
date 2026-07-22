# frozen_string_literal: true

# stack/medium/asteroid_collision.rb

# Problem
# https://leetcode.com/problems/asteroid-collision/description/

# @param {Integer[]} asteroids
# @return {Integer[]}
def asteroid_collision(asteroids)
    stack = []
    asteroids.each do |a|
        while stack.any? && a.negative? && stack[-1].positive?
            diff = a+stack[-1]
            if diff.positive?
                a=0
            elsif diff.negative?
                stack.pop
            else
                a=0
                stack.pop
            end
        end
        stack<<a if a!=0
    end
    stack
end


if __FILE__ == $PROGRAM_NAME
  p asteroid_collision([5,10,-5])
  p asteroid_collision([8,-8])
  p asteroid_collision([10,2,-5])
  p asteroid_collision([3,5,-6,2,-1,4])
end
