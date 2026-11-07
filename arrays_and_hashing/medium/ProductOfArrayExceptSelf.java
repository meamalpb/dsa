package arrays_and_hashing.medium;

import java.util.Arrays;

// https://leetcode.com/problems/product-of-array-except-self/

public class ProductOfArrayExceptSelf {
    public int[] productExceptSelf(int[] nums) {
        int n = nums.length;
        int[] pre = new int[n];
        int[] suf = new int[n];
        Arrays.fill(pre, 1);
        Arrays.fill(suf, 1);

        for (int i = 0; i < n - 1; i++) {
            pre[i + 1] = pre[i] * nums[i];
            suf[n - i + 2] = suf[n - i + 1] * nums[n - i + 1];
        }
        for (int i = 0; i < n - 1; i++) {
            pre[i] = pre[i] * suf[i];
        }
        return pre;
    }

}
