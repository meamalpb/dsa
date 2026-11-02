-- 1683. Invalid Tweets · Easy · Select
-- https://leetcode.com/problems/invalid-tweets/
--
-- A tweet is invalid if its content is longer than 15 characters. Find the ids of the invalid tweets.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/select/easy/invalid_tweets.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Tweets (tweet_id int, content varchar);
INSERT INTO Tweets VALUES
  (1, 'Let us Code'),
  (2, 'More than fifteen chars are here!');

-- Expected
CREATE TABLE expected (tweet_id int);
INSERT INTO expected VALUES
  (2);

-- Your query below this line ------------------------------------------------

