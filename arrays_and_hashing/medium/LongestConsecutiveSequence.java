package arrays_and_hashing.medium;

import java.util.HashSet;

// https://leetcode.com/problems/longest-consecutive-sequence/

public class LongestConsecutiveSequence {
    public int longestConsecutive(int[] nums) {
        int result = 0;
        // Set<Integer> numset = Arrays.stream(nums).boxed().collect(Collectors.toSet());
        HashSet<Integer> numset = new HashSet<>();
        for(int i:nums){
            numset.add(i);
        }
        for(int i: numset){
            int t = 1;
            if(!numset.contains(i-1)){
                int c = i;
                while(numset.contains(c+1)){
                    c++;
                    t++;
                }
            }
            result = Math.max(t, result);
        }
        return result;
    }
}
