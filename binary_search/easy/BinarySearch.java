package binary_search.easy;

// https://leetcode.com/problems/binary-search/

public class BinarySearch {
    public int search(int[] nums, int target) {
        int l = 0;
        int r = nums.length;
        while(l<=r){
            int m = (l+r)/2;
            int main = nums[m];
            if(main>target){
                r=m-1;
            }else if(main<target){
                l=m+1;
            }else{
                return m;
            }
        }
        return -1;
    }
}
