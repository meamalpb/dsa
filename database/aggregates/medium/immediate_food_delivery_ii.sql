-- 1174. Immediate Food Delivery II · Medium · Basic Aggregate Functions
-- https://leetcode.com/problems/immediate-food-delivery-ii/
--
-- An order is immediate if the preferred delivery date is the order date. A customer's first
-- order is the one with the earliest order_date. Find the percentage of first orders that are\nimmediate, rounded to 2 decimals, as immediate_percentage.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/medium/immediate_food_delivery_ii.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Delivery (delivery_id int, customer_id int, order_date date, customer_pref_delivery_date date);
INSERT INTO Delivery VALUES
  (1, 1, '2019-08-01', '2019-08-02'),
  (2, 2, '2019-08-02', '2019-08-02'),
  (3, 1, '2019-08-11', '2019-08-12'),
  (4, 3, '2019-08-24', '2019-08-24'),
  (5, 3, '2019-08-21', '2019-08-22'),
  (6, 2, '2019-08-11', '2019-08-13'),
  (7, 4, '2019-08-09', '2019-08-09');

-- Expected
CREATE TABLE expected (immediate_percentage numeric);
INSERT INTO expected VALUES
  (50.00);

-- Your query below this line ------------------------------------------------

