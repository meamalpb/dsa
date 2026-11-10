package stack.medium;

import java.util.ArrayDeque;
import java.util.Deque;

// https://leetcode.com/problems/min-stack/
class MinStack {

    Deque<Integer> st;
    Deque<Integer> min;

    public MinStack() {
        this.st = new ArrayDeque<>();
        this.min = new ArrayDeque<>();
    }

    public void push(int value) {
        st.push(value);
        if ((min.isEmpty()) || (min.peek() >= value)) {
            min.push(value);
        }
    }

    public void pop() {
        if (min.peek() >= st.pop()) {
            min.pop();
        }
    }

    public int top() {
        return st.peek();
    }

    public int getMin() {
        return min.peek();
    }
}
