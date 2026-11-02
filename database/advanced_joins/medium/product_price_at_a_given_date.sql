-- 1164. Product Price at a Given Date · Medium · Advanced Select and Joins
-- https://leetcode.com/problems/product-price-at-a-given-date/
--
-- Find the price of every product on 2019-08-16: its latest price change on or before that date.
-- Before its first change, every product costs 10.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/medium/product_price_at_a_given_date.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Products (product_id int, new_price int, change_date date);
INSERT INTO Products VALUES
  (1, 20, '2019-08-14'),
  (2, 50, '2019-08-14'),
  (1, 30, '2019-08-15'),
  (1, 35, '2019-08-16'),
  (2, 65, '2019-08-17'),
  (3, 20, '2019-08-18');

-- Expected
CREATE TABLE expected (product_id int, price int);
INSERT INTO expected VALUES
  (3, 10),
  (2, 50),
  (1, 35);

-- Your query below this line ------------------------------------------------

