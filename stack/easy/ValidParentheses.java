package stack.easy;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;

// https://leetcode.com/problems/valid-parentheses/

public class ValidParentheses {
    public boolean isValid(String s) {
        Map<Character, Character> check = Map.of('}', '{', ')', '(', ']', '[');
        Deque<Character> stack = new ArrayDeque<>();
        for (int i = 0; i < s.length(); i++) {
            char k = s.charAt(i);
            if (check.containsValue(k)) {
                stack.push(k);
            } else if (check.containsValue(k)) {
                if ((stack.isEmpty()) || (stack.pop() != check.get(k))) {
                    return false;
                }
            }
        }

        if (stack.isEmpty()) {
            return true;
        }
        return false;
    }

    public static void main(String[] args) {
        String s = "amal";
        System.out.println(s.chars());
    }
}
