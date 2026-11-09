package arrays_and_hashing.medium;

import java.util.HashMap;
import java.util.HashSet;

// https://leetcode.com/problems/valid-sudoku/

public class ValidSudoku {
    public boolean isValidSudoku(char[][] board) {
        HashMap<Integer, HashSet<Character>> square = new HashMap<>();
        for (int i = 0; i < 9; i++) {
            HashSet<Character> row = new HashSet<>();
            HashSet<Character> column = new HashSet<>();

            for (int j = 0; j < 9; j++) {
                char r = board[i][j];
                char c = board[j][i];
                int s = ((i / 3) * 3) + (j / 3);
                if ((r != '.') && (row.contains(r))) {
                    return false;
                }
                if ((c != '.') && column.contains(c)) {
                    return false;
                }
                if ((r != '.') && square.getOrDefault(s, new HashSet<>()).contains(r)) {
                    return false;
                }

                row.add(r);
                column.add(c);
                HashSet<Character> square_hashset = square.getOrDefault(s, new HashSet<>());
                square_hashset.add(r);
                square.put(s, square_hashset);

            }
        }
        return true;
    }
}
