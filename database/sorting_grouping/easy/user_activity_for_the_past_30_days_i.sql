-- 1141. User Activity for the Past 30 Days I · Easy · Sorting and Grouping
-- https://leetcode.com/problems/user-activity-for-the-past-30-days-i/
--
-- Find the daily active user count for the 30 days ending 2019-07-27 (inclusive), for days
-- with at least one active user (columns day, active_users).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/easy/user_activity_for_the_past_30_days_i.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Activity (
  user_id       int,
  session_id    int,
  activity_date date,
  activity_type varchar  -- 'open_session', 'end_session', 'scroll_down' or 'send_message'
);
INSERT INTO Activity VALUES
  (1, 1, '2019-07-20', 'open_session'),
  (1, 1, '2019-07-20', 'scroll_down'),
  (1, 1, '2019-07-20', 'end_session'),
  (2, 4, '2019-07-20', 'open_session'),
  (2, 4, '2019-07-21', 'send_message'),
  (2, 4, '2019-07-21', 'end_session'),
  (3, 2, '2019-07-21', 'open_session'),
  (3, 2, '2019-07-21', 'send_message'),
  (3, 2, '2019-07-21', 'end_session'),
  (4, 3, '2019-06-25', 'open_session'),
  (4, 3, '2019-06-25', 'end_session');

-- Expected
CREATE TABLE expected (day date, active_users int);
INSERT INTO expected VALUES
  ('2019-07-20', 2),
  ('2019-07-21', 2);

-- Your query below this line ------------------------------------------------

