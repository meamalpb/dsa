package two_pointers.medium;

// https://leetcode.com/problems/container-with-most-water/

public class ContainerWithMostWater {
    public int maxArea(int[] h) {
        int result = 0;
        int l = 0;
        int r = h.length;
        while (l < r) {
            int s = Math.min(h[l], h[r]);
            int t = s * (r - l);
            result = Math.max(result, t);
            if (h[l] > h[r]) {
                r--;
            } else {
                l++;
            }
        }
        return result;
    }

}
