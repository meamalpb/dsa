package binary_search.medium;

// https://leetcode.com/problems/search-a-2d-matrix/

public class SearchIn2dMatrix {
    public boolean searchMatrix(int[][] matrix, int target) {
        int l = 0;
        int r = matrix.length - 1;
        int t = -1;
        while (l <= r) {
            int m = (l + r) / 2;
            if (matrix[m][0] > target) {
                r = m - 1;
            } else if (matrix[m][0] <= target) {
                if (matrix[m][matrix[m].length - 1] >= target) {
                    t = m;
                    break;
                } else {
                    l = m + 1;
                }
            }
        }
        if (t < 0) {
            return false;
        }
        l = 0;
        r = matrix[t].length - 1;
        while (l <= r) {
            int m = (l + r) / 2;
            if (matrix[t][m] < target) {
                l = m + 1;
            } else if (matrix[t][m] > target) {
                r = m - 1;
            } else {
                return true;
            }
        }
        return false;
    }

}
