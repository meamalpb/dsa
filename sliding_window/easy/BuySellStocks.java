package sliding_window.easy;

// https://leetcode.com/problems/best-time-to-buy-and-sell-stock/

public class BuySellStocks {

    public int maxProfit(int[] prices) {
        int lowst = prices[0];
        int result = 0;
        for(int i: prices){
            if(i<lowst){lowst = i;}
            if(result<(i-lowst)){result = i-lowst;}
        }
        return result;    
    }
}
