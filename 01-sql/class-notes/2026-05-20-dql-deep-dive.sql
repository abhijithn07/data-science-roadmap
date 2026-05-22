-- 20/05/2026, DQL DEEP DIVE
-- SELECT, WHERE, ORDER BY, GROUP BY, HAVING, LIKE, BETWEEN, NULL
-- order of execution, string functions, CASE, REGEXP

USE sakila;


-- =====================================================
-- 1. SELECT, DISTINCT, COUNT
-- =====================================================

-- all columns of the first 5 rows
SELECT * FROM film LIMIT 5;

-- specific columns
SELECT title, rating, length FROM film LIMIT 5;

-- DISTINCT removes duplicate values
SELECT DISTINCT rating FROM film;

-- how many distinct values
SELECT COUNT(DISTINCT rating) FROM film;

-- distinct on a COMBINATION of columns
SELECT COUNT(DISTINCT rating, length) FROM film;


-- =====================================================
-- 2. LIMIT
-- =====================================================

SELECT title FROM film LIMIT 10;

-- LIMIT makes more sense with ORDER BY
SELECT title, length FROM film ORDER BY length DESC LIMIT 10;

-- skip 10, take 5
SELECT title, length FROM film ORDER BY length DESC LIMIT 5 OFFSET 10;


-- =====================================================
-- 3. WHERE clause + comparison operators
-- =,  !=, <>,  >, <,  >=, <=
-- =====================================================

SELECT title, rating FROM film WHERE rating = 'PG';

-- != and <> both mean "not equal"
SELECT title, rating FROM film WHERE rating != 'PG';
SELECT title, rating FROM film WHERE rating <> 'PG';

SELECT title, length FROM film WHERE length > 120;

SELECT title, rental_rate FROM film WHERE rental_rate <= 2.99;


-- =====================================================
-- 4. AND, OR, NOT, IN, NOT IN
-- =====================================================

SELECT title FROM film WHERE rating = 'PG' AND length > 120;

SELECT title FROM film WHERE rating = 'G' OR rating = 'PG';

-- IN is cleaner than a long OR chain
SELECT title, rating FROM film WHERE rating IN ('G', 'PG');

SELECT title, rating FROM film WHERE rating NOT IN ('G', 'PG');

-- NOT on an expression
SELECT title FROM film WHERE NOT length > 120;


-- =====================================================
-- 5. ORDER BY (ASC default, DESC for high to low)
-- =====================================================

SELECT title, length FROM film ORDER BY length DESC LIMIT 10;
SELECT title, length FROM film ORDER BY length LIMIT 10;

-- multiple sort keys
SELECT title, rating, length
FROM film
ORDER BY rating ASC, length DESC
LIMIT 15;


-- =====================================================
-- 6. LIKE and wildcards
-- %  = any number of chars (including zero)
-- _  = exactly one char
-- =====================================================

SELECT title FROM film WHERE title LIKE 'A%';            -- starts with A
SELECT title FROM film WHERE title LIKE '%TION';         -- ends with TION
SELECT title FROM film WHERE title LIKE '%ALIEN%';       -- contains ALIEN
SELECT title FROM film WHERE title LIKE 'A____';         -- A + 4 chars
SELECT title FROM film WHERE title NOT LIKE 'A%' LIMIT 10;


-- =====================================================
-- 7. NULL  ->  use IS NULL / IS NOT NULL, never = NULL
-- =====================================================

SELECT customer_id, first_name, last_name
FROM customer
WHERE email IS NULL;

SELECT customer_id, first_name, last_name, email
FROM customer
WHERE email IS NOT NULL
LIMIT 10;

-- returns NOTHING because = NULL is always "unknown"
SELECT * FROM customer WHERE email = NULL;


-- =====================================================
-- 8. BETWEEN (inclusive on both ends)
-- =====================================================

SELECT title, length FROM film
WHERE length BETWEEN 60 AND 90
ORDER BY length;

-- works on dates too
SELECT rental_id, rental_date FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-05-31'
LIMIT 10;

SELECT title, length FROM film
WHERE length NOT BETWEEN 60 AND 90 LIMIT 10;


-- =====================================================
-- 9. GROUP BY and HAVING
-- WHERE  -> filters individual rows
-- HAVING -> filters groups, AFTER aggregation
-- =====================================================

-- films per rating
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
ORDER BY film_count DESC;

-- avg rental rate per rating
SELECT rating, COUNT(*), AVG(rental_rate)
FROM film
GROUP BY rating;

-- only ratings with more than 200 films
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
HAVING COUNT(*) > 200;

-- check for duplicate actor names
SELECT first_name, last_name, COUNT(*) AS appearances
FROM actor
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;


-- =====================================================
-- 10. ORDER OF EXECUTION (important)
-- FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
--
-- SELECT runs AFTER HAVING, so aliases shouldn't be used in HAVING.
-- MySQL allows it but PostgreSQL/Oracle do not. Use the full expression.
-- =====================================================

-- works in MySQL but not portable
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
HAVING film_count > 200;

-- safe everywhere
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
HAVING COUNT(*) > 200;


-- =====================================================
-- 11. STRING BUILT-IN FUNCTIONS
-- =====================================================

-- LENGTH
SELECT title, LENGTH(title) FROM film LIMIT 5;

-- UPPER, LOWER
SELECT first_name, UPPER(first_name), LOWER(first_name) FROM actor LIMIT 5;

-- CONCAT
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM actor LIMIT 5;

-- REVERSE
SELECT first_name, REVERSE(first_name) FROM actor LIMIT 5;

-- LEFT, RIGHT
SELECT title, LEFT(title, 3), RIGHT(title, 3) FROM film LIMIT 5;

-- SUBSTRING(string, start, length)
SELECT title, SUBSTRING(title, 1, 5) FROM film LIMIT 5;

-- LPAD, RPAD
SELECT title, LPAD(title, 25, '.'), RPAD(title, 25, '.')
FROM film LIMIT 5;

-- LOCATE = position of substring (1 based, 0 if not found)
SELECT first_name, email, LOCATE('@', email) FROM customer LIMIT 5;

-- SUBSTRING_INDEX splits around a separator
SELECT email,
       SUBSTRING_INDEX(email, '@', 1)  AS username,
       SUBSTRING_INDEX(email, '@', -1) AS domain
FROM customer LIMIT 5;

-- REPLACE
SELECT title, REPLACE(title, 'A', '*') FROM film LIMIT 5;


-- =====================================================
-- 12. CASE  (SQL's if/else)
-- CASE
--   WHEN cond THEN value
--   WHEN cond THEN value
--   ELSE default
-- END
-- =====================================================

SELECT title, rental_rate,
       CASE
         WHEN rental_rate < 1.00 THEN 'Cheap'
         WHEN rental_rate < 3.00 THEN 'Medium'
         ELSE 'Expensive'
       END AS price_band
FROM film LIMIT 10;

SELECT title, length,
       CASE
         WHEN length < 60  THEN 'Short'
         WHEN length < 120 THEN 'Medium'
         ELSE 'Long'
       END AS duration_band
FROM film LIMIT 10;

-- CASE inside an aggregate = conditional counting
SELECT
  SUM(CASE WHEN length < 60 THEN 1 ELSE 0 END) AS short_films,
  SUM(CASE WHEN length BETWEEN 60 AND 120 THEN 1 ELSE 0 END) AS medium_films,
  SUM(CASE WHEN length > 120 THEN 1 ELSE 0 END) AS long_films
FROM film;


-- =====================================================
-- 13. REGEXP, NOT REGEXP
-- ^  start    $  end    .  any char
-- [abc]  one of a/b/c    [^abc]  not one of a/b/c
-- *  0+      +  1+      {n}  exactly n      {n,}  n or more
-- =====================================================

-- starts with A
SELECT title FROM film WHERE title REGEXP '^A' LIMIT 10;

-- ends with TION
SELECT title FROM film WHERE title REGEXP 'TION$' LIMIT 10;

-- contains ALIEN
SELECT title FROM film WHERE title REGEXP 'ALIEN' LIMIT 10;

-- starts with A, B, or C
SELECT title FROM film WHERE title REGEXP '^[ABC]' LIMIT 10;

-- has any digit
SELECT title FROM film WHERE title REGEXP '[0-9]' LIMIT 10;

SELECT title FROM film WHERE title NOT REGEXP '^[ABC]' LIMIT 10;

-- 3 OR MORE consecutive vowels (the class example)
SELECT title FROM film WHERE title REGEXP '[AEIOUaeiou]{3,}';

-- exactly 3 consecutive vowels
SELECT title FROM film
WHERE title REGEXP '[AEIOUaeiou]{3}'
  AND title NOT REGEXP '[AEIOUaeiou]{4,}';


-- =====================================================
-- 14. wrap up : GROUP BY + HAVING + CASE in one query
-- =====================================================

SELECT rating,
       COUNT(*)    AS film_count,
       AVG(length) AS avg_length,
       CASE WHEN COUNT(*) > 200 THEN 'Common' ELSE 'Rare' END AS popularity
FROM film
WHERE rating IS NOT NULL
GROUP BY rating
HAVING AVG(length) > 100
ORDER BY film_count DESC;
