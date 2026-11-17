package binary_search.medium;

// https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/

public class MinimumInSortedArray {
    public int findMin(int[] nums) {
        int l = 0;
        int r = nums.length - 1;
        while(l<r){
            int m = (l+r)/2;
            // ordered correctly
            if(nums[m]>nums[r]){
                l = m+1;
            }else{
                r=m;
            }
        }
        return nums[l];
    }

}
