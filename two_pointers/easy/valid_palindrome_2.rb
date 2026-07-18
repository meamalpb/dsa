# frozen_string_literal: true

# two_pointers/easy/valid_palindrome_2.rb

# Problem
# https://leetcode.com/problems/valid-palindrome-ii/

# @param {String} s
# @return {Boolean}
def valid_palindrome(s)
    left = 0
    right=s.length-1
    f=false
    while left<right do
        if s[left]!=s[right]
            return false if f==true
            if left==0
                k= s[left+1..]
            else
                k =  s[..left-1]+s[left+1..]
            end
            if k==k.reverse
                return true
            else
                k = s[..right-1]+s[right+1..]
                return true if k==k.reverse
                return false
            end
        else
            left+=1
            right-=1
        end
    end
    return true
end


if __FILE__ == $PROGRAM_NAME
  p valid_palindrome('abca')
  p valid_palindrome('aba')
  p valid_palindrome('abc')
  p valid_palindrome('acbbba')
end
