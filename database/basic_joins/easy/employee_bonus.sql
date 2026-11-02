-- 577. Employee Bonus · Easy · Basic Joins
-- https://leetcode.com/problems/employee-bonus/
--
-- Report the name and bonus of each employee whose bonus is less than 1000 (no bonus counts too).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/employee_bonus.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employee (empId int, name varchar, supervisor int, salary int);
CREATE TABLE Bonus (empId int, bonus int);
INSERT INTO Employee VALUES
  (3, 'Brad', NULL, 4000),
  (1, 'John', 3, 1000),
  (2, 'Dan', 3, 2000),
  (4, 'Thomas', 3, 4000);
INSERT INTO Bonus VALUES
  (2, 500),
  (4, 2000);

-- Expected
CREATE TABLE expected (name varchar, bonus int);
INSERT INTO expected VALUES
  ('John', NULL),
  ('Dan', 500),
  ('Brad', NULL);

-- Your query below this line ------------------------------------------------

