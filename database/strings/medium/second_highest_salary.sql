-- 176. Second Highest Salary · Medium · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/second-highest-salary/
--
-- Find the second highest distinct salary, as SecondHighestSalary. If there is none, return a
-- single row with null.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/medium/second_highest_salary.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employee (id int, salary int);
INSERT INTO Employee VALUES
  (1, 100),
  (2, 200),
  (3, 300);

-- Expected
CREATE TABLE expected ("SecondHighestSalary" int);
INSERT INTO expected VALUES
  (200);

-- Case 2: no second highest -------------------------------------------------

CREATE TABLE Employee (id int, salary int);
INSERT INTO Employee VALUES
  (1, 100);

-- Expected
CREATE TABLE expected ("SecondHighestSalary" int);
INSERT INTO expected VALUES
  (NULL);

-- Case 3: highest salary twice ----------------------------------------------

CREATE TABLE Employee (id int, salary int);
INSERT INTO Employee VALUES
  (1, 300),
  (2, 300),
  (3, 200);

-- Expected
CREATE TABLE expected ("SecondHighestSalary" int);
INSERT INTO expected VALUES
  (200);

-- Your query below this line ------------------------------------------------

