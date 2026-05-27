-- Assignment 1
-- Abhijith Nallana 

USE sakila;


-- Q1. Get all customers whose first name starts with 'J' and who are active.
SELECT customer_id, first_name, last_name, email, active FROM customer
WHERE first_name LIKE 'J%' AND active = 1;


-- Q2. Find all films where the title contains the word 'ACTION' or the description contains 'WAR'.
SELECT film_id, title, description FROM film
WHERE title LIKE '%ACTION%' OR description LIKE '%WAR%';


-- Q3. List all customers whose last name is not 'SMITH' and whose first name ends with 'a'.
SELECT customer_id, first_name, last_name FROM customer
WHERE last_name <> 'SMITH' AND first_name LIKE '%a';


-- Q4. Get all films where the rental rate is greater than 3.0 and the replacement cost is not null.
SELECT film_id, title, rental_rate, replacement_cost FROM film
WHERE rental_rate > 3.0 AND replacement_cost IS NOT NULL;


-- Q5. Count how many customers exist in each store who have active status = 1.
SELECT store_id, COUNT(*) AS active_customers FROM customer
WHERE active = 1 
GROUP BY store_id;


-- Q6. Show distinct film ratings available in the film table.
SELECT DISTINCT rating FROM film;


-- Q7. Find the number of films for each rental duration where the average length is more than 100 minutes.
SELECT rental_duration,
       COUNT(*)    AS film_count,
       AVG(length) AS avg_length
FROM film
GROUP BY rental_duration
HAVING avg_length > 100;


-- Q8. List payment dates and total amount paid per date, but only include days where more than 100 payments were made. payment_date is a datetime, so DATE() strips the time to group by day.
SELECT DATE(payment_date) AS pay_date,
       COUNT(*)           AS payment_count,
       SUM(amount)        AS total_amount
FROM payment
GROUP BY DATE(payment_date)
HAVING COUNT(*) > 100
ORDER BY pay_date;


-- Q9. Find customers whose email address is null or ends with '.org'.
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE email IS NULL
   OR email LIKE '%.org';


-- Q10. List all films with rating 'PG' or 'G', and order them by rental rate in descending order.
SELECT film_id, title, rating, rental_rate
FROM film
WHERE rating IN ('PG', 'G')
ORDER BY rental_rate DESC;


-- Q11. Count how many films exist for each length where the film title starts with 'T' and the count is more than 5.
SELECT length,
       COUNT(*) AS film_count
FROM film
WHERE title LIKE 'T%'
GROUP BY length
HAVING COUNT(*) > 5;


-- Q12. List all actors who have appeared in more than 10 films.
SELECT a.actor_id,
       a.first_name,
       a.last_name,
       COUNT(*) AS film_count
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(*) > 10
ORDER BY film_count DESC;


-- Q13. Find the top 5 films with the highest rental rates and longest lengths combined, ordering by rental rate first and length second.
SELECT film_id, title, rental_rate, length
FROM film
ORDER BY rental_rate DESC, length DESC
LIMIT 5;


-- Q14. Show all customers along with the total number of rentals they have made, ordered from most to least rentals.
-- LEFT JOIN so customers with zero rentals still appear.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(r.rental_id) AS total_rentals
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_rentals DESC;


-- Q15. List the film titles that have never been rented.
-- a film links to rentals through inventory.
-- NOT EXISTS handles NULLs more cleanly than NOT IN.

SELECT f.film_id, f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental r ON r.inventory_id = i.inventory_id
    WHERE i.film_id = f.film_id
);
