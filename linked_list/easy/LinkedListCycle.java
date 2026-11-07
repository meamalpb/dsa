package linked_list.easy;

// https://leetcode.com/problems/linked-list-cycle/

public class LinkedListCycle {
    public boolean hasCycle(ListNode head) {
        ListNode slow = head;
        if(slow==null){return false;}
        ListNode fast = head.next;
        if(fast==null){return false;}

        while((fast!=null) && (fast.next!=null)){
            if(slow==fast){return true;}
            slow = slow.next;
            fast=fast.next.next;
        }
        return false;
    }

}
