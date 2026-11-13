package binary_search.medium;

import java.util.Arrays;

// https://leetcode.com/problems/koko-eating-bananas/

public class KokoEatingBananas {
    public int minEatingSpeed(int[] piles, int h) {
        int l = 1;
        int r = Arrays.stream(piles).max().getAsInt();
        int result = r;
        while(l<=r){
            int m = (l+r)/2;
            long hours = 0;
            for(int i =0;i<piles.length;i++){
                hours += (piles[i]+m-1)/m;
            }
            if(hours>h){
                l=m+1;
            }else{
                result = Math.min(m, result);
                r=m-1;
            }
        }
        return result;
    }

}
