package sliding_window.medium;

import java.util.HashMap;
import java.util.Map;

// https://leetcode.com/problems/permutation-in-string/

public class StringPermutations {
    public boolean checkInclusion(String s1, String s2) {
        if(s1.length()==0){return true;}
        Map<Character,Integer> need = new HashMap<>();
        Map<Character,Integer> window = new HashMap<>();
        for(char i:s1.toCharArray()){
            need.merge(i,1,Integer::sum);
        }

        int left = 0;
        int right = 0;
        while(right<s2.length()){
            window.merge(s2.charAt(right), 1, Integer::sum);
            if(right-left+1>s1.length()){
                window.put(s2.charAt(left),window.get(s2.charAt(left))-1);
                if(window.get(s2.charAt(left))==0){window.remove(s2.charAt(left));}
                left++;
            }
            if(window.equals(need)){return true;}
            right++;
        }
        return false;
    }

}
