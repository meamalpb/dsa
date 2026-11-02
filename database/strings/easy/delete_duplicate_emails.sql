-- 196. Delete Duplicate Emails · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/delete-duplicate-emails/
--
-- Write a DELETE statement that removes duplicate emails, keeping for each email only the row
-- with the smallest id. (Not a SELECT: the table itself is checked afterwards.)
-- Rows can come in any order.
-- Checked with: SELECT * FROM Person
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/delete_duplicate_emails.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Person (id int PRIMARY KEY, email varchar);
INSERT INTO Person VALUES
  (1, 'john@example.com'),
  (2, 'bob@example.com'),
  (3, 'john@example.com');

-- Expected
CREATE TABLE expected (id int, email varchar);
INSERT INTO expected VALUES
  (1, 'john@example.com'),
  (2, 'bob@example.com');

-- Your query below this line ------------------------------------------------

