# Note 06 — PIVOT & Set Operations

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

Two distinct DQL Advanced features that round out the "querying" chapter:

1. **`PIVOT`** — turning row values into columns
2. **`UNPIVOT`** — the reverse: turning columns into rows
3. **Set operators** — combining the results of multiple queries:
   - `UNION` and `UNION ALL`
   - `INTERSECT`
   - `EXCEPT` (a.k.a. `MINUS` in Oracle)

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## 1. PIVOT — Rows to Columns

A **pivot** takes a tall, narrow table and reshapes it into a wide one — each unique value in some column becomes its own new column.

> **Why?** Reports and dashboards often need **wide-format** data ("a column per category"), while transactional data is usually stored in **long format** (one fact per row).

### Example

> *"Show the average salary in each department, with departments as columns and cities as rows."*

In long format (the data we have), employees are listed one per row. The result we want has cities as rows and departments as columns:

| city | engineering | marketing | sales | hr |
|------|-------------|-----------|-------|-----|
| Tampa | 102500 | NULL | NULL | 65000 |
| New York | NULL | 77500 | NULL | NULL |
| San Francisco | NULL | NULL | 90000 | NULL |
| Remote | 70000 | NULL | NULL | NULL |

### Two Ways to Pivot

PIVOT syntax **varies a lot by dialect**. There are two common approaches.

#### Approach 1: `PIVOT` clause (SQL Server, Oracle)

```sql
SELECT city, [1] AS engineering, [2] AS marketing,
              [3] AS sales,       [4] AS hr
FROM (
    SELECT city, department_id, salary FROM employees
) src
PIVOT (
    AVG(salary) FOR department_id IN ([1], [2], [3], [4])
) AS pvt;
```

Inside `PIVOT(...)`:
- The aggregate (`AVG(salary)`) is what fills each cell.
- `FOR department_id IN (...)` says which column to pivot, and which values become column names.

#### Approach 2: `CASE` inside aggregates (PostgreSQL, MySQL, portable everywhere)

PostgreSQL and MySQL don't have a built-in `PIVOT`. You do it manually with conditional aggregates:

```sql
SELECT city,
    AVG(CASE WHEN department_id = 1 THEN salary END) AS engineering,
    AVG(CASE WHEN department_id = 2 THEN salary END) AS marketing,
    AVG(CASE WHEN department_id = 3 THEN salary END) AS sales,
    AVG(CASE WHEN department_id = 4 THEN salary END) AS hr
FROM employees
GROUP BY city;
```

This works in every SQL dialect. The trick: `CASE` returns `NULL` for non-matching rows, and aggregates ignore `NULL`s, so each column only "sees" its own department's salaries.

> **Beginner takeaway:** if you don't know the dialect or want portable code, **the `CASE`-based approach is the safe choice**.

### Pivoting with COUNT or SUM

The aggregate doesn't have to be `AVG`:

```sql
-- Count of employees per city × department:
SELECT city,
    COUNT(CASE WHEN department_id = 1 THEN 1 END) AS engineering,
    COUNT(CASE WHEN department_id = 2 THEN 1 END) AS marketing,
    COUNT(CASE WHEN department_id = 3 THEN 1 END) AS sales,
    COUNT(CASE WHEN department_id = 4 THEN 1 END) AS hr
FROM employees
GROUP BY city;
```

---

## 2. UNPIVOT — Columns to Rows

`UNPIVOT` is the reverse: take a wide table and turn columns into rows. Less common, but useful when you receive wide-format data and need to "tidy" it for analysis.

Suppose you had a wide quarterly sales table:

| product | q1 | q2 | q3 | q4 |
|---------|----|----|----|----|
| A | 100 | 150 | 120 | 200 |
| B | 80 | 90 | 110 | 130 |

UNPIVOT would turn it into:

| product | quarter | sales |
|---------|---------|-------|
| A | q1 | 100 |
| A | q2 | 150 |
| A | q3 | 120 |
| A | q4 | 200 |
| B | q1 | 80 |
| ... | ... | ... |

### Syntax (varies widely)

**SQL Server / Oracle:**
```sql
SELECT product, quarter, sales
FROM sales_wide
UNPIVOT (
    sales FOR quarter IN (q1, q2, q3, q4)
) AS u;
```

**PostgreSQL / MySQL — manual UNPIVOT with `UNION ALL`:**
```sql
SELECT product, 'q1' AS quarter, q1 AS sales FROM sales_wide
UNION ALL
SELECT product, 'q2', q2 FROM sales_wide
UNION ALL
SELECT product, 'q3', q3 FROM sales_wide
UNION ALL
SELECT product, 'q4', q4 FROM sales_wide;
```

> **Real-world tool tip:** in Python/Pandas, this is one line: `df.melt(...)`. In practice, many people unpivot in Python rather than SQL.

---

## 3. Set Operators — The Big Idea

**Set operators** combine the results of two `SELECT` statements. They treat each result like a set of rows and apply set-theory operations (union, intersection, difference).

### The Requirements

Both queries must:
- Return the **same number of columns**.
- Have **compatible data types** in each corresponding column.
- The column names in the *result* come from the **first** query.

### The Four Operators

| Operator | Returns |
|----------|---------|
| **`UNION`** | All rows from both queries — **duplicates removed** |
| **`UNION ALL`** | All rows from both queries — **duplicates kept** (faster) |
| **`INTERSECT`** | Only rows that appear in **both** queries |
| **`EXCEPT`** (or **`MINUS`** in Oracle) | Rows from the first query that are **not** in the second |

---

## 4. UNION and UNION ALL

> *"List every location where someone works — including employee cities and department locations."*

```sql
SELECT city AS location FROM employees
UNION
SELECT location FROM departments;
```

Cities in `employees`: Tampa, New York, San Francisco, Remote.
Locations in `departments`: Tampa, New York, San Francisco (Tampa appears twice because Engineering and HR are both there).

`UNION` removes duplicates, so the result is:

| location |
|----------|
| Tampa |
| New York |
| San Francisco |
| Remote |

### UNION vs. UNION ALL

Use `UNION ALL` when you **don't** want duplicates removed (and you want better performance — deduplication isn't free):

```sql
SELECT city FROM employees
UNION ALL
SELECT location FROM departments;
```

The result includes Tampa multiple times.

> **Performance tip:** if you know there can't be duplicates between your two queries — or if you don't care — **always prefer `UNION ALL`**. It skips the deduplication step entirely.

---

## 5. INTERSECT

> *"Find locations that exist in both the employees and departments tables."*

```sql
SELECT city AS location FROM employees
INTERSECT
SELECT location FROM departments;
```

| location |
|----------|
| Tampa |
| New York |
| San Francisco |

`Remote` is in `employees` but not `departments`, so it's excluded.

---

## 6. EXCEPT / MINUS

> *"Find employee cities that are NOT department locations"* — i.e., places where employees live but no department is physically based.

```sql
SELECT city FROM employees
EXCEPT
SELECT location FROM departments;
```

Result:

| city |
|------|
| Remote |

In Oracle, the same operator is called `MINUS` (same syntax otherwise).

> **Dialect note:** PostgreSQL, SQL Server, and SQLite use `EXCEPT`. Oracle uses `MINUS`. MySQL (before version 8.0.31) didn't support either — workaround: a `LEFT JOIN ... WHERE ... IS NULL`.

---

## Set Operators vs. JOINs — When to Use Which

A common beginner question: *"When do I use a `UNION` versus a `JOIN`?"*

| | UNION / INTERSECT / EXCEPT | JOIN |
|--|---------------------------|------|
| Combines | Rows of two queries (vertically — stacking) | Columns of two tables (horizontally) |
| Result has | Same number of columns as each input | Combined columns from both tables |
| Used for | "Items in A and/or B" set operations | "Look up related info" relational queries |

If you want to stack two similar result sets, use a set operator. If you want to enrich rows with related info, use a JOIN.

---

## Putting It All Together

Combining set operators with a pivot — for a quick summary report:

> *"Build a single column listing every distinct 'location' across employees and departments (using UNION), then count how many employees live there and how many departments are there."*

```sql
WITH all_locations AS (
    SELECT city AS location FROM employees
    UNION
    SELECT location FROM departments
)
SELECT
    a.location,
    COUNT(DISTINCT e.id) AS employees_here,
    COUNT(DISTINCT d.id) AS departments_here
FROM all_locations a
LEFT JOIN employees   e ON e.city     = a.location
LEFT JOIN departments d ON d.location = a.location
GROUP BY a.location
ORDER BY a.location;
```

| location | employees_here | departments_here |
|----------|---------------|------------------|
| New York | 2 | 1 |
| Remote | 1 | 0 |
| San Francisco | 2 | 1 |
| Tampa | 3 | 2 |

This combines a CTE, a set operator, and joins — the kind of layered query that's standard in real analytics work.

---

## Key Takeaways

- **`PIVOT`** turns row values into columns. Syntax varies — the **portable** approach is **`CASE` inside aggregates** with `GROUP BY`.
- **`UNPIVOT`** is the reverse — less common in SQL; usually easier in Pandas (`melt`).
- Set operators (`UNION`, `INTERSECT`, `EXCEPT`/`MINUS`) combine query results **vertically**. Both queries must have the same number of columns with compatible types.
- **`UNION`** removes duplicates; **`UNION ALL`** keeps them and is faster — prefer it when dedup isn't needed.
- **JOINs combine columns horizontally; set operators stack rows vertically.** Different jobs.

## Quick Self-Check

1. Why is the `CASE`-inside-`AVG` approach to pivoting portable across dialects?
2. When should you use `UNION ALL` instead of `UNION`?
3. What's the rule about the number of columns in each query when using `UNION`?
4. What's the difference between `INTERSECT` and a `JOIN`?
5. Write a query that returns cities where employees live but no department is located.

## Further Reading

| Topic | Reference |
|-------|-----------|
| PIVOT / UNPIVOT | [GeeksForGeeks: PIVOT/UNPIVOT](https://www.geeksforgeeks.org/?s=SQL+PIVOT+%2F+UNPIVOT) |
| Set operators | [GeeksForGeeks: Set operators](https://www.geeksforgeeks.org/?s=SQL+Set+operators) |
| UNION | [W3Schools: UNION](https://www.w3schools.com/sql/sql_union.asp) |

---

[← Prev: CTEs & Window Functions](./05-ctes-and-window-functions.md) · [Back to Week 1 →](../README.md)
