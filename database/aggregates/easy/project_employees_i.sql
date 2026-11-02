-- 1075. Project Employees I · Easy · Basic Aggregate Functions
-- https://leetcode.com/problems/project-employees-i/
--
-- Report the average experience years of each project's employees, rounded to 2 decimals,
-- as average_years.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/easy/project_employees_i.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Project (project_id int, employee_id int);
CREATE TABLE Employee (employee_id int, name varchar, experience_years int);
INSERT INTO Project VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (2, 1),
  (2, 4);
INSERT INTO Employee VALUES
  (1, 'Khaled', 3),
  (2, 'Ali', 2),
  (3, 'John', 1),
  (4, 'Doe', 2);

-- Expected
CREATE TABLE expected (project_id int, average_years numeric);
INSERT INTO expected VALUES
  (2, 2.50),
  (1, 2.00);

-- Your query below this line ------------------------------------------------

