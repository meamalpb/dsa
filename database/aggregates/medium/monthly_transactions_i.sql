-- 1193. Monthly Transactions I · Medium · Basic Aggregate Functions
-- https://leetcode.com/problems/monthly-transactions-i/
--
-- For each month ('YYYY-MM') and country, find the number of transactions and their total amount,
-- and the number of approved transactions and their total amount (columns month, country,\ntrans_count, approved_count, trans_total_amount, approved_total_amount).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/medium/monthly_transactions_i.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Transactions (
  id         int,
  country    varchar,
  state      varchar,  -- 'approved' or 'declined'
  amount     int,
  trans_date date
);
INSERT INTO Transactions VALUES
  (121, 'US', 'approved', 1000, '2018-12-18'),
  (122, 'US', 'declined', 2000, '2018-12-19'),
  (123, 'US', 'approved', 2000, '2019-01-01'),
  (124, 'DE', 'approved', 2000, '2019-01-07');

-- Expected
CREATE TABLE expected (month varchar, country varchar, trans_count int, approved_count int, trans_total_amount int, approved_total_amount int);
INSERT INTO expected VALUES
  ('2018-12', 'US', 2, 1, 3000, 1000),
  ('2019-01', 'US', 1, 1, 2000, 2000),
  ('2019-01', 'DE', 1, 1, 2000, 2000);

-- Your query below this line ------------------------------------------------

