-- 20/05/2026, SELF STUDY
-- extra string functions, beyond what was covered in class
-- advised by instructor to explore on my own

USE sakila;


-- =====================================================
-- 1. CHAR_LENGTH vs LENGTH, ASCII, CHAR, ORD
-- =====================================================

-- LENGTH = bytes,  CHAR_LENGTH = characters
-- differs for multi byte characters
SELECT title, LENGTH(title), CHAR_LENGTH(title) FROM film LIMIT 5;

SELECT LENGTH('café'), CHAR_LENGTH('café');     -- 5 vs 4

-- ASCII code of FIRST character
SELECT first_name, ASCII(first_name) FROM actor LIMIT 5;

-- CHAR converts a code back to a character
SELECT CHAR(65), CHAR(97), CHAR(36);            -- A, a, $

-- ORD : multi byte aware version of ASCII
SELECT ORD('A'), ORD('é');


-- =====================================================
-- 2. TRIM, LTRIM, RTRIM
-- =====================================================

SELECT TRIM('   hello   '), LTRIM('   hello   '), RTRIM('   hello   ');

-- custom characters with LEADING / TRAILING / BOTH
SELECT TRIM(LEADING  '#' FROM '###topic###'),
       TRIM(TRAILING '#' FROM '###topic###'),
       TRIM(BOTH     '#' FROM '###topic###');

-- clean a phone column
SELECT phone, TRIM(phone), LENGTH(phone), LENGTH(TRIM(phone))
FROM address LIMIT 5;


-- =====================================================
-- 3. CONCAT_WS, REPEAT, SPACE
-- =====================================================

-- CONCAT_WS = concat with separator. Skips NULLs (CONCAT returns NULL if any arg is NULL)
SELECT CONCAT_WS(' ',  first_name, last_name)              AS full_name,
       CONCAT_WS(', ', last_name, first_name)              AS last_first,
       CONCAT_WS(' | ', first_name, NULL, last_name)       AS skips_null
FROM actor LIMIT 5;

-- REPEAT a string N times
SELECT REPEAT('-', 20), REPEAT('ab', 5), REPEAT(first_name, 2)
FROM actor LIMIT 5;

-- SPACE(N) = REPEAT(' ', N)
SELECT CONCAT('[', SPACE(5), 'indented', ']');


-- =====================================================
-- 4. INSTR, POSITION, FIELD, FIND_IN_SET
-- (alternatives to LOCATE)
-- =====================================================

-- INSTR(string, needle) : argument order REVERSED vs LOCATE
SELECT email, INSTR(email, '@'), LOCATE('@', email) FROM customer LIMIT 5;

-- POSITION : standard SQL syntax
SELECT email, POSITION('@' IN email) FROM customer LIMIT 5;

-- FIELD : position of value in a list of args, 0 if not found
SELECT first_name, FIELD(first_name, 'PENELOPE', 'NICK', 'ED')
FROM actor
WHERE first_name IN ('PENELOPE', 'NICK', 'ED', 'JENNIFER');

-- sort by a custom rating order (not alphabetic)
SELECT title, rating
FROM film
ORDER BY FIELD(rating, 'G', 'PG', 'PG-13', 'R', 'NC-17')
LIMIT 15;

-- FIND_IN_SET : position in a CSV string
SELECT FIND_IN_SET('green',  'red,green,blue'),
       FIND_IN_SET('purple', 'red,green,blue');

-- real use : Sakila's special_features is a CSV column
SELECT title, special_features
FROM film
WHERE FIND_IN_SET('Trailers', special_features) > 0
LIMIT 10;


-- =====================================================
-- 5. INSERT (string function, NOT the DML INSERT INTO)
-- INSERT(string, position, length, new_substring)
-- =====================================================

SELECT INSERT('Hello World', 7, 5, 'MySQL');     -- Hello MySQL
SELECT INSERT('abcdef',      3, 2, 'XYZ');       -- abXYZef
SELECT INSERT('1234567',     1, 0, '00');        -- 001234567


-- =====================================================
-- 6. STRCMP, SOUNDEX, SOUNDS LIKE
-- =====================================================

-- STRCMP : 0 if equal, -1 if a<b, 1 if a>b
SELECT STRCMP('apple',  'banana'),
       STRCMP('banana', 'apple'),
       STRCMP('apple',  'apple');

-- SOUNDEX : phonetic code. Words that sound alike get similar codes
SELECT SOUNDEX('Robert'), SOUNDEX('Rupert'),
       SOUNDEX('Smith'),  SOUNDEX('Smyth');

-- SOUNDS LIKE uses SOUNDEX under the hood
SELECT first_name FROM actor WHERE first_name SOUNDS LIKE 'Penelope';


-- =====================================================
-- 7. FORMAT (number to string with separators)
-- =====================================================

SELECT FORMAT(1234567.891, 2);           -- "1,234,567.89"
SELECT FORMAT(1234567.891, 0);           -- "1,234,568"
SELECT FORMAT(1234567.891, 2, 'de_DE');  -- "1.234.567,89"

SELECT payment_id, amount, FORMAT(amount, 2) FROM payment LIMIT 5;


-- =====================================================
-- 8. REGEXP_LIKE, REGEXP_INSTR, REGEXP_SUBSTR, REGEXP_REPLACE
-- (MySQL 8.0+) beyond the REGEXP operator covered in class
-- =====================================================

-- REGEXP_LIKE : function form, returns 1 or 0
SELECT title, REGEXP_LIKE(title, '^A') FROM film LIMIT 5;

-- REGEXP_INSTR : position of first match
SELECT email, REGEXP_INSTR(email, '@') FROM customer LIMIT 5;

-- REGEXP_SUBSTR : extract the matched substring
SELECT REGEXP_SUBSTR('Order #12345 placed on day 7', '[0-9]+');

SELECT email,
       REGEXP_SUBSTR(email, '@.*$'),
       REGEXP_SUBSTR(email, '[^@]+$')
FROM customer LIMIT 5;

-- REGEXP_REPLACE : pattern based replace
SELECT REGEXP_REPLACE('SKU-12345-XYZ-678', '[0-9]', '');   -- removes all digits

-- mask all but the last 4 chars of an email
SELECT email, REGEXP_REPLACE(email, '.(?=.{4})', '*')
FROM customer LIMIT 5;


-- =====================================================
-- 9. HEX, UNHEX, QUOTE
-- =====================================================

SELECT HEX('SQL'), UNHEX('53514C');      -- 53514C , SQL
SELECT HEX(255);                          -- FF

-- QUOTE wraps and escapes for safe use as an SQL literal
SELECT QUOTE('hello'),
       QUOTE("it's a test"),
       QUOTE(NULL);


-- =====================================================
-- 10. aliases worth knowing
-- LCASE = LOWER,  UCASE = UPPER,  MID = SUBSTRING
-- =====================================================

SELECT first_name, LCASE(first_name), UCASE(first_name), MID(first_name, 1, 3)
FROM actor LIMIT 5;


-- =====================================================
-- recap : combine a few of these on customer emails
-- =====================================================

SELECT CONCAT_WS(' ', first_name, last_name)        AS full_name,
       REGEXP_SUBSTR(email, '^[^@]+')               AS email_user,
       SUBSTRING_INDEX(email, '@', -1)              AS email_domain,
       CHAR_LENGTH(email)                           AS email_len,
       REGEXP_REPLACE(email, '.(?=.{8})', '*')      AS masked
FROM customer
WHERE email IS NOT NULL
LIMIT 10;
