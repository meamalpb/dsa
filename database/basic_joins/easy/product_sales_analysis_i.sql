-- 1068. Product Sales Analysis I · Easy · Basic Joins
-- https://leetcode.com/problems/product-sales-analysis-i/
--
-- For each sale, report the product_name, year and price.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/product_sales_analysis_i.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Sales (sale_id int, product_id int, year int, quantity int, price int);
CREATE TABLE Product (product_id int, product_name varchar);
INSERT INTO Sales VALUES
  (1, 100, 2008, 10, 5000),
  (2, 100, 2009, 12, 5000),
  (7, 200, 2011, 15, 9000);
INSERT INTO Product VALUES
  (100, 'Nokia'),
  (200, 'Apple'),
  (300, 'Samsung');

-- Expected
CREATE TABLE expected (product_name varchar, year int, price int);
INSERT INTO expected VALUES
  ('Nokia', 2008, 5000),
  ('Nokia', 2009, 5000),
  ('Apple', 2011, 9000);

-- Your query below this line ------------------------------------------------

select product.product_name , sales.year , sales.price 
from sales inner join product
on sales.product_id = product.product_id;