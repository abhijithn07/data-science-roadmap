-- 26/05/2026, INDEXES, KEYS, QUERY FINE TUNING
-- was absent this session, catching up from a classmate's notes

USE sakila;


-- 1. INDEXES
--
-- an index is like the index page of a book.
-- without one, MySQL scans every row to find a match (full table scan).
-- with one, it can jump straight to the matching rows.
-- indexes are automatically created on PRIMARY KEY and UNIQUE columns.

-- see which indexes a table already has
SHOW INDEX FROM customer;


-- 2. CLUSTERED INDEX (the primary key)
--
-- decides the PHYSICAL order of rows in the table.
-- InnoDB stores the table data sorted by the primary key.
-- only ONE clustered index per table is possible (data can only be ordered one way).

-- customer_id is the PK, so this lookup is very fast
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = 10;


-- 3. NON-CLUSTERED INDEX (regular index)
--
-- a separate structure stored alongside the table.
-- holds the indexed column value plus a pointer to the row.
-- does NOT change the physical order of the table.
-- a table can have many non-clustered indexes.

-- index on last_name for faster name lookups
CREATE INDEX idx_customer_last_name ON customer(last_name);

-- without the index this would do a full scan, with it MySQL jumps to matches
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name = 'SMITH';


-- 4. INDEXES AND JOINS
--
-- joins are faster when the join columns are indexed on both sides.
-- here customer.customer_id is a PK (indexed) and payment.customer_id is a FK (indexed).

SELECT c.customer_id, c.first_name, c.last_name, p.amount, p.payment_date
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE c.customer_id = 5;


-- 5. COMPOSITE INDEX
--
-- an index built on TWO OR MORE columns together.
-- useful when queries filter on the LEADING columns of the index.
-- the order of columns in the index matters : (a, b) helps queries filtering on
-- a alone or on a+b, but NOT on b alone.

CREATE INDEX idx_rental_customer_date ON rental(customer_id, rental_date);

-- this query uses both columns of the composite index
SELECT rental_id, customer_id, rental_date, return_date
FROM rental
WHERE customer_id = 10
ORDER BY rental_date;


-- drop an index if it is no longer useful
DROP INDEX idx_customer_last_name ON customer;


-- 6. NATURAL KEY
--
-- a column with REAL-WORLD meaning that uniquely identifies a row.
-- examples : email, SSN, passport number, phone number, employee ID.
-- downside : real-world values can change. if email is the primary key and
-- a customer changes email, every foreign key referencing them has to update.
-- this is why natural keys are usually NOT chosen as primary keys.

-- email is meaningful in real life, so it can act as a natural key
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE email = 'MARY.SMITH@sakilacustomer.org';


-- 7. SURROGATE KEY
--
-- an artificial ID created only for the database. no real-world meaning.
-- usually an auto-incrementing integer.
-- examples in sakila : customer_id, film_id, actor_id, rental_id, payment_id.
-- preferred for primary keys because they never need to change.

-- joins typically use surrogate keys
SELECT c.customer_id, c.first_name, c.last_name, r.rental_id, r.rental_date
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE c.customer_id = 1;


-- 8. QUERY FINE TUNING TECHNIQUES
--
-- 20 techniques to make queries faster and use fewer resources.


-- Technique 1 : EXPLAIN
-- shows MySQL's execution plan for a query.
-- look at : type, possible_keys, key, rows, Extra.
-- if rows is huge and key is NULL, no index is being used.

EXPLAIN
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name = 'SMITH';


-- Technique 2 : avoid SELECT *
-- pulls every column even if you only need a few. wastes bandwidth and memory.

-- bad
SELECT * FROM customer;

-- good
SELECT customer_id, first_name, last_name, email
FROM customer;


-- Technique 3 : filter early with WHERE
-- bring back fewer rows from the database, do not filter in your head.

-- bad : pulls all payments
SELECT payment_id, customer_id, amount FROM payment;

-- good : only pulls the rows you care about
SELECT payment_id, customer_id, amount
FROM payment
WHERE amount > 8;


-- Technique 4 : index columns frequently used in WHERE
-- if you often filter by amount, an index on amount speeds those queries up.

CREATE INDEX idx_payment_amount ON payment(amount);


-- Technique 5 : do NOT wrap indexed columns in functions
-- the function blocks the optimizer from using the index.

-- bad : DATE() wraps payment_date, index cannot be used
SELECT payment_id, payment_date, amount
FROM payment
WHERE DATE(payment_date) = '2005-05-25';

-- good : range comparison on the raw column, index can be used
SELECT payment_id, payment_date, amount
FROM payment
WHERE payment_date >= '2005-05-25'
  AND payment_date <  '2005-05-26';


-- Technique 6 : prefer JOIN over repeated subqueries
-- usually easier to read and the optimizer handles JOINs better.

-- less efficient : subquery
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id FROM payment WHERE amount > 10
);

-- better : JOIN
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE p.amount > 10;


-- Technique 7 : use LIMIT when testing queries
-- avoids loading thousands of rows during exploration.

SELECT rental_id, rental_date, customer_id
FROM rental
LIMIT 10;


-- Technique 8 : index columns used in JOIN
-- both sides of the join condition should be indexed.

SELECT f.film_id, f.title, i.inventory_id
FROM film f
JOIN inventory i ON f.film_id = i.film_id;
-- film_id is a PK in film (auto-indexed) and a FK in inventory (auto-indexed).


-- Technique 9 : composite index for multi-column filters
-- when queries consistently filter on the same pair of columns.

CREATE INDEX idx_payment_customer_amount ON payment(customer_id, amount);

SELECT payment_id, customer_id, amount
FROM payment
WHERE customer_id = 10
  AND amount > 5;


-- Technique 10 : OR can hurt index usage
-- MySQL sometimes cannot use indexes on both sides of an OR.

-- can be slow
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name = 'MARY'
   OR last_name  = 'SMITH';

-- sometimes faster : UNION lets each side use its own index
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name = 'MARY'
UNION
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name  = 'SMITH';


-- Technique 11 : use EXISTS for existence checks
-- when you only care that ANY matching row exists, not the values.

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM payment p WHERE p.customer_id = c.customer_id
);


-- Technique 12 : avoid unnecessary DISTINCT
-- DISTINCT adds a sort or hash step. only use it if duplicates are a real problem.

-- bad : DISTINCT for no good reason
SELECT DISTINCT first_name, last_name FROM customer;

-- good : drop it if duplicates are fine
SELECT first_name, last_name FROM customer;


-- Technique 13 : GROUP BY with care
-- aggregates over all rows unless you filter first.

-- total payment per customer
SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id;

-- with customer names attached
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_amount
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;


-- Technique 14 : filter rows BEFORE grouping (WHERE) vs after (HAVING)
-- WHERE runs before GROUP BY, HAVING runs after.
-- reducing rows early means less work for the aggregator.

SELECT customer_id, SUM(amount) AS total_amount
FROM payment
WHERE amount > 5            -- filters rows before grouping
GROUP BY customer_id
HAVING SUM(amount) > 100;   -- filters groups after aggregating


-- Technique 15 : avoid LEADING wildcard in LIKE
-- '%ACADEMY%' cannot use an index. 'ACADEMY%' can.

-- bad : leading %
SELECT film_id, title FROM film WHERE title LIKE '%ACADEMY%';

-- good : pattern anchored at the start
SELECT film_id, title FROM film WHERE title LIKE 'ACADEMY%';


-- Technique 16 : use proper data types
-- wrong types break indexes and comparisons.
--   amount -> DECIMAL  (not VARCHAR)
--   date   -> DATE / DATETIME  (not VARCHAR)
--   id     -> INT
--   name   -> VARCHAR


-- Technique 17 : do not sort huge datasets without a limit
-- ORDER BY without LIMIT sorts every single row.

-- inefficient
SELECT rental_id, rental_date, customer_id
FROM rental
ORDER BY rental_date;

-- better : take only what is needed
SELECT rental_id, rental_date, customer_id
FROM rental
ORDER BY rental_date
LIMIT 20;

-- index on the ORDER BY column makes sorting much faster
CREATE INDEX idx_rental_date ON rental(rental_date);


-- Technique 18 : covering index
-- an index that contains ALL the columns a query needs.
-- MySQL can answer the query from the index alone, without ever touching the table.

CREATE INDEX idx_customer_name_email
ON customer(last_name, first_name, email);

-- this query is fully satisfied by the index above
SELECT first_name, email
FROM customer
WHERE last_name = 'SMITH';


-- Technique 19 : do NOT over-index
-- every index speeds up SELECT but slows down INSERT / UPDATE / DELETE,
-- because every index has to be updated when data changes.
--
-- good candidates : columns in WHERE, JOIN, ORDER BY, GROUP BY, foreign keys
-- bad candidates  : rarely used columns, columns with very few distinct values
--                   (Y/N flags), very small tables (overhead is not worth it)


-- Technique 20 : check existing indexes before creating new ones
-- you might already have what you need.

SHOW INDEX FROM customer;
SHOW INDEX FROM rental;
SHOW INDEX FROM payment;
SHOW INDEX FROM film;
