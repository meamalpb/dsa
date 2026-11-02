-- 185. Department Top Three Salaries · Hard · Subqueries
-- https://leetcode.com/problems/department-top-three-salaries/
--
-- A high earner is an employee whose salary is among the top three distinct salaries of their
-- department. Find the high earners of every department (columns Department, Employee, Salary).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/hard/department_top_three_salaries.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Department (id int PRIMARY KEY, name varchar);
CREATE TABLE Employee (id int PRIMARY KEY, name varchar, salary int, departmentId int REFERENCES Department (id));
INSERT INTO Department VALUES
  (1, 'IT'),
  (2, 'Sales');
INSERT INTO Employee VALUES
  (1, 'Joe', 85000, 1),
  (2, 'Henry', 80000, 2),
  (3, 'Sam', 60000, 2),
  (4, 'Max', 90000, 1),
  (5, 'Janet', 69000, 1),
  (6, 'Randy', 85000, 1),
  (7, 'Will', 70000, 1);

-- Expected
CREATE TABLE expected ("Department" varchar, "Employee" varchar, "Salary" int);
INSERT INTO expected VALUES
  ('IT', 'Max', 90000),
  ('IT', 'Joe', 85000),
  ('IT', 'Randy', 85000),
  ('IT', 'Will', 70000),
  ('Sales', 'Henry', 80000),
  ('Sales', 'Sam', 60000);

-- Your query below this line ------------------------------------------------

