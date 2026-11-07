-- 197. Rising Temperature · Easy · Basic Joins
-- https://leetcode.com/problems/rising-temperature/
--
-- Find the ids of the dates whose temperature is higher than on the day before (yesterday).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/rising_temperature.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Weather (id int, recordDate date, temperature int);
INSERT INTO Weather VALUES
  (1, '2015-01-01', 10),
  (2, '2015-01-02', 25),
  (3, '2015-01-03', 20),
  (4, '2015-01-04', 30);

-- Expected
CREATE TABLE expected (id int);
INSERT INTO expected VALUES
  (2),
  (4);

-- Your query below this line ------------------------------------------------

select w1.id 
from Weather w1 
join Weather w2 
on w1.recordDate = w2.recordDate + interval '1 Day'
where w1.temperature  > w2.temperature