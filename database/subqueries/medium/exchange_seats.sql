-- 626. Exchange Seats · Medium · Subqueries
-- https://leetcode.com/problems/exchange-seats/
--
-- Swap the seat ids of every two consecutive students (1<->2, 3<->4, ...). If the count is odd,
-- the last student stays put. Order by id.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/medium/exchange_seats.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Seat (id int, student varchar);
INSERT INTO Seat VALUES
  (1, 'Abbot'),
  (2, 'Doris'),
  (3, 'Emerson'),
  (4, 'Green'),
  (5, 'Jeames');

-- Expected
CREATE TABLE expected (id int, student varchar);
INSERT INTO expected VALUES
  (1, 'Doris'),
  (2, 'Abbot'),
  (3, 'Green'),
  (4, 'Emerson'),
  (5, 'Jeames');

-- Your query below this line ------------------------------------------------

