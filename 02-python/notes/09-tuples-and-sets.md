# 09. Tuples and Sets

Two more collection types beyond lists:

- **Tuple** - like a list but **immutable** (can't be changed after creation)
- **Set** - unordered collection of **unique** values

## Part 1: Tuples

A tuple is an ordered sequence, like a list, but you can't change it after creating.

```python
point = (3, 4)
colors = ("red", "green", "blue")
person = ("Aaron", 25, "Tampa")
```

Parentheses define a tuple. (You can actually omit them in most contexts: `point = 3, 4` also works.)

### Creating tuples

```python
empty = ()
single = (5,)            # IMPORTANT: trailing comma needed for single-item tuple!
single_wrong = (5)        # this is just the integer 5, not a tuple

# from another iterable
t = tuple([1, 2, 3])     # (1, 2, 3)
t = tuple("abc")         # ('a', 'b', 'c')
```

### Accessing elements - same as lists

```python
person = ("Aaron", 25, "Tampa")

print(person[0])         # 'Aaron'
print(person[-1])        # 'Tampa'
print(person[0:2])       # ('Aaron', 25)
```

### What you CAN'T do

```python
person = ("Aaron", 25, "Tampa")
person[0] = "Bea"        # TypeError: tuples are immutable
person.append("USA")     # AttributeError: tuples have no append method
```

Tuples have no `append`, `remove`, `pop`, `clear`, `sort`, etc. They have only two methods: `count()` and `index()`.

### Tuple unpacking - useful trick

You can assign multiple variables from a tuple in one line:

```python
point = (3, 4)
x, y = point
print(x, y)              # 3 4

# swap variables
a, b = 5, 10
a, b = b, a              # swap
print(a, b)              # 10 5

# function returning multiple values
def get_min_max(numbers):
    return min(numbers), max(numbers)

low, high = get_min_max([3, 1, 4, 1, 5, 9])
print(low, high)         # 1 9
```

Unpacking works with any iterable, not just tuples - but tuples are how Python "returns multiple values" from functions.

### Star unpacking

```python
first, *rest = [1, 2, 3, 4, 5]
print(first)             # 1
print(rest)              # [2, 3, 4, 5]

first, *middle, last = [1, 2, 3, 4, 5]
print(first, middle, last)   # 1 [2, 3, 4] 5
```

### When to use tuples vs lists

| Use a list when | Use a tuple when |
|---|---|
| Contents will change | Data should not change |
| Order matters and items are similar | Items represent different things (record) |
| You need add/remove methods | You want immutability |
| Example: shopping cart | Example: coordinates (x, y) |

Tuples are also slightly faster than lists and use less memory.

**Example - tuple as a record:**
```python
# tuples are often used like a lightweight "record"
employee = ("Aaron", 25, "Engineer", 75000)

# unpack into meaningful names
name, age, role, salary = employee
```

## Part 2: Sets

A set is an unordered collection of unique values. No duplicates allowed.

```python
fruits = {"apple", "banana", "cherry"}
numbers = {1, 2, 3, 4, 5}
mixed = {1, "hello", 3.14}
```

Curly braces define a set (also used for dicts - the difference is the contents).

### Creating sets

```python
empty = set()            # NOT {} - that's an empty dict
s = {1, 2, 3}

# from another iterable (deduplicates!)
s = set([1, 2, 2, 3, 3, 3])   # {1, 2, 3}
s = set("hello")               # {'h', 'e', 'l', 'o'}   (one 'l')
```

### Sets remove duplicates automatically

```python
numbers = [1, 2, 2, 3, 3, 3, 4]
unique = set(numbers)
print(unique)            # {1, 2, 3, 4}
```

This is a common one-liner to deduplicate a list. (Order is lost.)

### Adding and removing

```python
s = {1, 2, 3}

s.add(4)                 # {1, 2, 3, 4}
s.remove(2)              # {1, 3, 4}    (KeyError if 2 not in set)
s.discard(2)             # same as remove but no error if missing
s.pop()                  # removes and returns an arbitrary element
s.clear()                # empty the set
```

### Checking membership

```python
fruits = {"apple", "banana", "cherry"}
print("apple" in fruits)         # True
print("grape" in fruits)         # False
```

**Sets are very fast for `in` checks** compared to lists, even with thousands of items. This is a key reason to use sets.

```python
# slow with large lists
huge_list = list(range(1000000))
999999 in huge_list      # has to scan thousands of items

# fast with large sets
huge_set = set(range(1000000))
999999 in huge_set       # near-instant
```

### Set Operations - the math kind

Sets support mathematical set operations:

```python
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

# union: all items in either
print(a | b)             # {1, 2, 3, 4, 5, 6}
print(a.union(b))         # same thing

# intersection: items in both
print(a & b)             # {3, 4}
print(a.intersection(b))

# difference: in a but not in b
print(a - b)             # {1, 2}
print(a.difference(b))

# symmetric difference: in either but not both
print(a ^ b)             # {1, 2, 5, 6}
print(a.symmetric_difference(b))
```

### Subset and superset

```python
a = {1, 2}
b = {1, 2, 3, 4}

print(a.issubset(b))     # True
print(b.issuperset(a))   # True
print(a < b)             # True (strict subset)
print(a <= b)            # True (subset)
```

### Sets are UNORDERED

```python
s = {"banana", "apple", "cherry"}
print(s)                 # order varies between Python runs
```

Don't rely on the order of items in a set. If order matters, use a list.

### Frozenset - immutable set

```python
fs = frozenset([1, 2, 3])
# fs.add(4)              # AttributeError: frozensets are immutable
```

Used when you need a set to be hashable (e.g., as a dict key).

## When to Use Sets

Use a set when:
- You need unique values (deduplication)
- You need fast membership testing (`in`)
- You need set math (union, intersection, etc.)
- Order doesn't matter

Don't use a set when:
- Order matters - use a list
- You need duplicate values - use a list
- You need indexed access - use a list or tuple

### Common Set Patterns

#### Deduplicate a list

```python
items = [1, 2, 2, 3, 1, 4, 2]
unique = list(set(items))
print(unique)            # [1, 2, 3, 4]  (order may vary)
```

#### Find items in common

```python
my_skills = {"python", "sql", "docker"}
job_requires = {"python", "kubernetes", "sql"}

print(my_skills & job_requires)            # {'python', 'sql'}
print(job_requires - my_skills)            # {'kubernetes'}  (need to learn)
```

#### Check if all items in a list are unique

```python
items = [1, 2, 3, 4, 5]
all_unique = len(items) == len(set(items))
print(all_unique)        # True
```

## Quick Comparison Table

| Feature | list | tuple | set |
|---|---|---|---|
| Mutable | Yes | No | Yes |
| Ordered | Yes | Yes | No |
| Duplicates allowed | Yes | Yes | No |
| Indexed access | Yes | Yes | No |
| Syntax | `[1, 2, 3]` | `(1, 2, 3)` | `{1, 2, 3}` |
| Empty | `[]` | `()` | `set()` |

## Common Mistakes

### Mistake 1: empty set vs empty dict

```python
empty = {}               # this is an EMPTY DICT, not a set!
print(type(empty))       # <class 'dict'>

empty = set()            # this is the actual empty set
print(type(empty))       # <class 'set'>
```

### Mistake 2: single-item tuple needs trailing comma

```python
t = (5)                  # this is the int 5, not a tuple
print(type(t))           # <class 'int'>

t = (5,)                 # this is a tuple
print(type(t))           # <class 'tuple'>
```

### Mistake 3: trying to mutate a tuple

```python
t = (1, 2, 3)
t[0] = 99                # TypeError
t.append(4)              # AttributeError
```

If you need to "change" a tuple, create a new one:

```python
t = (1, 2, 3)
t = (99,) + t[1:]
print(t)                 # (99, 2, 3)
```

### Mistake 4: assuming sets keep order

```python
s = {1, 2, 3, 4, 5}
print(s)                 # might print {1, 2, 3, 4, 5} or any other order
```

For ordered unique values, use `dict.fromkeys()`:

```python
items = [3, 1, 2, 1, 3]
unique_ordered = list(dict.fromkeys(items))
print(unique_ordered)    # [3, 1, 2]   (preserves first-seen order)
```

## Summary

**Tuples**:
- Immutable ordered sequences
- Created with parentheses (or commas alone)
- Use for fixed records, function returns, or anywhere "don't change this" matters
- Unpacking is the killer feature

**Sets**:
- Unordered unique-only collections
- Created with curly braces or `set()`
- Use for deduplication, fast membership tests, set math
- `set()` not `{}` for empty set

Next: [Dictionaries](./10-dictionaries.md) - the most important collection type for data work.
