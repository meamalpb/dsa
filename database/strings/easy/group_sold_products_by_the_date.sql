-- 1484. Group Sold Products By The Date · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/group-sold-products-by-the-date/
--
-- For each sell_date, find the number of different products sold (num_sold) and their names,
-- sorted and joined with commas (products). Order by sell_date.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/group_sold_products_by_the_date.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Activities (sell_date date, product varchar);
INSERT INTO Activities VALUES
  ('2020-05-30', 'Headphone'),
  ('2020-06-01', 'Pencil'),
  ('2020-06-02', 'Mask'),
  ('2020-05-30', 'Basketball'),
  ('2020-06-01', 'Bible'),
  ('2020-06-02', 'Mask'),
  ('2020-05-30', 'T-Shirt');

-- Expected
CREATE TABLE expected (sell_date date, num_sold int, products varchar);
INSERT INTO expected VALUES
  ('2020-05-30', 3, 'Basketball,Headphone,T-Shirt'),
  ('2020-06-01', 2, 'Bible,Pencil'),
  ('2020-06-02', 1, 'Mask');

-- Your query below this line ------------------------------------------------

