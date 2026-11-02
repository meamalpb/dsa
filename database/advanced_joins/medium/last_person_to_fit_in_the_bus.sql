-- 1204. Last Person to Fit in the Bus · Medium · Advanced Select and Joins
-- https://leetcode.com/problems/last-person-to-fit-in-the-bus/
--
-- People board a bus in `turn` order; the bus holds at most 1000 kg. Find the person_name of
-- the last person who can board without going over the limit.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/advanced_joins/medium/last_person_to_fit_in_the_bus.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Queue (person_id int, person_name varchar, weight int, turn int);
INSERT INTO Queue VALUES
  (5, 'Alice', 250, 1),
  (4, 'Bob', 175, 5),
  (3, 'Alex', 350, 2),
  (6, 'John Cena', 400, 3),
  (1, 'Winston', 500, 6),
  (2, 'Marie', 200, 4);

-- Expected
CREATE TABLE expected (person_name varchar);
INSERT INTO expected VALUES
  ('John Cena');

-- Your query below this line ------------------------------------------------

