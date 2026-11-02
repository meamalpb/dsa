-- 595. Big Countries · Easy · Select
-- https://leetcode.com/problems/big-countries/
--
-- A country is big if its area is at least 3,000,000 km² or its population at least 25,000,000.
-- Find the name, population and area of the big countries.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/select/easy/big_countries.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE World (name varchar, continent varchar, area int, population int, gdp bigint);
INSERT INTO World VALUES
  ('Afghanistan', 'Asia',   652230,  25500100, 20343000000),
  ('Albania',     'Europe', 28748,   2831741,  12960000000),
  ('Algeria',     'Africa', 2381741, 37100000, 188681000000),
  ('Andorra',     'Europe', 468,     78115,    3712000000),
  ('Angola',      'Africa', 1246700, 20609294, 100990000000);

-- Expected
CREATE TABLE expected (name varchar, population int, area int);
INSERT INTO expected VALUES
  ('Afghanistan', 25500100, 652230),
  ('Algeria', 37100000, 2381741);

-- Your query below this line ------------------------------------------------

