-- 21/05/2026, MATH FUNCTIONS, DATE FUNCTIONS, SUBQUERIES
-- aggregates recap, math (MOD/CEIL/FLOOR/ROUND), dates,
-- subqueries (basic, derived tables, correlated)

USE sakila;


-- 1. AGGREGATE RECAP
-- COUNT, SUM, AVG, MAX, MIN
--
-- aggregates collapse many rows into a single value.
-- they ignore NULLs (except COUNT(*) which counts every row).
-- MIN and MAX work on dates and strings too, not just numbers.

SELECT COUNT(*) FROM film;
SELECT COUNT(rental_rate) FROM film;            -- skips NULL rental_rate values
SELECT COUNT(DISTINCT rating) FROM film;        -- count unique values

SELECT SUM(amount) AS total_revenue FROM payment;
SELECT AVG(amount) AS avg_payment   FROM payment;
SELECT MIN(amount), MAX(amount)     FROM payment;

-- MIN/MAX on a non-numeric column
SELECT MIN(rental_date), MAX(rental_date) FROM rental;

-- aggregates with GROUP BY = one summary row per group
SELECT customer_id, COUNT(*) AS rentals, SUM(amount) AS spent
FROM payment
GROUP BY customer_id
ORDER BY spent DESC
LIMIT 10;


-- 2. MATH FUNCTIONS
-- MOD, CEIL (ceiling), FLOOR, ROUND
--
-- useful when working with division results, time conversions
-- (minutes to hours), pagination math (rows / per_page),
-- or rounding money / percentages.

-- MOD = remainder after division. Often used to check even/odd
-- or to cycle through values (MOD by N gives 0 to N-1).
SELECT MOD(10, 3), MOD(15, 4), MOD(20, 5);    -- 1, 3, 0
SELECT film_id, MOD(film_id, 2) AS even_or_odd FROM film LIMIT 5;

-- CEIL rounds UP toward positive infinity, FLOOR rounds DOWN.
-- Both return an integer.
SELECT CEIL(4.2), CEIL(4.8);                  -- 5, 5
SELECT FLOOR(4.2), FLOOR(4.8);                -- 4, 4

-- ROUND rounds to nearest. Optional second arg = number of decimal places.
SELECT ROUND(4.5), ROUND(4.4);                -- 5, 4
SELECT ROUND(123.456, 2), ROUND(123.456, 0);  -- 123.46, 123

-- on real Sakila data : break film length (minutes) into hours + minutes
SELECT film_id, length,
       ROUND(length / 60.0, 2) AS length_hours,    -- like 1.92
       FLOOR(length / 60.0)    AS full_hours,      -- like 1
       MOD(length, 60)         AS extra_minutes,   -- the remainder
       CEIL(length / 60.0)     AS rounded_up_hours
FROM film
LIMIT 10;


-- 3. DATE FUNCTIONS
-- NOW, CURDATE, CURTIME, DATEDIFF, YEAR, MONTH, DAY, DAYOFWEEK, etc.
--
-- date functions are how we slice and compare timestamps.
-- date columns store both date and time. functions like
-- CURDATE / MONTH let us work with just the parts we need.

SELECT NOW();         -- date AND time
SELECT CURDATE();     -- date only
SELECT CURTIME();     -- time only

-- DATEDIFF(d1, d2) = days from d2 to d1.
-- can be negative if d2 is after d1. ignores the time portion.
SELECT DATEDIFF('2026-05-21', '2026-01-01');     -- positive
SELECT DATEDIFF('2026-01-01', '2026-05-21');     -- negative
SELECT DATEDIFF(NOW(), '2025-01-01');

-- pull out parts of a date
-- note : DAYOFWEEK in MySQL returns 1=Sunday ... 7=Saturday
-- (this differs from PostgreSQL where 0=Sunday)
SELECT NOW(),
       YEAR(NOW())       AS yr,
       MONTH(NOW())      AS mn,
       DAY(NOW())        AS dy,
       DAYOFWEEK(NOW())  AS dow,
       DAYNAME(NOW())    AS day_name,
       MONTHNAME(NOW())  AS month_name;

-- common use : "how recent" or "in what month" did something happen
SELECT rental_id, rental_date,
       DATEDIFF(NOW(), rental_date) AS days_ago,
       MONTH(rental_date)           AS rental_month,
       DAYNAME(rental_date)         AS rental_day
FROM rental
LIMIT 10;


-- 4. INTERVAL, DATE_ADD, DATE_SUB
-- adding or subtracting time from a date.
--
-- units you can use : DAY, HOUR, MINUTE, SECOND, WEEK, MONTH, YEAR,
-- QUARTER, MICROSECOND. Two ways to write the same thing :
-- the INTERVAL keyword directly, or DATE_ADD / DATE_SUB functions.

-- INTERVAL keyword (shorter, more readable)
SELECT NOW(),
       NOW() - INTERVAL 1 DAY   AS yesterday,
       NOW() + INTERVAL 7 DAY   AS next_week,
       NOW() + INTERVAL 1 HOUR  AS in_one_hour,
       NOW() + INTERVAL 3 MONTH AS in_three_months;

-- DATE_ADD / DATE_SUB (do the same thing, function form)
SELECT DATE_ADD(NOW(), INTERVAL 5 DAY)   AS five_days_later,
       DATE_SUB(NOW(), INTERVAL 1 MONTH) AS one_month_ago;

-- real example : payment is "due" 5 days after each payment_date
SELECT payment_id, payment_date,
       DATE_ADD(payment_date, INTERVAL 5 DAY) AS due_date
FROM payment
LIMIT 10;

-- CONCAT a date into a string (CURDATE / NOW get converted automatically)
SELECT CONCAT('Generated on ', CURDATE()) AS report_header;
SELECT CONCAT('Run at ', NOW())            AS log_line;


-- 5. DATE_FORMAT
-- format a date/datetime as a string using placeholders.
--
-- main placeholders :
--   %Y year (4 digit, e.g. 2026)   %y year (2 digit, e.g. 26)
--   %m month (01-12)               %M month name (May)
--   %d day (01-31)                 %e day without leading zero
--   %D day with English suffix (1st, 2nd, 3rd)
--   %H hour 24 (00-23)             %h hour 12 (01-12)
--   %i minute (00-59)              %s second (00-59)
--   %p AM / PM                     %W weekday name (Monday)

SELECT DATE_FORMAT(NOW(), '%d-%m-%Y');           -- 21-05-2026
SELECT DATE_FORMAT(NOW(), '%Y/%m/%d');           -- 2026/05/21
SELECT DATE_FORMAT(NOW(), '%M %D, %Y');          -- May 21st, 2026
SELECT DATE_FORMAT(NOW(), '%W, %M %e at %h:%i %p');

-- common use : turn dates into the format a report or stakeholder expects
SELECT payment_id, payment_date,
       DATE_FORMAT(payment_date, '%d-%m-%y') AS short_date,
       DATE_FORMAT(payment_date, '%M %Y')    AS month_year
FROM payment
LIMIT 10;


-- 6. SUBQUERIES
-- a query nested inside another query, wrapped in parentheses.
--
-- the inner one runs first (usually), the outer one uses its result.
-- can sit in three places :
--   WHERE   = filter using a computed value
--   SELECT  = add a computed column per row
--   FROM    = treat the result as a "derived" temporary table
--
-- when to use : when the value or set you need to filter / join /
-- compare against is not a constant, it has to be calculated from
-- another query.

-- a) subquery in WHERE returning a SINGLE value (use with =, >, <)
-- payments above the global average
SELECT payment_id, customer_id, amount
FROM payment
WHERE amount > (SELECT AVG(amount) FROM payment)
LIMIT 10;

-- find the language_id for English, then use it
SELECT title
FROM film
WHERE language_id = (SELECT language_id FROM language WHERE name = 'English')
LIMIT 10;

-- b) subquery returning a LIST of values (use with IN, NOT IN)
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id FROM film_actor WHERE actor_id = 1
)
LIMIT 10;


-- 7. SUBQUERY IN SELECT
-- runs once per row of the outer query.
-- must return exactly one value per outer row.
--
-- handy for adding a related count or total to each row.
-- slower than a JOIN for large datasets, but more readable for quick
-- one-off questions.

-- how many actors are in each film
SELECT title,
       (SELECT COUNT(*) FROM film_actor fa
        WHERE fa.film_id = f.film_id) AS actor_count
FROM film f
LIMIT 10;

-- total rentals each film has had
SELECT title,
       (SELECT COUNT(*)
        FROM inventory i
        JOIN rental r ON r.inventory_id = i.inventory_id
        WHERE i.film_id = f.film_id) AS total_rentals
FROM film f
LIMIT 10;


-- 8. DERIVED TABLES (subquery in FROM)
-- the inner query produces a result set, you query the outer just
-- like any normal table.
--
-- rules :
--   - MUST have an alias after the closing paren (this is enforced)
--   - the outer query can join, filter, group it like a regular table
--
-- use case : when you need to do something AFTER aggregation that
-- you can't express with HAVING alone (like joining to other tables).
-- modern alternative : CTEs (WITH clause), more readable for nested logic.

-- group customers by first letter of last_name, then filter the groups
SELECT *
FROM (
    SELECT last_name,
           CASE
               WHEN LEFT(last_name, 1) BETWEEN 'A' AND 'M' THEN 'Group A-M'
               WHEN LEFT(last_name, 1) BETWEEN 'N' AND 'Z' THEN 'Group N-Z'
               ELSE 'Other'
           END AS group_label
    FROM customer
) AS grouped_customers      -- alias is REQUIRED here
WHERE group_label = 'Group N-Z'
LIMIT 15;

-- top 10 spenders, then join customer info back in
SELECT c.first_name, c.last_name, top_spenders.total_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
    ORDER BY total_spent DESC
    LIMIT 10
) AS top_spenders
JOIN customer c ON c.customer_id = top_spenders.customer_id;


-- 9. CORRELATED SUBQUERY
-- a subquery that references a column from the outer query.
-- it runs ONCE PER ROW of the outer query (not once total).
--
-- gives you "row vs its group" comparisons :
--   "this payment vs THIS customer's own average"
--   "this film vs the average for films of the same rating"
--
-- watch out : slower than non-correlated for large tables because
-- of the per-row execution. window functions can often replace these.

-- payments above THIS customer's own average (not the global one)
SELECT payment_id, customer_id, amount, payment_date
FROM payment p1
WHERE amount > (
    SELECT AVG(amount)
    FROM payment p2
    WHERE p2.customer_id = p1.customer_id
)
LIMIT 15;

-- films longer than the average length of films with the same rating
SELECT title, rating, length
FROM film f1
WHERE length > (
    SELECT AVG(length)
    FROM film f2
    WHERE f2.rating = f1.rating
)
LIMIT 10;


-- 10. WHEN SUBQUERIES FAIL : ambiguity
-- the three most common errors and how to fix them.

-- a) subquery returns multiple rows but used with = (will ERROR)
-- "Subquery returns more than 1 row"
-- this happens when you use = expecting a single value, but the
-- subquery is actually returning a list.
SELECT title
FROM film
WHERE language_id = (SELECT language_id FROM language);
-- fix : use IN instead of =
SELECT title
FROM film
WHERE language_id IN (SELECT language_id FROM language);

-- b) ambiguous column name (outer and inner both have it)
-- always alias your tables so you can refer to columns clearly.
-- the inner can read outer columns ONLY in correlated subqueries.
SELECT title
FROM film f
WHERE f.film_id IN (
    SELECT fa.film_id
    FROM film_actor fa
    WHERE fa.actor_id = 1
);

-- c) derived table without an alias (will ERROR)
-- "Every derived table must have its own alias"
-- bad  : SELECT * FROM (SELECT * FROM film);
-- good : alias it (any name works)
SELECT * FROM (SELECT * FROM film) AS f_alias LIMIT 5;
