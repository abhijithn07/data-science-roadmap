-- 22/05/2026, CARDINALITY, JOINS, CTEs

USE sakila;


-- 1. CARDINALITY

-- one-to-many
SELECT c.customer_id, c.first_name, COUNT(r.rental_id) AS rentals
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name
ORDER BY rentals DESC
LIMIT 5;

-- many-to-one
SELECT f.title, l.name AS language
FROM film f
JOIN language l ON l.language_id = f.language_id
LIMIT 5;

-- many-to-many
SELECT f.title, a.first_name, a.last_name
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a       ON a.actor_id = fa.actor_id
LIMIT 10;


-- 2. INNER JOIN

SELECT c.first_name, c.last_name, r.rental_date
FROM customer c
INNER JOIN rental r ON r.customer_id = c.customer_id
LIMIT 10;


-- 3. LEFT JOIN

SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
LIMIT 10;


-- 4. RIGHT JOIN

SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
RIGHT JOIN rental r ON r.customer_id = c.customer_id
LIMIT 10;


-- 5. FULL OUTER JOIN  (MySQL : simulate with UNION)

SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
UNION
SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
RIGHT JOIN rental r ON r.customer_id = c.customer_id;


-- 6. LEFT JOIN EXCLUDING INNER

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
WHERE r.rental_id IS NULL;


-- 7. RIGHT JOIN EXCLUDING INNER

SELECT r.rental_id, c.customer_id
FROM customer c
RIGHT JOIN rental r ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 8. FULL OUTER JOIN EXCLUDING INNER

SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
WHERE r.rental_id IS NULL
UNION
SELECT c.customer_id, c.first_name, r.rental_id
FROM customer c
RIGHT JOIN rental r ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 9. CROSS JOIN

SELECT cat.name AS category, lang.name AS language
FROM category cat
CROSS JOIN language lang;

SELECT cat.name AS category, lang.name AS language
FROM category cat
CROSS JOIN language lang
WHERE cat.name = 'Action';


-- 10. SELF JOIN

SELECT c1.first_name AS person1, c2.first_name AS person2, c1.address_id
FROM customer c1
JOIN customer c2 ON c1.address_id  = c2.address_id
                AND c1.customer_id < c2.customer_id
LIMIT 10;


-- 11. MULTI-TABLE JOIN

SELECT c.first_name, c.last_name, a.address, ci.city, co.country
FROM customer c
JOIN address a  ON a.address_id  = c.address_id
JOIN city ci    ON ci.city_id    = a.city_id
JOIN country co ON co.country_id = ci.country_id
LIMIT 10;


-- 12. CTE

-- subquery version
SELECT customer_id, total_payments
FROM (
    SELECT customer_id, COUNT(*) AS total_payments
    FROM payment
    GROUP BY customer_id
) AS sub
WHERE total_payments > 5;

-- CTE version
WITH payment_counts AS (
    SELECT customer_id, COUNT(*) AS total_payments
    FROM payment
    GROUP BY customer_id
)
SELECT customer_id, total_payments
FROM payment_counts
WHERE total_payments > 5;

-- CTE joined to another table
WITH payment_counts AS (
    SELECT customer_id, COUNT(*) AS total_payments
    FROM payment
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, p.total_payments
FROM customer c
JOIN payment_counts p ON c.customer_id = p.customer_id
WHERE p.total_payments > 5;


-- 13. MULTIPLE CTEs

WITH
    total_payments AS (
        SELECT customer_id, SUM(amount) AS total_amount
        FROM payment
        GROUP BY customer_id
    ),
    latest_payment AS (
        SELECT customer_id, MAX(payment_date) AS last_payment_date
        FROM payment
        GROUP BY customer_id
    )
SELECT c.customer_id, c.first_name, c.last_name,
       tp.total_amount,
       lp.last_payment_date
FROM customer c
LEFT JOIN total_payments tp ON c.customer_id = tp.customer_id
LEFT JOIN latest_payment lp ON c.customer_id = lp.customer_id;


-- 14. RECURSIVE CTE

-- numbers 1 to 20
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20
)
SELECT * FROM numbers;

-- last 10 days of rentals (with counts per day)
WITH RECURSIVE dates AS (
    SELECT DATE(MAX(rental_date)) - INTERVAL 9 DAY AS rental_day
    FROM rental
    UNION ALL
    SELECT rental_day + INTERVAL 1 DAY
    FROM dates
    WHERE rental_day + INTERVAL 1 DAY <= (SELECT MAX(rental_date) FROM rental)
)
SELECT d.rental_day, COUNT(r.rental_id) AS rentals
FROM dates d
LEFT JOIN rental r ON DATE(r.rental_date) = d.rental_day
GROUP BY d.rental_day;
