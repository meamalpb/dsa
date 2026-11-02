-- 1934. Confirmation Rate · Medium · Basic Joins
-- https://leetcode.com/problems/confirmation-rate/
--
-- A user's confirmation rate is their 'confirmed' messages divided by all their confirmation
-- requests (0 if they asked for none). Find each signed-up user's rate, rounded to 2 decimals.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/medium/confirmation_rate.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Signups (user_id int, time_stamp timestamp);
CREATE TABLE Confirmations (
  user_id    int,
  time_stamp timestamp,
  action     varchar  -- 'confirmed' or 'timeout'
);
INSERT INTO Signups VALUES
  (3, '2020-03-21 10:16:13'),
  (7, '2020-01-04 13:57:59'),
  (2, '2020-07-29 23:09:44'),
  (6, '2020-12-09 10:39:37');
INSERT INTO Confirmations VALUES
  (3, '2021-01-06 03:30:46', 'timeout'),
  (3, '2021-07-14 14:00:00', 'timeout'),
  (7, '2021-06-12 11:57:29', 'confirmed'),
  (7, '2021-06-13 12:58:28', 'confirmed'),
  (7, '2021-06-14 13:59:27', 'confirmed'),
  (2, '2021-01-22 00:00:00', 'confirmed'),
  (2, '2021-02-28 23:59:59', 'timeout');

-- Expected
CREATE TABLE expected (user_id int, confirmation_rate numeric);
INSERT INTO expected VALUES
  (2, 0.50),
  (3, 0.00),
  (6, 0.00),
  (7, 1.00);

-- Your query below this line ------------------------------------------------

