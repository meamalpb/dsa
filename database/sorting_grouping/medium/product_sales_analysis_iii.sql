-- 1070. Product Sales Analysis III · Medium · Sorting and Grouping
-- https://leetcode.com/problems/product-sales-analysis-iii/
--
-- For each product, find the first year it was sold and every sale from that year
-- (columns product_id, first_year, quantity, price).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/medium/product_sales_analysis_iii.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Sales (sale_id int, product_id int, year int, quantity int, price int);
INSERT INTO Sales VALUES
  (1, 100, 2008, 10, 5000),
  (2, 100, 2009, 12, 5000),
  (7, 200, 2011, 15, 9000);

-- Expected
CREATE TABLE expected (product_id int, first_year int, quantity int, price int);
INSERT INTO expected VALUES
  (100, 2008, 10, 5000),
  (200, 2011, 15, 9000);

-- Your query below this line ------------------------------------------------

