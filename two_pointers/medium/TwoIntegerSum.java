package two_pointers.medium;

// https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/

public class TwoIntegerSum {
    public int[] twoSum(int[] nums, int t) {
        int[] result = new int[2];
        int l = 0;
        int r = nums.length-1;
        while(l<r){
            int sum = nums[l]+nums[r];
             if(sum<t){
                l++;
            }else if(sum>t){
                r--;
            }else{
                result[0] = l+1;
                result[1] = r+1;
                return result;
            }
        }
        return result;
    }

}
