-- 23/05/2026, TEMP TABLES, VIEWS, STORED PROCEDURES

USE sakila;


-- 1. TEMPORARY TABLES
--
-- exists only for the current session.
-- automatically dropped when the connection closes, or with DROP TEMPORARY TABLE.
-- two different sessions can have temp tables with the same name without conflict.
-- useful for storing intermediate results during a multi-step analysis,
-- without polluting the actual schema with throwaway tables.

-- if a previous run in this session left the temp table behind, drop it first.
DROP TEMPORARY TABLE IF EXISTS sakila.top_categories;

-- top 5 most-rented film categories.
-- the chain of joins follows the data : rental -> inventory -> film ->
-- film_category -> category. need film_category because film and category
-- are many-to-many, linked through this junction table.
CREATE TEMPORARY TABLE sakila.top_categories AS
SELECT c.name AS category_name, COUNT(*) AS rental_count
FROM sakila.rental r
JOIN sakila.inventory     i  ON r.inventory_id = i.inventory_id
JOIN sakila.film          f  ON f.film_id      = i.film_id
JOIN sakila.film_category fc ON fc.film_id     = f.film_id
JOIN sakila.category      c  ON c.category_id  = fc.category_id
GROUP BY c.name
ORDER BY rental_count DESC
LIMIT 5;

-- query the temp table just like a regular table
SELECT * FROM sakila.top_categories;


-- 2. VIEWS
--
-- a saved SELECT query that can be queried like a table.
-- nothing is stored physically - the query re-runs each time the view is used.
-- two main uses:
--   (a) simplify complex queries by giving a name to a result set
--   (b) hide sensitive columns from certain users (security / abstraction)

-- view #1 : each customer's most recent rental date
DROP VIEW IF EXISTS sakila.recent_rentals;

CREATE OR REPLACE VIEW sakila.recent_rentals AS
SELECT r.customer_id, MAX(r.rental_date) AS last_rental
FROM sakila.rental r
GROUP BY r.customer_id;

-- use the view by itself
SELECT * FROM sakila.recent_rentals;

-- views are just tables to the outer query, so they join normally.
-- this pulls each customer's name alongside their most recent rental date.
SELECT c.first_name, c.last_name, rr.last_rental
FROM sakila.customer c
JOIN sakila.recent_rentals rr ON c.customer_id = rr.customer_id;

-- view #2 : hides sensitive columns.
-- the underlying customer table has address_id, store_id, active flag,
-- create_date, last_update - this view exposes only the public fields.
-- give users access to the view instead of the table for PII protection.
CREATE OR REPLACE VIEW sakila.customer_public_view AS
SELECT customer_id, first_name, last_name, email
FROM sakila.customer;

SELECT * FROM sakila.customer_public_view;


-- 3. STORED PROCEDURES
--
-- a saved block of SQL with a name and parameters. call it with CALL.
--
-- parameter modes :
--   IN     value passed into the procedure (default if not specified)
--   OUT    value passed back out via a user variable (@var)
--   INOUT  both directions
--
-- DELIMITER //
-- changes the statement terminator from ; to // for the procedure body,
-- so the semicolons INSIDE the procedure body do not end it prematurely.
-- after the CREATE PROCEDURE is done, switch back with DELIMITER ;

-- procedure with IN parameter only.
-- returns all payments for a given customer.
DROP PROCEDURE IF EXISTS sakila.GetCustomerPayments;
DELIMITER //

CREATE PROCEDURE sakila.GetCustomerPayments(IN cid INT)
BEGIN
    SELECT payment_id, amount, payment_date
    FROM sakila.payment
    WHERE customer_id = cid;
END;
//
DELIMITER ;

-- call : returns the payments for customer 5
CALL sakila.GetCustomerPayments(5);


-- procedure with IN and OUT parameters.
-- computes total amount paid by a customer and writes it to the OUT param.
DROP PROCEDURE IF EXISTS sakila.TotalPaid;
DELIMITER //

CREATE PROCEDURE sakila.TotalPaid(IN cid INT, OUT total DECIMAL(10,2))
BEGIN
    -- SELECT ... INTO assigns the aggregate value to the OUT parameter
    SELECT SUM(amount) INTO total
    FROM sakila.payment
    WHERE customer_id = cid;
END;
//
DELIMITER ;

-- call : @total is a user variable that catches the OUT value
CALL sakila.TotalPaid(5, @total);
SELECT @total;


-- 4. DYNAMIC STORED PROCEDURE
--
-- when the table name (or any part of the query) isn't known until runtime,
-- you build the SQL as a STRING, then prepare + execute it.
--
-- three steps :
--   PREPARE     parse and compile the string into an executable statement
--   EXECUTE     actually run the compiled statement
--   DEALLOCATE  free the prepared statement (cleanup)
--
-- common use cases : admin tools, generic report builders, ETL jobs.

DROP PROCEDURE IF EXISTS sakila.DynamicQuery;
DELIMITER //

CREATE PROCEDURE sakila.DynamicQuery(IN tbl_name VARCHAR(64))
BEGIN
    -- build the SQL string using the table name passed in
    SET @s = CONCAT('SELECT COUNT(*) AS total_rows FROM ', tbl_name);

    -- compile, run, clean up
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DELIMITER ;

-- one procedure, different tables each call
CALL sakila.DynamicQuery('sakila.actor');
CALL sakila.DynamicQuery('sakila.film');


-- 5. DYNAMIC SP WITH CURSOR (the ETL pipeline pattern)
--
-- a CURSOR lets us walk through query results one row at a time, which is
-- necessary when each row needs a different SQL statement generated from it.
--
-- this procedure :
--   1. opens a cursor on information_schema.tables for a given schema
--   2. for each table name fetched, builds a SELECT COUNT(*) statement
--   3. inserts that generated SQL into a holding table
--
-- end result : a queryable list of count statements, one per table.
-- ETL pipelines use this pattern to auto-discover tables and process them.

-- holding table for the generated statements
DROP TEMPORARY TABLE IF EXISTS sakila.select_statements;

CREATE TEMPORARY TABLE sakila.select_statements (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    statement_text TEXT
);

DROP PROCEDURE IF EXISTS sakila.StoreSelectStatements;
DELIMITER //

CREATE PROCEDURE sakila.StoreSelectStatements(IN db_name VARCHAR(64))
BEGIN
    -- flag flipped to TRUE when the cursor runs out of rows
    DECLARE done     INT DEFAULT FALSE;

    -- holds each table name as we fetch it
    DECLARE tbl_name VARCHAR(64);

    -- cursor : a SELECT whose results we walk through one row at a time
    DECLARE cur CURSOR FOR
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = db_name;

    -- handler : when FETCH finds NOT FOUND, set done = TRUE so the loop exits
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        -- pull the next table name from the cursor
        FETCH cur INTO tbl_name;

        -- exit the loop when no more rows
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- build a count statement for this specific table
        SET @stmt = CONCAT('SELECT count(*) FROM ', db_name, '.', tbl_name, ';');

        -- insert the generated statement text into our holding table.
        -- using prepared statement here because we are passing the text
        -- as a parameter (?) into the INSERT.
        SET @ins  = 'INSERT INTO select_statements (statement_text) VALUES (?);';
        PREPARE stmt FROM @ins;
        EXECUTE stmt USING @stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END;
//
DELIMITER ;

-- run it for the sakila schema : produces one row per sakila table
CALL sakila.StoreSelectStatements('sakila');

-- view the generated SQL strings
SELECT * FROM sakila.select_statements;
