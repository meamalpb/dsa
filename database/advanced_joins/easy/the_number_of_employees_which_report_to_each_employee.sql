-- 1731. The Number of Employees Which Report to Each Employee · Easy · Advanced Select and Joins
-- https://leetcode.com/problems/the-number-of-employees-which-report-to-each-employee/
--
-- A manager is an employee with at least one direct report. For each manager, report their
-- employee_id, name, reports_count and average_age of the reports (rounded to the nearest\ninteger), ordered by employee_id.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/easy/the_number_of_employees_which_report_to_each_employee.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employees (employee_id int, name varchar, reports_to int, age int);
INSERT INTO Employees VALUES
  (9, 'Hercy', NULL, 43),
  (6, 'Alice', 9, 41),
  (4, 'Bob', 9, 36),
  (2, 'Winston', NULL, 37);

-- Expected
CREATE TABLE expected (employee_id int, name varchar, reports_count int, average_age numeric);
INSERT INTO expected VALUES
  (9, 'Hercy', 2, 39);

-- Your query below this line ------------------------------------------------

