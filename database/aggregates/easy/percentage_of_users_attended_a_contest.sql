-- 1633. Percentage of Users Attended a Contest · Easy · Basic Aggregate Functions
-- https://leetcode.com/problems/percentage-of-users-attended-a-contest/
--
-- For each contest, find the percentage of all users who registered, rounded to 2 decimals.
-- Order by percentage, highest first; on ties, by contest_id ascending.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/easy/percentage_of_users_attended_a_contest.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Users (user_id int, user_name varchar);
CREATE TABLE Register (contest_id int, user_id int);
INSERT INTO Users VALUES
  (6, 'Alice'),
  (2, 'Bob'),
  (7, 'Alex');
INSERT INTO Register VALUES
  (215, 6),
  (209, 2),
  (208, 2),
  (210, 6),
  (208, 6),
  (209, 7),
  (209, 6),
  (215, 7),
  (208, 7),
  (210, 2),
  (207, 2),
  (210, 7);

-- Expected
CREATE TABLE expected (contest_id int, percentage numeric);
INSERT INTO expected VALUES
  (208, 100.00),
  (209, 100.00),
  (210, 100.00),
  (215, 66.67),
  (207, 33.33);

-- Your query below this line ------------------------------------------------

