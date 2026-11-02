-- 584. Find Customer Referee · Easy · Select
-- https://leetcode.com/problems/find-customer-referee/
--
-- Find the names of the customers who were not referred by the customer with id = 2.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/select/easy/find_customer_referee.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Customer (id int, name varchar, referee_id int);
INSERT INTO Customer VALUES
  (1, 'Will', NULL),
  (2, 'Jane', NULL),
  (3, 'Alex', 2),
  (4, 'Bill', NULL),
  (5, 'Zack', 1),
  (6, 'Mark', 2);

-- Expected
CREATE TABLE expected (name varchar);
INSERT INTO expected VALUES
  ('Will'),
  ('Jane'),
  ('Bill'),
  ('Zack');

-- Your query below this line ------------------------------------------------

