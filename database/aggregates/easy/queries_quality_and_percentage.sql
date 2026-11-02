-- 1211. Queries Quality and Percentage · Easy · Basic Aggregate Functions
-- https://leetcode.com/problems/queries-quality-and-percentage/
--
-- quality = average of rating / position. poor_query_percentage = share of results with
-- rating < 3, as a percentage. Report both for each query_name, rounded to 2 decimals.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/easy/queries_quality_and_percentage.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Queries (query_name varchar, result varchar, position int, rating int);
INSERT INTO Queries VALUES
  ('Dog', 'Golden Retriever', 1, 5),
  ('Dog', 'German Shepherd', 2, 5),
  ('Dog', 'Mule', 200, 1),
  ('Cat', 'Shirazi', 5, 2),
  ('Cat', 'Siamese', 3, 3),
  ('Cat', 'Sphynx', 7, 4);

-- Expected
CREATE TABLE expected (query_name varchar, quality numeric, poor_query_percentage numeric);
INSERT INTO expected VALUES
  ('Cat', 0.66, 33.33),
  ('Dog', 2.50, 33.33);

-- Your query below this line ------------------------------------------------

