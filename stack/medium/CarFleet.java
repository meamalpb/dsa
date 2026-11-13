package stack.medium;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// https://leetcode.com/problems/car-fleet/

public class CarFleet {
    public int carFleet(int target, int[] position, int[] speed) {
        List<Float> result = new ArrayList<>();
        int[][] cars = new int[position.length][2];
        for (int i = 0; i < position.length; i++) {
            cars[i][0] = position[i];
            cars[i][1] = speed[i];
        }
        Arrays.sort(cars, (a, b) -> Integer.compare(b[0], a[0]));
        for (int[] i : cars) {
            float timetoreach = (float) (target - i[0]) / i[1];
            if (result.isEmpty() || result.getLast() < timetoreach) {
                result.add(timetoreach);
            }
        }
        return result.size();
    }
}
