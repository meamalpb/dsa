package arrays_and_hashing.easy;

import java.util.HashSet;

// https://leetcode.com/problems/contains-duplicate/

public class ContainsDuplicate {

    public static boolean containsDuplicate(int[] nums) {
        HashSet<Integer> seen = new HashSet<>();
        for (int i : nums) {
            if (seen.contains(i)) {
                return true;
            }
            seen.add(i);
        }
        return false;
    }

    public static void main(String[] args) {
        // tests go here
    }
}
