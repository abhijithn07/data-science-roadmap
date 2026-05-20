# Note 02 - SELECT & Filter

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

Every topic from the **DQL Beginner** category - the core of "reading data" in SQL:

1. The `SELECT` statement
2. `SELECT DISTINCT`
3. The `WHERE` clause
4. `ORDER BY`
5. `LIMIT` / `TOP` / `FETCH FIRST`
6. Pattern matching with `LIKE`
7. Wildcards
8. The `IN` operator
9. The `BETWEEN` operator
10. `IS NULL` / `IS NOT NULL`

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## The Basic Shape of a Query

Almost every read query you'll write starts with this four-line skeleton:

```sql
SELECT   <columns>
FROM     <table>
WHERE    <conditions>
ORDER BY <columns>;
```

In English: *"From this table, give me these columns, where these conditions are met, sorted this way."*

Master that shape and you can answer most beginner questions immediately.

---

## 1. The SELECT Statement

`SELECT` is the most-used SQL command - it **retrieves rows from a table**.

### Pick Specific Columns

```sql
SELECT name, salary
FROM employees;
```

| name | salary |
|------|--------|
| Alice Chen | 95000 |
| Bob Patel | 110000 |
| ... | ... |

### Pick All Columns with `*`

```sql
SELECT *
FROM employees;
```

`*` (called "star" or "wildcard") means *every column*. Useful for quick exploration.

> **Beginner tip:** in production code, name the columns you actually need. `SELECT *` is convenient but reads slower and can break things if columns get added or reordered.

### Calculated Columns

You can compute new values right in the `SELECT` list:

```sql
SELECT name,
       salary,
       salary * 12 AS annual_salary,
       salary * 0.10 AS bonus
FROM employees;
```

Anything that returns a value works in `SELECT` - math, function calls, `CASE` expressions, etc.

## 2. SELECT DISTINCT

`DISTINCT` removes duplicate rows from the result. Most often used on a single column to see *"what unique values exist?"*

```sql
SELECT DISTINCT city
FROM employees;
```

| city |
|------|
| Tampa |
| New York |
| San Francisco |
| Remote |

Without `DISTINCT`, you'd see "Tampa" three times (Alice, Bob, Fatima).

`DISTINCT` works across all columns in the `SELECT` list, treating each combination as a unit:

```sql
SELECT DISTINCT city, department_id
FROM employees;
```

This returns each unique *combination* of city and department.

> **Use case:** before joining or filtering, use `DISTINCT` to explore what categories live in a column.

## 3. The WHERE Clause

`WHERE` **filters rows** - keeps only the ones where a condition is true.

```sql
SELECT name, salary
FROM employees
WHERE city = 'Tampa';
```

| name | salary |
|------|--------|
| Alice Chen | 95000 |
| Bob Patel | 110000 |
| Fatima Ali | 65000 |

### Comparison Operators (Quick Recap)

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | equal to | `salary = 95000` |
| `<>` or `!=` | not equal to | `city <> 'Remote'` |
| `>` | greater than | `salary > 80000` |
| `<` | less than | `hire_date < '2022-01-01'` |
| `>=` | greater or equal | `salary >= 75000` |
| `<=` | less or equal | `salary <= 100000` |

### Combining Conditions

Stack conditions together with `AND`, `OR`, and `NOT`:

```sql
SELECT name, salary, city
FROM employees
WHERE city = 'Tampa'
  AND salary > 80000;
```

```sql
SELECT name, city
FROM employees
WHERE city = 'Tampa'
   OR city = 'New York';
```

```sql
SELECT name
FROM employees
WHERE NOT city = 'Remote';
```

### Parentheses for Order of Operations

When mixing `AND` and `OR`, use parentheses - `AND` binds tighter than `OR`, and the result can surprise you:

```sql
-- Reads as: (city='Tampa') OR (city='NY' AND salary>80000)
WHERE city = 'Tampa' OR city = 'New York' AND salary > 80000

-- Probably what you wanted - explicit:
WHERE (city = 'Tampa' OR city = 'New York') AND salary > 80000
```

> **Watch out:** strings go in `'single quotes'`. Numbers don't. `WHERE city = Tampa` (no quotes) will be a syntax error.

## 4. ORDER BY

`ORDER BY` **sorts** the result by one or more columns:

```sql
SELECT name, salary
FROM employees
ORDER BY salary DESC;
```

| name | salary |
|------|--------|
| Bob Patel | 110000 |
| Alice Chen | 95000 |
| Hiroshi Tanaka | 92000 |
| ... | ... |

- `ASC` = ascending (low to high) - **this is the default if you don't say**
- `DESC` = descending (high to low)

### Multiple Sort Keys

Provide several columns to break ties:

```sql
SELECT name, city, salary
FROM employees
ORDER BY city ASC, salary DESC;
```

Sorts primarily by city (A-Z), then within each city by salary (highest first).

### Sorting by Column Position

You can also sort by the *position* of a column in your `SELECT` list:

```sql
SELECT name, salary FROM employees ORDER BY 2 DESC;
-- 2 means "the second column" = salary
```

This works but is considered poor style - prefer the column name for readability.

## 5. LIMIT / TOP / FETCH FIRST

Want just the first N rows? Each major SQL dialect spells this differently - but they all do the same thing.

| Dialect | Syntax |
|---------|--------|
| **PostgreSQL, MySQL, SQLite** | `LIMIT 3` (at the end of the query) |
| **SQL Server** | `SELECT TOP 3 ...` (right after `SELECT`) |
| **Oracle / ANSI standard** | `FETCH FIRST 3 ROWS ONLY` (at the end) |

The PostgreSQL/MySQL form is the most common in modern data work:

```sql
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;
```

| name | salary |
|------|--------|
| Bob Patel | 110000 |
| Alice Chen | 95000 |
| Hiroshi Tanaka | 92000 |

> **Tip:** `LIMIT` without `ORDER BY` returns "some 3 rows" - but you have no control over *which* 3. Always pair `LIMIT` with `ORDER BY` when the order matters.

### LIMIT + OFFSET - Paginating

`OFFSET` skips a number of rows before starting. Combined with `LIMIT`, it's how you paginate:

```sql
SELECT name FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;        -- rows 4, 5, 6 (skipping the top 3)
```

## 6. Pattern Matching with LIKE

`LIKE` matches text against a **pattern** - useful when you don't know the exact value.

```sql
SELECT name FROM employees
WHERE name LIKE 'A%';        -- names starting with A
```

Returns: *Alice Chen*

The two wildcard characters in `LIKE` patterns:

| Wildcard | Meaning |
|----------|---------|
| `%` | matches **any sequence of characters** (including zero) |
| `_` | matches **exactly one** character |

### Common Patterns

```sql
WHERE name LIKE 'A%';        -- starts with A
WHERE name LIKE '%Chen';     -- ends with Chen
WHERE name LIKE '%a%';       -- contains an 'a' (anywhere)
WHERE name LIKE 'A____';     -- starts with A, exactly 5 characters total
WHERE name LIKE '_____';     -- exactly 5 characters long
```

### Case Sensitivity

`LIKE` is **case-sensitive** in some databases (PostgreSQL) and **case-insensitive** in others (MySQL, SQL Server by default). To force case-insensitive matching:

```sql
-- PostgreSQL: use ILIKE
SELECT name FROM employees WHERE name ILIKE 'a%';

-- Other dialects: use LOWER()
SELECT name FROM employees WHERE LOWER(name) LIKE 'a%';
```

### NOT LIKE

`NOT LIKE` inverts the match:

```sql
SELECT name FROM employees WHERE name NOT LIKE 'A%';
```

## 7. Wildcards

The `LIKE` wildcards (`%` and `_`) are the main two beginners need, but it's worth knowing the full set:

| Wildcard | Used in | Meaning |
|----------|---------|---------|
| `%` | `LIKE` | Any sequence of characters |
| `_` | `LIKE` | Exactly one character |
| `[abc]` | `LIKE` (SQL Server, PostgreSQL with SIMILAR TO) | Any one of a, b, or c |
| `[a-z]` | `LIKE` (some dialects) | Any character in the range |
| `[^abc]` | `LIKE` (SQL Server) | Any character *not* in the set |

For more powerful pattern matching (true regular expressions), most databases support `~` (PostgreSQL) or `REGEXP` (MySQL) - covered later in the Functions note.

### Escaping a Literal `%` or `_`

What if the data itself contains a `%` or `_`? Use an escape character:

```sql
SELECT product FROM items
WHERE name LIKE '50\%%' ESCAPE '\';     -- finds products starting with "50%"
```

## 8. The IN Operator

`IN` checks if a value matches **any value in a list**. It's a shorthand for many `OR`s.

```sql
-- Long way:
WHERE city = 'Tampa' OR city = 'New York' OR city = 'San Francisco'

-- Short way (equivalent):
WHERE city IN ('Tampa', 'New York', 'San Francisco')
```

```sql
SELECT name, city
FROM employees
WHERE city IN ('Tampa', 'New York');
```

### NOT IN

The inverse - match values *not* in the list:

```sql
SELECT name FROM employees
WHERE city NOT IN ('Tampa', 'Remote');
```

### IN with a Subquery

`IN` really shines with a subquery - checking against values computed by another query:

```sql
SELECT name FROM employees
WHERE department_id IN (
    SELECT id FROM departments WHERE location = 'Tampa'
);
```

This finds employees whose department is *located* in Tampa, even if those employees themselves live elsewhere. Subqueries get their own detailed note.

> **Beginner gotcha - `NOT IN` and `NULL`:** if the list contains a `NULL`, `NOT IN` returns no rows (because of three-valued logic). When the list might contain nulls, use `NOT EXISTS` instead - more on that in the subqueries note.

## 9. The BETWEEN Operator

`BETWEEN` checks if a value falls in an **inclusive range** - both endpoints are included.

```sql
SELECT name, salary
FROM employees
WHERE salary BETWEEN 70000 AND 90000;
```

This is equivalent to:
```sql
WHERE salary >= 70000 AND salary <= 90000
```

### BETWEEN with Dates

Particularly handy for date ranges:

```sql
SELECT name, hire_date
FROM employees
WHERE hire_date BETWEEN '2022-01-01' AND '2022-12-31';
```

> **Watch out:** `BETWEEN` is *inclusive on both ends*. `BETWEEN 10 AND 20` includes both 10 and 20. For "between but exclusive," use `>` and `<` explicitly.

### NOT BETWEEN

The inverse:
```sql
WHERE salary NOT BETWEEN 70000 AND 90000
```

## 10. IS NULL / IS NOT NULL

As covered in [Basics §14](./01-basics.md#14-null-values), **`NULL` doesn't behave like a regular value** - you can't compare to it with `=`. The special operators are `IS NULL` and `IS NOT NULL`.

```sql
-- Find employees with no assigned department:
SELECT name FROM employees WHERE department_id IS NULL;

-- Find employees who have a department:
SELECT name FROM employees WHERE department_id IS NOT NULL;
```

### Common NULL Mistakes

| Wrong | Right | Why |
|-------|-------|-----|
| `WHERE column = NULL` | `WHERE column IS NULL` | `=` against NULL always returns NULL (treated as false) |
| `WHERE column <> NULL` | `WHERE column IS NOT NULL` | Same reason |
| `WHERE column NOT IN (..., NULL)` | `WHERE column NOT IN (...) AND column IS NOT NULL` | NULL in a `NOT IN` list nukes the result |

> **Beginner mantra:** *"Compare with `IS NULL`, never with `= NULL`."*

---

## Putting It All Together

A realistic query that combines everything in this note:

> *"Show the top 3 highest-paid employees in Tampa or New York with a salary above $70,000, whose name doesn't start with 'E'. Show their name, city, and salary, sorted by salary descending."*

```sql
SELECT name, city, salary
FROM employees
WHERE city IN ('Tampa', 'New York')
  AND salary > 70000
  AND name NOT LIKE 'E%'
ORDER BY salary DESC
LIMIT 3;
```

| name | city | salary |
|------|------|--------|
| Bob Patel | Tampa | 110000 |
| Alice Chen | Tampa | 95000 |
| Grace Liu | New York | 80000 |

This kind of query - filter, sort, take the top N - is **80% of beginner SQL** in real jobs.

---

## Key Takeaways

- The basic shape: `SELECT … FROM … WHERE … ORDER BY … LIMIT …`
- `SELECT *` is for exploring; list specific columns in production code.
- `DISTINCT` returns unique values - great for exploring data.
- `WHERE` filters rows; combine conditions with `AND`, `OR`, `NOT` (and parentheses to be explicit).
- Strings in `'single quotes'`; numbers without quotes.
- `ORDER BY column ASC|DESC` sorts results; multiple columns break ties.
- `LIMIT N` returns just the first N rows - pair with `ORDER BY` for predictable results.
- `LIKE` matches text patterns with `%` (any sequence) and `_` (one character).
- `IN (...)` is shorthand for many `OR`s; `BETWEEN a AND b` is inclusive on both ends.
- **Always** use `IS NULL` / `IS NOT NULL` to test for nulls - never `= NULL`.

## Quick Self-Check

1. Write a query that returns the names of all employees hired after January 1, 2023.
2. What's the difference between `WHERE department_id = NULL` and `WHERE department_id IS NULL`?
3. Write a query that returns the bottom 2 lowest-paid employees, with their names and salaries.
4. What does `WHERE name LIKE '_a%'` match?
5. Rewrite `WHERE city = 'Tampa' OR city = 'NY' OR city = 'SF'` using `IN`.
6. Why is `BETWEEN 1 AND 10` not the same as "strictly between 1 and 10"?
7. Why does `SELECT *` get discouraged in production code?

## Further Reading

| Topic | Reference |
|-------|-----------|
| SELECT | [W3Schools: SELECT](https://www.w3schools.com/sql/sql_select.asp) |
| DISTINCT | [W3Schools: DISTINCT](https://www.w3schools.com/sql/sql_distinct.asp) |
| WHERE | [W3Schools: WHERE](https://www.w3schools.com/sql/sql_where.asp) |
| ORDER BY | [W3Schools: ORDER BY](https://www.w3schools.com/sql/sql_orderby.asp) |
| LIKE | [W3Schools: LIKE](https://www.w3schools.com/sql/sql_like.asp) |
| Wildcards | [W3Schools: Wildcards](https://www.w3schools.com/sql/sql_wildcards.asp) |
| IN | [W3Schools: IN](https://www.w3schools.com/sql/sql_in.asp) |
| BETWEEN | [W3Schools: BETWEEN](https://www.w3schools.com/sql/sql_between.asp) |

---

[← Prev: Basics](./01-basics.md) · [Next: Aggregation & CASE →](./03-aggregation-and-case.md)
