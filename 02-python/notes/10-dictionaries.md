# 10. Dictionaries

A **dictionary** (dict) is a collection of **key-value pairs**. You look up values by their key, not by position.

```python
person = {
    "name": "Aaron",
    "age": 25,
    "city": "Tampa"
}
```

Think of it like a real dictionary: you look up a word (key) to find its definition (value).

Dictionaries are extremely common in data work - JSON, API responses, configuration, etc. all use dict-like structures.

## 1. Creating Dictionaries

```python
# literal syntax
person = {"name": "Aaron", "age": 25}

# empty dict
d = {}
d = dict()

# from key-value pairs
d = dict(name="Aaron", age=25)        # only works with valid identifier keys
d = dict([("a", 1), ("b", 2)])        # from list of tuples
```

## 2. Accessing Values

### Square brackets

```python
person = {"name": "Aaron", "age": 25, "city": "Tampa"}

print(person["name"])           # 'Aaron'
print(person["age"])            # 25

# missing key raises KeyError
print(person["job"])            # KeyError: 'job'
```

### `.get()` - safer access

```python
print(person.get("name"))               # 'Aaron'
print(person.get("job"))                # None (no error)
print(person.get("job", "unknown"))     # 'unknown' (default)
```

Use `.get()` when a key might not exist. No error, just returns None (or a default you provide).

## 3. Modifying Dictionaries

### Add or update a key

```python
person = {"name": "Aaron", "age": 25}

person["city"] = "Tampa"        # add new key
person["age"] = 26              # update existing key
print(person)
# {'name': 'Aaron', 'age': 26, 'city': 'Tampa'}
```

Same syntax for both. If the key exists, it updates. If not, it's added.

### Remove a key

```python
person = {"name": "Aaron", "age": 25, "city": "Tampa"}

# del - removes the key
del person["city"]

# pop - removes and returns the value
age = person.pop("age")         # age is 25, dict no longer has "age"
print(age)

# pop with default to avoid errors
job = person.pop("job", None)   # returns None instead of error
```

### Update with another dict

```python
person = {"name": "Aaron", "age": 25}
extra = {"city": "Tampa", "age": 26}

person.update(extra)            # add/overwrite keys from extra
print(person)
# {'name': 'Aaron', 'age': 26, 'city': 'Tampa'}
```

### Check if a key exists

```python
person = {"name": "Aaron", "age": 25}

print("name" in person)         # True
print("job" in person)          # False
```

Use `in` (or `not in`), not `.has_key()` (that's removed in Python 3).

## 4. Iterating Over Dictionaries

```python
person = {"name": "Aaron", "age": 25, "city": "Tampa"}

# default: iterates over KEYS
for key in person:
    print(key)
# name
# age
# city

# values only
for value in person.values():
    print(value)
# Aaron
# 25
# Tampa

# both - the most common pattern
for key, value in person.items():
    print(f"{key}: {value}")
# name: Aaron
# age: 25
# city: Tampa
```

`.items()` is what you use 90% of the time.

## 5. Dictionary Methods Quick Reference

| Method | What it does |
|---|---|
| `d[key]` | Get value (KeyError if missing) |
| `d.get(key, default)` | Get value or return default |
| `d[key] = value` | Set value (add or update) |
| `del d[key]` | Delete a key |
| `d.pop(key)` | Remove and return value |
| `d.update(other)` | Add/overwrite from another dict |
| `d.keys()` | View of all keys |
| `d.values()` | View of all values |
| `d.items()` | View of (key, value) pairs |
| `d.clear()` | Remove all items |
| `len(d)` | Number of key-value pairs |
| `key in d` | Check if key exists |

## 6. Key Rules

Keys must be **immutable types**: strings, numbers, tuples, frozensets.

```python
d = {1: "one", "two": 2, (3, 4): "tuple key"}    # OK

# d = {[1, 2]: "list as key"}    # TypeError: lists are mutable
```

Strings are by far the most common key type. Numbers and tuples are occasionally useful.

## 7. Nested Dictionaries

Dicts can contain other dicts:

```python
people = {
    "alice": {"age": 30, "city": "NYC"},
    "bob":   {"age": 25, "city": "LA"},
    "carol": {"age": 35, "city": "SF"}
}

print(people["alice"]["age"])           # 30
print(people["bob"]["city"])            # 'LA'

# loop over nested
for name, info in people.items():
    print(f"{name} is {info['age']} in {info['city']}")
```

This structure mirrors JSON, which is why dicts are central to API work.

## 8. Common Patterns

### Count occurrences

```python
text = "apple banana apple cherry apple banana"
words = text.split()

counts = {}
for word in words:
    if word in counts:
        counts[word] += 1
    else:
        counts[word] = 1

print(counts)
# {'apple': 3, 'banana': 2, 'cherry': 1}
```

Or using `.get()`:
```python
counts = {}
for word in words:
    counts[word] = counts.get(word, 0) + 1
```

Or using `collections.Counter` (cleaner):
```python
from collections import Counter
counts = Counter(words)
print(counts)
# Counter({'apple': 3, 'banana': 2, 'cherry': 1})
```

### Group items

```python
people = [
    {"name": "Alice", "city": "NYC"},
    {"name": "Bob",   "city": "LA"},
    {"name": "Carol", "city": "NYC"},
    {"name": "Dave",  "city": "LA"}
]

groups = {}
for person in people:
    city = person["city"]
    if city not in groups:
        groups[city] = []
    groups[city].append(person["name"])

print(groups)
# {'NYC': ['Alice', 'Carol'], 'LA': ['Bob', 'Dave']}
```

`collections.defaultdict` makes this cleaner:
```python
from collections import defaultdict
groups = defaultdict(list)
for person in people:
    groups[person["city"]].append(person["name"])
```

### Switch/case using dict lookup

Python doesn't have switch statements (well, it does since 3.10 with `match`, but dicts work everywhere):

```python
def get_day_type(day_num):
    days = {
        1: "weekday", 2: "weekday", 3: "weekday",
        4: "weekday", 5: "weekday",
        6: "weekend", 7: "weekend"
    }
    return days.get(day_num, "invalid")

print(get_day_type(3))      # 'weekday'
print(get_day_type(7))      # 'weekend'
print(get_day_type(99))     # 'invalid'
```

### Convert lists to a dict

```python
keys   = ["name", "age", "city"]
values = ["Aaron", 25, "Tampa"]

d = dict(zip(keys, values))
print(d)
# {'name': 'Aaron', 'age': 25, 'city': 'Tampa'}
```

### Merge dicts

```python
a = {"x": 1, "y": 2}
b = {"y": 99, "z": 3}

# Python 3.9+: | operator
merged = a | b
print(merged)                # {'x': 1, 'y': 99, 'z': 3}   (b overrides a)

# alternative (3.5+): unpacking
merged = {**a, **b}
```

## 9. Dictionary Comprehensions

A compact way to build dicts (covered fully in note 13):

```python
# squares of 0-9
squares = {n: n*n for n in range(10)}
print(squares)
# {0: 0, 1: 1, 2: 4, 3: 9, 4: 16, 5: 25, 6: 36, 7: 49, 8: 64, 9: 81}

# invert a dict
person = {"name": "Aaron", "age": 25}
inverted = {v: k for k, v in person.items()}
print(inverted)              # {'Aaron': 'name', 25: 'age'}
```

## 10. Dict and JSON

JSON is everywhere in data work - APIs, config files, etc. Python's `json` module converts between dicts and JSON strings:

```python
import json

# dict to JSON string
person = {"name": "Aaron", "age": 25}
json_str = json.dumps(person)
print(json_str)              # '{"name": "Aaron", "age": 25}'

# JSON string to dict
text = '{"name": "Aaron", "age": 25}'
person = json.loads(text)
print(person["name"])        # 'Aaron'
```

## Common Mistakes

### Mistake 1: KeyError on missing key

```python
d = {"a": 1}
print(d["b"])                # KeyError
```

Use `.get()`:
```python
print(d.get("b"))            # None
print(d.get("b", 0))         # 0
```

### Mistake 2: trying to use a list as a key

```python
d = {[1, 2]: "value"}        # TypeError
```

Use a tuple instead:
```python
d = {(1, 2): "value"}        # OK
```

### Mistake 3: modifying during iteration

```python
d = {"a": 1, "b": 2, "c": 3}
for key in d:
    if d[key] < 3:
        del d[key]           # RuntimeError: dictionary changed size during iteration
```

Iterate over a copy of the keys:
```python
for key in list(d):
    if d[key] < 3:
        del d[key]
```

### Mistake 4: confusing empty dict and empty set

```python
empty = {}                   # this is an empty dict
empty_set = set()             # this is an empty set
```

## When to Use a Dict

Use a dict when:
- You need to look up values by name/key
- You're modeling a record/object with named fields
- You're counting things
- Order isn't the primary concern (though Python 3.7+ dicts do preserve insertion order)

Don't use a dict when:
- You just have a list of values in order - use a list
- You need duplicates of the same key - use a list of tuples

## Summary

- Dicts are unordered (Python 3.7+: ordered by insertion) collections of key-value pairs
- Keys must be immutable (strings, numbers, tuples)
- Access with `d[key]` or safer `d.get(key, default)`
- Iterate with `.items()` for both key and value
- Heavy use in JSON, APIs, config, counting

Next: [Strings In Depth](./11-strings-in-depth.md) - more on text manipulation.
