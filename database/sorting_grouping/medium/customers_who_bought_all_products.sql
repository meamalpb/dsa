-- 1045. Customers Who Bought All Products · Medium · Sorting and Grouping
-- https://leetcode.com/problems/customers-who-bought-all-products/
--
-- Find the ids of the customers who bought every product in the Product table.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/medium/customers_who_bought_all_products.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Customer (customer_id int, product_key int);
CREATE TABLE Product (product_key int);
INSERT INTO Customer VALUES
  (1, 5),
  (2, 6),
  (3, 5),
  (3, 6),
  (1, 6);
INSERT INTO Product VALUES (5), (6);

-- Expected
CREATE TABLE expected (customer_id int);
INSERT INTO expected VALUES
  (1),
  (3);

-- Your query below this line ------------------------------------------------

