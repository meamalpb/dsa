-- 1321. Restaurant Growth · Medium · Subqueries
-- https://leetcode.com/problems/restaurant-growth/
--
-- For each day that has 6 days before it in the data, report the total amount customers paid in
-- the 7-day window ending that day (amount) and its daily average rounded to 2 decimals\n(average_amount). There is at least one customer every day. Order by visited_on.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/medium/restaurant_growth.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Customer (customer_id int, name varchar, visited_on date, amount int);
INSERT INTO Customer VALUES
  (1, 'Jhon', '2019-01-01', 100),
  (2, 'Daniel', '2019-01-02', 110),
  (3, 'Jade', '2019-01-03', 120),
  (4, 'Khaled', '2019-01-04', 130),
  (5, 'Winston', '2019-01-05', 110),
  (6, 'Elvis', '2019-01-06', 140),
  (7, 'Anna', '2019-01-07', 150),
  (8, 'Maria', '2019-01-08', 80),
  (9, 'Jaze', '2019-01-09', 110),
  (1, 'Jhon', '2019-01-10', 130),
  (3, 'Jade', '2019-01-10', 150);

-- Expected
CREATE TABLE expected (visited_on date, amount int, average_amount numeric);
INSERT INTO expected VALUES
  ('2019-01-07', 860, 122.86),
  ('2019-01-08', 840, 120.00),
  ('2019-01-09', 840, 120.00),
  ('2019-01-10', 1000, 142.86);

-- Your query below this line ------------------------------------------------

