package binary_search.medium;

// https://leetcode.com/problems/search-in-rotated-sorted-array/

public class SearchInRotatedArray {
        public  static int search(int[] nums, int target) {
            int l = 0;
            int r = nums.length - 1;

            while (l <= r) {
                int m = (l + r) / 2;
                if (nums[m] == target) {
                    return m;
                }
                if (nums[l] <= nums[m]) {
                    if ((target >= nums[l]) && (target < nums[m])) {
                        r = m - 1;
                    } else {
                        l = m + 1;
                    }
                } else {
                    if ((nums[m] < target) && (nums[r] >= target)) {
                        l = m + 1;
                    } else {
                        r = m - 1;
                    }
                }
            }
            return -1;
        }

        public static void main(String[] args) {
            int[] nums ={4,5,6,7,0,1,2};
            System.out.println(search(nums,0));
        }

}
