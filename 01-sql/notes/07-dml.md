# Note 07: DML (Data Modification)

[Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

Everything from the **DML** category. The commands that *change* data in tables:

1. What is DML and how it differs from DQL and DDL
2. `INSERT`: adding new rows
3. `INSERT INTO SELECT`: copying rows from one table to another
4. `UPDATE`: modifying existing rows
5. `DELETE`: removing rows
6. The **safety habits** every beginner needs around `UPDATE` and `DELETE`
7. **`DELETE` vs `TRUNCATE` vs `DROP`**: the detailed comparison

All examples use the [`employees` and `departments` tables](./01-basics.md#the-working-example-setup-sql).

---

## 1. What Is DML?

So far you've used **DQL** (Data Query Language: `SELECT`) to *read* data. **DML** is the other side of the coin: how you *change* what's stored.

| Command | What it does |
|---------|--------------|
| `INSERT` | Add new rows |
| `UPDATE` | Change values in existing rows |
| `DELETE` | Remove rows |

DML changes data **inside existing tables**. Changing the tables themselves (their columns, types, constraints) is **DDL**, covered in [Note 08](./08-ddl.md).

> **Beginner safety mantra:** every `UPDATE` and `DELETE` should be tested with a `SELECT` first. More on this throughout the note.

---

## 2. INSERT: Adding New Rows

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

Stack the `VALUES` tuples. Much faster than separate `INSERT`s:

```sql
INSERT INTO employees (id, name, department_id, salary, hire_date, city) VALUES
    (9,  'Ivan Volkov',  2, 85000,  '2024-05-01', 'New York'),
    (10, 'Julia Mendez', 3, 90000,  '2024-05-15', 'San Francisco'),
    (11, 'Kenji Sato',   1, 100000, '2024-06-01', 'Tampa');
```

### Omitting the column list

You can leave out the column list if you provide values for **every** column in the table's defined order:

```sql
-- Risky. Depends on column order:
INSERT INTO employees VALUES (9, 'Ivan Volkov', 2, 85000, '2024-05-01', 'New York');
```

> **Beginner habit:** always list columns explicitly. If someone later adds a new column to the table, the unlisted version breaks. The listed one keeps working.

### Default values

If a column has a `DEFAULT` defined (see [Note 08: DDL](./08-ddl.md)), use the keyword `DEFAULT` to fill it in:

```sql
INSERT INTO employees (id, name, city)
VALUES (12, 'Lila Park', DEFAULT);
```

Or simply omit the column from your `INSERT`. It gets either its `DEFAULT` or `NULL` (if allowed).

---

## 3. INSERT INTO SELECT: Copying Rows

`INSERT INTO SELECT` copies rows from a query result into an **existing** table. Powerful for backups, archives, and ETL style work.

### Example: Backup before risky changes

> *"Back up high earners before a big salary update."*

```sql
-- Assume high_earners_backup already exists (created in DDL):
INSERT INTO high_earners_backup (id, name, salary)
SELECT id, name, salary
FROM employees
WHERE salary > 90000;
```

The `SELECT`'s columns must match the `INSERT`'s column list in **count and type**.

### Common pattern: copy plus transform

You can transform values inside the `SELECT` before they're inserted:

```sql
INSERT INTO employees_archived (id, name, archived_at)
SELECT id, UPPER(name), CURRENT_DATE
FROM employees
WHERE hire_date < '2021-01-01';
```

> **Compared to `CREATE TABLE AS`** (Note 04): `INSERT INTO SELECT` adds rows to an **existing** table. `CREATE TABLE AS` **creates a new** table from a query result. Different jobs.

---

## 4. UPDATE: Modifying Existing Rows

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
-- Set every salary to the company wide average:
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees);
```

### THE BIG GOTCHA: forgetting WHERE

```sql
UPDATE employees SET salary = 0;        -- DO NOT DO THIS
```

Without a `WHERE`, this updates **every row in the table**. There's no undo unless you're inside a transaction (covered in [Note 11: DCL and TCL](./11-dcl-tcl.md)).

**The safety pattern: always SELECT first**

```sql
-- Step 1: Preview which rows you'd hit
SELECT id, name, salary FROM employees WHERE department_id = 1;

-- Step 2: Run the UPDATE with the same WHERE
UPDATE employees SET salary = salary * 1.10 WHERE department_id = 1;
```

---

## 5. DELETE: Removing Rows

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
-- Remove anyone in Tampa based departments:
DELETE FROM employees
WHERE department_id IN (SELECT id FROM departments WHERE location = 'Tampa');
```

### THE BIG GOTCHA: same as UPDATE

```sql
DELETE FROM employees;        -- DELETES EVERY ROW. DO NOT DO THIS.
```

The `WHERE` is what limits the carnage. Same safety pattern as `UPDATE`: `SELECT` first, then `DELETE` with the same `WHERE`.

---

## 6. DML Safety: The Big Three Habits

1. **Always have a `WHERE` clause** on `UPDATE` and `DELETE`, unless you genuinely mean "every row."
2. **Run a `SELECT` first** to preview the rows you're about to modify or delete.
3. **Use transactions** for non trivial changes. Wrap your DML in `BEGIN; ... ROLLBACK;` to test, then `COMMIT;` if it looks right. Full coverage in [Note 11: DCL and TCL](./11-dcl-tcl.md).

These three habits prevent the majority of "oh no, I just updated/deleted everything" stories you'll hear about.

---

## 7. DELETE vs TRUNCATE vs DROP: The Detailed Comparison

These three commands all "remove things" but they do very different things. This is one of the most common SQL interview questions and a daily source of confusion.

### Quick summary

| Aspect | `DELETE` | `TRUNCATE` | `DROP` |
|--------|----------|------------|--------|
| **Category** | DML | DDL | DDL |
| **What it removes** | Specific rows (or all rows if no WHERE) | All rows | The entire table (structure + data) |
| **Table after** | Still exists, possibly empty | Still exists, empty | Gone |
| **`WHERE` allowed?** | Yes | No | No |
| **Speed** | Slow (per row logging) | Very fast (deallocates pages) | Very fast |
| **Rollback** | Yes (inside a transaction) | Depends on dialect (often not) | Depends on dialect (often not in MySQL) |
| **Auto increment / IDENTITY** | Counter not reset | Counter usually resets to start | N/A (table gone) |
| **Triggers fire?** | Yes (BEFORE / AFTER DELETE) | No (usually skipped) | N/A |
| **Lock type** | Row level locks | Table level lock | Table level lock |
| **Foreign key check** | Rejected if referencing rows exist (unless CASCADE) | Rejected if any FK references it (most dialects) | Rejected if any FK references it (unless CASCADE) |
| **Affects indexes?** | Indexes updated per row | Indexes truncated (fast) | Indexes dropped with table |
| **Affects views?** | Views still work | Views still work | Views break (if they referenced the dropped table) |
| **Affects permissions?** | Permissions unchanged | Permissions unchanged | Permissions on the table are dropped |

### Detailed breakdown

#### DELETE (DML)

```sql
DELETE FROM employees WHERE department_id = 1;
DELETE FROM employees;          -- removes every row, table still exists
```

- **What it does:** removes specific rows from a table.
- **Belongs to:** DML (Data Manipulation Language).
- **Use case:** when you need to remove rows that match a condition.
- **Speed:** slower because the database **logs each row removal** to support rollback and trigger firing. For a table with millions of rows, this can take a long time.
- **Rollback:** yes. Inside a `BEGIN ... ROLLBACK;` block, you can undo the delete. This is one of the strongest reasons to use `DELETE` over `TRUNCATE` when in doubt.
- **Triggers:** fires `BEFORE DELETE` and `AFTER DELETE` triggers for each row.
- **Auto increment behavior:** does NOT reset the next auto increment value. If your `id` column reached 100 and you `DELETE` everything, the next insert gets id 101, not 1.

#### TRUNCATE (DDL)

```sql
TRUNCATE TABLE employees;
```

- **What it does:** removes ALL rows from a table by deallocating the data pages. The table itself stays.
- **Belongs to:** DDL (Data Definition Language). This surprises beginners because it "feels" like deleting data.
- **Use case:** when you want to wipe a staging or temporary table fast.
- **Speed:** very fast, often nearly instant, because it doesn't log individual row removals. It just tells the storage engine "all the pages of this table are now free."
- **Rollback:** dialect dependent. In SQL Server you *can* roll back `TRUNCATE` inside a transaction. In MySQL with InnoDB you *cannot*. In PostgreSQL you can roll back `TRUNCATE` because it is fully transactional. Always test in your dialect before relying on it.
- **Triggers:** does NOT fire row level triggers in most dialects. This is a big difference from `DELETE`.
- **Auto increment behavior:** usually RESETS the auto increment counter to its starting value (e.g., 1). This means after `TRUNCATE`, the next inserted row gets id 1 again.
- **Foreign keys:** most dialects refuse to `TRUNCATE` a table that has rows in other tables referencing it via foreign key, even if you specify `CASCADE`. You may need to disable FK checks temporarily or drop the referencing rows first.

#### DROP (DDL)

```sql
DROP TABLE employees;
DROP TABLE IF EXISTS employees;
```

- **What it does:** removes the entire table from the database. The structure, data, indexes, triggers, and permissions all go.
- **Belongs to:** DDL.
- **Use case:** when you want to delete an entire table because you no longer need it.
- **Speed:** very fast. It is a metadata operation (the database just removes the table from its catalog and deallocates storage).
- **Rollback:** usually NOT possible after `COMMIT`. In MySQL, `DROP TABLE` auto commits. In PostgreSQL, you *can* roll back `DROP TABLE` if you're inside an explicit transaction.
- **Triggers:** all triggers on the table are also dropped.
- **Foreign keys:** by default, refuses to drop a table that other tables reference via foreign key. Use `CASCADE` to also drop those referencing constraints (covered in [Note 08, Dropping a Table with Foreign Keys](./08-ddl.md)).
- **Views:** any view that references the dropped table will break. You'll get an error when you try to use the view.
- **Permissions:** any `GRANT`s on the table are gone.

### The classic interview comparison

> *"What is the difference between DELETE, TRUNCATE, and DROP?"*

A clear answer:
- `DELETE` is **DML**. It removes specific rows (or all rows) based on a `WHERE` clause. It is slow but precise, can be rolled back inside a transaction, and fires triggers.
- `TRUNCATE` is **DDL**. It wipes all rows from a table by deallocating its storage. It is fast, usually cannot be rolled back, does not fire triggers, and usually resets the auto increment counter.
- `DROP` is **DDL**. It removes the entire table (structure plus data) from the database. The table no longer exists. Fast, dangerous, usually irreversible.

> **The rough rule:**
> - Use **`DELETE`** for surgical row removal where you need control.
> - Use **`TRUNCATE`** for "wipe this fast" on staging tables.
> - Use **`DROP`** only when you truly never need the table again.

### Visual decision flow

```
Do you want to remove specific rows (with a condition)?
                    │
              YES   │   NO
       ┌────────────┴─────────────┐
       ▼                          ▼
   Use DELETE              Do you want to keep the table?
                                   │
                             YES   │   NO
                       ┌───────────┴────────────┐
                       ▼                        ▼
                  Use TRUNCATE              Use DROP
                  (fast, all rows)        (table gone too)
```

---

## Putting It All Together

A typical maintenance script. Back up first, apply changes, then verify:

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

This three step pattern (back up, change, verify) is the standard for any production data change.

---

## Key Takeaways

- **DML** changes data inside tables: `INSERT`, `UPDATE`, `DELETE`.
- Always **list columns explicitly** in `INSERT`. Do not rely on column order.
- `INSERT INTO SELECT` copies rows into an **existing** table (different from `CREATE TABLE AS`).
- The most dangerous SQL mistake is forgetting `WHERE` on `UPDATE` or `DELETE`. **Always preview with `SELECT` first.**
- `DELETE` is DML, allows `WHERE`, can be rolled back, fires triggers, does not reset auto increment.
- `TRUNCATE` is DDL, removes all rows fast, usually no rollback, no triggers, resets auto increment.
- `DROP` is DDL, removes the entire table (structure plus data). Usually irreversible after commit.
- Use transactions for non trivial changes so you can roll back if something looks wrong.

## Quick Self Check

1. Why is listing columns explicitly in an `INSERT` safer than omitting the list?
2. What does this query do: `UPDATE employees SET salary = 0;` ?
3. Write a query that gives everyone in department 2 a $5,000 raise.
4. What's the difference between `DELETE FROM employees` and `TRUNCATE TABLE employees`?
5. Which of the three (DELETE, TRUNCATE, DROP) fires triggers? Which resets the auto increment counter?
6. How would you copy all employees with salary above $90,000 into a `high_earners` table that already exists?
7. What category does `DELETE` belong to? `TRUNCATE`? `DROP`?

## Further Reading

| Topic | Reference |
|-------|-----------|
| INSERT | [W3Schools: INSERT](https://www.w3schools.com/sql/sql_insert.asp) |
| INSERT INTO SELECT | [W3Schools: INSERT INTO SELECT](https://www.w3schools.com/sql/sql_insert_into_select.asp) |
| UPDATE | [W3Schools: UPDATE](https://www.w3schools.com/sql/sql_update.asp) |
| DELETE | [W3Schools: DELETE](https://www.w3schools.com/sql/sql_delete.asp) |
| DELETE vs TRUNCATE vs DROP | [GeeksForGeeks: Diff DELETE/TRUNCATE/DROP](https://www.geeksforgeeks.org/difference-between-delete-drop-and-truncate/) |

---

[Prev: PIVOT & Set Operations](./06-pivot-and-set-operations.md) · [Next: DDL](./08-ddl.md)
