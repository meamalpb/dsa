package sliding_window.medium;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

// https://leetcode.com/problems/longest-repeating-character-replacement/

public class LongestRepeatingCharacterReplacement {
    public static int characterReplacement(String s, int k) {
        int result = 0;
        int left = 0;
        int right = 0;
        Map<Character,Integer> check = new HashMap<>();
        while(right<s.length()){
            check.put(s.charAt(right),check.getOrDefault(s.charAt(right), 0)+1);
            int max_value = Collections.max(check.values());
            if((right-left+1)-max_value<=k){
                result = Math.max(result,right-left+1);
            }else{
                check.put(s.charAt(left),check.get(s.charAt(left))-1);
                left++;
            }
            right++;
        }
        System.out.println(check);
        return result;
    }

    public static void main(String[] args) {
        String s = "AABABBA";int k = 1;
        int kk = characterReplacement(s, k);
        System.out.println(kk);
    }
}
