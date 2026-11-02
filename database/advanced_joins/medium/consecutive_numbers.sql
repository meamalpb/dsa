-- 180. Consecutive Numbers · Medium · Advanced Select and Joins
-- https://leetcode.com/problems/consecutive-numbers/
--
-- Find all numbers that appear at least three times in a row (by id), as ConsecutiveNums.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/medium/consecutive_numbers.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Logs (id int, num int);
INSERT INTO Logs VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (4, 2),
  (5, 1),
  (6, 2),
  (7, 2);

-- Expected
CREATE TABLE expected ("ConsecutiveNums" int);
INSERT INTO expected VALUES
  (1);

-- Your query below this line ------------------------------------------------

