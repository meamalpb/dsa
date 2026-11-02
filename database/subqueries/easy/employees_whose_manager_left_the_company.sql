-- 1978. Employees Whose Manager Left the Company · Easy · Subqueries
-- https://leetcode.com/problems/employees-whose-manager-left-the-company/
--
-- Find the ids of employees earning less than 30000 whose manager left the company (the
-- manager_id is set but that employee is no longer in the table). Order by employee_id.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/easy/employees_whose_manager_left_the_company.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employees (employee_id int, name varchar, manager_id int, salary int);
INSERT INTO Employees VALUES
  (3, 'Mila', 9, 60301),
  (12, 'Antonella', NULL, 31000),
  (13, 'Emery', NULL, 67084),
  (1, 'Kalel', 11, 21241),
  (9, 'Mikaela', NULL, 50937),
  (11, 'Joziah', 6, 28485);

-- Expected
CREATE TABLE expected (employee_id int);
INSERT INTO expected VALUES
  (11);

-- Your query below this line ------------------------------------------------

