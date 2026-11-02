-- 2356. Number of Unique Subjects Taught by Each Teacher · Easy · Sorting and Grouping
-- https://leetcode.com/problems/number-of-unique-subjects-taught-by-each-teacher/
--
-- Find how many different subjects each teacher teaches (columns teacher_id, cnt).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/sorting_grouping/easy/number_of_unique_subjects_taught_by_each_teacher.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Teacher (teacher_id int, subject_id int, dept_id int);
INSERT INTO Teacher VALUES
  (1, 2, 3),
  (1, 2, 4),
  (1, 3, 3),
  (2, 1, 1),
  (2, 2, 1),
  (2, 3, 1),
  (2, 4, 1);

-- Expected
CREATE TABLE expected (teacher_id int, cnt int);
INSERT INTO expected VALUES
  (1, 2),
  (2, 4);

-- Your query below this line ------------------------------------------------

