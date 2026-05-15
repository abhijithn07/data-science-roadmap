# Note 04 — Subqueries

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The full DQL Intermediate subquery toolkit — every topic from the syllabus:

1. What is a **subquery** and where can it live?
2. **Correlated subqueries** — when the inner query depends on the outer
3. **`EXISTS` / `NOT EXISTS`** — existence-based filtering
4. **`ANY` / `ALL`** — comparing against a set of values
5. **Derived tables** — subqueries used as a table inside `FROM`
6. **`CREATE TABLE AS` / `SELECT INTO`** — saving query results to a new table

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## What Is a Subquery?

A **subquery** (also called *inner query* or *nested query*) is a `SELECT` statement **nested inside another query**. You write the inner query in parentheses, and SQL runs it as part of the outer one.

Subqueries can show up in three places:

| Where it goes | What it returns | Common use |
|---------------|-----------------|------------|
| Inside `WHERE` or `HAVING` | A single value, or a list of values | Filtering against computed values |
| Inside `FROM` | A whole result set (used as a table) | Building an intermediate result to query against |
| Inside `SELECT` | A single value, per row | Adding a calculated column from another query |

**Subqueries by what they return:**

- **Scalar subquery** — returns exactly one row, one column (one value). Can be used like a single number.
- **Multi-row subquery** — returns multiple rows, one column. Used with `IN`, `ANY`, `ALL`, `EXISTS`.
- **Multi-row, multi-column subquery** — returns a full table-shaped result. Used as a derived table in `FROM`.

### Example — Scalar Subquery in WHERE

> *"Find employees earning above the company-wide average salary."*

```sql
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

The inner query `(SELECT AVG(salary) FROM employees)` returns `84375.00` — a single number. The outer query uses it as a comparison value.

| name | salary |
|------|--------|
| Alice Chen | 95000 |
| Bob Patel | 110000 |
| Diana Kim | 88000 |
| Hiroshi Tanaka | 92000 |

### Example — Subquery with IN

> *"Find employees whose department is located in Tampa."*

```sql
SELECT name FROM employees
WHERE department_id IN (
    SELECT id FROM departments WHERE location = 'Tampa'
);
```

The inner query returns the IDs of Tampa-located departments (Engineering and HR — `1` and `4`). The outer query then filters employees by those IDs.

| name |
|------|
| Alice Chen |
| Bob Patel |
| Ethan Brown |
| Fatima Ali |

> **Beginner tip:** subqueries that return one value can be used anywhere a literal value would work. Subqueries that return many values need `IN`, `ANY`, `ALL`, or `EXISTS`.

---

## 2. Correlated Subqueries

A **correlated subquery** *references the outer query* — so it runs **once per row** of the outer query, with the outer row's values plugged in.

This is fundamentally different from the non-correlated examples above, where the inner query runs *once* and produces a result the outer query then uses.

### Example

> *"Find employees who are NOT the highest paid in their department."*

```sql
SELECT name, salary, department_id
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees other
    WHERE other.department_id = e.department_id
      AND other.salary > e.salary
);
```

Read this carefully:
- The outer query loops over each employee (aliased as `e`).
- For each one, the inner query asks: *"is there someone else (`other`) in the same department who earns more?"*
- The `e.department_id` and `e.salary` references inside the inner query mean it **depends on the current outer row** — that's what makes it correlated.

Result:

| name | salary | department_id |
|------|--------|---------------|
| Alice Chen | 95000 | 1 |
| Carlos Reyes | 75000 | 2 |
| Diana Kim | 88000 | 3 |
| Ethan Brown | 70000 | 1 |

(Bob, Grace, Hiroshi, and Fatima are each the top earner in their department — Fatima is also the only employee in HR.)

### Performance Note

Correlated subqueries can be slower than non-correlated ones because the inner query runs again for every outer row. Modern databases often optimize them well, but for huge tables a `JOIN` or a CTE is sometimes faster. Don't optimize prematurely though — readability first.

---

## 3. EXISTS / NOT EXISTS

`EXISTS` is a special operator that returns **`TRUE` if a subquery returns at least one row**, and `FALSE` otherwise. It doesn't care about the values — just whether anything matches.

`SELECT 1` is the conventional placeholder you'll see inside `EXISTS` — you only care about *existence*, not the actual data.

### Example — EXISTS

> *"Find employees in a department located in Tampa."*

```sql
SELECT name FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d
    WHERE d.id = e.department_id
      AND d.location = 'Tampa'
);
```

Same result as the `IN` example earlier: Alice, Bob, Ethan, Fatima.

### Example — NOT EXISTS

> *"Find employees whose department is NOT located in Tampa."*

```sql
SELECT name FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d
    WHERE d.id = e.department_id
      AND d.location = 'Tampa'
);
```

Result: Carlos, Diana, Grace, Hiroshi.

### EXISTS vs. IN — When to Use Which

| Pattern | Best for |
|---------|----------|
| `IN (subquery)` | Simple filtering against a list of values |
| `EXISTS (subquery)` | Complex correlated conditions; better with `NULL` values |

The big practical difference: **`NOT IN` can break with `NULL` values** in the inner list (it returns no rows because of three-valued logic), while **`NOT EXISTS` handles `NULL`s safely**. When in doubt for "find rows where the related thing doesn't exist," reach for `NOT EXISTS`.

---

## 4. ANY / ALL

These operators compare a value against *every* row in a subquery's result.

| Operator | Meaning |
|----------|---------|
| `ANY` (also `SOME`) | The condition is true if it's true for **at least one** row in the subquery |
| `ALL` | The condition is true only if it's true for **all** rows in the subquery |

### Example — ANY

> *"Find employees who earn more than ANY Engineering employee"* — i.e., more than the **lowest** Engineering salary.

```sql
SELECT name, salary FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE department_id = 1);
```

Engineering salaries: 95000, 110000, 70000. The minimum is 70000.

So this returns anyone earning more than 70000 — everyone except Ethan (70000 — the minimum itself doesn't count, since it's not *strictly* greater) and Fatima (65000).

Equivalent to: `salary > MIN(engineering_salaries)`.

### Example — ALL

> *"Find employees who earn more than ALL Engineering employees"* — i.e., more than the **highest** Engineering salary.

```sql
SELECT name, salary FROM employees
WHERE salary > ALL (SELECT salary FROM employees WHERE department_id = 1);
```

Engineering salaries: 95000, 110000, 70000. The maximum is 110000.

To beat *all* of them, you need to earn more than 110000 — nobody does. Result: empty.

Equivalent to: `salary > MAX(engineering_salaries)`.

> **Beginner mental model:**
> - `> ANY` ≈ `> MIN`
> - `> ALL` ≈ `> MAX`
> - `= ANY` is the same as `IN`
> - `<> ALL` is the same as `NOT IN`

`ANY` and `ALL` aren't used heavily in practice — usually `IN`, `EXISTS`, or aggregate-based approaches are clearer. But you'll see them in older code and on exams.

---

## 5. Derived Tables

A **derived table** is a subquery used in the `FROM` clause as if it were a real table. You give it an alias and then query it just like any other table.

This is the foundation of "build an intermediate result, then query against it."

### Example

> *"Show departments with average salary above 80,000."*

```sql
SELECT dept_stats.department_id, dept_stats.avg_salary
FROM (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_stats
WHERE dept_stats.avg_salary > 80000;
```

The inner query (`dept_stats`) produces a small result set with each department's average salary. The outer query then filters that.

| department_id | avg_salary |
|---------------|-----------|
| 1 | 91666.67 |
| 3 | 90000.00 |

> **Beginner note:** the alias after the closing `)` is **required** in most dialects — even if you don't reference it.

### Why use a derived table?

- When you can't apply a filter directly (e.g., filtering on the result of `GROUP BY` and `AVG` — which is also what `HAVING` does, but derived tables are more flexible when you need to do *more* than just filter the aggregates).
- When you need to compute a result once, then join/filter against it.

CTEs (covered in [Note 05](./05-ctes-and-window-functions.md)) are usually a cleaner alternative to derived tables — more on that next.

---

## 6. CREATE TABLE AS / SELECT INTO

Two ways to **save a query result as a new permanent table**.

### `CREATE TABLE AS` — Standard SQL

PostgreSQL, MySQL, Oracle (with slight variations):

```sql
CREATE TABLE high_earners AS
SELECT *
FROM employees
WHERE salary > 90000;
```

This creates a new `high_earners` table populated with the query's results. The new table inherits column names and types from the query.

### `SELECT INTO` — SQL Server Style

```sql
SELECT *
INTO high_earners
FROM employees
WHERE salary > 90000;
```

Same effect, different syntax. (In PostgreSQL, `SELECT INTO` is reserved for use *inside* PL/pgSQL procedures — outside, you use `CREATE TABLE AS`.)

### Practical Uses

- **Backups** — snapshot a table before a risky operation:
  ```sql
  CREATE TABLE employees_backup AS SELECT * FROM employees;
  ```
- **Materialized intermediate results** — when a complex query is reused often, save its results to skip recomputing.
- **One-off analysis tables** — quick "let me have this slice as a real table for a moment."

> **Note:** `CREATE TABLE AS` copies the *data* but typically does **not** copy constraints, indexes, or triggers from the source. You'd add those separately.

---

## Putting It All Together

A realistic query combining a derived table with subqueries:

> *"Find employees who earn above their department's average salary, AND whose department is located in Tampa."*

```sql
SELECT e.name, e.salary, dept_avg.avg_salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_avg
  ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
  AND e.department_id IN (
      SELECT id FROM departments WHERE location = 'Tampa'
  );
```

Walking through:
1. Inner derived table `dept_avg` computes each department's average salary.
2. It's joined to `employees` so each employee row has their department's average attached.
3. Filter to employees earning above that average.
4. Final filter: department must be in Tampa.

Result:

| name | salary | avg_salary |
|------|--------|-----------|
| Bob Patel | 110000 | 91666.67 |
| Alice Chen | 95000 | 91666.67 |

(Fatima is in Tampa-located HR but doesn't beat her own department's average since she's the only one — she *is* the average.)

This kind of layered query — derived tables + subqueries in `WHERE` — is heavy syntax. **CTEs (Note 05) make this kind of thing much more readable.**

---

## Key Takeaways

- A **subquery** is a `SELECT` nested inside another query — in `WHERE`, `FROM`, or `SELECT`.
- **Non-correlated** subqueries run once. **Correlated** subqueries reference the outer row and run once per outer row.
- **`EXISTS` / `NOT EXISTS`** check whether a subquery returns any rows — values don't matter, only existence.
- `NOT EXISTS` is safer than `NOT IN` when `NULL`s are possible.
- **`ANY`** ≈ "more than the minimum"; **`ALL`** ≈ "more than the maximum". `= ANY` is the same as `IN`.
- **Derived tables** are subqueries inside `FROM`, used like real tables. They need an alias.
- **`CREATE TABLE AS`** (standard) / **`SELECT INTO`** (SQL Server) save a query's result to a new table.

## Quick Self-Check

1. What's the difference between a **correlated** and a **non-correlated** subquery?
2. Why is `NOT EXISTS` often preferred over `NOT IN`?
3. Write a query using `EXISTS` to find departments that have at least one employee.
4. What's the result of `WHERE salary > ALL (SELECT salary FROM employees)` for any employee?
5. What's the difference between a **derived table** and a **CTE** (we'll meet CTEs next)?
6. Why does a derived table require an alias?
7. After running `CREATE TABLE high_earners AS SELECT * FROM employees`, do `employees` and `high_earners` stay in sync if you update `employees`?

## Further Reading

| Topic | Reference |
|-------|-----------|
| Subqueries | [GeeksForGeeks: Subqueries](https://www.geeksforgeeks.org/?s=SQL+Subqueries) |
| Correlated subqueries | [GeeksForGeeks: Correlated subqueries](https://www.geeksforgeeks.org/?s=SQL+Correlated+subqueries) |
| EXISTS | [W3Schools: EXISTS](https://www.w3schools.com/sql/sql_exists.asp) |
| ANY / ALL | [W3Schools: ANY/ALL](https://www.w3schools.com/sql/sql_any_all.asp) |
| Derived tables | [GeeksForGeeks: Derived tables](https://www.geeksforgeeks.org/?s=SQL+Derived+tables) |
| SELECT INTO / CREATE TABLE AS | [GeeksForGeeks](https://www.geeksforgeeks.org/?s=SQL+SELECT+INTO+%2F+CREATE+TABLE+AS) |

---

[← Prev: Aggregation & CASE](./03-aggregation-and-case.md) · [Next: CTEs & Window Functions →](./05-ctes-and-window-functions.md)
