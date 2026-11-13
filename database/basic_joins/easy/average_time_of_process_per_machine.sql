-- 1661. Average Time of Process per Machine · Easy · Basic Joins
-- https://leetcode.com/problems/average-time-of-process-per-machine/
--
-- Each process logs a 'start' and an 'end' timestamp. For each machine, find the average time
-- a process takes (end - start), rounded to 3 decimals, as processing_time.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/average_time_of_process_per_machine.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Activity (
  machine_id    int,
  process_id    int,
  activity_type varchar,  -- 'start' or 'end'
  timestamp     float
);
INSERT INTO Activity VALUES
  (0, 0, 'start', 0.712),
  (0, 0, 'end',   1.520),
  (0, 1, 'start', 3.140),
  (0, 1, 'end',   4.120),
  (1, 0, 'start', 0.550),
  (1, 0, 'end',   1.550),
  (1, 1, 'start', 0.430),
  (1, 1, 'end',   1.420),
  (2, 0, 'start', 4.100),
  (2, 0, 'end',   4.512),
  (2, 1, 'start', 2.500),
  (2, 1, 'end',   5.000);

-- Expected
CREATE TABLE expected (machine_id int, processing_time numeric);
INSERT INTO expected VALUES
  (0, 0.894),
  (1, 0.995),
  (2, 1.456);

-- Your query below this line ------------------------------------------------
-- Write your PostgreSQL query statement below
select a1.machine_id, round(avg(a1.timestamp - a2.timestamp)::numeric,3)
as processing_time
from Activity a1
join Activity a2
on a1.machine_id = a2.machine_id and a1.process_id=a2.process_id
WHERE a1.activity_type = 'end'
  AND a2.activity_type = 'start'
group by a1.machine_id;