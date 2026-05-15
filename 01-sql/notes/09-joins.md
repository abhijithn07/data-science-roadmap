# Note 09 — Joins

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The whole **Joins & Relationships** category — 11 topics that turn separate tables into combined data:

1. **Why joins?** — normalization in plain language
2. **`INNER JOIN`** — the workhorse
3. **`LEFT JOIN`**
4. **`RIGHT JOIN`**
5. **`FULL OUTER JOIN`**
6. **`CROSS JOIN`**
7. **`SELF JOIN`**
8. **Multi-table joins** — chaining 3+ tables
9. **Joining aggregated data**
10. **Join conditions and join order** — `ON` vs `WHERE`, why outer-join order matters
11. **Referential integrity basics**
12. **Many-to-many relationships** — junction tables

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql), plus two new tables (`projects` + `assignments`) introduced below.

---

## 1. Why Joins?

Look at the `employees` table. It has a `department_id` column with values like `1`, `2`, `3`. By itself, that's not useful — "Alice is in department 1" tells you nothing meaningful. The actual department name lives in a separate `departments` table.

This split is deliberate. It's called **normalization** — storing each piece of information *once* so it can't get out of sync. If "Engineering" gets renamed to "Software," you update it in one place, not in every employee row.

The price of normalization: to answer "what department is Alice in?" you have to **combine** the two tables. That's what joins do.

> **Mental model:** a join is a stitching operation — *"for each row in table A, find matching rows in table B, and combine them side-by-side."*

---

## 2. Setting Up Extra Tables

For multi-table and many-to-many examples, we'll add two more tables: `projects` and `assignments`.

```sql
CREATE TABLE projects (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    budget DECIMAL(10, 2)
);

CREATE TABLE assignments (
    employee_id INTEGER REFERENCES employees(id),
    project_id INTEGER REFERENCES projects(id),
    hours_per_week INTEGER,
    PRIMARY KEY (employee_id, project_id)
);

INSERT INTO projects (id, name, budget) VALUES
    (1, 'Migration to Cloud',    500000),
    (2, 'Mobile App v2',         300000),
    (3, 'Analytics Platform',    200000),
    (4, 'Customer Portal',       150000);

INSERT INTO assignments (employee_id, project_id, hours_per_week) VALUES
    (1, 1, 20),   -- Alice on Cloud
    (1, 3, 15),   -- Alice on Analytics
    (2, 1, 30),   -- Bob on Cloud
    (3, 2, 25),   -- Carlos on Mobile
    (4, 3, 40),   -- Diana on Analytics
    (6, 2, 20),   -- Fatima on Mobile
    (7, 2, 15),   -- Grace on Mobile
    (8, 1, 35);   -- Hiroshi on Cloud
```

**Key observations** for the examples:
- **Alice** is on **two** projects (Cloud + Analytics)
- **Ethan** is on **no** project
- **Customer Portal** (project 4) has **no** assignments
- `assignments` is a **junction table** linking employees to projects (many-to-many — see §12)

---

## 3. INNER JOIN — Only the Matches

`INNER JOIN` (or just `JOIN`) returns rows where the join condition matches in **both** tables. Rows without a match are dropped from both sides.

### Basic syntax

```sql
SELECT <columns>
FROM   table_a
INNER JOIN table_b
  ON   table_a.column = table_b.column;
```

### Example

```sql
SELECT employees.name, departments.name AS department
FROM employees
INNER JOIN departments
  ON employees.department_id = departments.id;
```

| name | department |
|------|-----------|
| Alice Chen | Engineering |
| Bob Patel | Engineering |
| Carlos Reyes | Marketing |
| Diana Kim | Sales |
| Ethan Brown | Engineering |
| Fatima Ali | HR |
| Grace Liu | Marketing |
| Hiroshi Tanaka | Sales |

All 8 employees show up because every employee has a valid `department_id`. If anyone had `department_id = NULL` or a value that didn't exist in `departments`, they'd be dropped.

### Table Aliases for Readability

Typing the full table name everywhere gets old. Use short aliases:

```sql
SELECT e.name, d.name AS department
FROM employees e
INNER JOIN departments d
  ON e.department_id = d.id;
```

`e` and `d` are nicknames that only exist inside this query. Standard practice in real-world SQL.

> **Beginner tip:** when both tables have a column with the same name (here, both have `name`), prefix with the table or alias (`e.name`, `d.name`) so SQL knows which one you mean.

---

## 4. LEFT JOIN — Keep All of the Left Table

`LEFT JOIN` (also written `LEFT OUTER JOIN`) returns **all rows from the left table**, even when there's no match in the right table. Where there's no match, the right-side columns come back as `NULL`.

```sql
SELECT e.name, a.project_id, a.hours_per_week
FROM employees e
LEFT JOIN assignments a
  ON e.id = a.employee_id
ORDER BY e.name;
```

| name | project_id | hours_per_week |
|------|-----------|----------------|
| Alice Chen | 1 | 20 |
| Alice Chen | 3 | 15 |
| Bob Patel | 1 | 30 |
| Carlos Reyes | 2 | 25 |
| Diana Kim | 3 | 40 |
| Ethan Brown | NULL | NULL |
| Fatima Ali | 2 | 20 |
| Grace Liu | 2 | 15 |
| Hiroshi Tanaka | 1 | 35 |

Notice:
- **Alice appears twice** — she's on two projects.
- **Ethan appears once** with `NULL`s on the right — he's on no projects, but `LEFT JOIN` keeps him anyway.

### Finding "missing" matches

A classic use of `LEFT JOIN` — find rows in the left table with **no** match on the right:

```sql
-- "Which employees are on no project?"
SELECT e.name
FROM employees e
LEFT JOIN assignments a ON e.id = a.employee_id
WHERE a.employee_id IS NULL;
```

Result: Ethan Brown.

> **Pattern to remember:** `LEFT JOIN ... WHERE right.column IS NULL` = "find rows in the left table that don't have a match." Comes up constantly in real queries.

---

## 5. RIGHT JOIN — Keep All of the Right Table

`RIGHT JOIN` (or `RIGHT OUTER JOIN`) is the mirror image of `LEFT JOIN` — it keeps all rows from the **right** table, even unmatched ones.

```sql
-- "Show every project, plus assigned employees — including projects with no one assigned."
SELECT p.name AS project, e.name AS employee
FROM employees e
RIGHT JOIN assignments a ON e.id = a.employee_id
RIGHT JOIN projects p ON a.project_id = p.id;
```

### Why you'll rarely use RIGHT JOIN

In practice, **`RIGHT JOIN` is rarely used** — most people swap the table order and use `LEFT JOIN` instead. These two queries are equivalent:

```sql
SELECT * FROM a LEFT  JOIN b ON a.x = b.x;
SELECT * FROM b RIGHT JOIN a ON a.x = b.x;
```

> **Real-world advice:** stick with `LEFT JOIN`. It's easier to read because the "primary" table is on the left, which matches the natural reading order. `RIGHT JOIN` exists for completeness — you'll see it occasionally in older code.

---

## 6. FULL OUTER JOIN — Keep Everything from Both

`FULL OUTER JOIN` returns **all rows from both tables**. Where there's a match, rows are joined; where there isn't, the missing side comes back as `NULL`.

```sql
SELECT p.name AS project, a.employee_id, a.hours_per_week
FROM projects p
FULL OUTER JOIN assignments a ON p.id = a.project_id;
```

Useful when you want to find **mismatches in either direction** — e.g., projects with no employees AND assignments referencing missing projects.

> **Dialect note:** MySQL doesn't support `FULL OUTER JOIN` directly — simulate it with a `UNION` of a `LEFT JOIN` and a `RIGHT JOIN`. PostgreSQL, SQL Server, Oracle, and SQLite all support it.

---

## 7. CROSS JOIN — Every Combination

`CROSS JOIN` returns the **Cartesian product** of two tables — every row in A paired with every row in B. **No `ON` clause needed** because there's no matching condition.

```sql
SELECT e.name, p.name AS project
FROM employees e
CROSS JOIN projects p;
```

With 8 employees and 4 projects, this returns 8 × 4 = **32 rows**.

**When is this useful?** Rarely on its own. Common real uses:
- Generating combinations for testing (e.g., all employee × week pairs to build a schedule template)
- Joining a tiny lookup table to every row (e.g., applying a constant tax rate)
- Generating date ranges with a date table

> **Beginner gotcha:** accidentally writing a `CROSS JOIN` by forgetting `ON` in an inner join (`FROM a, b` without a `WHERE` linking them) explodes your row count to millions. Always make joins explicit with `JOIN ... ON`.

---

## 8. SELF JOIN — Join a Table to Itself

A **self join** is a regular join where both sides are the same table — using aliases to tell them apart. It's how SQL handles **hierarchical** or **same-table relationship** queries.

The classic example: an org chart with a `manager_id` column pointing back into the same `employees` table. Our `employees` table doesn't have that — but imagine it did:

```sql
-- Hypothetical: employees has a manager_id column
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

Each row pairs an employee with their manager — both pulled from the same table, aliased as `e` and `m`.

### A real example with our data

Find pairs of employees in the same department (excluding pairing a row with itself, and avoiding duplicate pairs):

```sql
SELECT e1.name AS employee_a, e2.name AS employee_b, e1.department_id
FROM employees e1
JOIN employees e2
  ON e1.department_id = e2.department_id
 AND e1.id < e2.id        -- avoids X paired with X, and X-Y duplicated as Y-X
ORDER BY e1.department_id, e1.name;
```

Result — pairs of co-workers in the same department.

---

## 9. Multi-Table Joins

Chaining 3+ tables is just stacking more `JOIN ... ON` clauses.

```sql
SELECT e.name AS employee,
       d.name AS department,
       p.name AS project,
       a.hours_per_week
FROM employees e
JOIN departments d ON e.department_id = d.id
JOIN assignments a ON e.id = a.employee_id
JOIN projects p    ON a.project_id = p.id
ORDER BY e.name;
```

Result — each (employee × project) combination, enriched with department and project names. **8 rows** (the number of assignments).

### Reading the chain

Each `JOIN` builds on the running result. Mentally:
1. Start with `employees` (8 rows).
2. Add department columns → still 8 rows (one per employee).
3. Inner join `assignments` → Ethan drops out (no assignment), Alice doubles up (2 assignments) → 8 rows.
4. Add project columns → still 8 rows.

> **Beginner tip:** when joining many tables, mix `INNER JOIN` and `LEFT JOIN` deliberately. Use `LEFT JOIN` if you want to *preserve* rows even when later joins don't match. Use `INNER JOIN` if a missing match means the row should be dropped.

---

## 10. Joining Aggregated Data

A super-common pattern: aggregate one table, then join the result to another.

> *"For each department, show how many distinct projects its employees are working on."*

Aggregate the join of `employees + assignments` first, then join the result to `departments`:

```sql
WITH dept_project_counts AS (
    SELECT e.department_id,
           COUNT(DISTINCT a.project_id) AS num_projects
    FROM employees e
    JOIN assignments a ON e.id = a.employee_id
    GROUP BY e.department_id
)
SELECT d.name AS department,
       COALESCE(dpc.num_projects, 0) AS num_projects
FROM departments d
LEFT JOIN dept_project_counts dpc ON d.id = dpc.department_id;
```

The CTE produces one row per department. Then we `LEFT JOIN` it back to `departments` so even departments with no project work still show up (with `COALESCE` turning `NULL` counts into `0`).

> **Pattern:** aggregate first (in a CTE or subquery), then join. Trying to aggregate inside a multi-join often gives wrong totals due to row duplication. Aggregate to your desired grain, *then* combine.

---

## 11. Join Conditions and Join Order

Two subtle topics that trip people up.

### ON vs. WHERE

In an **inner join**, `ON` and `WHERE` are functionally similar — both filter rows. But in an **outer join** (LEFT/RIGHT/FULL), they're very different:

- **`ON` condition** is applied *during* the join (which rows get matched).
- **`WHERE` condition** is applied *after* the join (filtering the combined result).

```sql
-- A: condition in ON
SELECT e.name, a.project_id
FROM employees e
LEFT JOIN assignments a ON e.id = a.employee_id AND a.project_id = 1;
-- Keeps ALL employees; pairs them with their assignment to project 1 if any.
-- Ethan still appears (with NULL); so does anyone not on project 1.

-- B: condition in WHERE
SELECT e.name, a.project_id
FROM employees e
LEFT JOIN assignments a ON e.id = a.employee_id
WHERE a.project_id = 1;
-- LEFT JOIN happens first (includes everyone), THEN WHERE drops any row
-- where project_id != 1, including Ethan (his NULL fails the WHERE).
-- Effectively turns the LEFT JOIN into an INNER JOIN.
```

> **Rule of thumb:** if you want a condition to *not* turn an outer join into an inner join, put it in `ON`, not `WHERE`.

### Join Order Matters for Outer Joins

The order you write joins can change the result for outer joins:

```sql
FROM employees e LEFT JOIN assignments a ...  -- keeps all employees
FROM assignments a LEFT JOIN employees e ...  -- keeps all assignments
```

For inner joins, order doesn't change the *result* — though it can affect performance (the database's planner usually picks the best order automatically).

---

## 12. Referential Integrity Basics

**Referential integrity** is the database property that says: **if column A in table 1 references column B in table 2, every value in A must actually exist in B** — no orphan rows.

Foreign keys (covered in [Note 08 — DDL §11](./08-ddl.md)) are what enforce this. Without referential integrity:
- You might have an employee with `department_id = 99` when there's no department 99.
- A join wouldn't *break* the database, but the orphan row gets dropped silently — leading to wrong counts and broken reports.

### How Foreign Keys Enforce It

```sql
CREATE TABLE assignments (
    employee_id INTEGER REFERENCES employees(id),
    project_id INTEGER REFERENCES projects(id),
    ...
);
```

After this:
- You **can't** insert an assignment for an employee that doesn't exist — the database rejects it.
- You **can't** delete an employee who has assignments — unless you specified `ON DELETE CASCADE` or `SET NULL` (see [Note 08, §11](./08-ddl.md)).

> Referential integrity matters for *correctness*. When it's enforced, your joins always work as expected.

---

## 13. Many-to-Many Relationships

Most real-world relationships are **many-to-many**:
- One employee works on many projects; one project has many employees.
- One student takes many courses; one course has many students.
- One order has many products; one product appears in many orders.

SQL doesn't have a "many-to-many" type. You model it with a **junction table** (also called *associative table* or *link table*) that has foreign keys to both sides.

```sql
CREATE TABLE assignments (
    employee_id INTEGER REFERENCES employees(id),
    project_id INTEGER REFERENCES projects(id),
    hours_per_week INTEGER,
    PRIMARY KEY (employee_id, project_id)
);
```

The composite primary key `(employee_id, project_id)` guarantees the same employee can't be assigned to the same project twice.

### Querying a many-to-many relationship

To answer *"what projects is Alice on?"*:

```sql
SELECT p.name
FROM assignments a
JOIN projects p ON a.project_id = p.id
WHERE a.employee_id = 1;
```

Result: Migration to Cloud, Analytics Platform.

To answer *"how many employees on each project?"*:

```sql
SELECT p.name, COUNT(a.employee_id) AS num_employees
FROM projects p
LEFT JOIN assignments a ON p.id = a.project_id
GROUP BY p.name;
```

The `LEFT JOIN` makes sure projects with zero employees (Customer Portal) still appear, with count = 0.

### Adding attributes to the relationship

A junction table is also where **relationship attributes** live — info that doesn't belong to either side, but to the combination.

In our `assignments` table, `hours_per_week` is a relationship attribute. It doesn't make sense as a column on `employees` (an employee has many hours, depending on the project) or on `projects` (a project has many hours, depending on the employee). It belongs to the *combination*.

---

## Putting It All Together

A realistic query combining most of this note:

> *"For each department, show: the department name, how many employees it has, the total weekly hours those employees are committed to across all projects, and the highest single project budget anyone in the department is assigned to."*

```sql
SELECT
    d.name AS department,
    COUNT(DISTINCT e.id) AS num_employees,
    COALESCE(SUM(a.hours_per_week), 0) AS total_hours,
    MAX(p.budget) AS biggest_project_budget
FROM departments d
LEFT JOIN employees e   ON e.department_id = d.id
LEFT JOIN assignments a ON a.employee_id = e.id
LEFT JOIN projects p    ON p.id = a.project_id
GROUP BY d.name
ORDER BY total_hours DESC;
```

This uses 4 tables, `LEFT JOIN`s (to keep all departments), aggregation, and `COALESCE` (to handle `NULL` sums).

---

## Key Takeaways

- **Joins combine tables horizontally** based on a matching column. Normalization splits data; joins re-combine it.
- **`INNER JOIN`** keeps only matched rows. **`LEFT JOIN`** keeps all left rows. **`RIGHT JOIN`** keeps all right rows (rarely used — flip and use LEFT). **`FULL OUTER`** keeps everything.
- **`CROSS JOIN`** = every combination. Useful intentionally, dangerous accidentally.
- **`SELF JOIN`** = joining a table to itself with aliases. For hierarchies or same-table comparisons.
- **Multi-table joins** chain `JOIN ... ON` clauses; mix INNER and LEFT deliberately.
- **Aggregate then join** for correctness on grouped questions — don't aggregate inside a wide join.
- In **outer joins**, conditions in `ON` apply during matching; in `WHERE` they apply after. They're not interchangeable.
- **Referential integrity** (via foreign keys) prevents orphan rows.
- **Many-to-many** relationships need a **junction table** with foreign keys to both sides. Relationship attributes live in the junction.

## Quick Self-Check

1. What's the difference between `INNER JOIN` and `LEFT JOIN`?
2. Why is `RIGHT JOIN` rarely used?
3. What's the result of a `CROSS JOIN` between a 5-row table and a 10-row table?
4. Write a query to find departments that have **no** employees.
5. In a `LEFT JOIN`, what's the difference between putting a condition in `ON` vs. `WHERE`?
6. What is a junction table, and why do you need one for many-to-many?
7. What does "referential integrity" mean in plain words?

## Further Reading

| Topic | Reference |
|-------|-----------|
| INNER JOIN | [W3Schools: INNER JOIN](https://www.w3schools.com/sql/sql_join_inner.asp) |
| LEFT JOIN | [W3Schools: LEFT JOIN](https://www.w3schools.com/sql/sql_join_left.asp) |
| RIGHT JOIN | [W3Schools: RIGHT JOIN](https://www.w3schools.com/sql/sql_join_right.asp) |
| FULL OUTER JOIN | [W3Schools: FULL OUTER JOIN](https://www.w3schools.com/sql/sql_join_full.asp) |
| CROSS JOIN | [GeeksForGeeks: CROSS JOIN](https://www.geeksforgeeks.org/sql-cross-join/) |
| SELF JOIN | [W3Schools: SELF JOIN](https://www.w3schools.com/sql/sql_join_self.asp) |
| Many-to-many | [GeeksForGeeks: Many-to-many in SQL](https://www.geeksforgeeks.org/types-of-relationships-in-database/) |

---

[← Prev: DDL](./08-ddl.md) · [Next: Functions & Programming →](./10-functions-and-programming.md)
