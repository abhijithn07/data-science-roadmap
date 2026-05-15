# Note 10 — Functions & Programming

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The full **Functions & Programming** category — built-in functions and procedural SQL:

1. **String functions** — manipulating text
2. **Numeric functions** — math on numbers
3. **Date & time functions** — working with dates
4. **`CAST` / `CONVERT`** — type conversion
5. **`COALESCE` / `IFNULL` / `ISNULL`** — handling `NULL`
6. **`CASE` / `IF` / `IIF`** — conditional logic (recap + dialect cousins)
7. **Regular expressions in SQL**
8. **User-defined functions (UDFs)**
9. **Stored procedures**
10. **Dynamic SQL** — with a big SQL-injection warning

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## A Note on Dialects

Function names and signatures vary more between SQL dialects than any other area. This note shows **PostgreSQL syntax by default** (closest to the ANSI standard), with major variations noted. When in doubt, check your database's documentation.

---

## 1. String Functions

For working with text columns.

| Function | What it does | Example |
|----------|--------------|---------|
| **`UPPER(s)`** | All uppercase | `UPPER('alice')` → `'ALICE'` |
| **`LOWER(s)`** | All lowercase | `LOWER('ALICE')` → `'alice'` |
| **`LENGTH(s)`** | Number of characters | `LENGTH('Alice')` → `5` |
| **`TRIM(s)`** | Remove leading/trailing whitespace | `TRIM('  hi  ')` → `'hi'` |
| **`LTRIM(s)` / `RTRIM(s)`** | Trim left or right only | |
| **`SUBSTRING(s, start, length)`** | Extract a substring | `SUBSTRING('Alice', 1, 3)` → `'Ali'` |
| **`REPLACE(s, find, replace)`** | Replace all occurrences | `REPLACE('abc', 'a', 'X')` → `'Xbc'` |
| **`CONCAT(a, b, ...)`** | Combine strings | `CONCAT('Hi ', 'Alice')` → `'Hi Alice'` |
| **`a \|\| b`** (Postgres/SQLite) or **`+`** (SQL Server) | Concatenate | `'Hi ' \|\| 'Alice'` |
| **`POSITION(sub IN s)`** | Find substring's position | `POSITION('ce' IN 'Alice')` → `4` |
| **`LEFT(s, n)` / `RIGHT(s, n)`** | First/last n characters | `LEFT('Alice', 3)` → `'Ali'` |

### Example

```sql
SELECT name,
       UPPER(name) AS upper_name,
       LENGTH(name) AS name_length,
       LEFT(name, 1) AS first_initial
FROM employees;
```

> **Indexing note:** in most SQL dialects, string positions are **1-indexed** (first character is at position 1, not 0).

---

## 2. Numeric Functions

For math on number columns.

| Function | What it does | Example |
|----------|--------------|---------|
| **`ABS(n)`** | Absolute value | `ABS(-5)` → `5` |
| **`ROUND(n, d)`** | Round to d decimal places | `ROUND(3.14159, 2)` → `3.14` |
| **`CEIL(n)` / `CEILING(n)`** | Round up | `CEIL(3.1)` → `4` |
| **`FLOOR(n)`** | Round down | `FLOOR(3.9)` → `3` |
| **`MOD(a, b)`** or `a % b` | Remainder | `MOD(10, 3)` → `1` |
| **`POWER(a, b)`** | Exponentiation | `POWER(2, 10)` → `1024` |
| **`SQRT(n)`** | Square root | `SQRT(16)` → `4` |
| **`GREATEST(a, b, ...)`** | Largest value in list | `GREATEST(3, 7, 2)` → `7` |
| **`LEAST(a, b, ...)`** | Smallest value in list | `LEAST(3, 7, 2)` → `2` |
| **`RANDOM()` / `RAND()`** | Random number in `[0, 1)` | |

### Example

```sql
SELECT name, salary,
       ROUND(salary / 12, 2) AS monthly_salary,
       ROUND(salary * 0.10, 0) AS bonus
FROM employees;
```

---

## 3. Date and Time Functions

Where dialect differences are most obvious. Showing PostgreSQL syntax with notes.

### Getting the Current Date/Time

| Function | Returns |
|----------|---------|
| **`CURRENT_DATE`** | Today's date |
| **`CURRENT_TIMESTAMP`** | Right now (date + time) |
| **`NOW()`** | Same as `CURRENT_TIMESTAMP` (most dialects) |

### Extracting Parts

```sql
SELECT EXTRACT(YEAR FROM hire_date) AS hire_year,
       EXTRACT(MONTH FROM hire_date) AS hire_month
FROM employees;
```

In SQL Server: `YEAR(hire_date)`, `MONTH(hire_date)`, `DAY(hire_date)`.

### Date Arithmetic

```sql
-- "How long ago was each person hired?"
SELECT name, hire_date,
       CURRENT_DATE - hire_date AS days_employed       -- PostgreSQL: integer days
FROM employees;
```

For adding intervals:

```sql
-- PostgreSQL:
SELECT hire_date + INTERVAL '1 year' AS first_anniversary FROM employees;

-- MySQL:
SELECT DATE_ADD(hire_date, INTERVAL 1 YEAR) FROM employees;

-- SQL Server:
SELECT DATEADD(YEAR, 1, hire_date) FROM employees;
```

### Formatting

```sql
-- PostgreSQL:
SELECT TO_CHAR(hire_date, 'Mon YYYY') AS hire_period FROM employees;
-- → 'Mar 2022'

-- MySQL:
SELECT DATE_FORMAT(hire_date, '%b %Y') FROM employees;
```

> **Beginner tip:** dates are the most dialect-dependent part of SQL. Always check your specific database's date function reference.

---

## 4. CAST / CONVERT — Type Conversion

Convert a value from one data type to another. Both spellings exist; **`CAST` is standard SQL** and works everywhere.

### CAST syntax

```sql
CAST(<value> AS <data_type>)
```

Examples:

```sql
SELECT CAST(salary AS INTEGER) AS salary_int FROM employees;
SELECT CAST('2024-05-01' AS DATE) AS converted_date;
SELECT CAST(id AS TEXT) AS id_string FROM employees;
```

### CONVERT (SQL Server style)

SQL Server has its own non-standard `CONVERT(target_type, value)` syntax, sometimes with a format code:

```sql
SELECT CONVERT(VARCHAR, hire_date, 23) FROM employees;
-- '2024-05-01' format
```

**Use `CAST`** unless you specifically need SQL Server's format codes.

### Implicit vs. Explicit Conversion

The database sometimes converts types automatically (implicit conversion), e.g., comparing an `INTEGER` to a `DECIMAL`. But relying on this can be slow or surprising. **Explicit `CAST` is safer.**

---

## 5. COALESCE / IFNULL / ISNULL — Handling NULL

A constant headache for beginners: `NULL` poisons calculations. These functions let you substitute a default when a value is `NULL`.

### `COALESCE(a, b, c, ...)` — standard, works everywhere

Returns the **first non-NULL** value from its arguments:

```sql
SELECT name, COALESCE(department_id, 0) AS dept_or_zero
FROM employees;
```

If `department_id` is `NULL`, returns `0`. Otherwise returns the actual `department_id`.

`COALESCE` accepts any number of arguments — it tries them in order:

```sql
COALESCE(preferred_email, work_email, personal_email, 'unknown')
```

### `IFNULL(a, b)` — MySQL/SQLite

Same as `COALESCE(a, b)` but only two arguments:

```sql
SELECT IFNULL(department_id, 0) FROM employees;     -- MySQL
```

### `ISNULL(a, b)` — SQL Server

Same again — different name:

```sql
SELECT ISNULL(department_id, 0) FROM employees;     -- SQL Server
```

> **Use `COALESCE`** — it's the only one that's standard across all dialects.

### A common pitfall — averages with NULLs

```sql
-- Counts employees including ones with NULL salary, but averages only non-NULL salaries:
SELECT AVG(salary), AVG(COALESCE(salary, 0))
FROM employees;
```

These return *different* numbers when nulls exist. Be intentional about which you want.

---

## 6. Conditional Logic — CASE / IF / IIF

`CASE` was covered in detail in [Note 03](./03-aggregation-and-case.md). Here's a quick recap and the cousin functions.

### CASE (standard, every dialect)

```sql
SELECT name, salary,
       CASE WHEN salary >= 100000 THEN 'High'
            WHEN salary >= 80000  THEN 'Mid'
            ELSE 'Entry'
       END AS band
FROM employees;
```

### IF — MySQL only

A two-way shortcut:

```sql
SELECT name, IF(salary >= 100000, 'High', 'Other') AS band
FROM employees;
-- IF(condition, value_if_true, value_if_false)
```

### IIF — SQL Server / Access

Same two-way idea:

```sql
SELECT name, IIF(salary >= 100000, 'High', 'Other') AS band
FROM employees;
```

> **Use `CASE`** for portability. `IF`/`IIF` are convenient shortcuts only when the logic has exactly two outcomes.

---

## 7. Regular Expressions in SQL

For pattern matching beyond what `LIKE` can do. Heavily dialect-specific.

### PostgreSQL — `~`, `~*` (case-insensitive), `!~`

```sql
SELECT name FROM employees WHERE name ~ '^[A-D]';
-- names starting with A, B, C, or D
```

### MySQL — `REGEXP` or `RLIKE`

```sql
SELECT name FROM employees WHERE name REGEXP '^[A-D]';
```

### SQL Server — `LIKE` with limited character classes (no full regex without CLR)

```sql
SELECT name FROM employees WHERE name LIKE '[A-D]%';
```

### Common Regex Patterns

| Pattern | Matches |
|---------|---------|
| `^A` | Starts with A |
| `e$` | Ends with e |
| `[A-D]` | Any one of A, B, C, D |
| `[^aeiou]` | Any one character NOT a vowel |
| `\d` | A digit |
| `.{3,5}` | Any 3 to 5 characters |
| `(cat\|dog)` | "cat" or "dog" |

> Regex in SQL is powerful but heavily dialect-dependent. For complex pattern work, it's often easier to extract data and process it in Python.

---

## 8. User-Defined Functions (UDFs)

A **UDF** is a reusable function you define in the database. Once created, you call it like a built-in function.

### Scalar UDF — returns a single value

```sql
-- PostgreSQL:
CREATE FUNCTION salary_band(s DECIMAL) RETURNS TEXT AS $$
    SELECT CASE
        WHEN s >= 100000 THEN 'High'
        WHEN s >= 80000  THEN 'Mid'
        ELSE 'Entry'
    END;
$$ LANGUAGE SQL;

-- Use it:
SELECT name, salary, salary_band(salary) AS band FROM employees;
```

### When to use UDFs

- The same calculation appears in many queries.
- The logic is non-trivial enough that copy-pasting is risky.

### When NOT to use UDFs

- **Performance** — UDFs can prevent the query optimizer from making good plans. Built-in functions are usually faster.
- **Portability** — UDF syntax varies wildly across dialects.

### Table-valued UDF (briefly)

Some dialects support UDFs that return a *whole table*, useful for parameterized views. Syntax varies; covered in dialect-specific docs.

---

## 9. Stored Procedures

A **stored procedure** is a block of SQL (often with control flow — loops, variables, error handling) that's saved in the database and called as a unit.

The big difference from a UDF: **stored procedures don't return a single value**. They can read/write multiple rows, execute multiple statements, and have side effects.

### Example (PostgreSQL)

```sql
CREATE OR REPLACE PROCEDURE give_raise(dept INTEGER, pct DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + pct / 100)
    WHERE department_id = dept;
END;
$$;

-- Call it:
CALL give_raise(1, 10);    -- 10% raise for Engineering
```

### Stored Procedures vs. UDFs

| | UDF | Stored Procedure |
|--|-----|------------------|
| Returns | A value | Nothing (or output params / result sets) |
| Used in | `SELECT`, `WHERE`, etc. | Called explicitly with `CALL` or `EXEC` |
| Can modify data? | Usually no | Yes |
| Use cases | Calculations | Multi-step business logic, data maintenance |

> **In modern data work**, stored procedures are used less than they used to be — most logic now lives in application code or in tools like dbt. But you'll still see them in legacy systems and enterprise environments.

---

## 10. Dynamic SQL

**Dynamic SQL** = SQL that's constructed as a *string* at runtime, then executed. Useful when the query depends on values you don't know at compile time (e.g., a table name passed in).

### Example (PostgreSQL)

```sql
DO $$
DECLARE
    target_table TEXT := 'employees';
    sql_text TEXT;
BEGIN
    sql_text := 'SELECT COUNT(*) FROM ' || target_table;
    EXECUTE sql_text;
END $$;
```

### SQL Injection — the Big Risk

**Dynamic SQL is the source of SQL injection vulnerabilities.** If you ever build a SQL string by concatenating user input:

```sql
-- DANGEROUS:
'SELECT * FROM users WHERE name = ''' || user_input || ''''
```

A malicious user could enter `'; DROP TABLE users; --` and wreck your database.

**Always parameterize.** Use the database's parameter binding (e.g., `EXECUTE ... USING $1`), or — better yet — handle dynamic logic in application code with parameterized queries.

> **Beginner takeaway:** dynamic SQL is occasionally necessary but always dangerous. Never concatenate user input into SQL strings.

---

## Putting It All Together

A realistic query that mixes several of these functions:

```sql
SELECT
    UPPER(LEFT(e.name, 1)) || LOWER(SUBSTRING(e.name FROM 2)) AS clean_name,
    EXTRACT(YEAR FROM e.hire_date) AS hire_year,
    COALESCE(d.name, 'Unassigned') AS department,
    CASE WHEN e.salary >= 100000 THEN 'High'
         WHEN e.salary >= 80000  THEN 'Mid'
         ELSE 'Entry'
    END AS salary_band,
    ROUND(e.salary / 12, 2) AS monthly_salary
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```

String functions, date functions, NULL handling, conditional logic, numeric functions — all in one query. Most analytical SQL looks roughly like this.

---

## Key Takeaways

- **Function names and signatures vary heavily by dialect.** Always check your database's docs.
- **String functions:** `UPPER`, `LOWER`, `LENGTH`, `TRIM`, `SUBSTRING`, `REPLACE`, `CONCAT` (or `||` / `+`).
- **Numeric functions:** `ABS`, `ROUND`, `CEIL`, `FLOOR`, `MOD`, `POWER`, `SQRT`, `GREATEST`, `LEAST`.
- **Date functions:** the most dialect-dependent. `CURRENT_DATE`, `EXTRACT`, date math with `+ INTERVAL` (Postgres) or `DATE_ADD`/`DATEADD`.
- **Type conversion:** use `CAST(x AS type)` — it's portable. `CONVERT` is SQL Server-specific.
- **NULL handling:** use `COALESCE(a, b, ...)` everywhere — it's the standard. `IFNULL` (MySQL) and `ISNULL` (SQL Server) are dialect shortcuts.
- **Conditional logic:** `CASE` is portable; `IF`/`IIF` are dialect shortcuts for two-way logic.
- **Regex** is powerful but dialect-specific — `~` in Postgres, `REGEXP` in MySQL, limited in SQL Server.
- **UDFs** = reusable functions you define. Use sparingly — built-ins are usually faster.
- **Stored procedures** = multi-statement blocks of logic stored in the database. Falling out of fashion in favor of application code / dbt.
- **Dynamic SQL** runs SQL built as a string. Powerful but the source of SQL injection — **always parameterize**.

## Quick Self-Check

1. Why use `COALESCE` instead of `IFNULL` or `ISNULL`?
2. What's the difference between `CAST` and `CONVERT`?
3. Write a query to get the first initial of each employee's name (uppercase) and the year they were hired.
4. What's the difference between a UDF and a stored procedure?
5. Why is dynamic SQL with concatenated user input dangerous?
6. What does `EXTRACT(YEAR FROM hire_date)` do?
7. What's the difference between `ROUND(3.7)` and `CEIL(3.7)`?

## Further Reading

| Topic | Reference |
|-------|-----------|
| String functions | [W3Schools: String Functions](https://www.w3schools.com/sql/sql_ref_mysql.asp) |
| Date functions | [W3Schools: Dates](https://www.w3schools.com/sql/sql_dates.asp) |
| CAST / CONVERT | [GeeksForGeeks: CAST/CONVERT](https://www.geeksforgeeks.org/sql-server-cast-and-convert-functions/) |
| COALESCE | [W3Schools: COALESCE](https://www.w3schools.com/sql/func_sqlserver_coalesce.asp) |
| Regex in SQL | [GeeksForGeeks: Regex](https://www.geeksforgeeks.org/sql-regular-expressions/) |
| Stored procedures | [W3Schools: Stored Procedures](https://www.w3schools.com/sql/sql_stored_procedures.asp) |
| Dynamic SQL | [GeeksForGeeks: Dynamic SQL](https://www.geeksforgeeks.org/dynamic-sql/) |

---

[← Prev: Joins](./09-joins.md) · [Next: DCL & TCL →](./11-dcl-tcl.md)
