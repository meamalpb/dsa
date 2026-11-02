-- 585. Investments in 2016 · Medium · Subqueries
-- https://leetcode.com/problems/investments-in-2016/
--
-- Sum tiv_2016 over the policyholders whose tiv_2015 equals someone else's tiv_2015 and whose
-- (lat, lon) location is unique. Round to 2 decimals, as tiv_2016.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/medium/investments_in_2016.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Insurance (pid int, tiv_2015 float, tiv_2016 float, lat float, lon float);
INSERT INTO Insurance VALUES
  (1, 10, 5, 10, 10),
  (2, 20, 20, 20, 20),
  (3, 10, 30, 20, 20),
  (4, 10, 40, 40, 40);

-- Expected
CREATE TABLE expected (tiv_2016 numeric);
INSERT INTO expected VALUES
  (45.00);

-- Your query below this line ------------------------------------------------

