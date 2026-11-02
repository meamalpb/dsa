-- 1327. List the Products Ordered in a Period · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/list-the-products-ordered-in-a-period/
--
-- Find the names of products with at least 100 units ordered in February 2020, and those units (unit).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/list_the_products_ordered_in_a_period.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Products (product_id int, product_name varchar, product_category varchar);
CREATE TABLE Orders (product_id int, order_date date, unit int);
INSERT INTO Products VALUES
  (1, 'Leetcode Solutions', 'Book'),
  (2, 'Jewels of Stringology', 'Book'),
  (3, 'HP', 'Laptop'),
  (4, 'Lenovo', 'Laptop'),
  (5, 'Leetcode Kit', 'T-shirt');
INSERT INTO Orders VALUES
  (1, '2020-02-05', 60),
  (1, '2020-02-10', 70),
  (2, '2020-01-18', 30),
  (2, '2020-02-11', 80),
  (3, '2020-02-17', 2),
  (3, '2020-02-24', 3),
  (4, '2020-03-01', 20),
  (4, '2020-03-04', 30),
  (4, '2020-03-04', 60),
  (5, '2020-02-25', 50),
  (5, '2020-02-27', 50),
  (5, '2020-03-01', 50);

-- Expected
CREATE TABLE expected (product_name varchar, unit int);
INSERT INTO expected VALUES
  ('Leetcode Kit', 100),
  ('Leetcode Solutions', 130);

-- Your query below this line ------------------------------------------------

