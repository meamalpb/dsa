-- 602. Friend Requests II: Who Has the Most Friends · Medium · Subqueries
-- https://leetcode.com/problems/friend-requests-ii-who-has-the-most-friends/
--
-- An accepted request makes the requester and the accepter friends. Find the person with the
-- most friends and how many they have (columns id, num). Only one person has the most.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/medium/friend_requests_ii_who_has_the_most_friends.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE RequestAccepted (requester_id int, accepter_id int, accept_date date);
INSERT INTO RequestAccepted VALUES
  (1, 2, '2016-06-03'),
  (1, 3, '2016-06-08'),
  (2, 3, '2016-06-08'),
  (3, 4, '2016-06-09');

-- Expected
CREATE TABLE expected (id int, num int);
INSERT INTO expected VALUES
  (3, 3);

-- Your query below this line ------------------------------------------------

