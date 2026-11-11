class Solution:
    def canAttendMeetings(self, intervals: List[Interval]) -> bool:
        ss = sorted(intervals,key=lambda x: x.start)
        if(len(ss)>0):
            last_max = ss[0].end
        for i in range(1,len(ss)):
            last_max = max(last_max,ss[i].end)
            if(ss[i].start<last_max):
                return False
        return True