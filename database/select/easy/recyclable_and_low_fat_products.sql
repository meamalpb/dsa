-- 1757. Recyclable and Low Fat Products · Easy · Select
-- https://leetcode.com/problems/recyclable-and-low-fat-products/
--
-- Find the ids of products that are both low fat and recyclable.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/select/easy/recyclable_and_low_fat_products.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Products (
  product_id int,
  low_fats   varchar,  -- 'Y' or 'N'
  recyclable varchar   -- 'Y' or 'N'
);
INSERT INTO Products VALUES
  (0, 'Y', 'N'),
  (1, 'Y', 'Y'),
  (2, 'N', 'Y'),
  (3, 'Y', 'Y'),
  (4, 'N', 'N');

-- Expected
CREATE TABLE expected (product_id int);
INSERT INTO expected VALUES
  (1),
  (3);

-- Your query below this line ------------------------------------------------

Select product_id from products where low_fats='Y' and recyclable='Y';