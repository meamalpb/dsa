-- 1341. Movie Rating · Medium · Subqueries
-- https://leetcode.com/problems/movie-rating/
--
-- Return two rows in one column `results`: the name of the user who rated the most movies, and
-- the title of the movie with the highest average rating in February 2020. Break ties with\nthe lexicographically smaller name/title.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/subqueries/medium/movie_rating.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Movies (movie_id int, title varchar);
CREATE TABLE Users (user_id int, name varchar);
CREATE TABLE MovieRating (movie_id int, user_id int, rating int, created_at date);
INSERT INTO Movies VALUES
  (1, 'Avengers'),
  (2, 'Frozen 2'),
  (3, 'Joker');
INSERT INTO Users VALUES
  (1, 'Daniel'),
  (2, 'Monica'),
  (3, 'Maria'),
  (4, 'James');
INSERT INTO MovieRating VALUES
  (1, 1, 3, '2020-01-12'),
  (1, 2, 4, '2020-02-11'),
  (1, 3, 2, '2020-02-12'),
  (1, 4, 1, '2020-01-01'),
  (2, 1, 5, '2020-02-17'),
  (2, 2, 2, '2020-02-01'),
  (2, 3, 2, '2020-03-01'),
  (3, 1, 3, '2020-02-22'),
  (3, 2, 4, '2020-02-25');

-- Expected
CREATE TABLE expected (results varchar);
INSERT INTO expected VALUES
  ('Daniel'),
  ('Frozen 2');

-- Your query below this line ------------------------------------------------

