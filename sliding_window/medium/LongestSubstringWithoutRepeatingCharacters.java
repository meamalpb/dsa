package sliding_window.medium;

import java.util.HashMap;

// https://leetcode.com/problems/longest-substring-without-repeating-characters/

public class LongestSubstringWithoutRepeatingCharacters {
    public Integer lengthOfLongestSubstring(String s) {
        int left = 0;
        int right = 0;
        int result = 0;
        HashMap<Character,Integer> check = new HashMap<>();
        while(right<s.length()){
            char i = s.charAt(right);
            if((check.containsKey(i)) && check.get(i)>=left){
                left = check.get(i)+1;
                check.put(i, right);
            }else{
                check.put(i, right);
            }
            result = Math.max(result,right-left+1);
            right++;
        }
        return result;
    }

}
