-- 1251. Average Selling Price · Easy · Basic Aggregate Functions
-- https://leetcode.com/problems/average-selling-price/
--
-- Find each product's average selling price (total paid / units sold), rounded to 2 decimals,
-- as average_price. A sale uses the price whose date range contains the purchase date.\nA product with no units sold has an average price of 0.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/easy/average_selling_price.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Prices (product_id int, start_date date, end_date date, price int);
CREATE TABLE UnitsSold (product_id int, purchase_date date, units int);
INSERT INTO Prices VALUES
  (1, '2019-02-17', '2019-02-28', 5),
  (1, '2019-03-01', '2019-03-22', 20),
  (2, '2019-02-01', '2019-02-20', 15),
  (2, '2019-02-21', '2019-03-31', 30);
INSERT INTO UnitsSold VALUES
  (1, '2019-02-25', 100),
  (1, '2019-03-01', 15),
  (2, '2019-02-10', 200),
  (2, '2019-03-22', 30);

-- Expected
CREATE TABLE expected (product_id int, average_price numeric);
INSERT INTO expected VALUES
  (1, 6.96),
  (2, 16.96);

-- Case 2: a product that never sold -----------------------------------------

CREATE TABLE Prices (product_id int, start_date date, end_date date, price int);
CREATE TABLE UnitsSold (product_id int, purchase_date date, units int);
INSERT INTO Prices VALUES
  (1, '2019-02-17', '2019-02-28', 5),
  (3, '2019-02-01', '2019-03-31', 10);
INSERT INTO UnitsSold VALUES
  (1, '2019-02-25', 100);

-- Expected
CREATE TABLE expected (product_id int, average_price numeric);
INSERT INTO expected VALUES
  (1, 5.00),
  (3, 0);

-- Your query below this line ------------------------------------------------

