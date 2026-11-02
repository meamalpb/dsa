-- 610. Triangle Judgement · Easy · Advanced Select and Joins
-- https://leetcode.com/problems/triangle-judgement/
--
-- For each row of three segment lengths, report whether they can form a triangle
-- (column triangle, 'Yes' or 'No').
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/easy/triangle_judgement.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Triangle (x int, y int, z int);
INSERT INTO Triangle VALUES
  (13, 15, 30),
  (10, 20, 15);

-- Expected
CREATE TABLE expected (x int, y int, z int, triangle varchar);
INSERT INTO expected VALUES
  (13, 15, 30, 'No'),
  (10, 20, 15, 'Yes');

-- Your query below this line ------------------------------------------------

