-- 1667. Fix Names in a Table · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/fix-names-in-a-table/
--
-- Fix the names so only the first character is uppercase and the rest lowercase. Order by user_id.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/fix_names_in_a_table.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Users (user_id int, name varchar);
INSERT INTO Users VALUES
  (1, 'aLice'),
  (2, 'bOB');

-- Expected
CREATE TABLE expected (user_id int, name varchar);
INSERT INTO expected VALUES
  (1, 'Alice'),
  (2, 'Bob');

-- Your query below this line ------------------------------------------------

