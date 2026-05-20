# Week 1 - SQL

The first stop on the roadmap, and the most universally useful skill in data. **SQL** (Structured Query Language) is how you ask questions of stored data. Every data analyst, scientist, and engineer uses it.

These notes cover SQL **end to end** - from "what is a database" to ACID, transactions, and window functions - broken into 11 focused notes you can work through in order.

→ Back to [Roadmap Home](../README.md) · [Overview](../00-overview/README.md)

---

## What You'll Learn This Week

Organized by SQL category (the standard breakdown used in interviews and textbooks):

| Category | What it's for | Examples |
|----------|---------------|----------|
| **Basics** | Foundational concepts and setup | What is SQL, tables, data types, NULL, aliases |
| **DQL** (Data Query Language) | *Reading* data | `SELECT`, `WHERE`, `GROUP BY`, subqueries, CTEs, window functions |
| **DML** (Data Manipulation Language) | *Modifying* data | `INSERT`, `UPDATE`, `DELETE` |
| **DDL** (Data Definition Language) | Defining the *structure* of tables | `CREATE`, `ALTER`, `DROP`, constraints, indexes, views |
| **Joins & Relationships** | Combining data across tables | `INNER`, `LEFT`, `RIGHT`, `FULL OUTER`, self joins |
| **Functions & Programming** | Built-in functions and procedural SQL | String, numeric, date functions, stored procedures, UDFs |
| **DCL & TCL** (Control & Transaction) | Permissions, transactions, concurrency | `GRANT`, `REVOKE`, `COMMIT`, `ROLLBACK`, ACID, isolation levels |

## Why Start With SQL?

Look at the [data roles table in the overview](../00-overview/README.md#the-data-roles) - SQL shows up in *every* role. Most data lives in databases that speak SQL, and the syntax barely changes year to year. It's the most stable, transferable skill on the roadmap.

SQL maps to the **Store, Clean, Analyze** stages of the [data lifecycle](../00-overview/README.md#the-data-lifecycle).

## Getting Set Up

You don't need to install anything heavy to start.

| Option | What it is | Good for |
|--------|-----------|----------|
| **[DB Fiddle](https://www.db-fiddle.com/)** | Run SQL in a browser tab - no install | Quick experiments, switching dialects |
| **SQLite + [DB Browser for SQLite](https://sqlitebrowser.org/)** | A lightweight local database in a single file | Following along locally |
| **PostgreSQL + pgAdmin** | A production-grade database with a GUI | Full power, standard syntax |

For **practice problems** (essential for interview prep): [HackerRank SQL](https://www.hackerrank.com/domains/sql), [LeetCode SQL 50](https://leetcode.com/studyplan/top-sql-50/), [StrataScratch](https://www.stratascratch.com/).

## Notes

| # | Note | Covers | Status |
|---|------|--------|--------|
| 01 | [Basics](./notes/01-basics.md) | What SQL is, DBMS vs RDBMS, tables, schemas, syntax, data types, NULL, aliases, operators | ✅ |
| 02 | [SELECT & Filter](./notes/02-select-and-filter.md) | `SELECT`, `DISTINCT`, `WHERE`, `ORDER BY`, `LIMIT`, `LIKE`, wildcards, `IN`, `BETWEEN`, `IS NULL` | ✅ |
| 03 | [Aggregation & CASE](./notes/03-aggregation-and-case.md) | Aggregate functions, `GROUP BY`, `HAVING`, `CASE` expressions | ✅ |
| 04 | [Subqueries](./notes/04-subqueries.md) | Subqueries, correlated subqueries, `EXISTS`, `ANY`/`ALL`, derived tables, `CREATE TABLE AS` | ✅ |
| 05 | [CTEs & Window Functions](./notes/05-ctes-and-window-functions.md) | `WITH`, recursive CTEs, window functions, ranking, `LAG`/`LEAD`, window frames | ✅ |
| 06 | [PIVOT & Set Operations](./notes/06-pivot-and-set-operations.md) | `PIVOT`/`UNPIVOT`, `UNION`, `INTERSECT`, `EXCEPT` | ✅ |
| 07 | [DML](./notes/07-dml.md) | `INSERT`, `INSERT INTO SELECT`, `UPDATE`, `DELETE` | ✅ |
| 08 | [DDL](./notes/08-ddl.md) | `CREATE`/`ALTER`/`DROP`, constraints, indexes, views, schemas, temporary tables | ✅ |
| 09 | [Joins](./notes/09-joins.md) | `INNER`, `LEFT`, `RIGHT`, `FULL OUTER`, `CROSS`, `SELF`, multi-table, many-to-many | ✅ |
| 10 | [Functions & Programming](./notes/10-functions-and-programming.md) | String/numeric/date functions, `CAST`, `COALESCE`, regex, UDFs, stored procedures | ✅ |
| 11 | [DCL & TCL](./notes/11-dcl-tcl.md) | `GRANT`/`REVOKE`, `COMMIT`/`ROLLBACK`, `SAVEPOINT`, ACID, isolation levels, locks, MVCC | ✅ |

## The Working Example

All notes use the same two tables so the examples build up consistently:

**`employees`**

| id | name | department_id | salary | hire_date | city |
|----|------|---------------|--------|-----------|------|
| 1 | Alice Chen | 1 | 95000 | 2022-03-15 | Tampa |
| 2 | Bob Patel | 1 | 110000 | 2021-06-20 | Tampa |
| 3 | Carlos Reyes | 2 | 75000 | 2023-01-10 | New York |
| 4 | Diana Kim | 3 | 88000 | 2020-11-05 | San Francisco |
| 5 | Ethan Brown | 1 | 70000 | 2024-02-28 | Remote |
| 6 | Fatima Ali | 4 | 65000 | 2023-08-12 | Tampa |
| 7 | Grace Liu | 2 | 80000 | 2022-09-01 | New York |
| 8 | Hiroshi Tanaka | 3 | 92000 | 2021-04-18 | San Francisco |

**`departments`**

| id | name | location |
|----|------|----------|
| 1 | Engineering | Tampa |
| 2 | Marketing | New York |
| 3 | Sales | San Francisco |
| 4 | HR | Tampa |

(Setup SQL is at the end of [Note 01 - Basics](./notes/01-basics.md#the-working-example--setup-sql).)

## Progress

- [x] Read notes 01–11 - **Week 1 SQL complete!**
- [ ] Run every example yourself in DB Fiddle or your local database
- [ ] Do the Quick Self-Check questions at the end of each note
- [ ] Solve 15+ SQL problems on HackerRank or LeetCode
- [ ] Push notes and any practice queries to GitHub
- [ ] Move on to Week 2 - Python

---

*Part of my [Data Science Roadmap](../README.md) · Week 1 of 7*
