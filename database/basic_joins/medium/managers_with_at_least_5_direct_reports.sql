-- 570. Managers with at Least 5 Direct Reports · Medium · Basic Joins
-- https://leetcode.com/problems/managers-with-at-least-5-direct-reports/
--
-- Find the names of the managers with at least five direct reports.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/medium/managers_with_at_least_5_direct_reports.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.
-- Case 1: LeetCode's example ------------------------------------------------
CREATE TABLE
  Employee (
    id int,
    name varchar,
    department varchar,
    managerId int
  );

INSERT INTO
  Employee
VALUES
  (101, 'John', 'A', NULL),
  (102, 'Dan', 'A', 101),
  (103, 'James', 'A', 101),
  (104, 'Amy', 'A', 101),
  (105, 'Anne', 'A', 101),
  (106, 'Ron', 'B', 101);

-- Expected
CREATE TABLE
  expected (name varchar);

INSERT INTO
  expected
VALUES
  ('John');

-- Your query below this line ------------------------------------------------
select
  t2.name
from
  (
    select
      managerId
    from
      employee
    where
      managerId is not null
    group by
      managerId
    having
      count(*) >= 5
  ) as t1
  join employee t2 on t1.managerId = t2.id;