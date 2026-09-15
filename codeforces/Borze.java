// https://codeforces.com/problemset/problem/32/B
package codeforces;

import java.util.Scanner;

public class Borze {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        String input = sc.nextLine();
        sc.close();
        borzeToInt(input);
    }

    public static void borzeToInt(String input) {
        String result = "";
        for (int i = 0; i < input.length(); i++) {
            char i1 = input.charAt(i);
            if (i == input.length() - 1 && i1 == '.') {
                result += "0";
            } else {
                if (i1 == '-') {
                    char i2 = input.charAt(i + 1);
                    if (i2 == '.') {
                        result += "1";
                    } else {
                        result += "2";
                    }
                    i++;
                } else {
                    result += "0";
                }
            }
        }
        System.out.println(result);
    }
}