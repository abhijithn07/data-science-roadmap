# Note 11 - DCL & TCL - Permissions, Transactions, Concurrency

[← Back to Week 1: SQL](../README.md)

---

## What You'll Learn Here

The two remaining categories - and the most "production-grade" topics in SQL:

**DCL - Data Control Language (permissions):**

1. **`GRANT`**
2. **`REVOKE`**
3. **Roles and privileges**

**TCL - Transaction Control Language:**

4. **`COMMIT`**
5. **`ROLLBACK`**
6. **`SAVEPOINT`**
7. **ACID properties**
8. **Transaction isolation levels**
9. **Locks and blocking**
10. **Deadlocks**
11. **Concurrency control / MVCC**

These topics rarely show up in a beginner's day-to-day SQL - but they're **essential for any production work**, and they come up *constantly* in technical interviews.

---

# Part 1 - DCL (Permissions)

## 1. GRANT - Giving Permission

`GRANT` gives a user (or role) the right to do something. The shape:

```sql
GRANT <privilege> ON <object> TO <user>;
```

### Common Privileges

| Privilege | What it allows |
|-----------|----------------|
| `SELECT` | Read from the table |
| `INSERT` | Add new rows |
| `UPDATE` | Modify existing rows |
| `DELETE` | Remove rows |
| `ALL PRIVILEGES` | Everything |

### Examples

```sql
-- Let bob read the employees table:
GRANT SELECT ON employees TO bob;

-- Let alice modify employees (INSERT, UPDATE, DELETE) too:
GRANT SELECT, INSERT, UPDATE, DELETE ON employees TO alice;

-- Or all in one:
GRANT ALL PRIVILEGES ON employees TO alice;
```

### Grant on All Tables in a Schema

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only_users;
```

### Grant Option - passing the power on

```sql
GRANT SELECT ON employees TO bob WITH GRANT OPTION;
-- Now bob can also grant SELECT on employees to other users
```

---

## 2. REVOKE - Taking Permission Away

The mirror image of `GRANT`:

```sql
REVOKE SELECT ON employees FROM bob;

REVOKE ALL PRIVILEGES ON employees FROM alice;
```

If the user was given `WITH GRANT OPTION` and granted to others, you may also revoke from those downstream users - use `CASCADE`:

```sql
REVOKE SELECT ON employees FROM bob CASCADE;
```

---

## 3. Roles and Privileges

A **role** is a *named bundle of permissions* you assign to one or many users. Roles make permission management scalable - instead of granting privileges to each user individually, you define roles and assign users to them.

### Creating roles

```sql
-- Create a role:
CREATE ROLE analyst;

-- Grant permissions to the role:
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- Assign users to the role:
GRANT analyst TO bob, alice, carol;
```

Now Bob, Alice, and Carol all have read access - and if you want to add another permission to the role, you just `GRANT` it to `analyst` once. All three (and any future role members) inherit it.

### Privileges vs. Roles - the difference

- **Privilege** = a specific permission (e.g., `SELECT` on a specific table).
- **Role** = a named group of privileges (and possibly other roles).

Most production databases use roles for everything - direct user grants are rare.

---

# Part 2 - TCL (Transactions)

## What Is a Transaction?

A **transaction** is a group of SQL statements treated as **a single unit of work**. Either all of them succeed and are saved (`COMMIT`), or none of them are saved (`ROLLBACK`).

The classic example: transferring money between accounts.

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

If the second `UPDATE` fails (e.g., account 2 doesn't exist), you don't want the first to have already happened. Transactions make that guarantee.

---

## 4. COMMIT - Save the Changes

`COMMIT` finalizes a transaction. Everything you did since `BEGIN` (or `START TRANSACTION`) becomes permanent and visible to other users.

```sql
BEGIN;
    INSERT INTO employees (id, name, salary) VALUES (9, 'Ivan', 85000);
    UPDATE employees SET salary = 90000 WHERE id = 9;
COMMIT;
```

After `COMMIT`, the row exists with salary 90000 - and there's no going back.

> Many database tools (like psql, the MySQL CLI) **auto-commit** by default - each statement is its own transaction. To group statements, you have to start a transaction explicitly with `BEGIN`.

---

## 5. ROLLBACK - Throw the Changes Away

`ROLLBACK` undoes everything done since the transaction began.

```sql
BEGIN;
    DELETE FROM employees WHERE department_id = 1;
    -- Realize this was a mistake
ROLLBACK;
```

The `DELETE` is undone. The database is back to its state before `BEGIN`.

### The "safe deletion" pattern

```sql
BEGIN;
    DELETE FROM employees WHERE city = 'Remote';
    SELECT COUNT(*) FROM employees;  -- check
    -- If happy:
COMMIT;
    -- If not:
ROLLBACK;
```

This is how careful operators run risky `DELETE`s in production - start a transaction, do the change, verify it, commit or rollback.

---

## 6. SAVEPOINT - Partial Rollback

A **savepoint** marks an intermediate point inside a transaction. You can roll back to a savepoint without rolling back the whole transaction.

```sql
BEGIN;
    UPDATE employees SET salary = 100000 WHERE id = 1;

    SAVEPOINT after_first_update;

    UPDATE employees SET salary = 999999 WHERE id = 2;  -- oops, typo
    ROLLBACK TO SAVEPOINT after_first_update;

    -- Now id=2 is unchanged, but id=1's update is still in flight
    UPDATE employees SET salary = 105000 WHERE id = 2;
COMMIT;
```

Useful for long, multi-step transactions where you might want to back out one step without throwing away everything.

---

## 7. ACID Properties

Transactions guarantee four properties, captured in the acronym **ACID**:

| Letter | Property | What it means |
|--------|----------|---------------|
| **A** | **Atomicity** | All or nothing - every statement in the transaction succeeds, or none of them take effect |
| **C** | **Consistency** | The database goes from one valid state to another - constraints are never violated |
| **I** | **Isolation** | Concurrent transactions don't interfere with each other |
| **D** | **Durability** | Once committed, the change survives crashes - it's written to disk |

ACID is what makes relational databases *trustworthy* for important data. It's the main reason SQL databases dominate financial, healthcare, and other critical systems.

---

## 8. Transaction Isolation Levels

When multiple transactions run at the same time, they can affect each other in subtle ways. **Isolation levels** control *how much* concurrent transactions can see of each other's in-progress work.

The four standard isolation levels, from **least isolated** (most concurrency, most anomalies) to **most isolated** (least concurrency, fewest anomalies):

| Level | Allows... |
|-------|-----------|
| **`READ UNCOMMITTED`** | Dirty reads - seeing changes another transaction hasn't committed yet |
| **`READ COMMITTED`** | Non-repeatable reads - re-reading the same row may show different values |
| **`REPEATABLE READ`** | Phantom reads - re-running the same query may return different rows |
| **`SERIALIZABLE`** | Nothing - transactions appear to run one after another |

### The Anomalies

- **Dirty read** - reading uncommitted (possibly rolled-back) data from another transaction.
- **Non-repeatable read** - same `SELECT` returns different *values* for an existing row, because another transaction committed an update mid-flight.
- **Phantom read** - same `SELECT` returns different *rows* (new ones appearing, old ones disappearing), because another transaction inserted or deleted.

### Setting the Isolation Level

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
    -- your statements
COMMIT;
```

### Default Levels by Dialect

| Dialect | Default |
|---------|---------|
| PostgreSQL | `READ COMMITTED` |
| MySQL (InnoDB) | `REPEATABLE READ` |
| SQL Server | `READ COMMITTED` |
| Oracle | `READ COMMITTED` |

**`READ COMMITTED` is the practical default** for most applications - a good balance of safety and performance.

---

## 9. Locks and Blocking

Databases use **locks** to prevent concurrent transactions from corrupting data. When transaction A is modifying a row, it locks that row; transaction B has to wait until A releases.

### Types of Locks (Simplified)

| Lock | What it does |
|------|--------------|
| **Shared lock** | Multiple transactions can read; none can write |
| **Exclusive lock** | One transaction has full access; others wait |
| **Row-level lock** | Locks a single row |
| **Table-level lock** | Locks an entire table - coarser and slower |

### Blocking

**Blocking** = transaction B is waiting because transaction A holds a lock B needs.

```sql
-- Session 1:
BEGIN;
UPDATE employees SET salary = 100000 WHERE id = 1;
-- (No COMMIT yet - keeps the lock)

-- Session 2:
UPDATE employees SET salary = 110000 WHERE id = 1;
-- This is BLOCKED, waiting on Session 1 to commit or rollback.
```

Blocking is normal - it's what protects data integrity. But long-held locks cause performance problems.

### Tips to Reduce Blocking

- **Keep transactions short.** Open transactions hold locks.
- **Touch rows in a consistent order** (helps avoid deadlocks too - next section).
- **Avoid unnecessary table scans** inside transactions - locks may be acquired on more rows than expected.

---

## 10. Deadlocks

A **deadlock** is the worst-case version of blocking: two transactions are each holding a lock the other needs. Neither can proceed. They'd wait forever - so the database **detects deadlocks and kills one of them** (with an error like *"deadlock detected"*).

### Classic example

```sql
-- Transaction A:
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;  -- waits for B
COMMIT;

-- Transaction B (running at the same time):
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 2;
UPDATE accounts SET balance = balance + 100 WHERE id = 1;  -- waits for A
COMMIT;
```

Both are waiting on each other's locks. **Deadlock.** The database kills one transaction (rolling it back) so the other can finish.

### Preventing Deadlocks

- **Touch rows in a consistent order** across transactions. (If both A and B always update id 1 before id 2, no deadlock.)
- **Keep transactions short** - fewer locks held, less chance of conflict.
- **Use lower isolation levels** where appropriate - fewer locks.

### Handling a Deadlock

If your app gets a deadlock error, the right response is usually to **retry the transaction**. Most data libraries have built-in retry logic.

---

## 11. Concurrency Control / MVCC

**MVCC** = **Multi-Version Concurrency Control**. It's how modern databases (PostgreSQL, Oracle, MySQL InnoDB) let many readers and writers work simultaneously **without blocking each other** for reads.

### The Core Idea

Instead of locking a row while it's being modified, the database **keeps multiple versions** of the row. Readers see the version that existed at the start of their transaction; writers create a new version.

**The practical result:** **readers don't block writers, and writers don't block readers.** A long-running `SELECT` doesn't make `UPDATE`s wait, and vice versa.

### Trade-offs

- **More storage** - old row versions stick around until cleaned up.
- **Vacuum / cleanup processes** are needed to remove obsolete versions (PostgreSQL's `VACUUM`, for example).
- **Snapshot isolation** is achieved naturally - each transaction sees a consistent snapshot of the database.

### What This Means for You

In day-to-day SQL, MVCC mostly "just works." You'll meet it when:
- You're tuning a database that's growing larger than expected (look at vacuum settings).
- You're debugging a long-running query and wondering why it doesn't see recent changes (it sees the snapshot from when it started).

### Older Approach - Lock-Based Concurrency

Older or simpler databases (some SQL Server modes, older MySQL engines) use **lock-based** concurrency instead - read locks, write locks, and lots of blocking. MVCC was a big leap forward in concurrency.

---

## Putting It All Together

A realistic production-grade money-transfer transaction:

```sql
BEGIN;

    -- 1. Lock the rows we're about to modify (prevents races)
    SELECT balance FROM accounts WHERE id IN (1, 2) FOR UPDATE;

    -- 2. Check the source has enough funds
    --    (raise error if not - would trigger ROLLBACK)

    -- 3. Make the transfer
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;

    SAVEPOINT after_debit;

    UPDATE accounts SET balance = balance + 100 WHERE id = 2;

    -- Verify both balances are valid
    --    (could ROLLBACK TO SAVEPOINT here if needed)

COMMIT;
```

This combines: a transaction, a savepoint, a `FOR UPDATE` lock to prevent races, and a controlled commit point. The transaction is ACID - the transfer is **atomic** (both updates or neither), **consistent** (no row leaves the database in an invalid state), **isolated** from concurrent transactions, and **durable** once committed.

---

## Key Takeaways

- **DCL** manages **permissions**: `GRANT` and `REVOKE`, organized into **roles** that bundle privileges for groups of users.
- **TCL** manages **transactions**: a transaction is a unit of work that's all-or-nothing.
- **`COMMIT`** finalizes; **`ROLLBACK`** undoes everything since `BEGIN`. **`SAVEPOINT`** lets you partial-rollback inside a transaction.
- **ACID** = Atomicity, Consistency, Isolation, Durability - the guarantees relational databases provide.
- **Isolation levels** trade safety for concurrency: `READ UNCOMMITTED` < `READ COMMITTED` < `REPEATABLE READ` < `SERIALIZABLE`. **`READ COMMITTED`** is the practical default.
- **Locks** prevent concurrent corruption. **Blocking** is when one transaction waits on another's locks. **Deadlocks** are two transactions waiting on each other - the database breaks the tie by killing one.
- **MVCC** (Multi-Version Concurrency Control) is how modern databases let readers and writers work simultaneously without blocking each other - by keeping multiple row versions.

## Quick Self-Check

1. What's the difference between `GRANT` and `REVOKE`?
2. Why use roles instead of granting privileges to each user individually?
3. What do `COMMIT` and `ROLLBACK` do?
4. What does ACID stand for?
5. Which isolation level allows "dirty reads," and what does that mean?
6. What's a deadlock, and how does the database resolve one?
7. In plain words, what does MVCC let you do?

## Further Reading

| Topic | Reference |
|-------|-----------|
| GRANT / REVOKE | [GeeksForGeeks: GRANT/REVOKE](https://www.geeksforgeeks.org/sql-grant-revoke-privileges/) |
| Roles | [PostgreSQL: Database Roles](https://www.postgresql.org/docs/current/user-manag.html) |
| COMMIT / ROLLBACK | [W3Schools: SQL Transactions](https://www.w3schools.com/sql/sql_transactions.asp) |
| ACID | [GeeksForGeeks: ACID](https://www.geeksforgeeks.org/acid-properties-in-dbms/) |
| Isolation levels | [GeeksForGeeks: Isolation Levels](https://www.geeksforgeeks.org/transaction-isolation-levels-dbms/) |
| Locks / Deadlocks | [GeeksForGeeks: Deadlock](https://www.geeksforgeeks.org/deadlock-in-dbms/) |
| MVCC | [GeeksForGeeks: MVCC](https://www.geeksforgeeks.org/multiversion-concurrency-control-mvcc-in-dbms/) |

---

[← Prev: Functions & Programming](./10-functions-and-programming.md) · [Back to Week 1 README](../README.md)
