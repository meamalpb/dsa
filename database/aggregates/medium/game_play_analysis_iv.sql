-- 550. Game Play Analysis IV · Medium · Basic Aggregate Functions
-- https://leetcode.com/problems/game-play-analysis-iv/
--
-- Find the fraction of players who logged in again on the day after their first login,
-- rounded to 2 decimals, as fraction.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/medium/game_play_analysis_iv.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Activity (player_id int, device_id int, event_date date, games_played int);
INSERT INTO Activity VALUES
  (1, 2, '2016-03-01', 5),
  (1, 2, '2016-03-02', 6),
  (2, 3, '2017-06-25', 1),
  (3, 1, '2016-03-02', 0),
  (3, 4, '2018-07-03', 5);

-- Expected
CREATE TABLE expected (fraction numeric);
INSERT INTO expected VALUES
  (0.33);

-- Your query below this line ------------------------------------------------

