# Note 01 — SQL Basics

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The full foundation, in one note. Every topic from the **Basics** category of the syllabus:

1. What is SQL?
2. DBMS vs. RDBMS
3. Tables, rows, and columns
4. Schemas and databases
5. SQL syntax rules
6. SQL keywords and identifiers
7. SQL data types
8. Creating a database
9. Using / selecting a database
10. Creating a table
11. Inserting starter data
12. Comments in SQL
13. Operators in SQL
14. NULL values
15. Aliases

Plus the **setup SQL** for the working example used across all the other notes.

---

## 1. What Is SQL?

**SQL** (pronounced "sequel" or "S-Q-L") stands for **Structured Query Language**. It's the standard language for **talking to a relational database** — asking it to give you data, change data, or change the structure of the data.

You write a **query** (a request) in SQL, the database executes it, and you get back a result:

```sql
SELECT name, salary
FROM employees
WHERE city = 'Tampa';
```

In plain English: *"From the employees table, give me the name and salary columns, but only for rows where the city is Tampa."*

SQL is **declarative** — you tell the database *what* you want, not *how* to get it. The database's query planner figures out the most efficient way to run your query under the hood.

## 2. DBMS vs. RDBMS

| Term | Meaning |
|------|---------|
| **DBMS** | **Database Management System** — software that stores, manages, and retrieves data. Any kind of database (relational, document, key-value, graph) is a DBMS. |
| **RDBMS** | **Relational Database Management System** — a DBMS where data is stored in **tables that can be related to each other** using keys. |

**The short version:** "RDBMS" = "DBMS that uses tables and relationships." All the big SQL databases — PostgreSQL, MySQL, SQL Server, Oracle, SQLite — are RDBMSs.

Non-relational ("NoSQL") DBMSs include MongoDB (document), Redis (key-value), Cassandra (wide-column), and Neo4j (graph). They have their own query languages.

> **Beginner takeaway:** SQL is the language for RDBMSs. When someone says "SQL database," they mean an RDBMS.

## 3. Tables, Rows, and Columns

In a relational database, data lives in **tables** — grids made up of rows and columns, like a spreadsheet but with strict rules.

**`employees`**

| id | name | department_id | salary |
|----|------|---------------|--------|
| 1 | Alice Chen | 1 | 95000 |
| 2 | Bob Patel | 1 | 110000 |

The vocabulary:

| Term | What it means | Other names |
|------|---------------|-------------|
| **Row** | One entry — e.g., "Alice Chen, dept 1, $95,000" | record, tuple |
| **Column** | One vertical slice — e.g., all the "name" values | field, attribute |
| **Cell** | The intersection of a row and column — one value | value |
| **Data type** | The kind of value a column holds (number, text, date…) | type |
| **Header / column name** | The label at the top of each column | identifier |

> **Beginner tip:** the vocabulary is sometimes used loosely. "Row," "record," and "tuple" all mean the same thing. Same for "column," "field," and "attribute."

## 4. Schemas and Databases

These two words get used differently in different products, so they confuse beginners. Here's the clean version:

- **Database** — a top-level container that holds related data. A single RDBMS server can host many databases.
- **Schema** — has two meanings, both correct:
  1. **The *structure* of a database or table** — its columns, types, and rules. ("The `employees` table's schema is `id INT, name TEXT, salary DECIMAL`.")
  2. **A namespace inside a database** — a grouping that contains tables, views, etc. ("The `analytics.daily_sales` table lives in the `analytics` schema.")

```
RDBMS Server
└── Database: "company_db"
    ├── Schema: "public"
    │   ├── Table: employees
    │   └── Table: departments
    └── Schema: "analytics"
        └── Table: daily_sales
```

> **In MySQL**, "database" and "schema" are essentially synonyms — confusing but true. In **PostgreSQL** and **SQL Server**, a database contains schemas, and schemas contain tables.

## 5. SQL Syntax Rules

A few rules that make SQL behave predictably:

- **Statements end in a semicolon** `;` — required when running multiple statements at once; optional for a single one in most tools.
- **SQL is case-insensitive** for keywords. `SELECT`, `select`, and `Select` all work. Convention: **UPPERCASE for keywords**, lowercase for table and column names. It makes queries readable.
- **String values go in single quotes** `'like this'`. Numbers don't. `'Tampa'` is a string; `95000` is a number.
- **Whitespace is mostly ignored.** You can format a query across many lines for readability.
- **Comments are skipped at runtime** (more on these below).

```sql
-- This is good SQL style:
SELECT name, salary
FROM   employees
WHERE  city = 'Tampa'
ORDER BY salary DESC;
```

## 6. SQL Keywords and Identifiers

Two kinds of words show up in a SQL query:

- **Keywords** — reserved words SQL understands: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`, etc. You can't use them as names.
- **Identifiers** — names *you* give to things: table names, column names, aliases. Example: `employees`, `name`, `salary`.

**Rules for identifiers:**
- Start with a letter or underscore.
- Use letters, digits, and underscores.
- Avoid spaces and special characters.
- Don't use SQL keywords as names (use `employee_name`, not `name` if `name` causes confusion — though `name` is technically allowed).

If you *must* use a name with spaces or special characters, quote it (using `"double quotes"` in PostgreSQL/standard SQL, or `` `backticks` `` in MySQL):

```sql
SELECT "First Name" FROM customers;   -- PostgreSQL
SELECT `First Name` FROM customers;   -- MySQL
```

## 7. SQL Data Types

Every column has a **data type** that controls what kind of value it can hold. The exact names vary slightly across dialects, but the categories are universal:

| Category | Common types | What they hold |
|----------|--------------|----------------|
| **Integer (whole numbers)** | `INT`, `INTEGER`, `BIGINT`, `SMALLINT` | `1`, `42`, `-7` |
| **Decimal (exact)** | `DECIMAL(p,s)`, `NUMERIC(p,s)` | `95000.00`, `3.14` — for money and precise math |
| **Floating-point (approximate)** | `FLOAT`, `REAL`, `DOUBLE PRECISION` | `3.14159` — for scientific values where exact precision isn't required |
| **Text** | `VARCHAR(n)`, `TEXT`, `CHAR(n)` | `'Alice'`, `'Tampa'` |
| **Date / Time** | `DATE`, `TIME`, `TIMESTAMP`, `DATETIME` | `'2024-01-15'`, `'2024-01-15 14:30:00'` |
| **Boolean** | `BOOLEAN`, `BOOL` | `TRUE`, `FALSE` |
| **Binary** | `BLOB`, `BYTEA` | Raw bytes — images, files |

> **`DECIMAL` vs. `FLOAT`:** for money, *always* use `DECIMAL` — `FLOAT` can have tiny rounding errors that quickly add up. For scientific measurements, `FLOAT` is fine and faster.

> **`VARCHAR(n)` vs. `TEXT`:** `VARCHAR(n)` enforces a maximum length (e.g., `VARCHAR(50)` allows up to 50 characters). `TEXT` has no limit. In PostgreSQL they're roughly equivalent; in older systems `VARCHAR` was sometimes faster.

## 8. Creating a Database

To make a brand-new, empty database:

```sql
CREATE DATABASE company_db;
```

That's it. The database now exists but has no tables, no data — just an empty container.

> **Dialect note:** SQLite doesn't have a `CREATE DATABASE` command — every `.sqlite` file *is* a database. PostgreSQL and MySQL use `CREATE DATABASE` as shown.

## 9. Using / Selecting a Database

After creating a database, you have to *connect to* or *select* it before you can create tables in it.

```sql
-- MySQL / SQL Server:
USE company_db;

-- PostgreSQL: usually done at connection time, or:
\c company_db
```

After this, any `CREATE TABLE` you run will go into `company_db`.

## 10. Creating a Table

A table is defined by listing its columns, their types, and any rules:

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER,
    salary DECIMAL(10, 2),
    hire_date DATE,
    city TEXT
);
```

Reading this:
- `id INTEGER PRIMARY KEY` — `id` is a whole number and the table's primary key (uniquely identifies each row).
- `name TEXT NOT NULL` — `name` is text and is required (can't be left blank).
- `salary DECIMAL(10, 2)` — up to 10 digits total, 2 after the decimal point (e.g., `99999999.99`).
- `hire_date DATE` — a date value.

Constraints like `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY`, `CHECK`, `DEFAULT` are covered in detail in the DDL note.

## 11. Inserting Starter Data

Once the table exists, fill it with rows using `INSERT INTO`:

```sql
INSERT INTO employees (id, name, department_id, salary, hire_date, city) VALUES
    (1, 'Alice Chen', 1, 95000, '2022-03-15', 'Tampa'),
    (2, 'Bob Patel', 1, 110000, '2021-06-20', 'Tampa'),
    (3, 'Carlos Reyes', 2, 75000, '2023-01-10', 'New York');
```

The shape: `INSERT INTO <table> (<column list>) VALUES (<row 1>), (<row 2>), …;`

You can omit the column list if you provide values for *every* column in the table's defined order — but listing them is safer and clearer.

## 12. Comments in SQL

Comments are ignored when the query runs. Use them to explain your code.

**Single-line comment:** anything after `--` until end of line.
```sql
-- Find all employees in Tampa
SELECT name FROM employees WHERE city = 'Tampa';
```

**Multi-line (block) comment:** anything between `/*` and `*/`.
```sql
/* Find employees hired after 2022.
   We use this for the new-hire training list. */
SELECT name FROM employees WHERE hire_date > '2022-01-01';
```

## 13. Operators in SQL

Operators are symbols (or keywords) that compare or combine values. They show up everywhere — `WHERE` clauses, `CASE` expressions, calculated columns, etc.

**Comparison operators:**

| Operator | Meaning |
|----------|---------|
| `=` | equal to |
| `<>` or `!=` | not equal to |
| `>` | greater than |
| `<` | less than |
| `>=` | greater than or equal to |
| `<=` | less than or equal to |

**Logical operators** (combine conditions):

| Operator | Meaning |
|----------|---------|
| `AND` | both must be true |
| `OR` | at least one must be true |
| `NOT` | inverts the condition |

**Arithmetic operators:**

| Operator | Meaning |
|----------|---------|
| `+` | addition |
| `-` | subtraction |
| `*` | multiplication |
| `/` | division |
| `%` | modulo (remainder) |

```sql
-- All operators in one example:
SELECT name, salary, salary * 0.10 AS bonus
FROM employees
WHERE (city = 'Tampa' OR city = 'New York')
  AND salary > 70000
  AND NOT department_id = 4;
```

There are also **special operators** — `BETWEEN`, `IN`, `LIKE`, `IS NULL` — covered in the next note (SELECT & Filter).

## 14. NULL Values

**`NULL` is SQL's way of saying "no value" — the absence of data**, not zero, not an empty string. It's a critical concept to understand because **`NULL` behaves differently from any other value**.

### The Three-Valued Logic Surprise

Any comparison with `NULL` returns `NULL` (which means "unknown"), not `TRUE` or `FALSE`:

```sql
SELECT 5 = NULL;       -- result: NULL (not FALSE!)
SELECT 5 <> NULL;      -- result: NULL (not TRUE!)
SELECT NULL = NULL;    -- result: NULL (not TRUE!)
```

This is why **you can't use `=` to test for `NULL`**. You have to use the special operators `IS NULL` and `IS NOT NULL`:

```sql
-- WRONG — won't match anything:
SELECT name FROM employees WHERE department_id = NULL;

-- RIGHT:
SELECT name FROM employees WHERE department_id IS NULL;
```

### NULL in Calculations

Any arithmetic with `NULL` returns `NULL`:

```sql
SELECT 100 + NULL;    -- result: NULL
SELECT 100 * NULL;    -- result: NULL
```

This can silently break calculations. Functions like `COALESCE`, `IFNULL`, and `ISNULL` handle `NULL` safely — covered in the Functions note.

### NULL and Aggregates

Most aggregate functions **ignore `NULL` values**. `COUNT(column)` doesn't count nulls; `AVG(column)` averages only non-null values. `COUNT(*)` counts *all* rows including nulls (because it counts rows, not values).

> **Beginner principle:** treat `NULL` as a third truth value beyond `TRUE`/`FALSE` — "unknown." Use `IS NULL` and `IS NOT NULL`, and remember that `NULL` poisons calculations unless you handle it.

## 15. Aliases

An **alias** is a temporary nickname you give to a column or table inside a query. It makes results readable and lets you reference the same table twice. The keyword is `AS` (often optional).

### Column Aliases — Renaming Output

```sql
SELECT name AS employee_name,
       salary * 12 AS annual_salary
FROM employees;
```

Without aliases, the calculated column would show up with an ugly auto-generated name like `?column?` or `salary * 12`. The alias gives it a clean label.

If the alias has spaces, wrap it in double quotes:
```sql
SELECT salary AS "Annual Salary" FROM employees;
```

### Table Aliases — Shorter References

When joining or referencing tables many times, give them short aliases:

```sql
SELECT e.name, d.name AS department
FROM employees AS e
JOIN departments AS d
  ON e.department_id = d.id;
```

`e` and `d` save typing and make complex joins readable. The `AS` is optional — `FROM employees e` works the same as `FROM employees AS e`.

> **Beginner tip:** aliases only exist for the duration of *that one query*. They don't change the underlying table or column names.

---

## The Working Example — Setup SQL

The two tables used across all SQL notes. Drop this into [DB Fiddle](https://www.db-fiddle.com/) (pick PostgreSQL) or your own database to follow along:

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

INSERT INTO departments (id, name, location) VALUES
    (1, 'Engineering', 'Tampa'),
    (2, 'Marketing', 'New York'),
    (3, 'Sales', 'San Francisco'),
    (4, 'HR', 'Tampa');

INSERT INTO employees (id, name, department_id, salary, hire_date, city) VALUES
    (1, 'Alice Chen', 1, 95000, '2022-03-15', 'Tampa'),
    (2, 'Bob Patel', 1, 110000, '2021-06-20', 'Tampa'),
    (3, 'Carlos Reyes', 2, 75000, '2023-01-10', 'New York'),
    (4, 'Diana Kim', 3, 88000, '2020-11-05', 'San Francisco'),
    (5, 'Ethan Brown', 1, 70000, '2024-02-28', 'Remote'),
    (6, 'Fatima Ali', 4, 65000, '2023-08-12', 'Tampa'),
    (7, 'Grace Liu', 2, 80000, '2022-09-01', 'New York'),
    (8, 'Hiroshi Tanaka', 3, 92000, '2021-04-18', 'San Francisco');
```

---

## Key Takeaways

- **SQL** is the declarative language for talking to a **relational database (RDBMS)**.
- Data lives in **tables** made of **rows** and **columns**, with each column having a **data type**.
- A **database** is a container; a **schema** is either the structure of a table or a namespace inside a database (depending on context).
- SQL is **case-insensitive for keywords**, statements end in `;`, and strings go in **single quotes**.
- **Data types** matter — use `DECIMAL` for money, `DATE` for dates, `VARCHAR`/`TEXT` for strings.
- `CREATE DATABASE`, `USE`, `CREATE TABLE`, and `INSERT INTO` are the core "setup" commands.
- `--` and `/* */` are how you write **comments**.
- **Operators**: `=`, `<>`, `<`, `>`, `AND`, `OR`, `NOT`, `+`, `-`, `*`, `/`.
- **`NULL`** means "no value" — it's not zero, and you compare with `IS NULL`, never `= NULL`.
- **Aliases** (`AS`) give temporary nicknames to columns and tables for readability.

## Quick Self-Check

1. What's the difference between a DBMS and an RDBMS?
2. Why use `DECIMAL` instead of `FLOAT` for storing money?
3. What does `WHERE department_id = NULL` return, and why?
4. What's the difference between `COUNT(*)` and `COUNT(department_id)` when there are nulls?
5. Why use table aliases (`employees e`) in queries?

## Further Reading

| Topic | Reference |
|-------|-----------|
| SQL overview | [W3Schools: SQL](https://www.w3schools.com/sql/) |
| Data types | [W3Schools: Data Types](https://www.w3schools.com/sql/sql_datatypes.asp) |
| Syntax | [W3Schools: SQL Syntax](https://www.w3schools.com/sql/sql_syntax.asp) |
| CREATE DATABASE | [W3Schools: CREATE DB](https://www.w3schools.com/sql/sql_create_db.asp) |
| CREATE TABLE | [W3Schools: CREATE TABLE](https://www.w3schools.com/sql/sql_create_table.asp) |
| Operators | [W3Schools: SQL Operators](https://www.w3schools.com/sql/sql_operators.asp) |
| NULL | [W3Schools: NULL Values](https://www.w3schools.com/sql/sql_null_values.asp) |
| Aliases | [W3Schools: SQL Aliases](https://www.w3schools.com/sql/sql_alias.asp) |
| Comments | [W3Schools: Comments](https://www.w3schools.com/sql/sql_comments.asp) |

---

[← Back to Week 1](../README.md) · [Next: SELECT & Filter →](./02-select-and-filter.md)
