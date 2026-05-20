# Note 05 - CTEs & Window Functions

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The most powerful tools in the DQL toolkit - used heavily in real data jobs and interviews:

1. **Common Table Expressions (CTEs)** - `WITH` clause for readable, layered queries
2. **Recursive CTEs** - for hierarchies and generated sequences
3. **Window functions** - calculate across rows without collapsing them
4. **Ranking functions** - `ROW_NUMBER`, `RANK`, `DENSE_RANK`
5. **Analytic functions** - `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`
6. **Window frames** - controlling exactly which rows a window function sees, for running totals and moving averages

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## 1. Common Table Expressions (CTEs)

A **CTE** is a *named, temporary result set* you define at the top of a query, then reference like a table. The keyword is `WITH`.

CTEs solve the readability problem that subqueries and derived tables create - instead of nesting queries inside queries, you stack them top-to-bottom in natural reading order.

### Basic Syntax

```sql
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.name, e.salary, d.avg_salary
FROM employees e
JOIN dept_avg d ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;
```

What's happening:
1. The `WITH` clause defines `dept_avg` - a temporary result set with each department's average salary.
2. The main `SELECT` uses `dept_avg` exactly like a real table.

Result - employees earning above their department's average:

| name | salary | avg_salary |
|------|--------|-----------|
| Bob Patel | 110000 | 91666.67 |
| Alice Chen | 95000 | 91666.67 |
| Grace Liu | 80000 | 77500.00 |
| Hiroshi Tanaka | 92000 | 90000.00 |

### Multiple CTEs in One Query

You can define several CTEs, each able to reference the ones before it:

```sql
WITH
high_earners AS (
    SELECT * FROM employees WHERE salary > 80000
),
tampa_high_earners AS (
    SELECT * FROM high_earners WHERE city = 'Tampa'
)
SELECT name, salary FROM tampa_high_earners;
```

This reads top-down like a recipe: *"first compute high earners, then filter to Tampa, then pick name and salary."* Much clearer than a nested subquery.

### CTE vs. Derived Table

| | CTE | Derived Table |
|--|-----|---------------|
| Defined | Top of query (`WITH ... AS`) | Inside `FROM (...)` |
| Readability | Better for complex queries | OK for simple ones |
| Reusable in same query | Yes - reference it multiple times | No - duplicate it |
| Recursive | Yes (with `RECURSIVE`) | No |

**Rule of thumb:** prefer CTEs for anything beyond a one-off, simple derived table.

---

## 2. Recursive CTEs

A **recursive CTE** can reference itself - it's how SQL handles **hierarchical data** (org charts, file trees, bill-of-materials) and **generated sequences**.

The shape:

```sql
WITH RECURSIVE cte_name AS (
    -- Base case: the starting rows
    SELECT ...
    UNION ALL
    -- Recursive step: extend by referencing cte_name
    SELECT ... FROM cte_name WHERE <stop condition>
)
SELECT * FROM cte_name;
```

### Example - Generate a Sequence of Numbers

```sql
WITH RECURSIVE numbers(n) AS (
    SELECT 1                                  -- base case
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 5     -- recursive step
)
SELECT n FROM numbers;
```

Result: 1, 2, 3, 4, 5.

### Example - Traverse a Hierarchy

If `employees` had a `manager_id` column (pointing to another employee's `id`), a recursive CTE could walk the org chart:

```sql
WITH RECURSIVE org_chart AS (
    -- Base: the CEO (no manager)
    SELECT id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: anyone reporting to someone already in org_chart
    SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart;
```

Each iteration finds one more level of the hierarchy until no new rows are added.

> **Dialect note:** PostgreSQL, SQL Server, Oracle, and MySQL 8+ all support recursive CTEs (with the `RECURSIVE` keyword required in most). The exact syntax is portable.

---

## 3. Window Functions - The Big Idea

**Window functions** are SQL's secret weapon. They compute values *across rows* - like aggregates - but **without collapsing the rows**. You keep every row of the original result, just with extra calculated columns.

The trigger is the **`OVER()`** clause. Whenever you see `OVER`, it's a window function.

### Compare: Aggregate vs. Window Function

```sql
-- Aggregate: collapses to 1 row
SELECT AVG(salary) AS overall_avg FROM employees;

-- Window function: keeps all 8 rows, adds the average as a column
SELECT name, salary, AVG(salary) OVER () AS overall_avg
FROM employees;
```

The window version returns:

| name | salary | overall_avg |
|------|--------|-------------|
| Alice Chen | 95000 | 84375 |
| Bob Patel | 110000 | 84375 |
| ... | ... | 84375 |

Every row shows its own data *and* the overall average - useful for comparisons.

### PARTITION BY - Per-Group Windows

Want the average *per department* on each row? Add `PARTITION BY`:

```sql
SELECT name, salary, department_id,
    AVG(salary) OVER (PARTITION BY department_id) AS dept_avg
FROM employees;
```

Now `dept_avg` shows each employee's department average:

| name | salary | department_id | dept_avg |
|------|--------|---------------|----------|
| Alice Chen | 95000 | 1 | 91666.67 |
| Bob Patel | 110000 | 1 | 91666.67 |
| Ethan Brown | 70000 | 1 | 91666.67 |
| Carlos Reyes | 75000 | 2 | 77500.00 |
| ... | ... | ... | ... |

This is hugely useful - you can compare each row to its group's stats in the same query, without a self-join.

### ORDER BY in OVER

When the order of rows within a window matters (for ranking, running totals, etc.), use `ORDER BY` inside `OVER`:

```sql
SELECT name, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rnk
FROM employees;
```

`ORDER BY` inside `OVER` is different from the `ORDER BY` at the end of the query (which sorts the *final output*). The one inside `OVER` controls the *window function's perspective*.

---

## 4. Ranking Functions

Three functions assign a **rank** to rows. The differences only matter when there are **ties**.

| Function | What it does on ties |
|----------|---------------------|
| **`ROW_NUMBER()`** | Always gives unique numbers (1, 2, 3, 4, …) - arbitrary tiebreak |
| **`RANK()`** | Ties get the same rank; the next rank **skips** (1, 2, 2, 4) |
| **`DENSE_RANK()`** | Ties get the same rank; the next rank **does not skip** (1, 2, 2, 3) |

### Example - Ranking by Salary

```sql
SELECT name, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
    RANK() OVER (ORDER BY salary DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
FROM employees;
```

In our data, all salaries are unique, so all three return 1, 2, 3, ..., 8 - identical. To see the difference, imagine Carlos earned `80000` (a tie with Grace):

| name | salary | ROW_NUMBER | RANK | DENSE_RANK |
|------|--------|-----------|------|------------|
| Bob Patel | 110000 | 1 | 1 | 1 |
| Alice Chen | 95000 | 2 | 2 | 2 |
| Hiroshi Tanaka | 92000 | 3 | 3 | 3 |
| Diana Kim | 88000 | 4 | 4 | 4 |
| Grace Liu | 80000 | 5 | 5 | 5 |
| **Carlos Reyes** | **80000** | **6** | **5** | **5** |
| Ethan Brown | 70000 | 7 | 7 | 6 |
| Fatima Ali | 65000 | 8 | 8 | 7 |

Notice on the tie:
- `ROW_NUMBER` keeps numbering (5, 6).
- `RANK` ties (5, 5) then skips to 7.
- `DENSE_RANK` ties (5, 5) then continues to 6.

### PARTITION BY in Ranking - "Top N per group"

The classic interview question: *"Find the top-paid employee in each department."*

```sql
SELECT name, salary, department_id
FROM (
    SELECT name, salary, department_id,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM employees
) ranked
WHERE rn = 1;
```

Result - each department's top earner:

| name | salary | department_id |
|------|--------|---------------|
| Bob Patel | 110000 | 1 |
| Grace Liu | 80000 | 2 |
| Hiroshi Tanaka | 92000 | 3 |
| Fatima Ali | 65000 | 4 |

> **Pattern to remember:** `ROW_NUMBER() OVER (PARTITION BY <group> ORDER BY <metric>)` → filter where `rn = 1` is the textbook "top per group" solution. Comes up constantly.

---

## 5. Analytic Functions - LAG / LEAD / FIRST_VALUE / LAST_VALUE

These let a row "peek" at other rows in the window.

| Function | Returns the value of |
|----------|---------------------|
| **`LAG(col)`** | The **previous** row's `col` (in the window's order) |
| **`LEAD(col)`** | The **next** row's `col` |
| **`FIRST_VALUE(col)`** | The **first** row's `col` in the window |
| **`LAST_VALUE(col)`** | The **last** row's `col` in the window |

### Example - LAG for Differences over Time

> *"For each employee in hire order, show the previous person's hire date."*

```sql
SELECT name, hire_date,
    LAG(hire_date) OVER (ORDER BY hire_date) AS prev_hire_date
FROM employees;
```

| name | hire_date | prev_hire_date |
|------|-----------|----------------|
| Diana Kim | 2020-11-05 | NULL |
| Hiroshi Tanaka | 2021-04-18 | 2020-11-05 |
| Bob Patel | 2021-06-20 | 2021-04-18 |
| Alice Chen | 2022-03-15 | 2021-06-20 |
| Grace Liu | 2022-09-01 | 2022-03-15 |
| Carlos Reyes | 2023-01-10 | 2022-09-01 |
| Fatima Ali | 2023-08-12 | 2023-01-10 |
| Ethan Brown | 2024-02-28 | 2023-08-12 |

The first row has `NULL` for `prev_hire_date` because there's no previous row.

### Specifying Offset and Default

`LAG` and `LEAD` accept optional arguments:

```sql
LAG(hire_date, 2, '1900-01-01') OVER (ORDER BY hire_date)
-- 2 rows back, default '1900-01-01' if there isn't one
```

### FIRST_VALUE and LAST_VALUE

```sql
SELECT name, salary, department_id,
    FIRST_VALUE(name) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS top_earner_in_dept
FROM employees;
```

Each row gets the name of the highest earner in its department.

---

## 6. Window Frames - Running Totals and Moving Averages

By default, when you `ORDER BY` inside `OVER`, the **window frame** for each row is *all rows from the start up to the current row*. This is what enables **running totals**.

The default can be made explicit: `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. You can change it.

### Example - Running Total

> *"For each employee in hire order, show a running total of salaries."*

```sql
SELECT name, hire_date, salary,
    SUM(salary) OVER (
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM employees
ORDER BY hire_date;
```

| name | hire_date | salary | running_total |
|------|-----------|--------|---------------|
| Diana Kim | 2020-11-05 | 88000 | 88000 |
| Hiroshi Tanaka | 2021-04-18 | 92000 | 180000 |
| Bob Patel | 2021-06-20 | 110000 | 290000 |
| Alice Chen | 2022-03-15 | 95000 | 385000 |
| Grace Liu | 2022-09-01 | 80000 | 465000 |
| Carlos Reyes | 2023-01-10 | 75000 | 540000 |
| Fatima Ali | 2023-08-12 | 65000 | 605000 |
| Ethan Brown | 2024-02-28 | 70000 | 675000 |

Each row's running total = sum of all salaries up to and including that row.

### Frame Specifications

The general shape:

```sql
ROWS BETWEEN <start> AND <end>
```

| Spec | Meaning |
|------|---------|
| `UNBOUNDED PRECEDING` | All rows before this one |
| `N PRECEDING` | The N rows before this one |
| `CURRENT ROW` | This row |
| `N FOLLOWING` | The N rows after this one |
| `UNBOUNDED FOLLOWING` | All rows after this one |

### Example - 3-Row Moving Average

```sql
SELECT name, hire_date, salary,
    AVG(salary) OVER (
        ORDER BY hire_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS moving_avg_3
FROM employees;
```

Each row's moving average is computed from itself and one row on either side - useful for smoothing time-series data.

### ROWS vs. RANGE

- `ROWS` - frames based on **physical row positions**.
- `RANGE` - frames based on **logical value ranges** of the ORDER BY column.

`ROWS` is what you want 95% of the time. `RANGE` matters when there are ties in the ORDER BY column and you want them treated as one group.

---

## Putting It All Together

> *"For each department, find the top 2 highest-paid employees, with their rank and a running total of department salary."*

```sql
WITH ranked AS (
    SELECT
        name,
        department_id,
        salary,
        RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk,
        SUM(salary) OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_dept_total
    FROM employees
)
SELECT name, department_id, salary, rnk, running_dept_total
FROM ranked
WHERE rnk <= 2
ORDER BY department_id, rnk;
```

| name | department_id | salary | rnk | running_dept_total |
|------|---------------|--------|-----|---------------------|
| Bob Patel | 1 | 110000 | 1 | 110000 |
| Alice Chen | 1 | 95000 | 2 | 205000 |
| Grace Liu | 2 | 80000 | 1 | 80000 |
| Carlos Reyes | 2 | 75000 | 2 | 155000 |
| Hiroshi Tanaka | 3 | 92000 | 1 | 92000 |
| Diana Kim | 3 | 88000 | 2 | 180000 |
| Fatima Ali | 4 | 65000 | 1 | 65000 |

This combines a CTE, ranking, and running totals - three of the most useful patterns in advanced SQL.

---

## Key Takeaways

- A **CTE** (`WITH cte_name AS (...)`) is a named temporary result set defined at the top of a query - much more readable than nested subqueries.
- **Recursive CTEs** handle hierarchies and generated sequences (base case + recursive step).
- **Window functions** compute across rows *without collapsing them*. The trigger is `OVER(...)`.
- **`PARTITION BY`** = "group within the window"; **`ORDER BY`** inside `OVER` = "order within the window."
- **Ranking:** `ROW_NUMBER` always unique, `RANK` ties+skip, `DENSE_RANK` ties+no skip.
- **Top-per-group pattern:** `ROW_NUMBER() OVER (PARTITION BY g ORDER BY x DESC)` → filter `rn = 1`.
- **Analytic functions:** `LAG`/`LEAD` (previous/next row), `FIRST_VALUE`/`LAST_VALUE` (window bounds).
- **Window frames** (`ROWS BETWEEN ...`) control which rows the window function sees. `UNBOUNDED PRECEDING AND CURRENT ROW` = running total.

## Quick Self-Check

1. What's the difference between a CTE and a derived table?
2. Why use a CTE over a subquery for a complex query?
3. What's the difference between `RANK` and `DENSE_RANK` when there are ties?
4. Write a query using `ROW_NUMBER` to find the second-highest-paid employee in each department.
5. What does `LAG(salary) OVER (ORDER BY hire_date)` give you?
6. What's the meaning of `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`?
7. When does `RANGE` give a different result from `ROWS` in a window frame?

## Further Reading

| Topic | Reference |
|-------|-----------|
| CTEs | [GeeksForGeeks: CTE in SQL](https://www.geeksforgeeks.org/sql/cte-in-sql/) |
| Recursive CTEs | [GeeksForGeeks: WITH clause / Recursive CTE](https://www.geeksforgeeks.org/sql/sql-with-clause/) |
| Window functions overview | [GeeksForGeeks: Window functions](https://www.geeksforgeeks.org/sql/window-functions-in-sql/) |
| Ranking functions | [GeeksForGeeks: ROW_NUMBER/RANK/DENSE_RANK](https://www.geeksforgeeks.org/sql/window-functions-in-sql/) |
| LAG / LEAD | [GeeksForGeeks: Analytic functions](https://www.geeksforgeeks.org/?s=SQL+Analytic+functions) |
| Window frames | [GeeksForGeeks: Window frames](https://www.geeksforgeeks.org/?s=SQL+Window+frames+and+running+totals) |

---

[← Prev: Subqueries](./04-subqueries.md) · [Next: PIVOT & Set Operations →](./06-pivot-and-set-operations.md)
