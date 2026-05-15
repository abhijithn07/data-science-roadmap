# Note 08 — DDL (Defining Tables, Constraints, Indexes & Views)

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The entire **DDL** category — 19 topics — organized into four parts:

**Tables:**
1. What is DDL?
2. `CREATE TABLE`
3. `ALTER TABLE`
4. `DROP TABLE`
5. `TRUNCATE TABLE`
6. `RENAME TABLE` / `RENAME COLUMN`

**Constraints (rules on the data):**
7. Constraints overview
8. `NOT NULL`
9. `UNIQUE`
10. `PRIMARY KEY`
11. `FOREIGN KEY`
12. `CHECK`
13. `DEFAULT`
14. `AUTO_INCREMENT` / `IDENTITY` / `SEQUENCE`

**Indexes (speeding up queries):**

15. `CREATE INDEX`
16. `DROP` / `ALTER` / `REBUILD INDEX`

**Views, schemas, temp tables:**

17. `CREATE VIEW` / `ALTER VIEW` / `DROP VIEW`
18. `CREATE SCHEMA`
19. Temporary tables

All examples use (or extend) the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## 1. What Is DDL?

**DDL** = **Data Definition Language**. It's the family of SQL commands that define and change the *structure* of your database — the tables, columns, constraints, indexes, views — not the data inside them.

| Command | What it does |
|---------|--------------|
| `CREATE` | Make a new table, view, index, schema |
| `ALTER` | Change an existing one (add a column, modify a type, rename) |
| `DROP` | Delete the entire object (the table itself, not its rows) |
| `TRUNCATE` | Wipe all rows from a table — fast, no `WHERE` |

> DDL is different from **DML** ([Note 07](./07-dml.md)), which changes the *data* inside tables. DDL changes the *containers*.

---

# Part 1 — Tables

## 2. CREATE TABLE

The most fundamental DDL command. The shape:

```sql
CREATE TABLE <table_name> (
    <column1> <data_type> [<constraints>],
    <column2> <data_type> [<constraints>],
    ...
);
```

### Example

```sql
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id),
    salary DECIMAL(10, 2),
    hire_date DATE,
    city TEXT
);
```

Reading the column definitions:
- `id INTEGER PRIMARY KEY` — a whole number that uniquely identifies each row
- `name TEXT NOT NULL` — text required (can't be blank)
- `salary DECIMAL(10, 2)` — up to 10 total digits, 2 after the decimal point
- `department_id INTEGER REFERENCES departments(id)` — a foreign key (covered in §11)

### CREATE TABLE IF NOT EXISTS

Avoid errors when the table might already exist:

```sql
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY,
    ...
);
```

## 3. ALTER TABLE

`ALTER TABLE` changes a table that already exists — adding or removing columns, changing types, adding constraints.

### Add a column

```sql
ALTER TABLE employees ADD COLUMN email TEXT;
```

The column is added with all `NULL` values for existing rows (unless you give it a `DEFAULT`).

### Drop a column

```sql
ALTER TABLE employees DROP COLUMN email;
```

### Change a column's data type

```sql
-- PostgreSQL:
ALTER TABLE employees ALTER COLUMN salary TYPE DECIMAL(12, 2);

-- MySQL:
ALTER TABLE employees MODIFY COLUMN salary DECIMAL(12, 2);

-- SQL Server:
ALTER TABLE employees ALTER COLUMN salary DECIMAL(12, 2);
```

### Add a constraint

```sql
ALTER TABLE employees ADD CONSTRAINT salary_positive CHECK (salary > 0);
```

### Rename a column

```sql
ALTER TABLE employees RENAME COLUMN city TO location;
```

### Rename a table

```sql
ALTER TABLE employees RENAME TO staff;
-- Or in MySQL: RENAME TABLE employees TO staff;
```

> **Dialect note:** the exact `ALTER` syntax varies more than most SQL. When in doubt, check your database's docs.

## 4. DROP TABLE

Remove the entire table — structure *and* all data.

```sql
DROP TABLE employees;
```

### DROP TABLE IF EXISTS

Avoid an error if the table doesn't exist:

```sql
DROP TABLE IF EXISTS employees;
```

> **Be very careful with `DROP`.** There's no `WHERE`. There's no confirmation. The table is gone. In production, this is one of the most dangerous commands you can run.

### CASCADE — drop dependents too

If other objects (foreign keys, views) reference the table, you may need `CASCADE`:

```sql
DROP TABLE departments CASCADE;
-- Drops departments and anything that references it
```

## 5. TRUNCATE TABLE

`TRUNCATE` removes **all rows** from a table — but keeps the table itself. It's much faster than `DELETE` because it doesn't log each row removal.

```sql
TRUNCATE TABLE employees;
```

### TRUNCATE vs. DELETE

| | TRUNCATE | DELETE |
|--|----------|--------|
| Can use `WHERE`? | No | Yes |
| Speed | Very fast | Slower (per-row) |
| Logging | Minimal | Each row logged |
| Rollback safe? | Sometimes not (dialect-dependent) | Yes, in transactions |
| Resets auto-increment counter? | Yes (usually) | No |

Use `TRUNCATE` for "wipe everything" operations like clearing staging tables. Use `DELETE` for "remove rows matching a condition."

## 6. RENAME TABLE / COLUMN

Covered as part of `ALTER` above. The two shapes you'll use most:

```sql
ALTER TABLE employees RENAME COLUMN city TO location;
ALTER TABLE employees RENAME TO staff;
```

---

# Part 2 — Constraints

## 7. Constraints Overview

**Constraints** are rules attached to columns that the database enforces. They keep your data clean and consistent by **rejecting invalid changes before they happen**.

| Constraint | What it enforces |
|-----------|------------------|
| **`NOT NULL`** | The column can't be `NULL` |
| **`UNIQUE`** | All values in the column (or set of columns) must differ |
| **`PRIMARY KEY`** | `UNIQUE` + `NOT NULL`; identifies each row |
| **`FOREIGN KEY`** | Value must exist in another table's column |
| **`CHECK`** | Custom condition every row must satisfy |
| **`DEFAULT`** | Auto-fills the column if no value provided |

Constraints can be defined **inline** (within the column) or as **table-level constraints**:

```sql
-- Inline:
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0)
);

-- Table-level (useful for multi-column constraints):
CREATE TABLE employees (
    id INTEGER,
    name TEXT NOT NULL,
    salary DECIMAL(10,2),
    CONSTRAINT pk_employees PRIMARY KEY (id),
    CONSTRAINT salary_positive CHECK (salary > 0)
);
```

Naming constraints (e.g., `pk_employees`) makes them easier to reference later when dropping or altering.

## 8. NOT NULL

The column **must have a value** — `NULL` is not allowed.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,    -- name is required
    salary DECIMAL(10,2)   -- salary can be NULL
);
```

Trying to `INSERT` a `NULL` into a `NOT NULL` column throws an error.

### Adding NOT NULL to an existing column

```sql
-- PostgreSQL:
ALTER TABLE employees ALTER COLUMN name SET NOT NULL;

-- MySQL:
ALTER TABLE employees MODIFY COLUMN name TEXT NOT NULL;
```

If existing rows have `NULL`s, this fails until you fix them (typically with `UPDATE ... SET ... WHERE col IS NULL`).

## 9. UNIQUE

All values in the column must be distinct — **no duplicates allowed**. `NULL`s are typically allowed and aren't treated as duplicates of each other.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE       -- no two employees can share an email
);
```

### Multi-column unique constraint

The combination of columns must be unique — individual columns can repeat:

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    UNIQUE (student_id, course_id)    -- combination must be unique
);
```

A student can be in many courses, a course has many students, but the same student can't enroll in the same course twice.

## 10. PRIMARY KEY

A **primary key** is the column (or combination of columns) that **uniquely identifies each row**. It's `UNIQUE` + `NOT NULL` combined.

A table has **at most one** primary key.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
```

### Composite primary key — multiple columns

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrolled_at DATE,
    PRIMARY KEY (student_id, course_id)
);
```

Each `(student_id, course_id)` combination uniquely identifies a row.

### Why primary keys matter

- Other tables reference them via **foreign keys**.
- They typically have a **clustered index** automatically — fast lookups.
- They make joins and updates unambiguous.

## 11. FOREIGN KEY

A **foreign key** says a column's value must **exist as a primary key in another table**. This is what links tables together and keeps the data **consistent** — a property called *referential integrity*.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id)
);
```

Now any `department_id` you insert into `employees` must already exist as an `id` in `departments`. The database rejects orphan rows.

### ON DELETE and ON UPDATE actions

What happens when the referenced row in the parent table is deleted or updated?

```sql
CREATE TABLE employees (
    ...
    department_id INTEGER REFERENCES departments(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

Common actions:

| Action | Meaning |
|--------|---------|
| `NO ACTION` (default) | Prevent the change |
| `RESTRICT` | Same — explicitly prevent it |
| `CASCADE` | Apply the change here too (delete the dependent rows, etc.) |
| `SET NULL` | Set the foreign key column to `NULL` |
| `SET DEFAULT` | Set it to its `DEFAULT` value |

## 12. CHECK

A **CHECK constraint** is a custom rule — any expression that must be true for every row.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    hire_date DATE CHECK (hire_date <= CURRENT_DATE)
);
```

CHECK constraints catch logical errors (negative salary, future hire date) at the database level — defense in depth on top of any application validation.

## 13. DEFAULT

A **DEFAULT** auto-fills a column when an `INSERT` doesn't provide a value.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT DEFAULT 'Remote',
    hire_date DATE DEFAULT CURRENT_DATE
);
```

Now if you omit `city` from an `INSERT`, it becomes `Remote`. Omit `hire_date`, it becomes today.

Useful with computed defaults like `CURRENT_DATE`, `CURRENT_TIMESTAMP`, or UUID generators.

## 14. AUTO_INCREMENT / IDENTITY / SEQUENCE

A way to **automatically generate unique integer values** for a column — typically the primary key. The syntax varies a lot by dialect:

| Dialect | Syntax |
|---------|--------|
| **MySQL** | `id INTEGER AUTO_INCREMENT PRIMARY KEY` |
| **SQL Server** | `id INTEGER IDENTITY(1,1) PRIMARY KEY` |
| **PostgreSQL** | `id SERIAL PRIMARY KEY` (newer: `GENERATED ALWAYS AS IDENTITY`) |
| **Oracle** | A separate `SEQUENCE` object, or `IDENTITY` (12c+) |
| **SQLite** | `id INTEGER PRIMARY KEY AUTOINCREMENT` |

```sql
-- PostgreSQL:
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,    -- auto-generates 1, 2, 3...
    name TEXT NOT NULL
);

-- Then you can omit id when inserting:
INSERT INTO employees (name) VALUES ('Alice');  -- gets id=1
INSERT INTO employees (name) VALUES ('Bob');    -- gets id=2
```

> **Sequences** are a separate database object that generates numbers — used internally by `IDENTITY`/`AUTO_INCREMENT`, but you can also use them directly (e.g., for a non-PK column).

---

# Part 3 — Indexes

## 15. CREATE INDEX

An **index** is a data structure (usually a B-tree) that lets the database find rows fast for specific columns — without scanning every row.

**Without an index:** `WHERE name = 'Alice'` requires scanning every row.
**With an index on `name`:** the database jumps directly to matching rows.

### Basic syntax

```sql
CREATE INDEX idx_employees_city ON employees(city);
```

After this, queries like `WHERE city = 'Tampa'` are dramatically faster on large tables.

### Multi-column index

```sql
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
```

This helps queries that filter on `department_id` (and especially those that filter on both `department_id` AND `salary`). **Column order matters** — this index doesn't help queries that filter on `salary` alone.

### Unique index

```sql
CREATE UNIQUE INDEX idx_employees_email ON employees(email);
```

Same effect as a `UNIQUE` constraint, plus the speed of an index.

### When to add an index

Add an index when:
- You query a column frequently with `WHERE` or `JOIN`
- The column has many distinct values
- The table has lots of rows (indexes don't matter much on tiny tables)

**Don't** add indexes when:
- The column is rarely filtered on
- You write to the table heavily (indexes slow down INSERT/UPDATE/DELETE)
- The table is small

> **Rule of thumb:** indexes trade write speed for read speed. Use them where reads dominate.

## 16. DROP / ALTER / REBUILD INDEX

### DROP INDEX

```sql
-- PostgreSQL / SQL Server:
DROP INDEX idx_employees_city;

-- MySQL:
DROP INDEX idx_employees_city ON employees;
```

### ALTER / REBUILD

Most databases don't expose much "alter index" — you typically drop and recreate.

**Rebuilding** an index defragments it. Useful after lots of inserts/deletes:

```sql
-- PostgreSQL:
REINDEX INDEX idx_employees_city;

-- SQL Server:
ALTER INDEX idx_employees_city ON employees REBUILD;
```

Rarely needed in everyday work — the database usually handles it automatically.

---

# Part 4 — Views, Schemas, Temp Tables

## 17. Views

A **view** is a **saved SELECT query** that you can query like a table. It doesn't store data — it runs the underlying query each time you reference it.

### CREATE VIEW

```sql
CREATE VIEW engineering_employees AS
SELECT id, name, salary, hire_date
FROM employees
WHERE department_id = 1;
```

Then anyone can query it like a table:

```sql
SELECT * FROM engineering_employees;
SELECT AVG(salary) FROM engineering_employees;
```

### Why use views?

- **Hide complexity** — bury a complex join behind a simple name.
- **Security** — give users access to a view that exposes only safe columns or filtered rows.
- **Reusability** — define the logic once, use it everywhere.

### ALTER VIEW / DROP VIEW

```sql
-- Most dialects: drop and recreate
DROP VIEW engineering_employees;

-- Or CREATE OR REPLACE (PostgreSQL/MySQL):
CREATE OR REPLACE VIEW engineering_employees AS
SELECT id, name, salary, hire_date, city
FROM employees
WHERE department_id = 1;
```

### Materialized views (briefly)

A **materialized view** (PostgreSQL, Oracle) actually **stores** the query result, like a cached table. Faster to read, but you have to refresh it manually when underlying data changes. Useful for expensive queries that run repeatedly.

## 18. CREATE SCHEMA

A **schema** is a namespace inside a database — a way to group related tables, views, and functions.

```sql
CREATE SCHEMA analytics;

CREATE TABLE analytics.daily_revenue (
    date DATE PRIMARY KEY,
    revenue DECIMAL(15, 2)
);

SELECT * FROM analytics.daily_revenue;
```

Why use schemas?
- **Organization** — separate concerns (transactional tables vs. analytics tables)
- **Permissions** — grant access at the schema level
- **Avoiding name collisions** — `analytics.users` and `app.users` can coexist

> **Dialect note:** in **MySQL**, "schema" and "database" are essentially synonyms. In **PostgreSQL**, **SQL Server**, and **Oracle**, a database contains many schemas.

## 19. Temporary Tables

A **temporary table** exists only for the duration of your session (or transaction). It's created the same way as a regular table, but with `TEMPORARY` (or `TEMP`):

```sql
CREATE TEMPORARY TABLE temp_high_earners AS
SELECT * FROM employees WHERE salary > 90000;

SELECT * FROM temp_high_earners;
-- Use it just like any table

-- It disappears when your session ends — no DROP needed.
```

Useful for:
- Breaking complex multi-step queries into named intermediate results
- Avoiding lock contention on real tables
- Sandboxing experiments

> **Tip:** CTEs ([Note 05](./05-ctes-and-window-functions.md)) often replace temporary tables for simple cases. Temp tables are better when the same intermediate result is used many times across queries in a session.

---

## Putting It All Together

A realistic DDL script — defining the schema for our example data, plus an index and a view:

```sql
-- 1. Tables with constraints
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    location TEXT
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    salary DECIMAL(10, 2) CHECK (salary > 0),
    hire_date DATE DEFAULT CURRENT_DATE,
    city TEXT DEFAULT 'Remote'
);

-- 2. Index for the most common filter
CREATE INDEX idx_employees_dept ON employees(department_id);

-- 3. Convenience view that joins the two tables
CREATE VIEW employee_with_dept AS
SELECT e.id, e.name, e.salary, e.hire_date, e.city,
       d.name AS department_name,
       d.location AS department_location
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```

This script captures the full toolkit: tables, primary/foreign keys, `NOT NULL`/`UNIQUE`/`CHECK`/`DEFAULT`, auto-increment, an index, and a view — all in one tight definition.

---

## Key Takeaways

- **DDL** changes the **structure** of the database (tables, columns, constraints, indexes, views) — not the data inside.
- **`CREATE TABLE`** with constraints inline is the standard. Use `IF NOT EXISTS` for safety.
- **`ALTER TABLE`** adds/drops columns and changes types. **`DROP TABLE`** removes the whole table. **`TRUNCATE`** wipes all rows fast.
- **Constraints** enforce rules on data: `NOT NULL`, `UNIQUE`, `PRIMARY KEY` (= unique + not null), `FOREIGN KEY` (referential integrity), `CHECK` (custom rules), `DEFAULT` (auto-fill).
- **Auto-increment** has different names per dialect: `SERIAL` (PostgreSQL), `AUTO_INCREMENT` (MySQL), `IDENTITY` (SQL Server).
- **Indexes** speed up reads on filtered/joined columns — but slow writes. Add them for hot columns on large tables.
- **Views** are saved queries — great for hiding complexity, simplifying access, or reusing logic.
- **Schemas** are namespaces inside a database.
- **Temporary tables** disappear at session end — useful for session-scoped intermediate results.

## Quick Self-Check

1. What's the difference between `DROP TABLE`, `TRUNCATE TABLE`, and `DELETE FROM table`?
2. What does a `PRIMARY KEY` enforce? Is it different from `UNIQUE`?
3. Write a `CREATE TABLE` for a `students` table with `id`, `name` (required), `email` (unique), and `gpa` (between 0 and 4).
4. What does `ON DELETE CASCADE` do on a foreign key?
5. When should you add an index? When shouldn't you?
6. What's a view, and how is it different from a real table?
7. What's the difference between a temporary table and a CTE?

## Further Reading

| Topic | Reference |
|-------|-----------|
| CREATE TABLE | [W3Schools: CREATE TABLE](https://www.w3schools.com/sql/sql_create_table.asp) |
| ALTER TABLE | [W3Schools: ALTER TABLE](https://www.w3schools.com/sql/sql_alter.asp) |
| DROP TABLE | [W3Schools: DROP TABLE](https://www.w3schools.com/sql/sql_drop_table.asp) |
| Constraints | [W3Schools: Constraints](https://www.w3schools.com/sql/sql_constraints.asp) |
| NOT NULL | [W3Schools: NOT NULL](https://www.w3schools.com/sql/sql_notnull.asp) |
| UNIQUE | [W3Schools: UNIQUE](https://www.w3schools.com/sql/sql_unique.asp) |
| PRIMARY KEY | [W3Schools: PRIMARY KEY](https://www.w3schools.com/sql/sql_primarykey.asp) |
| FOREIGN KEY | [W3Schools: FOREIGN KEY](https://www.w3schools.com/sql/sql_foreignkey.asp) |
| CHECK | [W3Schools: CHECK](https://www.w3schools.com/sql/sql_check.asp) |
| DEFAULT | [W3Schools: DEFAULT](https://www.w3schools.com/sql/sql_default.asp) |
| AUTO_INCREMENT | [W3Schools: AUTO_INCREMENT](https://www.w3schools.com/sql/sql_autoincrement.asp) |
| CREATE INDEX | [W3Schools: CREATE INDEX](https://www.w3schools.com/sql/sql_create_index.asp) |
| VIEW | [W3Schools: VIEW](https://www.w3schools.com/sql/sql_view.asp) |

---

[← Prev: DML](./07-dml.md) · [Next: Joins →](./09-joins.md)
