package arrays_and_hashing.medium;

import java.util.ArrayList;
import java.util.Arrays;

// https://leetcode.com/problems/merge-intervals/

public class MergeIntervals {
    public int[][] merge(int[][] intervals) {
        Arrays.sort(intervals,(a,b) -> Integer.compare(a[0],b[0]));
        ArrayList<int[]> result = new ArrayList<>();
        result.add(intervals[0]);
        for(int[] i: intervals){
            int[] last = result.get(result.size()-1);
            if(last[1] >= i[0]){
                result.get(result.size()-1)[1] = Math.max(last[1],i[1]);
            }else{
                result.add(i);
            }
        }
        return result.toArray(new int[result.size()][]);
    }

}
