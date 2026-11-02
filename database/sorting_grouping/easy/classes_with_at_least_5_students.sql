-- 596. Classes With at Least 5 Students · Easy · Sorting and Grouping
-- https://leetcode.com/problems/classes-with-at-least-5-students/
--
-- Find all the classes that have at least five students.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/easy/classes_with_at_least_5_students.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Courses (student varchar, class varchar);
INSERT INTO Courses VALUES
  ('A', 'Math'),
  ('B', 'English'),
  ('C', 'Math'),
  ('D', 'Biology'),
  ('E', 'Math'),
  ('F', 'Computer'),
  ('G', 'Math'),
  ('H', 'Math'),
  ('I', 'Math');

-- Expected
CREATE TABLE expected (class varchar);
INSERT INTO expected VALUES
  ('Math');

-- Your query below this line ------------------------------------------------

