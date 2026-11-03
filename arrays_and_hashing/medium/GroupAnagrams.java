package arrays_and_hashing.medium;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

// https://leetcode.com/problems/group-anagrams/

public class GroupAnagrams {
    public static List<List<String>> groupAnagrams(String[] strs) {
        HashMap<String, List<String>> res = new HashMap<>();
        for(String i:strs){
            int[] check = new int[26];
            for(char c: i.toCharArray()){
                check[c-'a']+=1;
            }
            String check2 = Arrays.toString(check);
            res.computeIfAbsent(check2, k -> new ArrayList<>()).add(i);
        }
        List<List<String>> ans = new ArrayList<>(res.values());
        System.out.println(res.keySet());
        return ans;
    }

    public static void main(String[] args) {
        String[] strs = {"eat","tea","tan","ate","nat","bat"};
        System.out.println(groupAnagrams(strs));
    }

}
