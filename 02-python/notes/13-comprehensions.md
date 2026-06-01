# 13. Comprehensions

A **comprehension** is a compact one-line way to build a list, set, dict, or generator from another iterable. They replace many simple loops with cleaner code.

## 1. List Comprehensions

### Basic syntax

```python
# loop version
squares = []
for n in range(10):
    squares.append(n * n)
print(squares)
# [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# comprehension version
squares = [n * n for n in range(10)]
print(squares)
# [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

The general form:
```
[expression for item in iterable]
```

Read it: "an expression for each item in iterable, collected in a list."

### With filtering

Add an `if` clause to filter:

```python
# loop version
evens = []
for n in range(10):
    if n % 2 == 0:
        evens.append(n)

# comprehension
evens = [n for n in range(10) if n % 2 == 0]
print(evens)             # [0, 2, 4, 6, 8]
```

Form:
```
[expression for item in iterable if condition]
```

### Combining transformation and filtering

```python
even_squares = [n * n for n in range(10) if n % 2 == 0]
print(even_squares)      # [0, 4, 16, 36, 64]
```

### Conditional expression in the result (ternary)

You can use `if/else` in the expression part to choose between values:

```python
labels = ["even" if n % 2 == 0 else "odd" for n in range(10)]
print(labels)
# ['even', 'odd', 'even', 'odd', 'even', 'odd', 'even', 'odd', 'even', 'odd']
```

Don't confuse this with filtering. They look similar but mean different things:

| Form | What it does |
|---|---|
| `[x for x in lst if cond]` | filter: keep only matching items |
| `[A if cond else B for x in lst]` | transform: pick A or B for each item |

### Examples

```python
# uppercase all strings in a list
words = ["hello", "world", "python"]
upper = [w.upper() for w in words]
print(upper)             # ['HELLO', 'WORLD', 'PYTHON']

# get lengths
lengths = [len(w) for w in words]
print(lengths)           # [5, 5, 6]

# flatten a 2D list
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flat = [x for row in matrix for x in row]
print(flat)              # [1, 2, 3, 4, 5, 6, 7, 8, 9]

# parse a CSV row
row = "Aaron, 25, Tampa"
parts = [s.strip() for s in row.split(",")]
print(parts)             # ['Aaron', '25', 'Tampa']

# squares of multiples of 3
squares = [n * n for n in range(20) if n % 3 == 0]
print(squares)           # [0, 9, 36, 81, 144, 225, 324]
```

## 2. Set Comprehensions

Same syntax but with curly braces - returns a set (so unique values, no order).

```python
# squares modulo 10 - only unique values
unique = {n * n % 10 for n in range(20)}
print(unique)            # {0, 1, 4, 5, 6, 9}   (set, order may vary)
```

```python
# unique first letters from a list
words = ["apple", "banana", "avocado", "blueberry"]
first_letters = {w[0] for w in words}
print(first_letters)     # {'a', 'b'}
```

## 3. Dict Comprehensions

Build a dict in one line. Syntax has both key and value separated by `:`.

```python
# squares
squares = {n: n * n for n in range(5)}
print(squares)           # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# invert a dict
person = {"name": "Aaron", "age": 25}
inverted = {v: k for k, v in person.items()}
print(inverted)          # {'Aaron': 'name', 25: 'age'}

# filter a dict
prices = {"apple": 1.5, "bread": 2.5, "milk": 3.0, "eggs": 0.5}
expensive = {k: v for k, v in prices.items() if v > 1.0}
print(expensive)         # {'apple': 1.5, 'bread': 2.5, 'milk': 3.0}

# zip two lists into a dict
keys = ["name", "age", "city"]
values = ["Aaron", 25, "Tampa"]
d = {k: v for k, v in zip(keys, values)}
print(d)                 # {'name': 'Aaron', 'age': 25, 'city': 'Tampa'}
# (note: dict(zip(keys, values)) is more idiomatic for this specific case)
```

## 4. Generator Expressions

Same syntax as list comprehensions but with parentheses. Returns a **generator** instead of a list.

```python
# list comprehension (eager - computes everything immediately)
squares_list = [n * n for n in range(1000000)]   # uses lots of memory

# generator expression (lazy - computes on demand)
squares_gen = (n * n for n in range(1000000))    # uses almost no memory
```

A generator produces values one at a time as you iterate. This is memory-efficient for large sequences.

### Use generators for large data

```python
# read a huge file line by line, get the lengths
with open("huge_file.txt") as f:
    lengths = (len(line) for line in f)
    total = sum(lengths)                  # processes one line at a time
print(total)
```

### Generators in aggregates

Functions like `sum()`, `max()`, `min()`, `any()`, `all()` accept generators:

```python
# sum of squares (no intermediate list)
total = sum(n * n for n in range(100))
print(total)             # 328350

# any negative number?
nums = [3, -1, 5, 7]
print(any(n < 0 for n in nums))          # True

# all positive?
print(all(n > 0 for n in nums))          # False
```

You can omit the surrounding parens when a generator expression is the only argument:

```python
sum(n * n for n in range(100))   # parens are implicit when alone
```

### One-time use

Generators can only be iterated once:

```python
gen = (n * n for n in range(5))
print(list(gen))         # [0, 1, 4, 9, 16]
print(list(gen))         # []  (already exhausted)
```

For repeated iteration, use a list comprehension.

## 5. Nested Comprehensions

You can have multiple `for` clauses:

```python
# all pairs
pairs = [(x, y) for x in range(3) for y in range(3)]
print(pairs)
# [(0,0), (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)]

# 2D matrix - 3x3 zeros
matrix = [[0 for _ in range(3)] for _ in range(3)]
print(matrix)
# [[0, 0, 0], [0, 0, 0], [0, 0, 0]]

# multiplication table
table = [[i * j for j in range(1, 6)] for i in range(1, 6)]
for row in table:
    print(row)
# [1, 2, 3, 4, 5]
# [2, 4, 6, 8, 10]
# [3, 6, 9, 12, 15]
# [4, 8, 12, 16, 20]
# [5, 10, 15, 20, 25]
```

### Flattening with nested for

The order of `for` clauses matches the order in nested loops:

```python
# nested loop version
flat = []
for row in matrix:
    for x in row:
        flat.append(x)

# comprehension version (same order)
flat = [x for row in matrix for x in row]
```

## 6. When NOT to Use a Comprehension

Comprehensions are great when they're **short and readable**. Don't force them when:

### The logic is complex

```python
# BAD - hard to read
result = [process(x) if condition1(x) else other(x) if condition2(x) else default(x) for x in items if x in valid]

# GOOD - regular loop
result = []
for x in items:
    if x not in valid:
        continue
    if condition1(x):
        result.append(process(x))
    elif condition2(x):
        result.append(other(x))
    else:
        result.append(default(x))
```

### You have side effects

Comprehensions are for **building collections**. If you're not building anything, don't use a comprehension:

```python
# BAD - using a list comprehension just to print
[print(x) for x in items]    # creates a wasteful list of Nones

# GOOD - just use a loop
for x in items:
    print(x)
```

### Multiple statements needed

A comprehension can only do one expression. If you need to do multiple things, use a loop.

## 7. Practical Examples

### Squaring negative numbers, leaving positive alone

```python
nums = [3, -2, 5, -1, 0, -4]
result = [n * n if n < 0 else n for n in nums]
print(result)            # [3, 4, 5, 1, 0, 16]
```

### Counting word frequencies (compare loop vs comprehension)

```python
words = "apple banana apple cherry apple banana".split()

# from earlier (loop version)
counts = {}
for word in words:
    counts[word] = counts.get(word, 0) + 1

# comprehension version (less clean here - loop is fine)
counts = {word: words.count(word) for word in set(words)}
print(counts)            # {'apple': 3, 'banana': 2, 'cherry': 1}

# best: use Counter from collections
from collections import Counter
counts = Counter(words)
```

### Get all email addresses from a list of users

```python
users = [
    {"name": "Aaron", "email": "aaron@x.com"},
    {"name": "Bea",   "email": "bea@x.com"},
    {"name": "Carlos"}    # no email
]

emails = [u["email"] for u in users if "email" in u]
print(emails)            # ['aaron@x.com', 'bea@x.com']
```

### Find prime numbers (simple)

```python
def is_prime(n):
    if n < 2: return False
    return all(n % i != 0 for i in range(2, int(n ** 0.5) + 1))

primes = [n for n in range(2, 50) if is_prime(n)]
print(primes)
# [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
```

### Transpose a matrix

```python
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
transposed = [[row[i] for row in matrix] for i in range(3)]
print(transposed)
# [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

# or use zip
list(zip(*matrix))       # [(1, 4, 7), (2, 5, 8), (3, 6, 9)]
```

## 8. Performance

Comprehensions are slightly faster than equivalent loops because Python optimizes them internally. Plus they're more readable for simple cases. Win-win.

Generator expressions are best for large data when you don't need the whole result at once.

## Common Mistakes

### Mistake 1: confusing filter and conditional expression

```python
# filter (if at the end)
[x for x in nums if x > 0]              # keep positives only

# conditional expression (if/else in the result part)
[x if x > 0 else 0 for x in nums]       # negative -> 0, others unchanged

# both together
[x*2 if x > 0 else 0 for x in nums if x is not None]
```

### Mistake 2: using a list comp just for side effects

```python
# WRONG - creates useless list of Nones
[print(x) for x in items]

# RIGHT
for x in items:
    print(x)
```

### Mistake 3: making it too clever

```python
# unreadable
result = [[[k*v for k, v in d.items() if k.startswith('a')] for d in row] for row in matrix]
```

If it's hard to read, break it into multiple steps with named intermediates.

### Mistake 4: exhausting a generator twice

```python
gen = (n*n for n in range(5))
print(list(gen))         # [0, 1, 4, 9, 16]
print(list(gen))         # []   - already consumed
```

Convert to list if you need to iterate multiple times.

## Summary

| Type | Syntax | Returns |
|---|---|---|
| List | `[expr for x in iter]` | list |
| Set | `{expr for x in iter}` | set |
| Dict | `{k: v for k, v in iter}` | dict |
| Generator | `(expr for x in iter)` | generator |

- Add `if cond` at the end to filter
- Add `if/else` in the expression to transform conditionally
- Use generators for large data
- Stop using comprehensions when they become hard to read

Next: [File I/O](./14-file-io.md) - reading and writing files.
