-- 1527. Patients With a Condition · Easy · Advanced String Functions / Regex / Clause
-- https://leetcode.com/problems/patients-with-a-condition/
--
-- conditions holds space-separated codes. Find the patients with Type I Diabetes: a code that
-- starts with DIAB1 (columns patient_id, patient_name, conditions).
-- Rows can come in any order.
--
-- Write your query (PostgreSQL) under the last line, then run:
--   bin/srs sql run database/strings/easy/patients_with_a_condition.sql
-- Each case runs in its own transaction (rolled back afterwards) and your
-- result is compared with that case's `expected` table.

-- Case 1: LeetCode's example ------------------------------------------------

CREATE TABLE Patients (patient_id int, patient_name varchar, conditions varchar);
INSERT INTO Patients VALUES
  (1, 'Daniel', 'YFEV COUGH'),
  (2, 'Alice', ''),
  (3, 'Bob', 'DIAB100 MYOP'),
  (4, 'George', 'ACNE DIAB100'),
  (5, 'Alain', 'DIAB201');

-- Expected
CREATE TABLE expected (patient_id int, patient_name varchar, conditions varchar);
INSERT INTO expected VALUES
  (3, 'Bob', 'DIAB100 MYOP'),
  (4, 'George', 'ACNE DIAB100');

-- Case 2: DIAB1 inside another code does not count --------------------------

CREATE TABLE Patients (patient_id int, patient_name varchar, conditions varchar);
INSERT INTO Patients VALUES
  (1, 'Ana', 'SADIAB100'),
  (2, 'Ben', 'MYOP DIAB100 ACNE'),
  (3, 'Cleo', 'ACNE +DIAB100');

-- Expected
CREATE TABLE expected (patient_id int, patient_name varchar, conditions varchar);
INSERT INTO expected VALUES
  (2, 'Ben', 'MYOP DIAB100 ACNE');

-- Your query below this line ------------------------------------------------

