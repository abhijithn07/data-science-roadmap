-- =====================================================
-- Class Notes : 19/05/2026
-- Topic       : SQL Basics, DDL, DML, DQL, Constraints,
--               Primary Key, Foreign Key, RESTRICT vs CASCADE,
--               DELETE vs TRUNCATE vs DROP, INFORMATION_SCHEMA
-- Database    : sakila (we add a few practice tables inside it)
-- =====================================================

/*
QUICK CONCEPT RECAP
-------------------
MySQL Server     : the engine that stores data on disk and runs SQL.
MySQL Workbench  : the GUI client. Workbench sends SQL to the server,
                   the server runs it and sends results back.
SQL              : Structured Query Language. The language used to talk to a relational DB.
Schema           : a container that holds tables, views, procedures, etc.
                   In MySQL, "schema" and "database" mean the same thing.
Sakila           : MySQL's official sample database. 16 tables modelling a DVD rental store.

THE 5 SQL COMMAND CATEGORIES
----------------------------
DDL  ->  Data Definition Language     ->  CREATE, ALTER, DROP, TRUNCATE  (define structure)
DML  ->  Data Manipulation Language   ->  INSERT, UPDATE, DELETE         (modify data)
DQL  ->  Data Query Language          ->  SELECT                         (read data)
DCL  ->  Data Control Language        ->  GRANT, REVOKE                  (permissions)
TCL  ->  Transaction Control Language ->  COMMIT, ROLLBACK, SAVEPOINT    (transactions)
*/


-- Use sakila as the active database. Everything below runs inside sakila.
USE sakila;


-- =====================================================
-- 1. DDL : create our own tables inside sakila
-- (Sakila already has its 16 original tables. We add practice ones.)
-- =====================================================

-- Departments table
CREATE TABLE departments (
    department_id   INT,
    department_name VARCHAR(60)
);

-- Employees table
CREATE TABLE employees (
    employee_id      INT,
    full_name        VARCHAR(100),
    base_salary      DECIMAL(10,2),
    department_id    INT
);

-- See the structure of each table
DESC departments;
DESC employees;


-- =====================================================
-- 2. DML : insert rows into the tables
-- =====================================================

-- Departments
INSERT INTO departments (department_id, department_name) VALUES (10, 'Engineering');
INSERT INTO departments (department_id, department_name) VALUES (20, 'Operations');
INSERT INTO departments (department_id, department_name) VALUES (30, 'Marketing');
INSERT INTO departments (department_id, department_name) VALUES (40, 'Support');

-- Employees
INSERT INTO employees (employee_id, full_name, base_salary, department_id)
VALUES (1001, 'Aaron Mehta',      72000.00, 10);
INSERT INTO employees (employee_id, full_name, base_salary, department_id)
VALUES (1002, 'Beatrice Lopez',   55500.75, 40);
INSERT INTO employees (employee_id, full_name, base_salary, department_id)
VALUES (1003, 'Carlos Fernandes', 91000.00, 20);
INSERT INTO employees (employee_id, full_name, base_salary, department_id)
VALUES (1004, 'Devi Krishnan',    48000.00, 30);
INSERT INTO employees (employee_id, full_name, base_salary, department_id)
VALUES (1005, 'Esha Banerjee',    63500.50, 10);

-- Look at what we inserted
SELECT * FROM departments;
SELECT * FROM employees;

-- UPDATE a single row
-- MySQL safe update mode can block UPDATE without a key column in WHERE.
-- Adding LIMIT 1 is a workaround.
UPDATE employees
SET base_salary = 78000.00
WHERE employee_id = 1001
LIMIT 1;

-- ALTER TABLE : add a new column
ALTER TABLE employees ADD contact_email VARCHAR(150);

-- Populate the new column
UPDATE employees SET contact_email = 'aaron@corp.com'    WHERE employee_id = 1001 LIMIT 1;
UPDATE employees SET contact_email = 'beatrice@corp.com' WHERE employee_id = 1002 LIMIT 1;
UPDATE employees SET contact_email = 'carlos@corp.com'   WHERE employee_id = 1003 LIMIT 1;
UPDATE employees SET contact_email = 'devi@corp.com'     WHERE employee_id = 1004 LIMIT 1;
UPDATE employees SET contact_email = 'esha@corp.com'     WHERE employee_id = 1005 LIMIT 1;


-- =====================================================
-- 3. DQL : SELECT statements to read data
-- =====================================================

-- All rows of both tables
SELECT * FROM departments;
SELECT * FROM employees;

-- Specific columns only
SELECT full_name, base_salary FROM employees;

-- Filter rows with WHERE
SELECT full_name, contact_email
FROM employees
WHERE department_id = 10;

-- Sort with ORDER BY (DESC = high to low, ASC = low to high)
SELECT full_name, base_salary
FROM employees
ORDER BY base_salary DESC;

-- A quick peek at a real Sakila table while we are in here
SELECT title, rating, rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 5;


-- =====================================================
-- 4. Constraints : rules the database enforces on data
-- Common ones : NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT
-- We demonstrate them on a fresh "persons" table.
-- =====================================================

-- ---- NOT NULL and UNIQUE ----
--   NOT NULL : the column must always have a value (cannot be NULL).
--   UNIQUE   : every value in this column must differ from every other.

CREATE TABLE persons (
    user_id        INT UNIQUE,
    full_name      VARCHAR(80) NOT NULL,
    contact_email  VARCHAR(120) UNIQUE,
    user_age       INT
);

INSERT INTO persons VALUES (1, 'Krishna Iyer', 'krishna@mail.com', 27);
INSERT INTO persons VALUES (2, 'Lila Roy',     'lila@mail.com',    32);

-- FAILS : full_name is NOT NULL
INSERT INTO persons VALUES (3, NULL, 'blank@mail.com', 24);

-- FAILS : user_id 2 is already in use (UNIQUE)
INSERT INTO persons VALUES (2, 'Mohan Das', 'mohan@mail.com', 29);

-- FAILS : contact_email 'krishna@mail.com' already exists (UNIQUE)
INSERT INTO persons VALUES (4, 'Naveen Pillai', 'krishna@mail.com', 35);

SELECT * FROM persons;


-- ---- CHECK and DEFAULT ----
--   CHECK   : a custom condition that every row must satisfy.
--   DEFAULT : a fallback value used when the column is omitted in an INSERT.

DROP TABLE IF EXISTS persons;

CREATE TABLE persons (
    user_id        INT,
    full_name      VARCHAR(80) NOT NULL,
    home_city      VARCHAR(50) DEFAULT 'Bangalore',           -- default city
    user_age       INT CHECK (user_age BETWEEN 18 AND 80)     -- realistic adult range
);

-- home_city omitted, default 'Bangalore' is used
INSERT INTO persons (user_id, full_name, user_age) VALUES (1, 'Krishna Iyer', 27);

-- home_city given explicitly
INSERT INTO persons VALUES (2, 'Lila Roy', 'Mumbai', 32);

-- home_city omitted again, takes default
INSERT INTO persons (user_id, full_name, user_age) VALUES (3, 'Mohan Das', 29);

-- FAILS : user_age 15 violates CHECK (BETWEEN 18 AND 80)
INSERT INTO persons VALUES (4, 'Young Sam', 'Bangalore', 15);

-- FAILS : full_name cannot be NULL
INSERT INTO persons VALUES (5, NULL, 'Bangalore', 25);

SELECT * FROM persons;


-- =====================================================
-- 5. PRIMARY KEY and FOREIGN KEY
--
-- PRIMARY KEY : uniquely identifies each row (= UNIQUE + NOT NULL).
--               A table has at most ONE primary key.
-- FOREIGN KEY : links one table's column to another table's primary key.
--               A table can have many foreign keys.
--
-- Terminology pairs (mean the same thing) :
--   Parent table  =  Referenced table   (the one with the primary key being pointed to)
--   Child  table  =  Referencing table  (the one with the foreign key column)
-- =====================================================

-- Recreate persons as the PARENT (referenced) table
DROP TABLE persons;

CREATE TABLE persons (
    user_id        INT PRIMARY KEY,         -- PK = UNIQUE + NOT NULL
    full_name      VARCHAR(80) NOT NULL,
    contact_email  VARCHAR(120)
);

-- orders is the CHILD (referencing) table.
-- user_id in orders must match a user_id that exists in persons.
CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    item_name   VARCHAR(80),
    user_id     INT,

    FOREIGN KEY (user_id) REFERENCES persons(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Fill the parent
INSERT INTO persons VALUES (1, 'Krishna Iyer', 'krishna@mail.com');
INSERT INTO persons VALUES (2, 'Lila Roy',     'lila@mail.com');
INSERT INTO persons VALUES (3, 'Mohan Das',    'mohan@mail.com');

-- FAILS : user_id 1 already taken (primary key must be unique)
INSERT INTO persons VALUES (1, 'Krishna Twin', 'twin@mail.com');

-- Fill the child
INSERT INTO orders VALUES (5001, 'Headphones',  1);
INSERT INTO orders VALUES (5002, 'Smart Watch', 2);
INSERT INTO orders VALUES (5003, 'Backpack',    1);
INSERT INTO orders VALUES (5004, 'Notebook',    3);

-- FAILS : user_id 9 does not exist in persons. FK rejects it.
INSERT INTO orders VALUES (5005, 'Keyboard', 9);

-- FAILS : order_id 5001 already taken
INSERT INTO orders VALUES (5001, 'Mouse', 2);

SELECT * FROM persons;
SELECT * FROM orders;

-- All orders placed by Krishna
SELECT * FROM orders WHERE user_id = 1;


-- =====================================================
-- 6. RESTRICT vs CASCADE in action
--
-- RESTRICT : the DB refuses to delete or update the parent while
--            child rows still reference it.
-- CASCADE  : the DB automatically propagates the change to children.
--
-- We set ON DELETE RESTRICT and ON UPDATE CASCADE above.
-- =====================================================

-- ---- RESTRICT (on delete) ----
-- Try to delete Krishna while she still has order rows. REJECTED.
DELETE FROM persons WHERE user_id = 1;

-- Fix : delete the child rows first, then the parent
DELETE FROM orders  WHERE user_id = 1;
DELETE FROM persons WHERE user_id = 1;

SELECT * FROM persons;
SELECT * FROM orders;

-- ---- CASCADE (on update) ----
-- Change Lila's user_id. Because of ON UPDATE CASCADE, the FK in orders
-- updates automatically.
SELECT * FROM persons;
SELECT * FROM orders;

UPDATE persons
SET user_id = 20
WHERE user_id = 2;

SELECT * FROM persons;     -- Lila now has user_id 20
SELECT * FROM orders;      -- her order row also shows user_id 20


-- =====================================================
-- 7. DELETE vs TRUNCATE vs DROP
-- Three different "remove" commands. Demonstrated on the employees table.
-- =====================================================

-- DELETE  : DML. Removes specific rows (or all rows). Supports WHERE.
--           Can be rolled back inside a transaction. Slow (logs each row).
--           The table and its structure stay.
DELETE FROM employees
WHERE employee_id = 1002
LIMIT 1;

-- TRUNCATE : DDL. Removes ALL rows fast by deallocating storage pages.
--            No WHERE clause. Usually cannot be rolled back. Resets AUTO_INCREMENT.
--            The table and its structure stay.
TRUNCATE TABLE employees;

-- DROP : DDL. Removes the entire table. Data, structure, constraints, triggers all gone.
--        Cannot be rolled back in MySQL. The table no longer exists.
DROP TABLE employees;

-- FAILS : the employees table no longer exists
SELECT * FROM employees;


-- =====================================================
-- 8. INFORMATION_SCHEMA and metadata
--
-- Metadata = "data about data". Describes the structure of the database
-- itself (tables, columns, types, constraints, relationships). Stored in
-- the read only INFORMATION_SCHEMA system database. We can query it like
-- any other set of tables.
-- =====================================================

-- List every table in the sakila database
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'sakila'
ORDER BY table_name;

-- List every column of the film table (a real Sakila table) with its type
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'sakila'
  AND table_name   = 'film'
ORDER BY ordinal_position;

-- List every foreign key in sakila : which child column points to which parent
SELECT table_name              AS child_table,
       column_name             AS child_column,
       referenced_table_name   AS parent_table,
       referenced_column_name  AS parent_column
FROM information_schema.key_column_usage
WHERE table_schema = 'sakila'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name, column_name;


-- =====================================================
-- 9. Cleanup : drop the practice tables so sakila is back to its
-- original 16 tables. Comment these out if you want to keep them.
-- =====================================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS persons;
DROP TABLE IF EXISTS departments;
-- employees was already dropped in section 7.


-- =====================================================
-- END OF NOTES : 19/05/2026
-- Covered today : DDL, DML, DQL, NOT NULL, UNIQUE, CHECK, DEFAULT,
--                 PRIMARY KEY, FOREIGN KEY with parent / child terminology,
--                 RESTRICT vs CASCADE, DELETE vs TRUNCATE vs DROP,
--                 INFORMATION_SCHEMA queries on sakila.
-- =====================================================
