-- Assignment 3, subqueries

USE sakila;


-- Q1. Display all customer details who have made more than 5 payments.

SELECT *
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING COUNT(*) > 5
);


-- Q2. Find the names of actors who have acted in more than 10 films.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    HAVING COUNT(*) > 10
);


-- Q3. Find the names of customers who never made a payment.

SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM payment
);


-- Q4. List all films whose rental rate is higher than the average rental rate
--     of all films.

SELECT film_id, title, rental_rate
FROM film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
);


-- Q5. List the titles of films that were never rented.

SELECT title
FROM film
WHERE film_id NOT IN (
    SELECT DISTINCT i.film_id
    FROM inventory i
    JOIN rental r ON r.inventory_id = i.inventory_id
);


-- Q6. Display the customers who rented films in the same month
--     as customer with ID 5.

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
WHERE MONTH(r.rental_date) IN (
    SELECT MONTH(rental_date)
    FROM rental
    WHERE customer_id = 5
)
AND c.customer_id <> 5;


-- Q7. Find all staff members who handled a payment greater than
--     the average payment amount.

SELECT DISTINCT s.staff_id, s.first_name, s.last_name
FROM staff s
WHERE s.staff_id IN (
    SELECT staff_id
    FROM payment
    WHERE amount > (
        SELECT AVG(amount)
        FROM payment
    )
);


-- Q8. Show the title and rental duration of films whose rental duration
--     is greater than the average.

SELECT title, rental_duration
FROM film
WHERE rental_duration > (
    SELECT AVG(rental_duration)
    FROM film
);


-- Q9. Find all customers who have the same address as customer with ID 1.

SELECT customer_id, first_name, last_name, address_id
FROM customer
WHERE address_id = (
    SELECT address_id
    FROM customer
    WHERE customer_id = 1
)
AND customer_id <> 1;


-- Q10. List all payments that are greater than the average of all payments.

SELECT payment_id, customer_id, amount, payment_date
FROM payment
WHERE amount > (
    SELECT AVG(amount)
    FROM payment
);
