package arrays_and_hashing.medium;

import java.util.ArrayList;
import java.util.List;

// https://leetcode.com/problems/encode-and-decode-strings/

public class EncodeAndDecodeStrings {
    public String encode(List<String> strs) {
        StringBuilder result = new StringBuilder();
        for (String i : strs) {
            result.append(i.length());
            result.append("#");
            result.append(i);
        }
        return result.toString();
    }

    public List<String> decode(String str) {
        ArrayList<String> result = new ArrayList<>();
        int i = 0;
        while (i < str.length()) {
            int j = i;
            while (str.charAt(j) != '#') {
                j++;
            }
            int c = Integer.parseInt(str.substring(i, j));
            result.add(str.substring(j + 1, j + 1 + c));
            i = j + 1 + c;
        }
        return result;
    }

}
