# 07. Loops

A **loop** lets you repeat a block of code multiple times. Python has two kinds:

- **`for`** - loop a known number of times, or over a collection
- **`while`** - loop as long as a condition is True

## 1. The `for` Loop

The `for` loop iterates over a sequence (list, tuple, string, range, etc.). On each iteration, the loop variable takes the next value.

```python
fruits = ["apple", "banana", "cherry"]

for fruit in fruits:
    print(fruit)

# apple
# banana
# cherry
```

Read this as: *for each fruit in the fruits list, print it*.

### Looping over a string

A string is a sequence of characters, so you can loop over it directly:

```python
for letter in "hello":
    print(letter)

# h
# e
# l
# l
# o
```

### `range()` - generate a sequence of numbers

When you want to loop a specific number of times, use `range()`:

```python
for i in range(5):
    print(i)

# 0
# 1
# 2
# 3
# 4
```

`range(n)` gives numbers from 0 up to (but not including) n.

`range()` has three forms:

```python
range(5)         # 0, 1, 2, 3, 4         (stop only)
range(2, 8)      # 2, 3, 4, 5, 6, 7      (start, stop)
range(0, 10, 2)  # 0, 2, 4, 6, 8         (start, stop, step)
range(10, 0, -1) # 10, 9, 8, ..., 1      (countdown with negative step)
```

### Looping with index AND value: `enumerate()`

If you need both the index and the value, use `enumerate()`:

```python
fruits = ["apple", "banana", "cherry"]

for index, fruit in enumerate(fruits):
    print(index, fruit)

# 0 apple
# 1 banana
# 2 cherry
```

This is much cleaner than:
```python
# don't do this - awkward
for i in range(len(fruits)):
    print(i, fruits[i])
```

### Looping over two lists at once: `zip()`

```python
names = ["Aaron", "Bea", "Carlos"]
ages = [25, 30, 35]

for name, age in zip(names, ages):
    print(f"{name} is {age}")

# Aaron is 25
# Bea is 30
# Carlos is 35
```

`zip()` pairs up corresponding elements. If lists are different lengths, it stops at the shorter one.

### Looping over a dictionary

```python
person = {"name": "Aaron", "age": 25, "city": "Tampa"}

# loop over keys (default)
for key in person:
    print(key)

# loop over values
for value in person.values():
    print(value)

# loop over both
for key, value in person.items():
    print(f"{key}: {value}")
```

## 2. The `while` Loop

A `while` loop runs as long as a condition is True. Used when you don't know in advance how many iterations you need.

```python
count = 0
while count < 5:
    print(count)
    count += 1

# 0
# 1
# 2
# 3
# 4
```

**Crucial:** make sure something in the loop body eventually makes the condition False, or you create an **infinite loop** (the program never stops).

```python
count = 0
while count < 5:
    print(count)
    # forgot to increment count - INFINITE LOOP
```

### Common while loop pattern: user input until valid

```python
while True:
    answer = input("Type 'yes' to continue: ")
    if answer.lower() == "yes":
        break        # exit the loop
    print("Try again")
```

`while True` is an infinite loop intentionally - you exit it with `break` when a condition is met.

## 3. `break` - exit the loop early

`break` immediately stops the loop, even if the loop condition is still True.

```python
for i in range(10):
    if i == 5:
        break
    print(i)

# 0
# 1
# 2
# 3
# 4
```

Loop stops at 5, never prints 5 or beyond.

### Search pattern with break

```python
numbers = [10, 25, 33, 47, 89, 12]
target = 47

for n in numbers:
    if n == target:
        print(f"Found {target}!")
        break
else:
    print("Not found")
```

Once found, no point continuing the loop.

## 4. `continue` - skip to next iteration

`continue` skips the rest of the current iteration and goes back to the top of the loop.

```python
for i in range(10):
    if i % 2 == 0:
        continue
    print(i)

# 1
# 3
# 5
# 7
# 9
```

When `i` is even, the `continue` skips the print. Only odd numbers print.

## 5. The `else` Clause on Loops

Python has a unique feature: `for` and `while` can have an `else` clause that runs only if the loop completed **without** `break`.

```python
for n in [1, 3, 5, 7]:
    if n % 2 == 0:
        print("Found even")
        break
else:
    print("All numbers were odd")

# All numbers were odd
```

If `break` was triggered, the `else` block is skipped.

Mostly useful for search-style loops. Many programmers don't use it - the `else` keyword for this is a bit confusing.

## 6. Nested Loops

Loops can be inside other loops:

```python
for i in range(3):
    for j in range(3):
        print(i, j)

# 0 0
# 0 1
# 0 2
# 1 0
# 1 1
# 1 2
# 2 0
# 2 1
# 2 2
```

The inner loop completes fully for each iteration of the outer loop.

### Multiplication table (classic example)

```python
for i in range(1, 6):
    for j in range(1, 6):
        print(f"{i*j:4}", end="")
    print()

#    1   2   3   4   5
#    2   4   6   8  10
#    3   6   9  12  15
#    4   8  12  16  20
#    5  10  15  20  25
```

### Star patterns (common beginner exercise)

```python
# right triangle
for i in range(1, 6):
    print("*" * i)

# *
# **
# ***
# ****
# *****

# pyramid
n = 5
for i in range(1, n + 1):
    spaces = " " * (n - i)
    stars = "*" * (2 * i - 1)
    print(spaces + stars)

#     *
#    ***
#   *****
#  *******
# *********
```

## 7. Common Patterns

### Count occurrences

```python
text = "hello world"
count = 0
for char in text:
    if char == 'l':
        count += 1
print(count)         # 3
```

### Find max value manually

```python
numbers = [3, 7, 1, 9, 4, 8, 2]
max_val = numbers[0]
for n in numbers:
    if n > max_val:
        max_val = n
print(max_val)       # 9

# of course, just use the built-in
print(max(numbers))  # 9
```

### Accumulate a sum

```python
numbers = [1, 2, 3, 4, 5]
total = 0
for n in numbers:
    total += n
print(total)         # 15

# or use built-in
print(sum(numbers))  # 15
```

### Build a new list

```python
numbers = [1, 2, 3, 4, 5]
squares = []
for n in numbers:
    squares.append(n * n)
print(squares)       # [1, 4, 9, 16, 25]

# (later you'll learn list comprehensions which do this in one line)
```

### Loop with index (when you really need it)

```python
items = ["a", "b", "c"]
for i, item in enumerate(items):
    print(f"{i}: {item}")

# 0: a
# 1: b
# 2: c
```

### Process file line by line

```python
with open("data.txt") as f:
    for line in f:
        print(line.strip())
```

(More on file I/O in note 14.)

## 8. `for` vs `while` - when to use which

| Use `for` when | Use `while` when |
|---|---|
| You know the number of iterations | You don't know how many iterations |
| You're looping over a collection | You're waiting for a condition to become True/False |
| You want clean, Pythonic code | You need infinite-loop-until-X behavior |

Examples:

```python
# for: iterate over a known collection
for user in users:
    send_email(user)

# while: keep going until something happens
while not file_exists("report.pdf"):
    time.sleep(1)
```

## Common Mistakes

### Mistake 1: forgot the colon

```python
for i in range(5)        # SyntaxError
    print(i)

for i in range(5):
    print(i)
```

### Mistake 2: modifying a list while iterating

```python
numbers = [1, 2, 3, 4, 5]
for n in numbers:
    if n % 2 == 0:
        numbers.remove(n)   # DANGEROUS: changing list during loop
print(numbers)              # might not give what you expect
```

Better: build a new list, or iterate over a copy.

```python
numbers = [1, 2, 3, 4, 5]
numbers = [n for n in numbers if n % 2 != 0]   # list comprehension
print(numbers)                                  # [1, 3, 5]
```

### Mistake 3: infinite loop

```python
i = 0
while i < 10:
    print(i)
    # forgot i += 1
```

Always make sure the condition can eventually become False.

### Mistake 4: using `range(len(list))` instead of direct iteration

```python
# not Pythonic
for i in range(len(fruits)):
    print(fruits[i])

# Pythonic
for fruit in fruits:
    print(fruit)

# need index too? use enumerate
for i, fruit in enumerate(fruits):
    print(i, fruit)
```

## Summary

- `for` iterates over a sequence (list, string, range, dict, etc.)
- `while` iterates as long as a condition is True
- `range(start, stop, step)` generates numbers
- `enumerate()` gives index + value
- `zip()` pairs up multiple sequences
- `break` exits the loop
- `continue` skips to next iteration
- Avoid modifying a collection while looping over it

Next: [Lists](./08-lists.md) - the workhorse collection type in Python.
