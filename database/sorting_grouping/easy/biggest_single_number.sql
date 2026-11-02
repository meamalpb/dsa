-- 619. Biggest Single Number · Easy · Sorting and Grouping
-- https://leetcode.com/problems/biggest-single-number/
--
-- A single number appears only once in the table. Find the largest single number (column num);
-- if there is none, return null.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/easy/biggest_single_number.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE MyNumbers (num int);
INSERT INTO MyNumbers VALUES (8), (8), (3), (3), (1), (4), (5), (6);

-- Expected
CREATE TABLE expected (num int);
INSERT INTO expected VALUES
  (6);

-- Case 2: no single number --------------------------------------------------

CREATE TABLE MyNumbers (num int);
INSERT INTO MyNumbers VALUES (8), (8), (7), (7), (3), (3), (3);

-- Expected
CREATE TABLE expected (num int);
INSERT INTO expected VALUES
  (NULL);

-- Your query below this line ------------------------------------------------

