# Note 07 — DML (Data Modification)

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

Everything from the **DML** category — the four commands that *change* data in tables:

1. What is **DML** and how it differs from DQL and DDL
2. **`INSERT`** — adding new rows
3. **`INSERT INTO SELECT`** — copying rows from one table to another
4. **`UPDATE`** — modifying existing rows
5. **`DELETE`** — removing rows
6. The **safety habits** every beginner needs around `UPDATE` and `DELETE`

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example--setup-sql).

---

## 1. What Is DML?

So far you've used **DQL** (Data Query Language — `SELECT`) to *read* data. **DML** is the other side of the coin: how you *change* what's stored.

| Command | What it does |
|---------|--------------|
| `INSERT` | Add new rows |
| `UPDATE` | Change values in existing rows |
| `DELETE` | Remove rows |

DML changes data **inside existing tables**. Changing the tables themselves — their columns, types, constraints — is **DDL**, covered in [Note 08](./08-ddl.md).

> **Beginner safety mantra:** every `UPDATE` and `DELETE` should be tested with a `SELECT` first. More on this throughout the note.

---

## 2. INSERT — Adding New Rows

The basic shape:

```sql
INSERT INTO <table> (<column list>) VALUES (<value list>);
```

### Single row

```sql
INSERT INTO employees (id, name, department_id, salary, hire_date, city)
VALUES (9, 'Ivan Volkov', 2, 85000, '2024-05-01', 'New York');
```

### Multiple rows in one statement

Stack the `VALUES` tuples — much faster than separate `INSERT`s:

```sql
INSERT INTO employees (id, name, department_id, salary, hire_date, city) VALUES
    (9,  'Ivan Volkov',  2, 85000,  '2024-05-01', 'New York'),
    (10, 'Julia Mendez', 3, 90000,  '2024-05-15', 'San Francisco'),
    (11, 'Kenji Sato',   1, 100000, '2024-06-01', 'Tampa');
```

### Omitting the column list

You can leave out the column list if you provide values for **every** column in the table's defined order:

```sql
-- Risky — depends on column order:
INSERT INTO employees VALUES (9, 'Ivan Volkov', 2, 85000, '2024-05-01', 'New York');
```

> **Beginner habit:** always list columns explicitly. If someone later adds a new column to the table, the unlisted version breaks — but the listed one keeps working.

### Default values

If a column has a `DEFAULT` defined (see [Note 08 — DDL](./08-ddl.md)), use the keyword `DEFAULT` to fill it in:

```sql
INSERT INTO employees (id, name, city)
VALUES (12, 'Lila Park', DEFAULT);
```

Or simply omit the column from your `INSERT` — it gets either its `DEFAULT` or `NULL` (if allowed).

---

## 3. INSERT INTO SELECT — Copying Rows

`INSERT INTO SELECT` copies rows from a query result into an **existing** table. Powerful for backups, archives, and ETL-style work.

### Example — Backup before risky changes

> *"Back up high-earners before a big salary update."*

```sql
-- Assume high_earners_backup already exists (created in DDL):
INSERT INTO high_earners_backup (id, name, salary)
SELECT id, name, salary
FROM employees
WHERE salary > 90000;
```

The `SELECT`'s columns must match the `INSERT`'s column list in **count and type**.

### Common pattern — copy + transform

You can transform values inside the `SELECT` before they're inserted:

```sql
INSERT INTO employees_archived (id, name, archived_at)
SELECT id, UPPER(name), CURRENT_DATE
FROM employees
WHERE hire_date < '2021-01-01';
```

> **Compared to `CREATE TABLE AS`** (Note 04): `INSERT INTO SELECT` adds rows to an **existing** table; `CREATE TABLE AS` **creates a new** table from a query result. Different jobs.

---

## 4. UPDATE — Modifying Existing Rows

The shape:

```sql
UPDATE <table>
SET   <column> = <value>, <column2> = <value2>, ...
WHERE <condition>;
```

### Single column update

```sql
UPDATE employees
SET salary = 100000
WHERE id = 1;
```

### Multiple columns at once

```sql
UPDATE employees
SET salary = 120000,
    city = 'Tampa'
WHERE name = 'Alice Chen';
```

### Update using expressions

You can compute the new value based on the current value:

```sql
-- Give everyone in Engineering a 10% raise:
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 1;
```

### Update using a subquery

```sql
-- Set every salary to the company-wide average:
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees);
```

### THE BIG GOTCHA — Forgetting WHERE

```sql
UPDATE employees SET salary = 0;        -- DON'T
```

Without a `WHERE`, this updates **every row in the table**. There's no undo unless you're inside a transaction (covered in [Note 11 — DCL & TCL](./11-dcl-tcl.md)).

**The safety pattern — always SELECT first:**

```sql
-- Step 1: Preview which rows you'd hit
SELECT id, name, salary FROM employees WHERE department_id = 1;

-- Step 2: Run the UPDATE with the same WHERE
UPDATE employees SET salary = salary * 1.10 WHERE department_id = 1;
```

---

## 5. DELETE — Removing Rows

The shape:

```sql
DELETE FROM <table> WHERE <condition>;
```

### Delete matching rows

```sql
DELETE FROM employees WHERE city = 'Remote';
```

### Delete using a subquery

```sql
-- Remove anyone in Tampa-based departments:
DELETE FROM employees
WHERE department_id IN (SELECT id FROM departments WHERE location = 'Tampa');
```

### THE BIG GOTCHA — Same as UPDATE

```sql
DELETE FROM employees;        -- DELETES EVERY ROW. DON'T.
```

The `WHERE` is what limits the carnage. Same safety pattern as `UPDATE`: `SELECT` first, then `DELETE` with the same `WHERE`.

### DELETE vs. TRUNCATE vs. DROP

These three look similar but do different things:

| Statement | Removes | Keeps table? | Can have WHERE? | Logs each row? |
|-----------|---------|--------------|----------------|----------------|
| **`DELETE`** | Specific rows (or all) | Yes | Yes | Yes — can be rolled back |
| **`TRUNCATE`** | All rows | Yes | No | No — much faster |
| **`DROP`** | The entire table | **No** | No | N/A |

`TRUNCATE` and `DROP` are DDL, so they're covered in Note 08. The rough rule:
- **`DELETE`** for surgical row removal
- **`TRUNCATE`** for "wipe this fast"
- **`DROP`** for "kill the whole table"

---

## 6. DML Safety — The Big Three Habits

1. **Always have a `WHERE` clause** on `UPDATE` and `DELETE`, unless you genuinely mean "every row."
2. **Run a `SELECT` first** to preview the rows you're about to modify or delete.
3. **Use transactions** for non-trivial changes — wrap your DML in `BEGIN; ... ROLLBACK;` to test, then `COMMIT;` if it looks right. Full coverage in [Note 11 — DCL & TCL](./11-dcl-tcl.md).

These three habits prevent the majority of "oh no, I just dropped/updated/deleted everything" stories you'll hear about.

---

## Putting It All Together

A typical maintenance script — back up first, apply changes, then verify:

```sql
-- 1. Back up the rows we're about to change
INSERT INTO employees_backup
SELECT * FROM employees WHERE department_id = 1;

-- 2. Apply the change (10% raise for Engineering)
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 1;

-- 3. Verify
SELECT name, salary FROM employees WHERE department_id = 1;
```

This three-step pattern — **back up → change → verify** — is the standard for any production data change.

---

## Key Takeaways

- **DML** changes data inside tables: `INSERT`, `UPDATE`, `DELETE`.
- Always **list columns explicitly** in `INSERT` — don't rely on column order.
- `INSERT INTO SELECT` copies rows into an **existing** table (different from `CREATE TABLE AS`).
- The most dangerous SQL mistake is forgetting `WHERE` on `UPDATE`/`DELETE`. **Always preview with `SELECT` first.**
- `DELETE` removes rows (can have `WHERE`, can be rolled back); `TRUNCATE` wipes all rows fast (DDL); `DROP` removes the table entirely (DDL).
- Use transactions for non-trivial changes so you can roll back if something looks wrong.

## Quick Self-Check

1. Why is listing columns explicitly in an `INSERT` safer than omitting the list?
2. What does this query do: `UPDATE employees SET salary = 0;` ?
3. Write a query that gives everyone in department 2 a $5,000 raise.
4. What's the difference between `DELETE FROM employees` and `TRUNCATE TABLE employees`?
5. How would you copy all employees with salary above $90,000 into a `high_earners` table that already exists?

## Further Reading

| Topic | Reference |
|-------|-----------|
| INSERT | [W3Schools: INSERT](https://www.w3schools.com/sql/sql_insert.asp) |
| INSERT INTO SELECT | [W3Schools: INSERT INTO SELECT](https://www.w3schools.com/sql/sql_insert_into_select.asp) |
| UPDATE | [W3Schools: UPDATE](https://www.w3schools.com/sql/sql_update.asp) |
| DELETE | [W3Schools: DELETE](https://www.w3schools.com/sql/sql_delete.asp) |

---

[← Prev: PIVOT & Set Operations](./06-pivot-and-set-operations.md) · [Next: DDL →](./08-ddl.md)
