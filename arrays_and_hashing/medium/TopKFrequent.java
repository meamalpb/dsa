package arrays_and_hashing.medium;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// https://leetcode.com/problems/top-k-frequent-elements/

public class TopKFrequent {
    public int[] topKFrequent(int[] nums, int k) {
        HashMap<Integer, Integer> map = new HashMap<>();
        for (int i : nums) {
            map.put(i, map.getOrDefault(i, 0) + 1);
        }

        List<List<Integer>> buckets = new ArrayList<>();
        for (int i = 0; i < nums.length; i++) {
            buckets.add(new ArrayList<>());
        }

        for (Map.Entry<Integer, Integer> e : map.entrySet()) {
            buckets.get(e.getValue()).add(e.getKey());
        }
        int[] res = new int[k];
        int idx = 0;
        for (int f = buckets.size() - 1; f >= 0 && idx < k; f--) {
            for (int num : buckets.get(f)) {
                if (idx == k)
                    break;
                res[idx++] = num;
            }
        }
        return res;
    }

}
