-- 1517. Find Users With Valid E-Mails · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/find-users-with-valid-e-mails/
--
-- A valid email is a prefix, then '@leetcode.com'. The prefix starts with a letter and may contain
-- letters, digits, '_', '.' and '-'. Find the users with valid emails.
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/find_users_with_valid_e_mails.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Users (user_id int, name varchar, mail varchar);
INSERT INTO Users VALUES
  (1, 'Winston', 'winston@leetcode.com'),
  (2, 'Jonathan', 'jonathanisgreat'),
  (3, 'Annabelle', 'bella-@leetcode.com'),
  (4, 'Sally', 'sally.come@leetcode.com'),
  (5, 'Marwan', 'quarz#2020@leetcode.com'),
  (6, 'David', 'david69@gmail.com'),
  (7, 'Shapiro', '.shapo@leetcode.com');

-- Expected
CREATE TABLE expected (user_id int, name varchar, mail varchar);
INSERT INTO expected VALUES
  (1, 'Winston', 'winston@leetcode.com'),
  (3, 'Annabelle', 'bella-@leetcode.com'),
  (4, 'Sally', 'sally.come@leetcode.com');

-- Case 2: trickier emails ---------------------------------------------------

CREATE TABLE Users (user_id int, name varchar, mail varchar);
INSERT INTO Users VALUES
  (8, 'Benjamin', 'Benjamin._2@leetcode.com'),
  (9, 'Winston', 'winston@leetcode?com'),
  (10, 'Eve', 'eve@leetcodeXcom'),
  (11, 'Max', 'max@leetcode.com.au'),
  (12, 'Ivy', '7ivy@leetcode.com');

-- Expected
CREATE TABLE expected (user_id int, name varchar, mail varchar);
INSERT INTO expected VALUES
  (8, 'Benjamin', 'Benjamin._2@leetcode.com');

-- Your query below this line ------------------------------------------------

