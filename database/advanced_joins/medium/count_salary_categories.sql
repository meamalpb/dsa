-- 1907. Count Salary Categories · Medium · Advanced Select and Joins
-- https://leetcode.com/problems/count-salary-categories/
--
-- Count the bank accounts in each salary category: 'Low Salary' (< 20000), 'Average Salary'
-- (20000 to 50000 inclusive), 'High Salary' (> 50000). All three categories must appear, with
-- 0 when empty (columns category, accounts_count).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/medium/count_salary_categories.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Accounts (account_id int, income int);
INSERT INTO Accounts VALUES
  (3, 108939),
  (2, 12747),
  (8, 87709),
  (6, 91796);

-- Expected
CREATE TABLE expected (category varchar, accounts_count int);
INSERT INTO expected VALUES
  ('Low Salary', 1),
  ('Average Salary', 0),
  ('High Salary', 3);

-- Your query below this line ------------------------------------------------

