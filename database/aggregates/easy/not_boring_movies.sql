-- 620. Not Boring Movies · Easy · Basic Aggregate Functions
-- https://leetcode.com/problems/not-boring-movies/
--
-- Report the movies with an odd id whose description is not 'boring',
-- ordered by rating, highest first.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/aggregates/easy/not_boring_movies.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Cinema (id int, movie varchar, description varchar, rating numeric(2, 1));
INSERT INTO Cinema VALUES
  (1, 'War', 'great 3D', 8.9),
  (2, 'Science', 'fiction', 8.5),
  (3, 'irish', 'boring', 6.2),
  (4, 'Ice song', 'Fantacy', 8.6),
  (5, 'House card', 'Interesting', 9.1);

-- Expected
CREATE TABLE expected (id int, movie varchar, description varchar, rating numeric);
INSERT INTO expected VALUES
  (5, 'House card', 'Interesting', 9.1),
  (1, 'War', 'great 3D', 8.9);

-- Your query below this line ------------------------------------------------

