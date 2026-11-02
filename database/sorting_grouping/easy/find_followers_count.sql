-- 1729. Find Followers Count · Easy · Sorting and Grouping
-- https://leetcode.com/problems/find-followers-count/
--
-- For each user, return the number of followers (followers_count), ordered by user_id.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/easy/find_followers_count.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Followers (user_id int, follower_id int);
INSERT INTO Followers VALUES
  (0, 1),
  (1, 0),
  (2, 0),
  (2, 1);

-- Expected
CREATE TABLE expected (user_id int, followers_count int);
INSERT INTO expected VALUES
  (0, 1),
  (1, 1),
  (2, 2);

-- Your query below this line ------------------------------------------------

