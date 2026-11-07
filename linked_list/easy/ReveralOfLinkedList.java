package linked_list.easy;

// https://leetcode.com/problems/reverse-linked-list/

/**
 * Definition for singly-linked list.
 * public class ListNode {
 * int val;
 * ListNode next;
 * ListNode() {}
 * ListNode(int val) { this.val = val; }
 * ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */

public class ReveralOfLinkedList {

    public ListNode reverseList(ListNode head) {
        ListNode previous = null;
        ListNode tail = head;
        while (tail != null) {
            ListNode temp = tail.next;
            tail.next = previous;
            previous = tail;
            tail = temp;
        }
        return previous;
    }
}
