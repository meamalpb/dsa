-- 1378. Replace Employee ID With The Unique Identifier · Easy · Basic Joins
-- https://leetcode.com/problems/replace-employee-id-with-the-unique-identifier/
--
-- Show the unique id of each employee next to their name; if an employee has no unique id,
-- show null instead.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/replace_employee_id_with_the_unique_identifier.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Employees (id int, name varchar);
CREATE TABLE EmployeeUNI (id int, unique_id int);
INSERT INTO Employees VALUES
  (1, 'Alice'),
  (7, 'Bob'),
  (11, 'Meir'),
  (90, 'Winston'),
  (3, 'Jonathan');
INSERT INTO EmployeeUNI VALUES
  (3, 1),
  (11, 2),
  (90, 3);

-- Expected
CREATE TABLE expected (unique_id int, name varchar);
INSERT INTO expected VALUES
  (NULL, 'Alice'),
  (1, 'Jonathan'),
  (NULL, 'Bob'),
  (2, 'Meir'),
  (3, 'Winston');

-- Your query below this line ------------------------------------------------

