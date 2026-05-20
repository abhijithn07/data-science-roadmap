# Note 08: DDL (Defining Tables, Constraints, Indexes & Views)

[Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The entire **DDL** category, organized into six parts:

**Part 1: Tables**
1. What is DDL?
2. `CREATE TABLE`
3. `ALTER TABLE`
4. `DROP TABLE`
5. `TRUNCATE TABLE`
6. `RENAME TABLE` / `RENAME COLUMN`
7. Dropping a Table with Foreign Keys

**Part 2: Constraints (rules on the data)**

8. Constraints overview
9. `NOT NULL`
10. `UNIQUE`
11. `PRIMARY KEY`
12. `FOREIGN KEY` (with parent/child and referencing/referenced terminology)
13. `RESTRICT`, `CASCADE`, `SET NULL`, `SET DEFAULT`, `NO ACTION`
14. `CHECK`
15. `DEFAULT`
16. `AUTO_INCREMENT` / `IDENTITY` / `SEQUENCE`

**Part 3: Normalization and Denormalization**

17. What is normalization?
18. First Normal Form (1NF)
19. Second Normal Form (2NF)
20. Third Normal Form (3NF)
21. Boyce Codd Normal Form (BCNF)
22. Higher normal forms (4NF, 5NF) briefly
23. Denormalization

**Part 4: Indexes**

24. `CREATE INDEX`
25. `DROP` / `ALTER` / `REBUILD INDEX`

**Part 5: Views, Schemas, Temporary Tables**

26. `CREATE VIEW` / `ALTER VIEW` / `DROP VIEW`
27. `CREATE SCHEMA`
28. Temporary tables

**Part 6: Information Schema and Metadata**

29. What is metadata?
30. `INFORMATION_SCHEMA`
31. Practical examples

All examples use (or extend) the [`employees` and `departments` tables](./01-basics.md#the-working-example-setup-sql).

---

## 1. What Is DDL?

**DDL** = **Data Definition Language**. It is the family of SQL commands that define and change the *structure* of your database. Tables, columns, constraints, indexes, views. Not the data inside them.

| Command | What it does |
|---------|--------------|
| `CREATE` | Make a new table, view, index, schema |
| `ALTER` | Change an existing one (add a column, modify a type, rename) |
| `DROP` | Delete the entire object (the table itself, not its rows) |
| `TRUNCATE` | Wipe all rows from a table (fast, no `WHERE` clause) |

> DDL is different from **DML** ([Note 07](./07-dml.md)), which changes the *data* inside tables. DDL changes the *containers*.

---

# Part 1: Tables

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
- `id INTEGER PRIMARY KEY`. A whole number that uniquely identifies each row.
- `name TEXT NOT NULL`. Text required (can't be blank).
- `salary DECIMAL(10, 2)`. Up to 10 total digits, 2 after the decimal point.
- `department_id INTEGER REFERENCES departments(id)`. A foreign key (covered in §12).

### CREATE TABLE IF NOT EXISTS

Avoid errors when the table might already exist:

```sql
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY,
    ...
);
```

## 3. ALTER TABLE

`ALTER TABLE` changes a table that already exists. Adding or removing columns, changing types, adding constraints.

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

Remove the entire table. Structure and all data.

```sql
DROP TABLE employees;
```

### DROP TABLE IF EXISTS

Avoid an error if the table doesn't exist:

```sql
DROP TABLE IF EXISTS employees;
```

> **Be very careful with `DROP`.** There's no `WHERE`. There's no confirmation. The table is gone. In production, this is one of the most dangerous commands you can run.

### CASCADE: drop dependents too

If other objects (foreign keys, views) reference the table, you may need `CASCADE`:

```sql
DROP TABLE departments CASCADE;
-- Drops departments and anything that references it
```

See section 7 below for full coverage of dropping tables that have foreign key relationships.

## 5. TRUNCATE TABLE

`TRUNCATE` removes **all rows** from a table while keeping the table itself. Much faster than `DELETE` because it doesn't log each row removal.

```sql
TRUNCATE TABLE employees;
```

### TRUNCATE vs DELETE vs DROP

See [Note 07, §7](./07-dml.md) for the detailed three way comparison. Quick summary:

| | TRUNCATE | DELETE | DROP |
|--|----------|--------|------|
| Category | DDL | DML | DDL |
| Removes | All rows | Specific rows | Entire table |
| `WHERE`? | No | Yes | No |
| Rollback safe? | Dialect dependent | Yes (in transaction) | Dialect dependent |
| Resets auto increment? | Yes (usually) | No | N/A |

Use `TRUNCATE` for "wipe everything" operations like clearing staging tables. Use `DELETE` for "remove rows matching a condition." Use `DROP` to remove the table entirely.

## 6. RENAME TABLE / COLUMN

Covered as part of `ALTER` above. The two shapes you'll use most:

```sql
ALTER TABLE employees RENAME COLUMN city TO location;
ALTER TABLE employees RENAME TO staff;
```

## 7. Dropping a Table with Foreign Keys

If another table references your table via a foreign key, you **cannot** simply drop your table. The database refuses to break referential integrity.

### What happens by default

Suppose `employees.department_id` is a foreign key to `departments.id`:

```sql
DROP TABLE departments;
-- ERROR: cannot drop table departments because other objects depend on it
-- (the foreign key in employees.department_id depends on it)
```

The error message varies by database, but the meaning is the same: dropping the **parent** (referenced) table would leave **orphan rows** in the **child** (referencing) table.

### Option 1: Drop the child table first

The simplest solution. Remove the dependent table, then the parent:

```sql
DROP TABLE employees;       -- drop the child first
DROP TABLE departments;     -- then the parent
```

### Option 2: Use CASCADE (PostgreSQL, SQL Server, Oracle)

`CASCADE` tells the database to drop everything that depends on the table:

```sql
-- PostgreSQL:
DROP TABLE departments CASCADE;
-- Drops departments AND removes the foreign key from employees.
-- The employees table itself stays, but loses the FK constraint.

-- SQL Server uses the same syntax:
DROP TABLE departments CASCADE CONSTRAINTS;  -- Oracle syntax
```

> **MySQL does not support `DROP TABLE ... CASCADE` directly.** You must drop the foreign key constraint first, then drop the table.

### Option 3: Drop the foreign key constraint first

If you want to keep the child table and just drop the parent:

```sql
-- Step 1: Find the FK constraint name
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'employees' AND CONSTRAINT_TYPE = 'FOREIGN KEY';

-- Step 2: Drop the FK constraint
ALTER TABLE employees DROP CONSTRAINT fk_employees_department;
-- Or in MySQL:
ALTER TABLE employees DROP FOREIGN KEY fk_employees_department;

-- Step 3: Now you can drop the parent
DROP TABLE departments;
```

### Option 4: Temporarily disable FK checks (MySQL specific, dangerous)

MySQL allows you to disable foreign key checks for a session:

```sql
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE departments;
SET FOREIGN_KEY_CHECKS = 1;
```

> **Warning:** this leaves orphan rows in the child table. Only use this when you are also planning to drop or fix the child table immediately after. It can corrupt your data model if forgotten.

### The safe production workflow

1. Identify all tables that reference your table (using `INFORMATION_SCHEMA`, covered in Part 6).
2. Decide: drop the children, drop the FK constraints, or use `CASCADE`?
3. Wrap the operation in a transaction if your database allows DDL rollback (PostgreSQL does).
4. Test on a staging copy first.

---

# Part 2: Constraints

## 8. Constraints Overview

**Constraints** are rules attached to columns that the database enforces. They keep your data clean and consistent by **rejecting invalid changes before they happen**.

| Constraint | What it enforces |
|-----------|------------------|
| `NOT NULL` | The column can't be `NULL` |
| `UNIQUE` | All values in the column (or set of columns) must differ |
| `PRIMARY KEY` | `UNIQUE` plus `NOT NULL`. Identifies each row |
| `FOREIGN KEY` | Value must exist in another table's column |
| `CHECK` | Custom condition every row must satisfy |
| `DEFAULT` | Auto fills the column if no value provided |

Constraints can be defined **inline** (within the column) or as **table level constraints**:

```sql
-- Inline:
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0)
);

-- Table level (useful for multi column constraints):
CREATE TABLE employees (
    id INTEGER,
    name TEXT NOT NULL,
    salary DECIMAL(10,2),
    CONSTRAINT pk_employees PRIMARY KEY (id),
    CONSTRAINT salary_positive CHECK (salary > 0)
);
```

Naming constraints (e.g., `pk_employees`) makes them easier to reference later when dropping or altering.

### Why constraints matter

Without constraints, the data inside a database can drift into inconsistency. An employee might end up with no name, two employees might share the same ID, a salary might be negative, or an order might reference a customer that doesn't exist. Constraints are how the database **protects itself** from bad data, regardless of which application is inserting rows. The database enforces them centrally, not just at the application layer.

## 9. NOT NULL

The column **must have a value**. `NULL` is not allowed.

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

-- SQL Server:
ALTER TABLE employees ALTER COLUMN name VARCHAR(100) NOT NULL;
```

If existing rows have `NULL`s, this fails until you fix them (typically with `UPDATE ... SET ... WHERE col IS NULL`).

### When to use NOT NULL

Mark a column `NOT NULL` whenever the business rule says "every row *must* have a value here." Examples:
- Every employee must have a name.
- Every order must have a customer.
- Every row must have a primary key (this is automatic for primary keys).

> **Beginner tip:** prefer `NOT NULL` columns unless you have a real reason to allow nulls. `NULL` is a constant source of subtle query bugs.

## 10. UNIQUE

All values in the column must be distinct. **No duplicates allowed**. `NULL`s are typically allowed and aren't treated as duplicates of each other (one of the few exceptions where `NULL` doesn't behave like a regular value).

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE       -- no two employees can share an email
);
```

### Multi column unique constraint

The combination of columns must be unique. Individual columns can repeat:

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    UNIQUE (student_id, course_id)    -- combination must be unique
);
```

A student can be in many courses, a course has many students, but the same student can't enroll in the same course twice.

### UNIQUE vs PRIMARY KEY

- `UNIQUE` allows `NULL` (in most dialects, one `NULL` is allowed, sometimes multiple).
- `PRIMARY KEY` does NOT allow `NULL`. It is `UNIQUE` plus `NOT NULL` combined.
- A table has **at most one** primary key, but can have **many** unique constraints.

### Adding a UNIQUE constraint later

```sql
ALTER TABLE employees ADD CONSTRAINT uq_email UNIQUE (email);
```

## 11. PRIMARY KEY

A **primary key** is the column (or combination of columns) that **uniquely identifies each row**. It is `UNIQUE` plus `NOT NULL` combined.

A table has **at most one** primary key.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
```

### Composite primary key (multiple columns)

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
- They typically have a **clustered index** automatically. Fast lookups.
- They make joins and updates unambiguous.

### Choosing a primary key

Two common approaches:
1. **Surrogate key:** a meaningless auto generated number, usually called `id`. Always unique, always stable. Most common in modern systems.
2. **Natural key:** a column with meaningful business data (like an SSN or an ISBN). Unique by business rules, but can sometimes change.

> **Beginner tip:** use a surrogate `id` column as the primary key unless you have a strong reason to use a natural key. It avoids the headache of "what if the natural key value changes?"

## 12. FOREIGN KEY

A **foreign key** says a column's value must **exist as a primary key in another table**. This is what links tables together and keeps the data **consistent**. The property is called **referential integrity**.

### The two terminology pairs

Two pairs of terms describe the relationship. They mean the same thing, just with different vocabulary:

| Pair 1 | Pair 2 | Description |
|--------|--------|-------------|
| **Parent table** | **Referenced table** | The table whose primary key is being referenced |
| **Child table** | **Referencing table** | The table that has the foreign key column |

In our example:

```sql
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id)
);
```

- `departments` is the **parent** table (also called the **referenced** table). Its `id` column is being referenced.
- `employees` is the **child** table (also called the **referencing** table). It has the foreign key column `department_id`.

You'll hear both pairs of terms in interviews and documentation. They are interchangeable.

### How foreign keys enforce referential integrity

After the constraint is defined:
- **You cannot insert** a `department_id` in `employees` that doesn't exist as an `id` in `departments`. The database rejects orphan rows.
- **You cannot delete** a row from `departments` if any row in `employees` references it (unless you specify a different `ON DELETE` action, see below).
- **You cannot update** a `departments.id` to a value that would orphan rows in `employees` (unless you specify a different `ON UPDATE` action).

### Defining a foreign key

**Inline (shortest):**

```sql
department_id INTEGER REFERENCES departments(id)
```

**Table level with constraint name (preferred for production):**

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER,
    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
);
```

Naming the constraint (`fk_employees_department`) makes it easy to drop or alter later.

### Composite foreign keys

A foreign key can reference a composite primary key, in which case it must include the same number of columns:

```sql
CREATE TABLE attendance (
    student_id INTEGER,
    course_id INTEGER,
    date DATE,
    FOREIGN KEY (student_id, course_id) REFERENCES enrollments(student_id, course_id)
);
```

## 13. RESTRICT, CASCADE, SET NULL, SET DEFAULT, NO ACTION

These are the **referential actions** that say what happens to **child** rows when the **parent** row is deleted or updated.

### The five actions

| Action | What happens on `ON DELETE` of parent | What happens on `ON UPDATE` of parent's key |
|--------|---------------------------------------|---------------------------------------------|
| **`NO ACTION`** | Reject the delete if any child references it. Check happens at end of statement (or transaction, depending on dialect). | Reject the update. |
| **`RESTRICT`** | Same as `NO ACTION` but check happens immediately. The delete is rejected if any child references it. | Reject the update immediately. |
| **`CASCADE`** | Delete the matching child rows too. | Update the child's foreign key value to match the new parent key. |
| **`SET NULL`** | Set the child's foreign key column to `NULL`. (Requires the FK column to allow `NULL`.) | Same. |
| **`SET DEFAULT`** | Set the child's foreign key column to its `DEFAULT` value. | Same. |

### Syntax

You specify the action when defining the foreign key:

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

You can specify both `ON DELETE` and `ON UPDATE`, only one, or neither (in which case the default `NO ACTION` applies).

### RESTRICT vs NO ACTION

Both prevent the change. The only real difference is the *timing* of the check:
- `RESTRICT`: checked **immediately** when the statement runs.
- `NO ACTION`: checked at the **end of the statement** (or end of the transaction, in some dialects).

For most beginners, treat them as the same. In practice, the behavioral difference matters only in advanced scenarios with deferred constraints.

### CASCADE in plain words

Pick a parent row to delete:
- `ON DELETE CASCADE`: "If you delete me, delete my children too."
- `ON DELETE SET NULL`: "If you delete me, set my children's link to `NULL`."
- `ON DELETE RESTRICT`: "You cannot delete me while my children exist."

### Concrete examples

#### CASCADE: parent deletion deletes children

```sql
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT,
    department_id INTEGER REFERENCES departments(id) ON DELETE CASCADE
);

INSERT INTO departments VALUES (1, 'Engineering');
INSERT INTO employees VALUES (10, 'Alice', 1);
INSERT INTO employees VALUES (11, 'Bob', 1);

DELETE FROM departments WHERE id = 1;
-- This succeeds. Alice and Bob are also deleted automatically.
```

#### SET NULL: parent deletion sets child FK to NULL

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL
);

-- Same INSERT data as above

DELETE FROM departments WHERE id = 1;
-- Engineering deleted. Alice and Bob's department_id is now NULL.
```

#### RESTRICT: parent deletion blocked

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT,
    department_id INTEGER REFERENCES departments(id) ON DELETE RESTRICT
);

-- Same INSERT data as above

DELETE FROM departments WHERE id = 1;
-- ERROR: cannot delete because employees rows reference it
```

### When to use which

| Situation | Action |
|-----------|--------|
| Children should be deleted along with parent (e.g., delete an order and its line items) | `ON DELETE CASCADE` |
| Children can survive without parent, link should clear (e.g., delete a department, employees become "unassigned") | `ON DELETE SET NULL` |
| Children should never be orphaned. Block the delete. (e.g., can't delete a customer who has orders) | `ON DELETE RESTRICT` (or default `NO ACTION`) |
| Children should fall back to a default (e.g., "unassigned" department) | `ON DELETE SET DEFAULT` |

> **Beginner default:** if you're not sure, use `RESTRICT` (or no action, which is the default). It is the safest. You can change it later.

### Dialect note

| Dialect | Default action if you don't specify |
|---------|-------------------------------------|
| **PostgreSQL** | `NO ACTION` |
| **MySQL (InnoDB)** | `NO ACTION` (alias for `RESTRICT` in MySQL) |
| **SQL Server** | `NO ACTION` |
| **Oracle** | `NO ACTION` |

## 14. CHECK

A **CHECK constraint** is a custom rule. Any expression that must be true for every row.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    hire_date DATE CHECK (hire_date <= CURRENT_DATE)
);
```

CHECK constraints catch logical errors (negative salary, future hire date) at the database level. Defense in depth on top of any application validation.

### Multi column CHECK

A CHECK can reference multiple columns:

```sql
CREATE TABLE bookings (
    id INTEGER PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    CHECK (end_date >= start_date)
);
```

### Naming CHECK constraints

For clearer error messages later, name them:

```sql
CONSTRAINT salary_positive CHECK (salary > 0)
```

### CHECK with IN

A common idiom for restricting a column to a set of values:

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    employment_type TEXT CHECK (employment_type IN ('FULL_TIME', 'PART_TIME', 'CONTRACTOR'))
);
```

### Dialect note

Older MySQL versions (before 8.0.16) accepted `CHECK` syntax but didn't enforce it. Modern MySQL, PostgreSQL, SQL Server, and Oracle all enforce CHECK constraints.

## 15. DEFAULT

A **DEFAULT** auto fills a column when an `INSERT` doesn't provide a value.

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT DEFAULT 'Remote',
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE
);
```

Now if you omit `city` from an `INSERT`, it becomes `'Remote'`. Omit `hire_date`, it becomes today.

### Common useful defaults

| Default | What it gives you |
|---------|-------------------|
| Literal values: `0`, `''`, `'unknown'` | Starting values |
| `CURRENT_DATE` | Today's date |
| `CURRENT_TIMESTAMP` (or `NOW()`) | Right now |
| `UUID generators` (e.g., `gen_random_uuid()` in PostgreSQL) | A new UUID per row |
| Sequences | Next number in a sequence |

### Using DEFAULT in an INSERT

You can explicitly invoke the default with the `DEFAULT` keyword:

```sql
INSERT INTO employees (id, name, city) VALUES (1, 'Alice', DEFAULT);
-- city becomes 'Remote' (the column's default)
```

### Changing a default

```sql
-- PostgreSQL / SQL Server:
ALTER TABLE employees ALTER COLUMN city SET DEFAULT 'Tampa';

-- MySQL:
ALTER TABLE employees ALTER city SET DEFAULT 'Tampa';
```

## 16. AUTO_INCREMENT / IDENTITY / SEQUENCE

A way to **automatically generate unique integer values** for a column. Typically the primary key. The syntax varies a lot by dialect:

| Dialect | Syntax |
|---------|--------|
| **MySQL** | `id INTEGER AUTO_INCREMENT PRIMARY KEY` |
| **SQL Server** | `id INTEGER IDENTITY(1,1) PRIMARY KEY` |
| **PostgreSQL** | `id SERIAL PRIMARY KEY` (newer: `GENERATED ALWAYS AS IDENTITY`) |
| **Oracle** | A separate `SEQUENCE` object, or `IDENTITY` (12c plus) |
| **SQLite** | `id INTEGER PRIMARY KEY AUTOINCREMENT` |

```sql
-- PostgreSQL:
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,    -- auto generates 1, 2, 3, ...
    name TEXT NOT NULL
);

-- Then you can omit id when inserting:
INSERT INTO employees (name) VALUES ('Alice');  -- gets id=1
INSERT INTO employees (name) VALUES ('Bob');    -- gets id=2
```

> **Sequences** are a separate database object that generates numbers. Used internally by `IDENTITY` and `AUTO_INCREMENT`. You can also use them directly (e.g., for a non primary key column).

---

# Part 3: Normalization and Denormalization

## 17. What Is Normalization?

**Normalization** is the process of organizing data in a database to **reduce redundancy** (storing the same fact in multiple places) and **eliminate update anomalies** (situations where changing one fact requires updates in many places, with risk of inconsistency).

It was formalized by **E.F. Codd**, the inventor of the relational model, in the 1970s. He defined a series of **normal forms** (rules a table must satisfy), each one stricter than the last.

### Why normalize?

Imagine an unnormalized table:

| order_id | customer_name | customer_email | customer_address | product_name | product_price | order_quantity |
|----------|---------------|----------------|------------------|--------------|---------------|----------------|
| 1 | Alice | alice@x.com | 123 Main | Book | 20 | 2 |
| 2 | Alice | alice@x.com | 123 Main | Pen | 5 | 10 |
| 3 | Alice | alice@x.com | 124 Main | Book | 20 | 1 |

Problems:
- **Update anomaly:** Alice moved to 124 Main. Rows 1 and 2 still show 123 Main. The data is inconsistent.
- **Insert anomaly:** you can't add a new customer who has no orders yet, because the orders table requires order data.
- **Delete anomaly:** if Alice's last order is deleted, you lose all her contact info.
- **Redundancy:** Alice's name, email, and address are repeated for every order.

Normalization splits this into separate tables (`customers`, `products`, `orders`) linked by foreign keys, removing the redundancy.

### The normal forms

The most commonly applied normal forms are:

1. **1NF (First Normal Form):** atomic values, no repeating groups, each row identifiable.
2. **2NF (Second Normal Form):** 1NF, and no partial dependency on a composite primary key.
3. **3NF (Third Normal Form):** 2NF, and no transitive dependency.
4. **BCNF (Boyce Codd Normal Form):** stricter version of 3NF.
5. **4NF, 5NF:** less commonly used in practice. Address multi valued and join dependencies.

In real world databases, most tables are designed to **3NF** or **BCNF**. Higher forms are usually theoretical.

## 18. First Normal Form (1NF)

A table is in **1NF** when:

1. Each column contains **atomic** (indivisible) values. No lists, no sets, no nested structures inside a single cell.
2. Each column contains values of a **single type**.
3. Each row is uniquely identifiable (a primary key exists).
4. The order of rows and columns doesn't matter.

### Example of a 1NF violation

A table where one column holds multiple values:

| employee_id | name | phone_numbers |
|-------------|------|---------------|
| 1 | Alice | 555-1234, 555-5678 |
| 2 | Bob | 555-9999 |

The `phone_numbers` column is not atomic. It holds a list.

### 1NF fix

Split into a separate `phones` table:

**employees**
| employee_id | name |
|-------------|------|
| 1 | Alice |
| 2 | Bob |

**phones**
| phone_id | employee_id | phone_number |
|----------|-------------|--------------|
| 1 | 1 | 555-1234 |
| 2 | 1 | 555-5678 |
| 3 | 2 | 555-9999 |

Now each cell holds one atomic value, and Alice can have any number of phones without changing the table structure.

## 19. Second Normal Form (2NF)

A table is in **2NF** when:

1. It is in 1NF.
2. **No partial dependency** exists. Every non key column depends on the **entire** primary key, not just part of it.

This rule only matters for tables with **composite primary keys**. If your primary key is a single column, you can't have partial dependencies, so 2NF is automatically satisfied if 1NF is.

### Example of a 2NF violation

A table with a composite primary key `(order_id, product_id)`:

| order_id | product_id | product_name | quantity |
|----------|------------|--------------|----------|
| 1 | 101 | Book | 2 |
| 1 | 102 | Pen | 10 |
| 2 | 101 | Book | 1 |

- `quantity` depends on the full key `(order_id, product_id)`. Good.
- `product_name` depends only on `product_id`, not on `order_id`. Bad. This is a **partial dependency**.

### 2NF fix

Split into two tables:

**order_items** (the relationship)
| order_id | product_id | quantity |
|----------|------------|----------|
| 1 | 101 | 2 |
| 1 | 102 | 10 |
| 2 | 101 | 1 |

**products**
| product_id | product_name |
|------------|--------------|
| 101 | Book |
| 102 | Pen |

Now each non key column depends on the **whole** primary key of its table.

## 20. Third Normal Form (3NF)

A table is in **3NF** when:

1. It is in 2NF.
2. **No transitive dependency** exists. Non key columns depend only on the primary key, not on other non key columns.

A **transitive dependency** is when column A depends on column B, and column B depends on the primary key. So A is *indirectly* depending on the key.

### Example of a 3NF violation

An employee table:

| employee_id | name | department_id | department_name | department_location |
|-------------|------|---------------|-----------------|---------------------|
| 1 | Alice | 10 | Engineering | Tampa |
| 2 | Bob | 10 | Engineering | Tampa |
| 3 | Carlos | 20 | Marketing | New York |

- `name` depends on `employee_id`. Good.
- `department_id` depends on `employee_id`. Good.
- `department_name` depends on `department_id`, not directly on `employee_id`. **Transitive dependency.** Same for `department_location`.

If Engineering is renamed to "Software," you have to update many rows. Update anomaly.

### 3NF fix

Split out the department info:

**employees**
| employee_id | name | department_id |
|-------------|------|---------------|
| 1 | Alice | 10 |
| 2 | Bob | 10 |
| 3 | Carlos | 20 |

**departments**
| department_id | department_name | department_location |
|---------------|-----------------|---------------------|
| 10 | Engineering | Tampa |
| 20 | Marketing | New York |

Now each non key column depends only on its table's primary key.

> **Most production databases are designed at 3NF.** It is the sweet spot of redundancy reduction without too much join complexity.

## 21. Boyce Codd Normal Form (BCNF)

BCNF is a slightly stricter version of 3NF. A table is in **BCNF** when:

1. It is in 3NF.
2. For every functional dependency `X to Y`, `X` is a **superkey** (a column or set of columns that uniquely identifies each row).

In plain words: every column that "determines" another column must itself be a candidate key.

### When 3NF and BCNF differ

In *most* tables, 3NF and BCNF are the same. They diverge only in rare cases where a table has multiple overlapping candidate keys. For day to day database design, satisfying 3NF usually satisfies BCNF.

### Example where they differ

A table tracking which professor teaches which subject in which classroom:

| professor | subject | classroom |
|-----------|---------|-----------|
| Smith | Algebra | Room 101 |
| Jones | Calculus | Room 102 |

Suppose:
- Each `(professor, subject)` combo identifies a unique `classroom`. So `(professor, subject)` is a candidate key.
- Each subject is always taught in a specific classroom. So `subject` determines `classroom`. But `subject` alone is not a candidate key.

This violates BCNF because `subject` determines `classroom` but isn't a candidate key. The fix: split into two tables (one for subject to classroom, one for professor to subject).

> **Practical takeaway:** in most database design work, 3NF is enough. If you ever encounter a BCNF problem, your tables can usually be further split into smaller, cleaner ones.

## 22. Higher Normal Forms (4NF, 5NF) Briefly

**4NF (Fourth Normal Form):**
- Requires BCNF.
- Eliminates **multi valued dependencies**. A table shouldn't store two independent multi valued facts about an entity.
- Example violation: a table that stores both "courses a student takes" and "hobbies a student has" in the same table.

**5NF (Fifth Normal Form, also called Project Join Normal Form):**
- Requires 4NF.
- Eliminates **join dependencies**. The table can't be decomposed into smaller tables that, when joined, return exactly the original data.

These higher forms are rarely encountered in real world database design. Most real systems sit at 3NF or BCNF.

### Normal form summary

| Form | What it eliminates |
|------|-------------------|
| **1NF** | Non atomic values, repeating groups |
| **2NF** | Partial dependencies (on composite PKs) |
| **3NF** | Transitive dependencies |
| **BCNF** | Anomalies from overlapping candidate keys |
| **4NF** | Multi valued dependencies |
| **5NF** | Join dependencies |

## 23. Denormalization

**Denormalization** is the process of **deliberately introducing redundancy back into a normalized database** to improve read performance. It is a trade off: more storage and write complexity in exchange for fewer joins on read.

### Why denormalize?

Joining many normalized tables can be slow, especially on large datasets in analytical or reporting workloads. If a query is run thousands of times and needs to join five tables every time, you might decide it's faster to store some redundant data.

### Common denormalization patterns

| Pattern | What you do | Benefit | Cost |
|---------|-------------|---------|------|
| **Duplicated columns** | Copy a frequently joined column from the parent into the child | Fewer joins | Updates must touch both copies |
| **Computed columns** | Pre compute and store aggregated values (e.g., `total_orders` per customer) | Fast reads | Must update on every change |
| **Wide tables** | Combine related entities into one fat table | Single read | Lots of nulls, harder to maintain |
| **Star schema** (data warehouses) | Big "fact" table joined to small "dimension" tables | Optimized for analytical queries | Different design from OLTP |

### Example

Normalized:

```
employees(id, name, department_id)
departments(id, name)
```

To get an employee with their department name, you join. If this query runs constantly, you might denormalize:

```
employees(id, name, department_id, department_name)
departments(id, name)   -- still exists for updates
```

Now `department_name` is duplicated in `employees`. Reads are faster (no join). But every time a department name changes, you have to update both tables.

### When to denormalize

- **Read heavy** workloads where the same expensive join runs many times.
- **Data warehouses** and reporting databases where data is mostly written once and read many times.
- After **measuring** that the normalized design is actually a bottleneck.

### When NOT to denormalize

- Early in design. Normalize first, denormalize later only if needed.
- Write heavy or transactional systems. The cost of keeping duplicates consistent outweighs the read benefit.
- When you can solve the problem with a **materialized view** or **caching** instead.

> **Beginner advice:** start with a properly normalized design (3NF). Only denormalize when you have a real, measured performance problem that needs it.

---

# Part 4: Indexes

## 24. CREATE INDEX

An **index** is a data structure (usually a B tree) that lets the database find rows fast for specific columns. Without scanning every row.

**Without an index:** `WHERE name = 'Alice'` requires scanning every row.
**With an index on `name`:** the database jumps directly to matching rows.

### Basic syntax

```sql
CREATE INDEX idx_employees_city ON employees(city);
```

After this, queries like `WHERE city = 'Tampa'` are dramatically faster on large tables.

### Multi column index

```sql
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
```

This helps queries that filter on `department_id` (and especially those that filter on both `department_id` and `salary`). **Column order matters.** This index doesn't help queries that filter on `salary` alone.

### Unique index

```sql
CREATE UNIQUE INDEX idx_employees_email ON employees(email);
```

Same effect as a `UNIQUE` constraint, plus the speed of an index.

### When to add an index

Add an index when:
- You query a column frequently with `WHERE` or `JOIN`.
- The column has many distinct values.
- The table has lots of rows (indexes don't matter much on tiny tables).

**Don't** add indexes when:
- The column is rarely filtered on.
- You write to the table heavily (indexes slow down INSERT, UPDATE, DELETE).
- The table is small.

> **Rule of thumb:** indexes trade write speed for read speed. Use them where reads dominate.

## 25. DROP / ALTER / REBUILD INDEX

### DROP INDEX

```sql
-- PostgreSQL / SQL Server:
DROP INDEX idx_employees_city;

-- MySQL:
DROP INDEX idx_employees_city ON employees;
```

### ALTER / REBUILD

Most databases don't expose much "alter index." You typically drop and recreate.

**Rebuilding** an index defragments it. Useful after lots of inserts and deletes:

```sql
-- PostgreSQL:
REINDEX INDEX idx_employees_city;

-- SQL Server:
ALTER INDEX idx_employees_city ON employees REBUILD;
```

Rarely needed in everyday work. The database usually handles it automatically.

---

# Part 5: Views, Schemas, Temporary Tables

## 26. Views

A **view** is a **saved SELECT query** that you can query like a table. It doesn't store data. It runs the underlying query each time you reference it.

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

- **Hide complexity.** Bury a complex join behind a simple name.
- **Security.** Give users access to a view that exposes only safe columns or filtered rows.
- **Reusability.** Define the logic once, use it everywhere.

### ALTER VIEW / DROP VIEW

```sql
-- Most dialects: drop and recreate
DROP VIEW engineering_employees;

-- Or CREATE OR REPLACE (PostgreSQL, MySQL):
CREATE OR REPLACE VIEW engineering_employees AS
SELECT id, name, salary, hire_date, city
FROM employees
WHERE department_id = 1;
```

### Materialized views (briefly)

A **materialized view** (PostgreSQL, Oracle) actually **stores** the query result, like a cached table. Faster to read, but you have to refresh it manually when underlying data changes. Useful for expensive queries that run repeatedly.

## 27. CREATE SCHEMA

A **schema** is a namespace inside a database. A way to group related tables, views, and functions.

```sql
CREATE SCHEMA analytics;

CREATE TABLE analytics.daily_revenue (
    date DATE PRIMARY KEY,
    revenue DECIMAL(15, 2)
);

SELECT * FROM analytics.daily_revenue;
```

Why use schemas?
- **Organization.** Separate concerns (transactional tables vs analytics tables).
- **Permissions.** Grant access at the schema level.
- **Avoiding name collisions.** `analytics.users` and `app.users` can coexist.

> **Dialect note:** in **MySQL**, "schema" and "database" are essentially synonyms. In **PostgreSQL**, **SQL Server**, and **Oracle**, a database contains many schemas.

## 28. Temporary Tables

A **temporary table** exists only for the duration of your session (or transaction). It is created the same way as a regular table, but with `TEMPORARY` (or `TEMP`):

```sql
CREATE TEMPORARY TABLE temp_high_earners AS
SELECT * FROM employees WHERE salary > 90000;

SELECT * FROM temp_high_earners;
-- Use it just like any table

-- It disappears when your session ends. No DROP needed.
```

Useful for:
- Breaking complex multi step queries into named intermediate results.
- Avoiding lock contention on real tables.
- Sandboxing experiments.

> **Tip:** CTEs ([Note 05](./05-ctes-and-window-functions.md)) often replace temporary tables for simple cases. Temp tables are better when the same intermediate result is used many times across queries in a session.

---

# Part 6: Information Schema and Metadata

## 29. What Is Metadata?

**Metadata** literally means "data about data." In databases, metadata is the information that describes the *structure* of your database itself: the tables, columns, types, constraints, indexes, and relationships.

When you run `CREATE TABLE employees (...)`, the database stores both:
- The actual rows (the **data**).
- A record of the table's name, columns, types, constraints, and so on (the **metadata**).

Examples of metadata:

| Metadata type | What it describes |
|---------------|-------------------|
| **Table metadata** | Table name, schema it belongs to, owner, creation date |
| **Column metadata** | Column name, data type, max length, nullable or not, default value |
| **Constraint metadata** | Constraint name, type (PK, FK, CHECK, UNIQUE), affected columns |
| **Foreign key metadata** | Which column references which, ON DELETE / ON UPDATE actions |
| **Index metadata** | Index name, indexed columns, unique or not |
| **View metadata** | View name, the query that defines it |
| **User and permission metadata** | Users, roles, who has what permissions |

The database stores all of this in a **system catalog** that you can query with regular SQL.

## 30. INFORMATION_SCHEMA

Every modern RDBMS exposes its metadata through a special read only schema called **`INFORMATION_SCHEMA`**. It is part of the ANSI SQL standard, though each database adds its own extensions.

### Key INFORMATION_SCHEMA views

| View | What it contains |
|------|------------------|
| `INFORMATION_SCHEMA.TABLES` | Every table in the database, with name, schema, type (table or view) |
| `INFORMATION_SCHEMA.COLUMNS` | Every column in every table, with data type, nullable, default |
| `INFORMATION_SCHEMA.TABLE_CONSTRAINTS` | Every constraint, with type (PK, FK, CHECK, UNIQUE) |
| `INFORMATION_SCHEMA.KEY_COLUMN_USAGE` | Which columns make up each PK or FK |
| `INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS` | Which FK references which table, with `ON DELETE` and `ON UPDATE` rules |
| `INFORMATION_SCHEMA.VIEWS` | Every view with its defining SQL |
| `INFORMATION_SCHEMA.SCHEMATA` | Every schema in the database |
| `INFORMATION_SCHEMA.ROUTINES` | Every stored procedure and function |

> **Dialect note:** SQL Server, MySQL, and PostgreSQL all support `INFORMATION_SCHEMA`. Oracle does not (Oracle uses its own `USER_TABLES`, `ALL_TABLES`, `DBA_TABLES` views instead). SQLite has `sqlite_master`.

### Some databases also have their own system catalogs

- **PostgreSQL:** `pg_catalog` (more detailed than INFORMATION_SCHEMA)
- **SQL Server:** `sys.tables`, `sys.columns`, `sys.foreign_keys`, etc.
- **Oracle:** `USER_TABLES`, `ALL_TABLES`, `DBA_TABLES`
- **MySQL:** also has `mysql.*` system tables for users and grants

`INFORMATION_SCHEMA` is the most portable. The dialect specific ones are more detailed.

## 31. Practical Examples

### List all tables in a database

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'sakila';
```

### List all columns of a specific table, with their types

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'film'
  AND table_schema = 'sakila';
```

### Find all foreign keys in the database

```sql
SELECT
    tc.table_name        AS child_table,
    kcu.column_name      AS child_column,
    ccu.table_name       AS parent_table,
    ccu.column_name      AS parent_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

> This query is PostgreSQL specific. The exact join columns vary by dialect.

### Find all check constraints in the database

```sql
SELECT table_name, constraint_name, check_clause
FROM information_schema.check_constraints
JOIN information_schema.table_constraints
    USING (constraint_name)
WHERE table_schema = 'public';
```

### Count rows in every table (approximation)

In PostgreSQL:

```sql
SELECT schemaname, relname AS table_name, n_live_tup AS approx_rows
FROM pg_stat_user_tables
ORDER BY approx_rows DESC;
```

### Why use INFORMATION_SCHEMA?

- **Documentation.** Generate a report of all tables and their columns.
- **Migration scripts.** Programmatically build SQL based on existing tables.
- **Data validation tools.** Check that all foreign keys are properly defined.
- **Database exploration.** When connecting to an unfamiliar database, query `INFORMATION_SCHEMA` to understand what's there.

> **Beginner tip:** when in doubt about what's in a database, query `INFORMATION_SCHEMA.TABLES` to list everything and `INFORMATION_SCHEMA.COLUMNS` to see what each table holds.

---

## Putting It All Together

A realistic DDL script. Defining the schema for our example data, plus constraints, an index, and a view:

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

This script captures the full toolkit: tables, primary and foreign keys, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, auto increment, an index, and a view. All in one tight definition.

---

## Key Takeaways

- **DDL** changes the **structure** of the database. Tables, columns, constraints, indexes, views. Not the data inside.
- **`CREATE TABLE`** with constraints inline is the standard. Use `IF NOT EXISTS` for safety.
- **`ALTER TABLE`** adds, drops, or changes columns. **`DROP TABLE`** removes the whole table. **`TRUNCATE`** wipes all rows fast.
- **Constraints** enforce rules on data: `NOT NULL`, `UNIQUE`, `PRIMARY KEY` (unique plus not null), `FOREIGN KEY` (referential integrity), `CHECK` (custom rules), `DEFAULT` (auto fill).
- A **foreign key** links a **child** (referencing) table to a **parent** (referenced) table. The terms "parent / child" and "referencing / referenced" mean the same thing.
- Foreign keys have **referential actions**: `CASCADE` (propagate), `SET NULL` (clear the link), `RESTRICT` / `NO ACTION` (block the change), `SET DEFAULT`.
- **Dropping a table with FK references** requires either dropping the children first, using `CASCADE`, or dropping the FK constraint first.
- **Normalization** organizes data to reduce redundancy. The common forms are 1NF, 2NF, 3NF, and BCNF. Most production databases sit at 3NF.
- **Denormalization** is deliberately adding redundancy back for read performance. Use it only when measured to be needed.
- **Indexes** speed up reads on filtered or joined columns but slow writes.
- **Views** are saved queries. **Schemas** are namespaces. **Temporary tables** disappear at session end.
- **Metadata** is data about data. Query **`INFORMATION_SCHEMA`** to see your database's own structure.

## Quick Self Check

1. What's the difference between `DROP TABLE`, `TRUNCATE TABLE`, and `DELETE FROM table`?
2. What does a `PRIMARY KEY` enforce? Is it different from `UNIQUE`?
3. Write a `CREATE TABLE` for a `students` table with `id`, `name` (required), `email` (unique), and `gpa` (between 0 and 4).
4. In a foreign key relationship, what is the parent table called? What is the child called?
5. What does `ON DELETE CASCADE` do? What about `ON DELETE SET NULL`?
6. If table A has a foreign key pointing to table B, can you `DROP` table B directly? What are your options?
7. What is the difference between 2NF and 3NF?
8. What is denormalization, and when would you use it?
9. How do you list all the tables in a database using SQL?
10. What's the difference between a temporary table and a CTE?

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
| ON DELETE / CASCADE | [GeeksForGeeks: ON DELETE actions](https://www.geeksforgeeks.org/sql-on-delete-cascade-vs-on-delete-set-null/) |
| CHECK | [W3Schools: CHECK](https://www.w3schools.com/sql/sql_check.asp) |
| DEFAULT | [W3Schools: DEFAULT](https://www.w3schools.com/sql/sql_default.asp) |
| AUTO_INCREMENT | [W3Schools: AUTO_INCREMENT](https://www.w3schools.com/sql/sql_autoincrement.asp) |
| Normalization | [GeeksForGeeks: Normalization](https://www.geeksforgeeks.org/normal-forms-in-dbms/) |
| Denormalization | [GeeksForGeeks: Denormalization](https://www.geeksforgeeks.org/denormalization-in-databases/) |
| INFORMATION_SCHEMA | [GeeksForGeeks: INFORMATION_SCHEMA](https://www.geeksforgeeks.org/information_schema-in-sql/) |
| CREATE INDEX | [W3Schools: CREATE INDEX](https://www.w3schools.com/sql/sql_create_index.asp) |
| VIEW | [W3Schools: VIEW](https://www.w3schools.com/sql/sql_view.asp) |

---

[Prev: DML](./07-dml.md) · [Next: Joins](./09-joins.md)
