# 18. Iterators and Generators

You've used `for` loops a lot. This note covers **how** Python makes loops work, and how to create your own efficient sequences using **generators**.

## 1. Iterables

An **iterable** is anything you can loop over. Lists, tuples, strings, dicts, sets, files - all iterable.

```python
for x in [1, 2, 3]:        # list is iterable
    print(x)

for c in "hello":           # string is iterable
    print(c)

for k in {"a": 1}:           # dict is iterable
    print(k)
```

## 2. Iterators

An **iterator** is the thing that does the actual stepping through an iterable.

You can manually get one with `iter()` and step through it with `next()`:

```python
nums = [10, 20, 30]
it = iter(nums)         # get an iterator from the iterable

print(next(it))         # 10
print(next(it))         # 20
print(next(it))         # 30
print(next(it))         # StopIteration error (no more items)
```

This is what `for` loops do behind the scenes:

```python
# what `for x in nums` is really doing:
it = iter(nums)
while True:
    try:
        x = next(it)
        # ... loop body ...
    except StopIteration:
        break
```

You rarely write this manually. But understanding it helps you understand generators.

## 3. The Problem: Lazy vs Eager Evaluation

Consider:

```python
# eager: builds the whole list immediately
squares = [n * n for n in range(1000000)]   # uses lots of memory
```

For a million items, this needs to allocate memory for all of them up front.

If you only need to process one item at a time, you don't need the whole list in memory. That's where **generators** come in.

## 4. Generator Expressions

Same syntax as list comprehensions but with parentheses. Returns a **generator object** that produces values on demand:

```python
squares = (n * n for n in range(1000000))   # creates generator, NO computation yet
```

To get values, iterate or call `next()`:

```python
gen = (n * n for n in range(5))

print(next(gen))         # 0
print(next(gen))         # 1
print(next(gen))         # 4

# or use in a for loop
for value in gen:
    print(value)         # 9, 16   (continues from where we left off)
```

### Memory comparison

```python
import sys

list_version = [n * n for n in range(1000000)]
gen_version  = (n * n for n in range(1000000))

print(sys.getsizeof(list_version))      # 8000000+ bytes (8MB)
print(sys.getsizeof(gen_version))        # 200 bytes
```

The generator stores almost nothing - just enough to produce the next value when asked.

### Use generators with aggregate functions

```python
# sum of squares without building a list
total = sum(n * n for n in range(1000000))
print(total)

# check if any item meets a condition
nums = [3, -1, 5, 7]
has_negative = any(n < 0 for n in nums)
print(has_negative)             # True

# all positive?
print(all(n > 0 for n in nums)) # False
```

You can omit the parens when the generator is the only argument to a function:

```python
sum(n * n for n in range(100))   # implicit parens
```

## 5. Generator Functions - `yield`

For more complex generators, define a function that uses `yield` instead of `return`:

```python
def count_up_to(limit):
    n = 1
    while n <= limit:
        yield n
        n += 1

# nothing computed yet
gen = count_up_to(5)

# values produced one at a time
for x in gen:
    print(x)
# 1, 2, 3, 4, 5
```

### How `yield` works

`yield` is like `return` but it **pauses** the function instead of ending it. Next time `next()` is called, the function resumes from where it left off.

Mental trace of `count_up_to(3)`:
1. `gen = count_up_to(3)` - creates generator, function body hasn't run yet
2. `next(gen)` - runs until first `yield n` where n=1, returns 1, pauses
3. `next(gen)` - resumes, increments n to 2, runs until `yield`, returns 2, pauses
4. `next(gen)` - resumes, increments to 3, `yield`s 3, pauses
5. `next(gen)` - resumes, n becomes 4, loop ends, StopIteration raised

### Generator vs function

```python
# regular function - returns everything at once
def get_squares(limit):
    result = []
    for n in range(limit):
        result.append(n * n)
    return result

# generator function - yields one at a time
def gen_squares(limit):
    for n in range(limit):
        yield n * n


# regular - builds whole list
squares = get_squares(1000000)        # builds 1M items

# generator - lazy
squares = gen_squares(1000000)        # builds nothing yet
```

## 6. Common Generator Patterns

### Read a large file line by line

```python
def read_lines(filename):
    with open(filename) as f:
        for line in f:
            yield line.strip()

# process one line at a time, file never fully loaded
for line in read_lines("huge.log"):
    if "ERROR" in line:
        print(line)
```

### Infinite sequence

```python
def counter():
    n = 0
    while True:
        yield n
        n += 1

c = counter()
for _ in range(5):
    print(next(c))       # 0, 1, 2, 3, 4
```

Don't `for x in counter():` directly - that loop would never end. Combine with `break` or other terminating logic.

### Fibonacci numbers

```python
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

fib = fibonacci()
for _ in range(10):
    print(next(fib), end=" ")
# 0 1 1 2 3 5 8 13 21 34
```

### Filter a stream

```python
def only_positive(numbers):
    for n in numbers:
        if n > 0:
            yield n

data = [3, -1, 4, -2, 5, -6]
for n in only_positive(data):
    print(n)
# 3, 4, 5
```

### Chain generators

```python
def squares(numbers):
    for n in numbers:
        yield n * n

def positive(numbers):
    for n in numbers:
        if n > 0:
            yield n

# compose them
data = [3, -1, 4, -2, 5]
for sq in squares(positive(data)):
    print(sq)
# 9, 16, 25
```

Each generator processes one item at a time as needed. Very memory-efficient.

## 7. Iterators as Classes (Advanced)

You can make any class iterable by defining `__iter__` and `__next__`:

```python
class Countdown:
    def __init__(self, start):
        self.start = start
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.start <= 0:
            raise StopIteration
        self.start -= 1
        return self.start + 1


for n in Countdown(5):
    print(n)
# 5, 4, 3, 2, 1
```

For most cases, a generator function is simpler. This class approach is rare.

## 8. `yield from` - delegating to another generator

```python
def first_gen():
    yield 1
    yield 2
    yield 3

def second_gen():
    yield from first_gen()    # produce all values from first_gen
    yield 4
    yield 5

for x in second_gen():
    print(x)
# 1, 2, 3, 4, 5
```

`yield from` is shorthand for "yield each value from this iterable in turn." Useful when chaining generators.

## 9. When to Use Generators

**Use a generator when:**
- The sequence is huge (file lines, infinite streams)
- You don't need all values at once
- You're chaining transformations on a stream

**Use a list when:**
- You need to iterate multiple times
- You need to access by index
- You need random access (mid-stream)
- The data is small

### Multiple iteration trap

```python
gen = (n * n for n in range(5))

print(list(gen))        # [0, 1, 4, 9, 16]
print(list(gen))        # []   already consumed!
```

Generators can be iterated only once. If you need to iterate multiple times, convert to a list or recreate the generator.

## 10. The `itertools` Module

The standard library has tons of useful generator-based functions:

```python
import itertools

# infinite counter
for i in itertools.count(1, 2):    # 1, 3, 5, 7, ...
    if i > 10:
        break
    print(i)

# repeat a value
list(itertools.repeat("a", 3))     # ['a', 'a', 'a']

# cycle through items forever (use with break)
cycler = itertools.cycle(["red", "green", "blue"])
for _ in range(7):
    print(next(cycler))
# red, green, blue, red, green, blue, red

# chain iterables together
list(itertools.chain([1, 2], [3, 4]))     # [1, 2, 3, 4]

# take only the first N
list(itertools.islice(range(100), 5))     # [0, 1, 2, 3, 4]

# combinations and permutations
list(itertools.combinations([1, 2, 3], 2))    # [(1,2), (1,3), (2,3)]
list(itertools.permutations([1, 2, 3], 2))    # all ordered pairs

# group consecutive items
data = [1, 1, 2, 2, 2, 3, 1]
for key, group in itertools.groupby(data):
    print(key, list(group))
# 1 [1, 1]
# 2 [2, 2, 2]
# 3 [3]
# 1 [1]
```

## Common Mistakes

### Mistake 1: trying to iterate a generator twice

```python
gen = (n for n in range(5))
print(list(gen))        # [0, 1, 2, 3, 4]
print(list(gen))        # []   nothing left
```

Recreate or store as a list.

### Mistake 2: forgetting `yield` keyword

```python
def my_gen():
    for n in range(5):
        print(n)        # WRONG: this is just a function with print, no values produced

def my_gen():
    for n in range(5):
        yield n         # CORRECT: produces values
```

### Mistake 3: trying to use `return` with a value in a generator

```python
def gen():
    yield 1
    return 99           # this is allowed but ends the generator
    yield 2             # never reached
```

`return` in a generator stops the iteration. The returned value becomes the `StopIteration.value`, rarely used.

### Mistake 4: indexing a generator

```python
gen = (n*n for n in range(5))
print(gen[0])           # TypeError: not subscriptable
```

Convert to a list first if you need indexing:
```python
list(gen)[0]            # 0
```

## Summary

- An **iterable** is anything you can `for` loop over
- An **iterator** is the thing doing the stepping (made with `iter()`, advanced with `next()`)
- A **generator** is a lazy iterator that produces values on demand
- Make generators with `yield` in functions or `()` in expressions
- Generators save memory by producing one value at a time
- One-shot only: can't iterate the same generator twice
- `itertools` has tons of useful generator-based tools

Next: [Decorators](./19-decorators.md) - functions that wrap other functions.
