package two_pointers.medium;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// https://leetcode.com/problems/3sum/

public class ThreeSum {
    public List<List<Integer>> threeSum(int[] nums) {
        ArrayList<List<Integer>> result = new ArrayList<>();
        Arrays.sort(nums);

        for (int i = 0; i < nums.length; i++) {
            if (nums[i] > 0) {
                return result;
            }
            if ((i > 0) && (nums[i - 1] == nums[i])) {
                continue;
            }

            int l = i + 1;
            int r = nums.length - 1;

            while (l < r) {
                int sum = nums[l] + nums[r] + nums[i];
                if (sum == 0) {
                    result.add(new ArrayList<>(Arrays.asList(nums[i], nums[l], nums[r])));
                    l++;
                    while ((l < r) && (nums[l] == nums[l - 1])) {
                        l++;
                    }

                } else if (sum > 0) {
                    r -= 1;
                } else {
                    l += 1;

                }

            }
        }

        return result;

    }
}
