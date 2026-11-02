-- 1789. Primary Department for Each Employee · Easy · Advanced Select and Joins
-- https://leetcode.com/problems/primary-department-for-each-employee/
--
-- Report each employee's primary department (primary_flag = 'Y'). An employee who belongs
-- to only one department has primary_flag 'N' there, and that department is the answer.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/easy/primary_department_for_each_employee.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employee (
  employee_id   int,
  department_id int,
  primary_flag  varchar  -- 'Y' or 'N'
);
INSERT INTO Employee VALUES
  (1, 1, 'N'),
  (2, 1, 'Y'),
  (2, 2, 'N'),
  (3, 3, 'N'),
  (4, 2, 'N'),
  (4, 3, 'Y'),
  (4, 4, 'N');

-- Expected
CREATE TABLE expected (employee_id int, department_id int);
INSERT INTO expected VALUES
  (1, 1),
  (2, 1),
  (3, 3),
  (4, 3);

-- Your query below this line ------------------------------------------------

