-- 1280. Students and Examinations · Easy · Basic Joins
-- https://leetcode.com/problems/students-and-examinations/
--
-- Find how many times each student attended each exam: one row per student and subject,
-- even when the count is 0 (column attended_exams). Order by student_id, then subject_name.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/students_and_examinations.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Students (student_id int, student_name varchar);
CREATE TABLE Subjects (subject_name varchar);
CREATE TABLE Examinations (student_id int, subject_name varchar);
INSERT INTO Students VALUES
  (1, 'Alice'),
  (2, 'Bob'),
  (13, 'John'),
  (6, 'Alex');
INSERT INTO Subjects VALUES
  ('Math'),
  ('Physics'),
  ('Programming');
INSERT INTO Examinations VALUES
  (1, 'Math'),
  (1, 'Physics'),
  (1, 'Programming'),
  (2, 'Programming'),
  (1, 'Physics'),
  (1, 'Math'),
  (13, 'Math'),
  (13, 'Programming'),
  (13, 'Physics'),
  (2, 'Math'),
  (1, 'Math');

-- Expected
CREATE TABLE expected (student_id int, student_name varchar, subject_name varchar, attended_exams int);
INSERT INTO expected VALUES
  (1, 'Alice', 'Math', 3),
  (1, 'Alice', 'Physics', 2),
  (1, 'Alice', 'Programming', 1),
  (2, 'Bob', 'Math', 1),
  (2, 'Bob', 'Physics', 0),
  (2, 'Bob', 'Programming', 1),
  (6, 'Alex', 'Math', 0),
  (6, 'Alex', 'Physics', 0),
  (6, 'Alex', 'Programming', 0),
  (13, 'John', 'Math', 1),
  (13, 'John', 'Physics', 1),
  (13, 'John', 'Programming', 1);

-- Your query below this line ------------------------------------------------

select s.student_id , s.student_name , sub.subject_name , count(e.student_id) as attended_exams 
from students s
cross join Subjects sub 
left join examinations e
on s.student_id = e.student_id and 
sub.subject_name = e.subject_name
group by s.student_id,s.student_name,sub.subject_name
order by s.student_id,s.student_name,sub.subject_name
