package stack.medium;

import java.util.ArrayList;
import java.util.List;

// https://leetcode.com/problems/daily-temperatures/

public class DailyTemperatures {
    public int[] dailyTemperatures(int[] temperatures) {
        List<Integer> unsolved = new ArrayList<>();
        int[] result = new int[temperatures.length];
        for(int i=0;i<temperatures.length;i++){
            while(!unsolved.isEmpty() && temperatures[i]>temperatures[unsolved.get(unsolved.size()-1)]){
                result[unsolved.get(unsolved.size()-1)]= i-unsolved.get(unsolved.size()-1);
                unsolved.removeLast();
            }
            unsolved.add(i);
        }
        return result;
    }
}
