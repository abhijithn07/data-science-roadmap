# Note 03 — Aggregation & CASE

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

Four powerful tools that turn raw rows into summaries and conditional results:

1. **Aggregate functions** — `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
2. **`GROUP BY`** — one summary per category
3. **`HAVING`** — filtering the groups themselves
4. **`CASE` expressions** — `if/else` logic inside a query

Plus: **the logical order of execution** of a SELECT statement — one of the most important things to internalize about SQL.

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## 1. Aggregate Functions

So far, every query returned **individual rows**. **Aggregate functions** are the opposite — they **collapse many rows into a single summary value**.

- "How many employees do we have?" → one number.
- "What's the average salary?" → one number.
- "What's the highest salary?" → one number.

These questions all squash many rows down to one answer.

### The Five Core Aggregates

| Function | What it does | Works on |
|----------|--------------|----------|
| **`COUNT`** | Counts rows | Anything |
| **`SUM`** | Adds up values | Numbers |
| **`AVG`** | Computes the mean | Numbers |
| **`MIN`** | Finds the smallest value | Numbers, dates, strings |
| **`MAX`** | Finds the largest value | Numbers, dates, strings |

A few examples on the whole `employees` table:

```sql
SELECT COUNT(*) FROM employees;
-- → 8
```

```sql
SELECT AVG(salary) FROM employees;
-- → 84375.00
```

```sql
SELECT MAX(salary), MIN(salary) FROM employees;
-- → 110000, 65000
```

```sql
SELECT SUM(salary) FROM employees;
-- → 675000
```

### COUNT — The Three Flavors

`COUNT` has three forms worth knowing:

| Query | What it counts |
|-------|---------------|
| `COUNT(*)` | All rows in the table (including those with nulls) |
| `COUNT(column)` | Rows where that column is **not** `NULL` |
| `COUNT(DISTINCT column)` | The number of **unique** non-null values |

```sql
SELECT COUNT(*) AS total_rows,
       COUNT(department_id) AS rows_with_department,
       COUNT(DISTINCT city) AS unique_cities
FROM employees;
```

| total_rows | rows_with_department | unique_cities |
|-----------|---------------------|---------------|
| 8 | 8 | 4 |

### Aggregates Ignore NULL

All aggregates except `COUNT(*)` **ignore `NULL` values**. This is usually what you want — the average of `[100, 200, NULL]` is `150`, not `100` — but be aware of it.

### Renaming the Result with AS

The default column name for an aggregate is ugly (`avg`, `count`, `?column?`). Always alias it:

```sql
SELECT AVG(salary) AS average_salary,
       MAX(salary) AS highest_salary
FROM employees;
```

| average_salary | highest_salary |
|----------------|----------------|
| 84375.00 | 110000 |

### Mixing Aggregates with Math

You can do arithmetic on aggregate results:

```sql
SELECT MAX(salary) - MIN(salary) AS salary_range,
       AVG(salary) * 12 AS avg_annual_salary
FROM employees;
```

## 2. GROUP BY

A single number for the whole table is useful, but the *really* interesting question is: **"what's the average salary *in each department*?"**

`GROUP BY` produces **one summary row per group**.

```sql
SELECT department_id,
       AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;
```

| department_id | avg_salary |
|---------------|-----------|
| 1 | 91666.67 |
| 2 | 77500.00 |
| 3 | 90000.00 |
| 4 | 65000.00 |

**What happens under the hood:**
1. SQL groups all employees with the same `department_id` together.
2. It computes `AVG(salary)` separately for each group.
3. It returns one row per group.

### Grouping by Multiple Columns

You can group by several columns to slice more finely:

```sql
SELECT city, department_id, COUNT(*) AS headcount
FROM employees
GROUP BY city, department_id;
```

This returns one row for each unique *combination* of city and department.

### The Golden Rule of GROUP BY

> **Every column in the `SELECT` list must either appear in the `GROUP BY` clause, or be inside an aggregate function.**

**Why?** If you `GROUP BY department_id`, each group can have many different `name`s. The database doesn't know *which* name to display — it only knows how to *aggregate* (count them, get the max, etc.). So it errors out.

```sql
-- ❌ This fails:
SELECT name, AVG(salary)
FROM employees
GROUP BY department_id;
-- ERROR: column "name" must appear in the GROUP BY clause
--        or be used in an aggregate function

-- ✅ This works (name is in GROUP BY):
SELECT name, AVG(salary)
FROM employees
GROUP BY name;

-- ✅ This works (name is aggregated):
SELECT MAX(name), AVG(salary)
FROM employees
GROUP BY department_id;
```

Forgetting this rule is the **#1 beginner SQL error**.

## 3. HAVING

`WHERE` filters individual **rows** *before* aggregation. **`HAVING`** filters **groups** *after* aggregation.

> *"Show departments where the average salary is over 80,000."*

```sql
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 80000;
```

| department_id | avg_salary |
|---------------|-----------|
| 1 | 91666.67 |
| 3 | 90000.00 |

### WHERE vs. HAVING — Side by Side

| Clause | Filters | Runs |
|--------|---------|------|
| **`WHERE`** | Individual rows | **Before** `GROUP BY` |
| **`HAVING`** | Groups (aggregated results) | **After** `GROUP BY` |
| Can use aggregates? | **No** | **Yes** |

Both can appear in the same query — `WHERE` first (filter rows), then `GROUP BY` (group them), then `HAVING` (filter groups):

```sql
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
WHERE city <> 'Remote'           -- step 1: drop remote employees
GROUP BY department_id           -- step 2: group remaining by dept
HAVING AVG(salary) > 80000;      -- step 3: keep only depts with avg > 80k
```

> **Beginner heuristic:** if your condition uses an aggregate function like `COUNT(*)` or `AVG(...)`, it must be in `HAVING`. Otherwise, it goes in `WHERE`.

## 4. The Logical Order of Execution

This is one of the most important things to internalize about SQL — **the order you *write* clauses is not the order the database *runs* them**.

| You write it in this order | The database evaluates it in this order |
|---------------------------|-----------------------------------------|
| 1. `SELECT` | 5. `SELECT` (projections, aliases) |
| 2. `FROM` | 1. `FROM` (and `JOIN`) |
| 3. `WHERE` | 2. `WHERE` |
| 4. `GROUP BY` | 3. `GROUP BY` |
| 5. `HAVING` | 4. `HAVING` |
| 6. `ORDER BY` | 6. `ORDER BY` |
| 7. `LIMIT` | 7. `LIMIT` |

**Logical execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT**

**Why it matters:** when something goes wrong, it's almost always because of this ordering. Examples:

- **Aliases defined in `SELECT` aren't available to `WHERE`** — `WHERE` runs first, before the alias exists.
  ```sql
  -- ❌ This fails (in most dialects):
  SELECT salary * 12 AS annual FROM employees WHERE annual > 1000000;

  -- ✅ Either repeat the expression…
  SELECT salary * 12 AS annual FROM employees WHERE salary * 12 > 1000000;

  -- …or wrap it in a subquery, where the alias does exist outside.
  ```
- **Aggregates can't appear in `WHERE`** — aggregation hasn't happened yet. Use `HAVING`.
- **`ORDER BY` *can* see `SELECT` aliases** — because it runs last.

Memorize this sequence and a huge category of confusing SQL errors disappears.

## 5. The CASE Expression

`CASE` is SQL's **if/else** — it lets you assign different values based on conditions. Two forms:

### Searched CASE (most common)

```sql
SELECT name,
       salary,
       CASE
           WHEN salary >= 100000 THEN 'High'
           WHEN salary >= 80000 THEN 'Mid'
           ELSE 'Entry'
       END AS salary_band
FROM employees;
```

| name | salary | salary_band |
|------|--------|-------------|
| Alice Chen | 95000 | Mid |
| Bob Patel | 110000 | High |
| Carlos Reyes | 75000 | Entry |
| ... | ... | ... |

**How it reads:** for each row, check the conditions in order. Return the value for the first one that's true. If none match, return the `ELSE` value (or `NULL` if no `ELSE`).

### Simple CASE (when comparing one value to many)

When you're checking the same column against several values, the simple form is shorter:

```sql
SELECT name,
       department_id,
       CASE department_id
           WHEN 1 THEN 'Engineering'
           WHEN 2 THEN 'Marketing'
           WHEN 3 THEN 'Sales'
           WHEN 4 THEN 'HR'
           ELSE 'Unknown'
       END AS department
FROM employees;
```

(In practice, you'd use a `JOIN` for this — but `CASE` is useful when the mapping doesn't live in a table.)

### CASE Inside Aggregates — Conditional Counting

This is one of the most useful idioms in SQL: count rows that match a condition.

> *"For each department, count the high earners (salary > 80,000) and the entry-level (salary ≤ 80,000)."*

```sql
SELECT department_id,
       COUNT(*) AS total,
       SUM(CASE WHEN salary > 80000 THEN 1 ELSE 0 END) AS high_earners,
       SUM(CASE WHEN salary <= 80000 THEN 1 ELSE 0 END) AS entry_level
FROM employees
GROUP BY department_id;
```

| department_id | total | high_earners | entry_level |
|---------------|-------|--------------|-------------|
| 1 | 3 | 2 | 1 |
| 2 | 2 | 0 | 2 |
| 3 | 2 | 2 | 0 |
| 4 | 1 | 0 | 1 |

The trick: `CASE` returns `1` when the condition is true and `0` otherwise; `SUM` adds those up.

### CASE in ORDER BY — Custom Sorting

```sql
SELECT name, salary,
       CASE
           WHEN salary >= 100000 THEN 'High'
           WHEN salary >= 80000 THEN 'Mid'
           ELSE 'Entry'
       END AS salary_band
FROM employees
ORDER BY
    CASE salary_band
        WHEN 'High' THEN 1
        WHEN 'Mid' THEN 2
        ELSE 3
    END;
```

(This works in some dialects; in PostgreSQL you'd reference the alias directly.)

---

## Putting It All Together

> *"For each city other than Remote, show the number of employees, the average salary, and a label ('Big' if more than 2 employees, otherwise 'Small'). Only include cities with average salary above 70,000. Sort by average salary descending."*

```sql
SELECT city,
       COUNT(*) AS headcount,
       AVG(salary) AS avg_salary,
       CASE WHEN COUNT(*) > 2 THEN 'Big' ELSE 'Small' END AS size_label
FROM employees
WHERE city <> 'Remote'
GROUP BY city
HAVING AVG(salary) > 70000
ORDER BY avg_salary DESC;
```

| city | headcount | avg_salary | size_label |
|------|-----------|-----------|------------|
| Tampa | 3 | 90000.00 | Big |
| San Francisco | 2 | 90000.00 | Small |
| New York | 2 | 77500.00 | Small |

This is the **kind of query a data analyst writes every day**.

---

## Key Takeaways

- **Aggregate functions** (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) collapse many rows into one value.
- `COUNT(*)` counts rows; `COUNT(column)` ignores nulls; `COUNT(DISTINCT column)` counts uniques.
- All aggregates except `COUNT(*)` **ignore `NULL`** values.
- **`GROUP BY`** produces one summary per category.
- **Golden rule:** every non-aggregated column in `SELECT` must appear in `GROUP BY`.
- **`WHERE`** filters rows *before* grouping; **`HAVING`** filters groups *after*.
- **Logical execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.**
- **`CASE`** is SQL's if/else — searched and simple forms; powerful inside aggregates for conditional counting.

## Quick Self-Check

1. What's the difference between `COUNT(*)` and `COUNT(department_id)`?
2. Why does `SELECT name, AVG(salary) FROM employees GROUP BY department_id;` fail? How do you fix it?
3. When should you use `HAVING` instead of `WHERE`?
4. In what order does the database actually evaluate the clauses of a SELECT statement?
5. Write a query that returns each department_id with the count of employees making over 80,000 in it.
6. What value does a `CASE` expression return if no `WHEN` condition matches and there's no `ELSE`?
7. Why can't you reference a column alias defined in `SELECT` from inside `WHERE`?

## Further Reading

| Topic | Reference |
|-------|-----------|
| Aggregate functions | [W3Schools: COUNT/AVG/SUM](https://www.w3schools.com/sql/sql_count_avg_sum.asp) |
| GROUP BY | [W3Schools: GROUP BY](https://www.w3schools.com/sql/sql_groupby.asp) |
| HAVING | [W3Schools: HAVING](https://www.w3schools.com/sql/sql_having.asp) |
| CASE | [W3Schools: CASE](https://www.w3schools.com/sql/sql_case.asp) |
| Conditional logic patterns | [GeeksForGeeks: CASE / IF / IIF](https://www.geeksforgeeks.org/?s=SQL+Conditional+logic+with+CASE+%2F+IF+%2F+IIF) |

---

[← Prev: SELECT & Filter](./02-select-and-filter.md) · [Next: Subqueries →](./04-subqueries.md)
