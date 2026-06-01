# 08. Lists

A **list** is an ordered, mutable collection of values. It's the most commonly used data structure in Python.

```python
fruits = ["apple", "banana", "cherry"]
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]    # can contain different types
empty = []
```

Lists are:
- **Ordered**: items have positions (an "order")
- **Mutable**: you can change, add, remove items
- **Allow duplicates**: same value can appear multiple times
- **Mixed types allowed**: but usually you'll have all same type

## 1. Creating Lists

```python
# literal syntax
fruits = ["apple", "banana", "cherry"]

# empty list
empty = []
empty = list()

# from another iterable
numbers = list(range(5))           # [0, 1, 2, 3, 4]
letters = list("hello")            # ['h', 'e', 'l', 'l', 'o']

# with repetition
zeros = [0] * 5                    # [0, 0, 0, 0, 0]
pattern = ["yes", "no"] * 3        # ['yes', 'no', 'yes', 'no', 'yes', 'no']
```

## 2. Accessing Elements - Indexing

Lists are **zero-indexed**: the first item is at index 0.

```python
fruits = ["apple", "banana", "cherry"]

print(fruits[0])    # 'apple'
print(fruits[1])    # 'banana'
print(fruits[2])    # 'cherry'
```

**Negative indexing** counts from the end:

```python
print(fruits[-1])   # 'cherry'   (last)
print(fruits[-2])   # 'banana'   (second to last)
```

Out-of-range index raises an error:

```python
print(fruits[5])    # IndexError: list index out of range
```

## 3. Slicing - getting a sub-list

The syntax is `list[start:stop:step]`. Returns a new list containing elements from `start` up to (not including) `stop`.

```python
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

print(numbers[2:6])      # [2, 3, 4, 5]
print(numbers[:3])       # [0, 1, 2]      (from start)
print(numbers[7:])       # [7, 8, 9]      (to end)
print(numbers[:])        # entire list (copy)
print(numbers[::2])      # [0, 2, 4, 6, 8]   (every 2nd)
print(numbers[::-1])     # [9, 8, ..., 0]    (reversed)
print(numbers[-3:])      # [7, 8, 9]      (last 3)
```

Slicing always returns a **new** list. The original is unchanged.

## 4. Modifying Lists

### Change an element

```python
fruits = ["apple", "banana", "cherry"]
fruits[1] = "blueberry"
print(fruits)            # ['apple', 'blueberry', 'cherry']
```

### Add to the end - `append()`

```python
fruits.append("date")
print(fruits)            # ['apple', 'blueberry', 'cherry', 'date']
```

### Add at a specific position - `insert()`

```python
fruits.insert(0, "avocado")   # insert at index 0
print(fruits)                  # ['avocado', 'apple', 'blueberry', 'cherry', 'date']
```

### Add multiple items - `extend()`

```python
fruits.extend(["elderberry", "fig"])
print(fruits)
# ['avocado', 'apple', 'blueberry', 'cherry', 'date', 'elderberry', 'fig']
```

Note the difference between `append` and `extend`:

```python
a = [1, 2, 3]
a.append([4, 5])         # adds the LIST as a single item
print(a)                 # [1, 2, 3, [4, 5]]

b = [1, 2, 3]
b.extend([4, 5])         # adds each ITEM individually
print(b)                 # [1, 2, 3, 4, 5]
```

### Remove by value - `remove()`

```python
fruits = ["apple", "banana", "cherry", "banana"]
fruits.remove("banana")              # removes FIRST occurrence
print(fruits)                         # ['apple', 'cherry', 'banana']

fruits.remove("grape")                # ValueError: not in list
```

### Remove by index - `pop()`

```python
fruits = ["apple", "banana", "cherry"]
removed = fruits.pop(1)               # remove and return item at index 1
print(removed)                         # 'banana'
print(fruits)                          # ['apple', 'cherry']

fruits.pop()                           # without argument, removes LAST item
```

### Remove all - `clear()`

```python
fruits.clear()
print(fruits)                          # []
```

### Delete by index - `del`

```python
fruits = ["apple", "banana", "cherry"]
del fruits[0]
print(fruits)                          # ['banana', 'cherry']

del fruits[1:]                         # delete a slice
print(fruits)                          # ['banana']
```

## 5. Searching and Counting

```python
fruits = ["apple", "banana", "cherry", "banana"]

# is it in the list?
print("banana" in fruits)              # True
print("grape" in fruits)               # False

# find the position - index()
print(fruits.index("banana"))          # 1   (first occurrence)
# print(fruits.index("grape"))         # ValueError: not in list

# count occurrences
print(fruits.count("banana"))          # 2
print(fruits.count("grape"))           # 0

# length
print(len(fruits))                     # 4
```

## 6. Sorting

### `sort()` - sorts the list IN PLACE

```python
numbers = [3, 1, 4, 1, 5, 9, 2, 6]
numbers.sort()
print(numbers)                         # [1, 1, 2, 3, 4, 5, 6, 9]

numbers.sort(reverse=True)
print(numbers)                         # [9, 6, 5, 4, 3, 2, 1, 1]
```

### `sorted()` - returns a NEW sorted list

```python
numbers = [3, 1, 4, 1, 5]
sorted_numbers = sorted(numbers)
print(sorted_numbers)                  # [1, 1, 3, 4, 5]
print(numbers)                         # [3, 1, 4, 1, 5]   (unchanged)
```

Use `sort()` when you don't need the original. Use `sorted()` when you want to keep the original too.

### Custom sort with `key`

```python
words = ["apple", "fig", "banana", "kiwi"]
words.sort(key=len)                    # sort by length
print(words)                            # ['fig', 'kiwi', 'apple', 'banana']

people = [
    {"name": "Aaron", "age": 30},
    {"name": "Bea",   "age": 25},
    {"name": "Carlos", "age": 35},
]
people.sort(key=lambda p: p["age"])
print(people)
# [{'name': 'Bea', 'age': 25}, {'name': 'Aaron', 'age': 30}, {'name': 'Carlos', 'age': 35}]
```

## 7. Reversing

```python
numbers = [1, 2, 3, 4, 5]
numbers.reverse()                      # in place
print(numbers)                         # [5, 4, 3, 2, 1]

# or get a reversed copy
print(list(reversed([1, 2, 3])))       # [3, 2, 1]
print([1, 2, 3][::-1])                 # [3, 2, 1]   (slicing trick)
```

## 8. Common Operations

```python
numbers = [3, 1, 4, 1, 5, 9, 2, 6]

print(sum(numbers))              # 31
print(min(numbers))              # 1
print(max(numbers))              # 9
print(len(numbers))              # 8

# average (no built-in for this)
print(sum(numbers) / len(numbers))   # 3.875
```

## 9. Concatenation and Repetition

```python
a = [1, 2, 3]
b = [4, 5, 6]

print(a + b)                     # [1, 2, 3, 4, 5, 6]   (concat)
print(a * 3)                     # [1, 2, 3, 1, 2, 3, 1, 2, 3]   (repeat)
```

`a + b` creates a new list. `a.extend(b)` modifies `a` in place.

## 10. Copying a List

```python
original = [1, 2, 3]

# WRONG - this doesn't copy, just creates another name for the same list
same_list = original
same_list.append(4)
print(original)                  # [1, 2, 3, 4]   (changed!)

# RIGHT - actual copies
copy1 = original.copy()
copy2 = list(original)
copy3 = original[:]              # slice the whole thing
```

This is a very common bug. Always use `.copy()` or `list(...)` when you want a real copy.

### Shallow vs deep copy

For lists of lists, `.copy()` makes a **shallow** copy:

```python
nested = [[1, 2], [3, 4]]
shallow = nested.copy()
shallow[0].append(99)
print(nested)                    # [[1, 2, 99], [3, 4]]   (inner list shared!)
```

For deep copies:
```python
import copy
deep = copy.deepcopy(nested)
deep[0].append(99)
print(nested)                    # unchanged
```

## 11. List Methods Quick Reference

| Method | What it does |
|---|---|
| `append(x)` | Add x to end |
| `insert(i, x)` | Insert x at index i |
| `extend(iter)` | Add each item from iter |
| `remove(x)` | Remove first occurrence of x |
| `pop(i=-1)` | Remove and return item at index i (default: last) |
| `clear()` | Remove all items |
| `index(x)` | Return position of first occurrence of x |
| `count(x)` | Number of times x appears |
| `sort()` | Sort in place |
| `reverse()` | Reverse in place |
| `copy()` | Return a shallow copy |

## 12. Iterating Over Lists

```python
fruits = ["apple", "banana", "cherry"]

# value only
for fruit in fruits:
    print(fruit)

# index and value
for i, fruit in enumerate(fruits):
    print(i, fruit)

# multiple lists in parallel
prices = [1.50, 0.75, 3.99]
for fruit, price in zip(fruits, prices):
    print(f"{fruit}: ${price}")
```

## 13. Common Patterns

### Filter a list (with a loop)

```python
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
evens = []
for n in numbers:
    if n % 2 == 0:
        evens.append(n)
print(evens)                     # [2, 4, 6, 8, 10]
```

(With a comprehension this is one line - see note 13.)

### Transform a list

```python
numbers = [1, 2, 3, 4, 5]
squares = []
for n in numbers:
    squares.append(n * n)
print(squares)                   # [1, 4, 9, 16, 25]
```

### Remove duplicates while preserving order

```python
items = [1, 2, 2, 3, 1, 4, 2]
seen = []
for x in items:
    if x not in seen:
        seen.append(x)
print(seen)                      # [1, 2, 3, 4]

# or use a set (loses order in older python, preserves in 3.7+ via dict trick)
list(dict.fromkeys(items))       # [1, 2, 3, 4]
```

### Flatten a 2D list

```python
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flat = []
for row in matrix:
    for item in row:
        flat.append(item)
print(flat)                      # [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

## 14. When to Use a List

Use a list when you need:
- An ordered collection
- The ability to add/remove items dynamically
- Indexed access
- Allowing duplicates

Don't use a list when:
- You only need unique values - use a `set`
- You need key-value lookup - use a `dict`
- The data should never change - use a `tuple` (slightly faster, hashable)

## Common Mistakes

### Mistake 1: aliasing instead of copying

```python
a = [1, 2, 3]
b = a              # NOT a copy
b.append(4)
print(a)           # [1, 2, 3, 4]   (unexpected!)
```

### Mistake 2: confusing `append` and `extend`

```python
a = [1, 2, 3]
a.append([4, 5])   # [1, 2, 3, [4, 5]]   (probably not what you meant)
a.extend([4, 5])   # [1, 2, 3, 4, 5]
```

### Mistake 3: modifying while iterating

```python
nums = [1, 2, 3, 4, 5]
for n in nums:
    if n % 2 == 0:
        nums.remove(n)   # skips elements unpredictably
```

Instead, build a new list:
```python
nums = [n for n in nums if n % 2 != 0]
```

### Mistake 4: out-of-range index

```python
lst = [1, 2, 3]
print(lst[3])      # IndexError (indices 0, 1, 2 are valid)
```

## Summary

- Lists are ordered, mutable, allow duplicates and mixed types
- Indexing: `lst[0]` is first, `lst[-1]` is last
- Slicing: `lst[start:stop:step]` returns a new list
- Add: `append()`, `insert()`, `extend()`
- Remove: `remove()`, `pop()`, `clear()`, `del`
- Sort: `sort()` (in place) or `sorted()` (new list)
- Always use `.copy()` or `list(x)` for actual copies

Next: [Tuples and Sets](./09-tuples-and-sets.md) - two more important collection types.
