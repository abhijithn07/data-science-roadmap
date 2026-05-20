# Note 01: SQL Basics

[Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The full foundation in one note. Every topic from the Basics category, plus environment tools and the five language categories of SQL:

1. What is SQL?
2. DBMS vs RDBMS
3. SQL Server (Microsoft SQL Server)
4. MySQL Workbench
5. Sakila Database
6. Tables, rows, and columns
7. Schemas and databases (the two meanings of "schema")
8. SQL syntax rules
9. SQL keywords and identifiers
10. SQL commands and the five categories: DDL, DML, DQL, DCL, TCL
11. SQL data types
12. Creating a database
13. Using or selecting a database
14. Creating a table
15. Inserting starter data
16. Comments in SQL
17. Operators in SQL
18. NULL values
19. Aliases

Plus the setup SQL for the working example used across all the other notes.

---

## 1. What Is SQL?

**SQL** (pronounced "sequel" or "S Q L") stands for **Structured Query Language**. It is the standard language for talking to a relational database, asking it to give you data, change data, or change the structure of the data.

You write a **query** (a request) in SQL, the database executes it, and you get back a result:

```sql
SELECT name, salary
FROM employees
WHERE city = 'Tampa';
```

In plain English: *"From the employees table, give me the name and salary columns, but only for rows where the city is Tampa."*

SQL is **declarative**. You tell the database *what* you want, not *how* to get it. The database's query planner figures out the most efficient way to run your query under the hood.

SQL has been a standard since 1986 (ANSI SQL). Every major relational database supports it, though each database has small dialect differences. The core language is the same everywhere.

## 2. DBMS vs RDBMS

| Term | Meaning |
|------|---------|
| **DBMS** | Database Management System. Software that stores, manages, and retrieves data. Any kind of database (relational, document, key value, graph) is a DBMS. |
| **RDBMS** | Relational Database Management System. A DBMS where data is stored in tables that can be related to each other using keys. |

The short version: "RDBMS" means "DBMS that uses tables and relationships." All the big SQL databases (PostgreSQL, MySQL, **Microsoft SQL Server**, Oracle, SQLite) are RDBMSs.

Non relational ("NoSQL") DBMSs include MongoDB (document), Redis (key value), Cassandra (wide column), and Neo4j (graph). They have their own query languages.

> **Beginner takeaway:** SQL is the language for RDBMSs. When someone says "SQL database," they mean an RDBMS.

## 3. SQL Server (Microsoft SQL Server)

**SQL Server** is Microsoft's commercial relational database management system. It is one of the most widely used enterprise RDBMSs alongside Oracle, MySQL, and PostgreSQL.

**Key facts about SQL Server:**

| Aspect | Detail |
|--------|--------|
| **Owner / vendor** | Microsoft |
| **SQL dialect** | T SQL (Transact SQL), Microsoft's extension of standard SQL |
| **Latest version** | SQL Server 2022 (as of writing) |
| **Editions** | Express (free, limited), Developer (free for dev/test), Web, Standard, Enterprise |
| **Platforms** | Windows, Linux, Docker, macOS via container |
| **Default tool** | SQL Server Management Studio (SSMS) |
| **Cloud version** | Azure SQL Database, Azure SQL Managed Instance |

**Common terminology confusion:** the phrase "SQL server" (lowercase) is sometimes used generically to mean "any database server running SQL." When someone says "I'm using SQL Server" with capital letters, they specifically mean **Microsoft SQL Server** the product. Context usually makes it clear.

**T SQL extensions** (things T SQL has beyond standard SQL):
- `IDENTITY(1,1)` for auto incrementing columns (similar to MySQL's `AUTO_INCREMENT`)
- `TOP N` instead of `LIMIT N`
- `SELECT INTO` for creating a table from a query result
- Procedural extensions like `IF`, `WHILE`, `TRY...CATCH`
- Stored procedures with `EXEC`
- `GO` as a batch separator (only in SSMS, not standard SQL)

**Sample SQL Server query (T SQL):**

```sql
-- Top 5 employees by salary in SQL Server
SELECT TOP 5 name, salary
FROM employees
ORDER BY salary DESC;
```

## 4. MySQL Workbench

**MySQL Workbench** is the official graphical user interface (GUI) tool for MySQL databases, developed by Oracle (which owns MySQL). It is **not** the same thing as a database. MySQL Workbench is a *client* that connects to a MySQL database server and lets you write queries, design schemas, and administer the server.

> **Naming confusion:** people sometimes shorten "MySQL Workbench" to "SQL Workbench" in conversation. There is a *separate* tool called **SQL Workbench/J** which is a different (JDBC based) product. When someone says "SQL Workbench," they usually mean MySQL Workbench, but it's worth confirming.

**What MySQL Workbench gives you:**

| Feature | What it does |
|---------|--------------|
| **SQL editor** | Write and run queries with syntax highlighting and autocomplete |
| **Visual schema designer** | Draw tables and relationships, generate the SQL to create them |
| **Server administration** | Manage users, monitor performance, configure the server |
| **Data modeling** | Forward engineer (model to database) and reverse engineer (database to model) |
| **Data import / export** | Move data in and out via CSV, JSON, SQL dumps |
| **Visual query builder** | Build queries by clicking instead of typing (for beginners) |

**Connecting to a database:** MySQL Workbench connects to a MySQL server using a hostname, port (default 3306), username, and password. The connection persists across sessions so you can save and reuse it.

**A typical MySQL Workbench workflow:**
1. Open Workbench, click your saved connection, enter password.
2. The Navigator panel on the left shows your databases (schemas).
3. Double click a database to make it the default for queries.
4. Open a new SQL tab, type your query, press Ctrl+Enter (or the lightning icon) to run.
5. Results appear in a grid below the editor.

> **Beginner tip:** MySQL Workbench is *free* and works on Windows, macOS, and Linux. Download from `https://dev.mysql.com/downloads/workbench/`.

## 5. Sakila Database

**Sakila** is the official MySQL sample database. It models a **DVD rental store** with films, customers, rentals, payments, staff, and stores. Sakila is the standard practice dataset for learning SQL because it has realistic data and meaningful relationships across many tables.

**Origin:** Designed by Mike Hillyer, a former member of the MySQL AB documentation team. Released as part of MySQL's sample databases. Available at `https://dev.mysql.com/doc/sakila/en/`.

**Sakila in numbers:**
- 16 tables
- About 1,000 films
- About 16,000 customers
- About 16,000 inventory items
- About 16,000 rentals
- 2 stores, 2 staff members

**The 16 Sakila tables, grouped by purpose:**

| Group | Tables |
|-------|--------|
| **People** | `actor`, `customer`, `staff` |
| **Films** | `film`, `film_actor`, `film_category`, `category`, `language` |
| **Locations** | `address`, `city`, `country`, `store` |
| **Rentals** | `inventory`, `rental`, `payment` |

**Key relationships in Sakila:**
- A `customer` has an `address`, an `address` belongs to a `city`, a `city` belongs to a `country`.
- A `film` has a `language`, has many `actor`s (through `film_actor`), and many `category`s (through `film_category`).
- An `inventory` row is a physical copy of a `film` at a `store`.
- A `rental` is when a `customer` rents an `inventory` copy from a `staff` member.
- A `payment` is linked to a `rental`.

**Loading Sakila into MySQL:**

1. Download the sakila ZIP from MySQL docs.
2. Extract `sakila-schema.sql` (the structure) and `sakila-data.sql` (the data).
3. In MySQL Workbench, open `sakila-schema.sql` and run it. This creates the database and tables.
4. Open `sakila-data.sql` and run it. This loads the rows.
5. Refresh the Navigator. You should see a `sakila` schema with all 16 tables.

**Example query against Sakila:**

```sql
-- How many films are in each rating category?
SELECT rating, COUNT(*) AS film_count
FROM sakila.film
GROUP BY rating
ORDER BY film_count DESC;
```

**Sakila for other databases:** Sakila was designed for MySQL, but it has been ported to PostgreSQL, SQL Server, Oracle, and SQLite. Search for "sakila postgres" or "sakila sql server" to find the port for your database.

> **Why Sakila for learning?** It has enough complexity to practice real joins, aggregations, subqueries, and window functions, but small enough that you can run any query in under a second. Most SQL tutorials, courses, and interview prep sites use it.

## 6. Tables, Rows, and Columns

In a relational database, data lives in **tables**: grids made up of rows and columns, like a spreadsheet but with strict rules.

**`employees`**

| id | name | department_id | salary |
|----|------|---------------|--------|
| 1 | Alice Chen | 1 | 95000 |
| 2 | Bob Patel | 1 | 110000 |

The vocabulary:

| Term | What it means | Other names |
|------|---------------|-------------|
| **Row** | One entry (e.g., "Alice Chen, dept 1, $95,000") | record, tuple |
| **Column** | One vertical slice (e.g., all the "name" values) | field, attribute |
| **Cell** | The intersection of a row and column (one value) | value |
| **Data type** | The kind of value a column holds (number, text, date) | type |
| **Header / column name** | The label at the top of each column | identifier |

> **Beginner tip:** the vocabulary is sometimes used loosely. "Row," "record," and "tuple" all mean the same thing. Same for "column," "field," and "attribute."

## 7. Schemas and Databases

The word "schema" has two distinct meanings in SQL, and beginners often confuse them. Both are correct and both are used in practice.

### Meaning 1: Schema as the structure (blueprint) of data

A schema is the **definition** of how data is organized: the tables, their columns, the data types of those columns, the constraints (rules), and the relationships between tables.

> *"The employees table's schema is: id INT, name TEXT, salary DECIMAL."*

This is "schema as a noun for *the design* of a database or table." It is what you describe in a `CREATE TABLE` statement.

### Meaning 2: Schema as a namespace inside a database

A schema is a **logical container** inside a database that groups related tables, views, and functions together. It is a way to organize a large database into subfolders.

> *"The analytics.daily_sales table lives in the analytics schema."*

This is "schema as an object in the database hierarchy." It is what you create with `CREATE SCHEMA`.

### The hierarchy

```
RDBMS Server (the running database engine)
└── Database: "company_db" (a container)
    ├── Schema: "public" (a namespace)
    │   ├── Table: employees
    │   └── Table: departments
    ├── Schema: "analytics"
    │   └── Table: daily_sales
    └── Schema: "hr"
        └── Table: payroll
```

### Schema vs database in different RDBMSs

| RDBMS | Relationship |
|-------|--------------|
| **MySQL** | "Schema" and "database" are synonyms. `CREATE DATABASE x` and `CREATE SCHEMA x` do the same thing. |
| **PostgreSQL** | A database contains many schemas. Each schema contains tables. Default schema is `public`. |
| **SQL Server** | A database contains many schemas. Default schema is `dbo` (database owner). |
| **Oracle** | A schema is tied to a user account. Each user gets their own schema. |

> **Why this matters:** in MySQL Workbench, the left panel labels things as "Schemas" but they are actually databases. In SQL Server Management Studio, you see a database, then a "Schemas" folder under it, then tables under each schema. Both are correct usages of the word.

### The `information_schema` schema

Every modern RDBMS has a special read only schema called `INFORMATION_SCHEMA` that holds **metadata** (data about data). It contains views like `TABLES`, `COLUMNS`, `KEY_COLUMN_USAGE` that you can query to find out about the database's own structure. Detailed coverage in [Note 08, Information Schema section](./08-ddl.md).

## 8. SQL Syntax Rules

A few rules that make SQL behave predictably:

- **Statements end in a semicolon** (`;`). Required when running multiple statements; optional for a single one in most tools.
- **SQL is case insensitive for keywords.** `SELECT`, `select`, and `Select` all work. Convention: UPPERCASE for keywords, lowercase for table and column names. It makes queries readable.
- **String values go in single quotes** (`'like this'`). Numbers don't. `'Tampa'` is a string. `95000` is a number.
- **Whitespace is mostly ignored.** You can format a query across many lines for readability.
- **Comments are skipped at runtime** (more on these below).

```sql
SELECT name, salary
FROM   employees
WHERE  city = 'Tampa'
ORDER BY salary DESC;
```

## 9. SQL Keywords and Identifiers

Two kinds of words show up in a SQL query:

- **Keywords:** reserved words SQL understands. Examples: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`. You can't use them as names for your own objects.
- **Identifiers:** names *you* give to things. Examples: `employees`, `name`, `salary`. These are your table names, column names, and aliases.

**Rules for identifiers:**
- Start with a letter or underscore.
- Use letters, digits, and underscores.
- Avoid spaces and special characters.
- Don't use SQL keywords as names (use `employee_name`, not `name`, if `name` causes confusion, though `name` is technically allowed).

If you *must* use a name with spaces or special characters, quote it. Use `"double quotes"` in PostgreSQL and SQL Server, or `` `backticks` `` in MySQL:

```sql
SELECT "First Name" FROM customers;   -- PostgreSQL, SQL Server
SELECT `First Name` FROM customers;   -- MySQL
```

## 10. SQL Commands and the Five Categories

This is one of the most important conceptual maps in SQL. Every SQL command belongs to one of **five categories**, each handling a different concern: defining structure, modifying data, reading data, controlling access, or managing transactions.

| Category | Full name | Main commands | Concern |
|----------|-----------|---------------|---------|
| **DDL** | Data Definition Language | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` | The *structure* of database objects |
| **DML** | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE` | The *data inside* tables |
| **DQL** | Data Query Language | `SELECT` | *Reading* data |
| **DCL** | Data Control Language | `GRANT`, `REVOKE` | *Permissions* and access |
| **TCL** | Transaction Control Language | `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `BEGIN` | *Transactions* and atomicity |

Each one is covered in detail in its own note later in this week. Here's the orientation.

### 10.1 DDL (Data Definition Language)

**Purpose:** define and change the *structure* of the database, not the data inside.

**Commands and what they do:**

| Command | Action |
|---------|--------|
| `CREATE` | Make a new object: table, view, index, schema, database. |
| `ALTER` | Modify an existing object: add a column, change a data type, rename. |
| `DROP` | Delete an object entirely (the table and all its data). |
| `TRUNCATE` | Remove all rows from a table while keeping the table structure. |
| `RENAME` | Change the name of a table or column. |

**Example:**

```sql
-- Create a new table
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE
);

-- Add a column
ALTER TABLE customers ADD COLUMN phone TEXT;

-- Delete the table entirely
DROP TABLE customers;
```

**Key behaviors:**
- DDL statements often **auto commit** (each statement is its own transaction in many databases). You usually cannot roll back a `DROP TABLE`.
- DDL changes affect the *schema*, not the data.
- Heavy DDL (creating tables, indexes) can take time on large databases.

Full coverage in [Note 08: DDL](./08-ddl.md).

### 10.2 DML (Data Manipulation Language)

**Purpose:** change the *data inside* existing tables.

**Commands and what they do:**

| Command | Action |
|---------|--------|
| `INSERT` | Add new rows to a table. |
| `UPDATE` | Modify existing rows. |
| `DELETE` | Remove rows. |

**Example:**

```sql
-- Add a row
INSERT INTO customers (id, name, email)
VALUES (1, 'Alice', 'alice@example.com');

-- Modify a row
UPDATE customers SET email = 'alice@new.com' WHERE id = 1;

-- Delete a row
DELETE FROM customers WHERE id = 1;
```

**Key behaviors:**
- DML statements **can be rolled back** in a transaction. This is what makes `BEGIN...ROLLBACK` patterns useful.
- DML *only* changes data, never table structure.
- Always pair `UPDATE` and `DELETE` with a `WHERE` clause unless you really mean "every row."

Full coverage in [Note 07: DML](./07-dml.md).

### 10.3 DQL (Data Query Language)

**Purpose:** *read* data from tables. Doesn't change anything.

**Main command:** `SELECT` (with its clauses `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, and `JOIN`).

**Example:**

```sql
SELECT name, email
FROM customers
WHERE city = 'Tampa'
ORDER BY name;
```

**Note on classification:** some textbooks consider DQL a subcategory of DML (since `SELECT` was historically grouped with the manipulation commands). Other sources, including most modern training material, treat DQL as its own category because read operations are so common and have a distinct purpose. Both views are acceptable.

DQL is the most used category. About 80% of the SQL you'll write in a data role is some flavor of `SELECT`.

Full coverage in Notes 02 to 06.

### 10.4 DCL (Data Control Language)

**Purpose:** control *who can do what* in the database (permissions and access).

**Commands and what they do:**

| Command | Action |
|---------|--------|
| `GRANT` | Give a user or role a permission. |
| `REVOKE` | Take a permission away. |

**Example:**

```sql
-- Give Alice read access to the customers table
GRANT SELECT ON customers TO alice;

-- Allow Bob to add new rows but not delete
GRANT INSERT ON customers TO bob;

-- Take Bob's INSERT permission back
REVOKE INSERT ON customers FROM bob;
```

**Key behaviors:**
- Permissions are usually granted to **roles** (groups of users) rather than individual users for easier management.
- The `GRANT OPTION` allows a user to grant the same permission to others.

Full coverage in [Note 11: DCL and TCL](./11-dcl-tcl.md).

### 10.5 TCL (Transaction Control Language)

**Purpose:** manage **transactions**, which are groups of statements that succeed or fail together as a single unit.

**Commands and what they do:**

| Command | Action |
|---------|--------|
| `BEGIN` (or `START TRANSACTION`) | Start a new transaction. |
| `COMMIT` | Save all changes made in the transaction. |
| `ROLLBACK` | Undo all changes made in the transaction. |
| `SAVEPOINT` | Mark an intermediate point you can roll back to. |
| `RELEASE SAVEPOINT` | Discard a savepoint. |

**Example:**

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;     -- both updates succeed together, or use ROLLBACK to undo both
```

**Key behaviors:**
- Transactions enforce the **ACID properties**: Atomicity, Consistency, Isolation, Durability.
- They are essential for any operation that requires multiple statements to either all succeed or all fail (money transfers, multi step orders).

Full coverage in [Note 11: DCL and TCL](./11-dcl-tcl.md).

### The five categories in one mental map

| You want to... | Use the category | Examples |
|----------------|------------------|----------|
| Build or change the *structure* | DDL | `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE` |
| Add, change, or remove *rows* | DML | `INSERT`, `UPDATE`, `DELETE` |
| *Read* rows | DQL | `SELECT` |
| Control *who can do what* | DCL | `GRANT`, `REVOKE` |
| Group statements into *transactions* | TCL | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> **Beginner takeaway:** every SQL command you see belongs to one of these five. When learning a new command, identifying its category tells you what it does and what to expect from it.

## 11. SQL Data Types

Every column has a **data type** that controls what kind of value it can hold. The exact names vary slightly across dialects, but the categories are universal:

| Category | Common types | What they hold |
|----------|--------------|----------------|
| **Integer (whole numbers)** | `INT`, `INTEGER`, `BIGINT`, `SMALLINT` | `1`, `42`, `7` |
| **Decimal (exact)** | `DECIMAL(p,s)`, `NUMERIC(p,s)` | `95000.00`, `3.14`. For money and precise math. |
| **Floating point (approximate)** | `FLOAT`, `REAL`, `DOUBLE PRECISION` | `3.14159`. For scientific values where exact precision isn't required. |
| **Text** | `VARCHAR(n)`, `TEXT`, `CHAR(n)` | `'Alice'`, `'Tampa'` |
| **Date / Time** | `DATE`, `TIME`, `TIMESTAMP`, `DATETIME` | `'2024-01-15'`, `'2024-01-15 14:30:00'` |
| **Boolean** | `BOOLEAN`, `BOOL` | `TRUE`, `FALSE` |
| **Binary** | `BLOB`, `BYTEA` | Raw bytes: images, files |

> **`DECIMAL` vs `FLOAT`:** for money, always use `DECIMAL`. `FLOAT` can have tiny rounding errors that quickly add up. For scientific measurements, `FLOAT` is fine and faster.

> **`VARCHAR(n)` vs `TEXT`:** `VARCHAR(n)` enforces a maximum length (e.g., `VARCHAR(50)` allows up to 50 characters). `TEXT` has no limit. In PostgreSQL they're roughly equivalent. In older systems `VARCHAR` was sometimes faster.

## 12. Creating a Database

To make a brand new, empty database:

```sql
CREATE DATABASE company_db;
```

That's it. The database now exists but has no tables, no data, just an empty container.

> **Dialect note:** SQLite doesn't have a `CREATE DATABASE` command. Every `.sqlite` file *is* a database. PostgreSQL, MySQL, and SQL Server use `CREATE DATABASE` as shown.

## 13. Using or Selecting a Database

After creating a database, you have to *connect to* or *select* it before you can create tables in it.

```sql
-- MySQL / SQL Server:
USE company_db;

-- PostgreSQL: usually done at connection time, or:
\c company_db
```

After this, any `CREATE TABLE` you run will go into `company_db`.

## 14. Creating a Table

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
- `id INTEGER PRIMARY KEY`. `id` is a whole number and the table's primary key (uniquely identifies each row).
- `name TEXT NOT NULL`. `name` is text and is required (can't be left blank).
- `salary DECIMAL(10, 2)`. Up to 10 digits total, 2 after the decimal point (e.g., `99999999.99`).
- `hire_date DATE`. A date value.

Constraints like `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY`, `CHECK`, `DEFAULT` are covered in detail in [Note 08: DDL](./08-ddl.md).

## 15. Inserting Starter Data

Once the table exists, fill it with rows using `INSERT INTO`:

```sql
INSERT INTO employees (id, name, department_id, salary, hire_date, city) VALUES
    (1, 'Alice Chen', 1, 95000, '2022-03-15', 'Tampa'),
    (2, 'Bob Patel', 1, 110000, '2021-06-20', 'Tampa'),
    (3, 'Carlos Reyes', 2, 75000, '2023-01-10', 'New York');
```

The shape: `INSERT INTO <table> (<column list>) VALUES (<row 1>), (<row 2>), ...;`

You can omit the column list if you provide values for *every* column in the table's defined order, but listing them is safer and clearer.

## 16. Comments in SQL

Comments are ignored when the query runs. Use them to explain your code.

**Single line comment:** anything after `--` until end of line.

```sql
-- Find all employees in Tampa
SELECT name FROM employees WHERE city = 'Tampa';
```

**Multi line (block) comment:** anything between `/*` and `*/`.

```sql
/* Find employees hired after 2022.
   We use this for the new hire training list. */
SELECT name FROM employees WHERE hire_date > '2022-01-01';
```

## 17. Operators in SQL

Operators are symbols (or keywords) that compare or combine values. They show up everywhere: `WHERE` clauses, `CASE` expressions, calculated columns.

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
SELECT name, salary, salary * 0.10 AS bonus
FROM employees
WHERE (city = 'Tampa' OR city = 'New York')
  AND salary > 70000
  AND NOT department_id = 4;
```

There are also **special operators** (`BETWEEN`, `IN`, `LIKE`, `IS NULL`) covered in the next note (SELECT & Filter).

## 18. NULL Values

`NULL` is SQL's way of saying "no value": the absence of data, not zero, not an empty string. It is a critical concept to understand because `NULL` behaves differently from any other value.

### The three valued logic surprise

Any comparison with `NULL` returns `NULL` (which means "unknown"), not `TRUE` or `FALSE`:

```sql
SELECT 5 = NULL;       -- result: NULL (not FALSE)
SELECT 5 <> NULL;      -- result: NULL (not TRUE)
SELECT NULL = NULL;    -- result: NULL (not TRUE)
```

This is why you can't use `=` to test for `NULL`. You have to use the special operators `IS NULL` and `IS NOT NULL`:

```sql
-- WRONG: won't match anything
SELECT name FROM employees WHERE department_id = NULL;

-- RIGHT
SELECT name FROM employees WHERE department_id IS NULL;
```

### NULL in calculations

Any arithmetic with `NULL` returns `NULL`:

```sql
SELECT 100 + NULL;    -- result: NULL
SELECT 100 * NULL;    -- result: NULL
```

This can silently break calculations. Functions like `COALESCE`, `IFNULL`, and `ISNULL` handle `NULL` safely (covered in the Functions note).

### NULL and aggregates

Most aggregate functions **ignore `NULL` values**. `COUNT(column)` doesn't count nulls. `AVG(column)` averages only non null values. `COUNT(*)` counts *all* rows including nulls (because it counts rows, not values).

> **Beginner principle:** treat `NULL` as a third truth value beyond `TRUE` and `FALSE` (think of it as "unknown"). Use `IS NULL` and `IS NOT NULL`, and remember that `NULL` poisons calculations unless you handle it.

## 19. Aliases

An **alias** is a temporary nickname you give to a column or table inside a query. It makes results readable and lets you reference the same table twice. The keyword is `AS` (often optional).

### Column aliases: renaming output

```sql
SELECT name AS employee_name,
       salary * 12 AS annual_salary
FROM employees;
```

Without aliases, the calculated column would show up with an ugly auto generated name like `?column?` or `salary * 12`. The alias gives it a clean label.

If the alias has spaces, wrap it in double quotes:

```sql
SELECT salary AS "Annual Salary" FROM employees;
```

### Table aliases: shorter references

When joining or referencing tables many times, give them short aliases:

```sql
SELECT e.name, d.name AS department
FROM employees AS e
JOIN departments AS d
  ON e.department_id = d.id;
```

`e` and `d` save typing and make complex joins readable. The `AS` is optional. `FROM employees e` works the same as `FROM employees AS e`.

> **Beginner tip:** aliases only exist for the duration of *that one query*. They don't change the underlying table or column names.

---

## The Working Example: Setup SQL

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
- **SQL Server** is Microsoft's RDBMS, using the T SQL dialect. The generic phrase "SQL server" sometimes means any database server. SQL Server Management Studio (SSMS) is the standard client.
- **MySQL Workbench** is the official GUI client for MySQL (free, by Oracle). It is *not* a database. It connects to a MySQL server.
- **Sakila** is the standard MySQL sample database (DVD rental store, 16 tables) used for learning SQL.
- Data lives in **tables** made of **rows** and **columns**, with each column having a **data type**.
- A **database** is a top level container. A **schema** has two meanings: the structure of a database, *and* a namespace inside a database.
- SQL has **five command categories**: DDL (structure), DML (data), DQL (reading), DCL (permissions), TCL (transactions).
- SQL is **case insensitive for keywords**, statements end in `;`, and strings go in **single quotes**.
- **Data types** matter. Use `DECIMAL` for money, `DATE` for dates, `VARCHAR` or `TEXT` for strings.
- `--` and `/* */` are how you write **comments**.
- **Operators:** `=`, `<>`, `<`, `>`, `AND`, `OR`, `NOT`, `+`, `-`, `*`, `/`.
- **`NULL`** means "no value." It's not zero. Compare with `IS NULL`, never `= NULL`.
- **Aliases** (`AS`) give temporary nicknames to columns and tables for readability.

## Quick Self Check

1. What's the difference between a DBMS and an RDBMS?
2. What is SQL Server, and what does T SQL refer to?
3. Why is MySQL Workbench not the same as MySQL?
4. What is Sakila and why is it used for learning SQL?
5. Name the five categories of SQL commands and one command in each.
6. What are the two meanings of the word "schema"?
7. Why use `DECIMAL` instead of `FLOAT` for storing money?
8. What does `WHERE department_id = NULL` return, and why?
9. What's the difference between `COUNT(*)` and `COUNT(department_id)` when there are nulls?
10. Why use table aliases (`employees e`) in queries?

## Further Reading

| Topic | Reference |
|-------|-----------|
| SQL overview | [W3Schools: SQL](https://www.w3schools.com/sql/) |
| SQL Server docs | [Microsoft: SQL Server](https://learn.microsoft.com/sql/sql-server/) |
| MySQL Workbench | [MySQL Workbench docs](https://dev.mysql.com/doc/workbench/en/) |
| Sakila Sample DB | [MySQL: Sakila](https://dev.mysql.com/doc/sakila/en/) |
| Data types | [W3Schools: Data Types](https://www.w3schools.com/sql/sql_datatypes.asp) |
| SQL command categories | [GeeksForGeeks: SQL command types](https://www.geeksforgeeks.org/sql-ddl-dml-dcl-tcl-commands/) |
| Syntax | [W3Schools: SQL Syntax](https://www.w3schools.com/sql/sql_syntax.asp) |
| CREATE DATABASE | [W3Schools: CREATE DB](https://www.w3schools.com/sql/sql_create_db.asp) |
| Operators | [W3Schools: SQL Operators](https://www.w3schools.com/sql/sql_operators.asp) |
| NULL | [W3Schools: NULL Values](https://www.w3schools.com/sql/sql_null_values.asp) |
| Aliases | [W3Schools: SQL Aliases](https://www.w3schools.com/sql/sql_alias.asp) |

---

[Back to Week 1](../README.md) · [Next: SELECT & Filter](./02-select-and-filter.md)
