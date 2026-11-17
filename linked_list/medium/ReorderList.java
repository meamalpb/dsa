package linked_list.medium;

// https://leetcode.com/problems/reorder-list/

public class ReorderList {
    public void reorderList(ListNode head) {
        ListNode dummy = head;
        ListNode slow = head;
        ListNode fast = head;
        while(fast!=null && fast.next!=null){
            slow = slow.next;
            fast = fast.next.next;
        }
        ListNode r = slow.next;
        slow.next = null;
        ListNode p  =null;
        while(r!=null){
            ListNode t = r.next;
            r.next = p;
            p = r;
            r = t;
        }
        while(p!=null && dummy!=null){
            ListNode t1 = dummy.next;
            ListNode t2 = p.next;
            dummy.next = p;
            dummy = t1;
            p.next = dummy;
            p = t2;
        }
    }

}
