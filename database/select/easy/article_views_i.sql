-- 1148. Article Views I · Easy · Select
-- https://leetcode.com/problems/article-views-i/
--
-- Find all the authors that viewed at least one of their own articles (column `id`),
-- sorted by id ascending. The table may contain duplicate rows.
-- Rows must come in the order shown.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/select/easy/article_views_i.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Views (article_id int, author_id int, viewer_id int, view_date date);
INSERT INTO Views VALUES
  (1, 3, 5, '2019-08-01'),
  (1, 3, 6, '2019-08-02'),
  (2, 7, 7, '2019-08-01'),
  (2, 7, 6, '2019-08-02'),
  (4, 7, 1, '2019-07-22'),
  (3, 4, 4, '2019-07-21'),
  (3, 4, 4, '2019-07-21');

-- Expected
CREATE TABLE expected (id int);
INSERT INTO expected VALUES
  (4),
  (7);

-- Your query below this line ------------------------------------------------

