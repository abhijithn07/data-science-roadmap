-- Assignment 2, built-in functions

USE sakila;


-- Q1. Identify if there are duplicates in Customer table.
--     Don't use customer id to check the duplicates.

SELECT first_name, last_name, email, COUNT(*) AS occurrences
FROM customer
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;


-- Q2. Number of times letter 'a' is repeated in film descriptions.

SELECT
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'a', ''))) AS total_a_count
FROM film;


-- Q3. Number of times each vowel is repeated in film descriptions.

SELECT
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'a', ''))) AS a_count,
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'e', ''))) AS e_count,
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'i', ''))) AS i_count,
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'o', ''))) AS o_count,
    SUM(CHAR_LENGTH(LOWER(description))
        - CHAR_LENGTH(REPLACE(LOWER(description), 'u', ''))) AS u_count
FROM film;


-- Q4. Display the payments made by each customer.
--     1. Month wise
--     2. Year wise
--     3. Week wise

-- year wise
SELECT
    customer_id,
    YEAR(payment_date) AS year,
    SUM(amount)        AS total_paid
FROM payment
GROUP BY customer_id, YEAR(payment_date)
ORDER BY customer_id, year;

-- month wise
SELECT
    customer_id,
    YEAR(payment_date)  AS year,
    MONTH(payment_date) AS month,
    SUM(amount)         AS total_paid
FROM payment
GROUP BY customer_id, YEAR(payment_date), MONTH(payment_date)
ORDER BY customer_id, year, month;

-- week wise
SELECT
    customer_id,
    YEAR(payment_date) AS year,
    WEEK(payment_date) AS week,
    SUM(amount)        AS total_paid
FROM payment
GROUP BY customer_id, YEAR(payment_date), WEEK(payment_date)
ORDER BY customer_id, year, week;


-- Q5. Check if any given year is a leap year or not.
--     You need not consider any table from sakila database.
--     Write within the select query with hardcoded date.

SELECT
    '2024-02-01' AS test_date,
    CASE
        WHEN DAY(LAST_DAY('2024-02-01')) = 29 THEN 'Leap Year'
        ELSE 'Not a Leap Year'
    END AS result;


-- Q6. Display number of days remaining in the current year from today.

SELECT
    CURDATE() AS today,
    DATEDIFF(CONCAT(YEAR(CURDATE()), '-12-31'), CURDATE()) AS days_remaining;


-- Q7. Display quarter number (Q1, Q2, Q3, Q4) for the payment dates
--     from payment table.

SELECT
    payment_id,
    payment_date,
    CONCAT('Q', QUARTER(payment_date)) AS quarter
FROM payment;


-- Q8. Display the age in year, months, days based on your date of birth.
--     For example: 21 years, 4 months, 12 days.

SELECT
    '2000-01-15' AS dob,
    CURDATE()    AS today,
    CONCAT(
        TIMESTAMPDIFF(YEAR,  '2000-01-15', CURDATE()),         ' years, ',
        TIMESTAMPDIFF(MONTH, '2000-01-15', CURDATE()) MOD 12,  ' months, ',
        DATEDIFF(
            CURDATE(),
            DATE_ADD('2000-01-15',
                INTERVAL TIMESTAMPDIFF(MONTH, '2000-01-15', CURDATE()) MONTH
            )
        ),                                                     ' days'
    ) AS age;
