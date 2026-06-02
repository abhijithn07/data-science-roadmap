# Class Notes: Lists, Tuples, Sets, and Dictionaries (2 June 2026)

Topics covered in class:

1. Lists in depth
2. Nested lists (matrix)
3. List comprehensions
4. Tuples - immutability, constructing, when to use
5. Sets - removing duplicates, methods
6. Dictionaries - key-value pairs, methods, nested dictionaries
7. Dictionary comprehensions

## 1. Lists in Depth

A list is an ordered, mutable collection of items. Items can be of any type.

```python
# create a list
my_list = [10, 20, 30, 40, 50]
print(my_list)
```

**Output:**

```
[10, 20, 30, 40, 50]
```

```python
# list can hold mixed types
mixed = [1, "hello", 3.14, True, [1, 2]]
print(mixed)
```

**Output:**

```
[1, 'hello', 3.14, True, [1, 2]]
```

### List indexing and slicing

Same rules as strings - 0-based positive index, negative index from the end.

```python
my_list = [10, 20, 30, 40, 50]

print(my_list[0])     # 10   first item
print(my_list[-1])    # 50   last item
print(my_list[1:4])   # [20, 30, 40]   slice
print(my_list[::-1])  # [50, 40, 30, 20, 10]   reversed
```

**Output:**

```
10
50
[20, 30, 40]
[50, 40, 30, 20, 10]
```

### .append() - add item to the end

```python
my_list = [1, 2, 3]
my_list.append(4)
print(my_list)
```

**Output:**

```
[1, 2, 3, 4]
```

### .insert(index, value) - add at a specific position

```python
my_list = [1, 2, 3, 5]
my_list.insert(3, 4)    # insert 4 at index 3
print(my_list)
```

**Output:**

```
[1, 2, 3, 4, 5]
```

### .extend() - add multiple items from another list

```python
my_list = [1, 2, 3]
my_list.extend([4, 5, 6])
print(my_list)
```

**Output:**

```
[1, 2, 3, 4, 5, 6]
```

### .pop() - remove and return the last item

Pass an index to remove from a specific position.

```python
my_list = [10, 20, 30, 40, 50]

last = my_list.pop()
print(last)         # 50
print(my_list)      # [10, 20, 30, 40]
```

**Output:**

```
50
[10, 20, 30, 40]
```

```python
my_list = [10, 20, 30, 40, 50]
first = my_list.pop(0)
print(first)        # 10
print(my_list)      # [20, 30, 40, 50]
```

**Output:**

```
10
[20, 30, 40, 50]
```

### .remove(value) - remove first occurrence of a value

```python
my_list = [10, 20, 30, 20, 40]
my_list.remove(20)       # only removes the first 20
print(my_list)
```

**Output:**

```
[10, 30, 20, 40]
```

### .count(value) - how many times a value appears

```python
my_list = [1, 2, 3, 2, 4, 2, 5]
print(my_list.count(2))
```

**Output:**

```
3
```

### .index(value) - position of the first occurrence

```python
my_list = [10, 20, 30, 40, 50]
print(my_list.index(30))
```

**Output:**

```
2
```

### .sort() - sort in place

```python
my_list = [40, 10, 30, 50, 20]
my_list.sort()
print(my_list)
```

**Output:**

```
[10, 20, 30, 40, 50]
```

```python
# sort in descending order
my_list = [40, 10, 30, 50, 20]
my_list.sort(reverse=True)
print(my_list)
```

**Output:**

```
[50, 40, 30, 20, 10]
```

### .reverse() - reverse in place

```python
my_list = [1, 2, 3, 4, 5]
my_list.reverse()
print(my_list)
```

**Output:**

```
[5, 4, 3, 2, 1]
```

## 2. Nested Lists (Matrix)

A list can contain other lists. This is how we represent a matrix (or any 2D data) in Python.

```python
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]
print(matrix)
```

**Output:**

```
[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
```

### Accessing elements in a matrix

Use two indices - first for the row, second for the column.

```python
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

print(matrix[0])        # first row -> [1, 2, 3]
print(matrix[0][0])     # first item of first row -> 1
print(matrix[1][2])     # second row, third column -> 6
print(matrix[2][2])     # last row, last column -> 9
```

**Output:**

```
[1, 2, 3]
1
6
9
```

## 3. List Comprehensions

A short way to build a list from another sequence. The syntax is:

```
[expression for item in sequence]
```

Equivalent to a for loop that builds a list.

```python
# normal way using a for loop
squares = []
for i in range(1, 6):
    squares.append(i ** 2)
print(squares)
```

**Output:**

```
[1, 4, 9, 16, 25]
```

```python
# same thing using a list comprehension
squares = [i ** 2 for i in range(1, 6)]
print(squares)
```

**Output:**

```
[1, 4, 9, 16, 25]
```

### List comprehension with a condition

```python
# get only even numbers from 1 to 10
evens = [i for i in range(1, 11) if i % 2 == 0]
print(evens)
```

**Output:**

```
[2, 4, 6, 8, 10]
```

```python
# multiple conditions
my_list = [1, 2, 3, 91, 4, 5, 6, 18, 9, 7]
filtered = [i for i in my_list if i != 91 and i != 18]
print(filtered)
```

**Output:**

```
[1, 2, 3, 4, 5, 6, 9, 7]
```

### Extracting columns from a matrix

```python
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

first_col = [row[0] for row in matrix]
print(first_col)
```

**Output:**

```
[1, 4, 7]
```

## 4. Tuples

Tuples are similar to lists but they are **immutable** - once created, they cannot be changed.

Use tuples for data that should not change, like days of the week or coordinates.

### Constructing tuples

Use parentheses `()` with elements separated by commas.

```python
# tuple with mixed types
t = (1, 2, 3)
print(t)
print(type(t))
```

**Output:**

```
(1, 2, 3)
<class 'tuple'>
```

```python
# tuple can mix object types
t = ("one", 2, "three")
print(t)
```

**Output:**

```
('one', 2, 'three')
```

### Difference between list and tuple

Lists use `[]` and are mutable. Tuples use `()` and are immutable.

```python
# this works on a list
my_list = [1, 2, 3]
my_list[0] = 100
print(my_list)
```

**Output:**

```
[100, 2, 3]
```

```python
# this fails on a tuple
t = (1, 2, 3)
# t[0] = 100         # TypeError - tuple object does not support item assignment
print("tuples cannot be changed after creation")
```

**Output:**

```
tuples cannot be changed after creation
```

### Converting between list and tuple

If you need to modify a tuple, convert to a list, change it, then convert back.

```python
t = (1, 2, 3)

# convert tuple to list
my_list = list(t)
my_list[0] = 100
print(my_list)

# convert list back to tuple
t = tuple(my_list)
print(t)
```

**Output:**

```
[100, 2, 3]
(100, 2, 3)
```

### When to use tuples

- Days of the week
- Months of the year
- Coordinates like (x, y)
- Database records that should not change
- Anything where data accidentally changing would be a bug

```python
days = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
print(days)
print(days[0])
```

**Output:**

```
('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
Mon
```

## 5. Sets

A set is an unordered collection of **unique** values. Sets automatically remove duplicates.

Created with `{}` or `set()`.

```python
# create a set
s = {1, 2, 3, 4, 5}
print(s)
print(type(s))
```

**Output:**

```
{1, 2, 3, 4, 5}
<class 'set'>
```

```python
# duplicates are removed automatically
s = {1, 2, 2, 3, 3, 3, 4}
print(s)
```

**Output:**

```
{1, 2, 3, 4}
```

### .add() - add an item

```python
s = {1, 2, 3}
s.add(4)
print(s)
```

**Output:**

```
{1, 2, 3, 4}
```

```python
# adding a duplicate has no effect
s = {1, 2, 3}
s.add(2)
print(s)
```

**Output:**

```
{1, 2, 3}
```

### .remove() vs .discard()

`.remove()` raises an error if the value is not present. `.discard()` does nothing if not present.

```python
s = {1, 2, 3}
s.remove(2)
print(s)
```

**Output:**

```
{1, 3}
```

```python
# remove() with missing value raises KeyError
s = {1, 2, 3}
# s.remove(99)        # KeyError - 99 not in set

# discard() is safer - no error
s.discard(99)
print(s)
```

**Output:**

```
{1, 2, 3}
```

### .pop() - remove and return an arbitrary item

Sets are unordered so you cannot predict which item gets popped.

```python
s = {10, 20, 30, 40}
item = s.pop()
print(item)
print(s)
```

**Output:**

```
10
{20, 30, 40}
```

### .clear() - empty the set

```python
s = {1, 2, 3}
s.clear()
print(s)
```

**Output:**

```
set()
```

### Using a set to remove duplicates from a list

```python
my_list = [1, 2, 2, 3, 3, 3, 4, 5, 5, 6]
unique = list(set(my_list))
print(unique)
```

**Output:**

```
[1, 2, 3, 4, 5, 6]
```

## 6. Dictionaries

A dictionary stores **key-value pairs**. Unlike lists, tuples, and sets (which use index position), dictionaries are accessed by their key.

Created with `{}` or `dict()`.

### Constructing a dictionary

```python
# use {} with key:value pairs
my_dict = {"key1": "value1", "key2": "value2", "key3": "value3"}
print(my_dict)
```

**Output:**

```
{'key1': 'value1', 'key2': 'value2', 'key3': 'value3'}
```

```python
# can also use the dict() constructor
my_dict = dict(key1="value1", key2="value2", key3="value3")
print(my_dict)
```

**Output:**

```
{'key1': 'value1', 'key2': 'value2', 'key3': 'value3'}
```

```python
# values can be any type
student = {
    "name": "John",
    "age": 25,
    "grades": [90, 85, 88],
    "active": True
}
print(student)
```

**Output:**

```
{'name': 'John', 'age': 25, 'grades': [90, 85, 88], 'active': True}
```

### Retrieving values by key

```python
my_dict = {"key1": 123, "key2": "hello", "key3": [1, 2, 3]}

print(my_dict["key1"])       # 123
print(my_dict["key2"])       # hello
```

**Output:**

```
123
hello
```

### Calling methods on values

Once you access a value, you can use it like any other object - call methods, index into it, etc.

```python
my_dict = {"key1": 123, "key3": ["item0", "item1", "item2"]}

# call index on the list value
print(my_dict["key3"][0])

# call a method on a string value
print(my_dict["key3"][0].upper())
```

**Output:**

```
item0
ITEM0
```

### Adding or modifying entries

```python
d = {}
d["animal"] = "joey"
d["answer"] = 42
print(d)
```

**Output:**

```
{'animal': 'joey', 'answer': 42}
```

```python
# modify an existing value
d = {"key1": 123}
d["key1"] = d["key1"] - 23
print(d)
```

**Output:**

```
{'key1': 100}
```

### Nested dictionaries

A dictionary value can be another dictionary - any number of levels deep.

```python
d = {"key1": {"nestkey": {"subnestkey": 123}}}

# access by chaining keys
print(d["key1"]["nestkey"]["subnestkey"])
```

**Output:**

```
123
```

### .keys() - get all the keys

```python
d = {"key1": 1, "key2": 2, "key3": 3}
print(d.keys())
```

**Output:**

```
dict_keys(['key1', 'key2', 'key3'])
```

### .values() - get all the values

```python
d = {"key1": 1, "key2": 2, "key3": 3}
print(d.values())
```

**Output:**

```
dict_values([1, 2, 3])
```

### .items() - get all key-value pairs as tuples

```python
d = {"key1": 1, "key2": 2, "key3": 3}
print(d.items())
```

**Output:**

```
dict_items([('key1', 1), ('key2', 2), ('key3', 3)])
```

```python
# iterate through key-value pairs
d = {"key1": 1, "key2": 2, "key3": 3}
for key, value in d.items():
    print(key, "->", value)
```

**Output:**

```
key1 -> 1
key2 -> 2
key3 -> 3
```

## 7. Dictionary Comprehensions

Same idea as list comprehensions but builds a dictionary. Syntax:

```
{key_expression: value_expression for item in sequence}
```

```python
# build a dictionary of numbers and their squares
d = {x: x ** 2 for x in range(1, 11)}
print(d)
```

**Output:**

```
{1: 1, 2: 4, 3: 9, 4: 16, 5: 25, 6: 36, 7: 49, 8: 64, 9: 81, 10: 100}
```

```python
# with a condition - only include even numbers
d = {x: x ** 2 for x in range(1, 11) if x % 2 == 0}
print(d)
```

**Output:**

```
{2: 4, 4: 16, 6: 36, 8: 64, 10: 100}
```
