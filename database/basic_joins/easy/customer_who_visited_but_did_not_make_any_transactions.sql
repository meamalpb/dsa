-- 1581. Customer Who Visited but Did Not Make Any Transactions · Easy · Basic Joins
-- https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/
--
-- Find the customers who visited without making any transaction, and how many such visits
-- each made (columns customer_id, count_no_trans).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/basic_joins/easy/customer_who_visited_but_did_not_make_any_transactions.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Visits (visit_id int, customer_id int);
CREATE TABLE Transactions (transaction_id int, visit_id int, amount int);
INSERT INTO Visits VALUES
  (1, 23),
  (2, 9),
  (4, 30),
  (5, 54),
  (6, 96),
  (7, 54),
  (8, 54);
INSERT INTO Transactions VALUES
  (2, 5, 310),
  (3, 5, 300),
  (9, 5, 200),
  (12, 1, 910),
  (13, 2, 970);

-- Expected
CREATE TABLE expected (customer_id int, count_no_trans int);
INSERT INTO expected VALUES
  (30, 1),
  (54, 2),
  (96, 1);

-- Your query below this line ------------------------------------------------

