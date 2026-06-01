# 02. Variables and Data Types

## What is a Variable?

A **variable** is a name that points to a value. Think of it as a label you stick on a piece of data so you can refer to it later.

```python
age = 25
name = "Aaron"
```

After these two lines, `age` refers to the integer `25`, and `name` refers to the string `"Aaron"`. You can now use those names instead of typing the values repeatedly.

```python
print(age)              # 25
print(name)             # Aaron
print(age + 1)          # 26
print("Hi " + name)     # Hi Aaron
```

## How Python is Different

In many languages (Java, C, C++) you have to **declare** the type of a variable before using it:

```java
int age = 25;           // Java: explicitly declare age is an integer
String name = "Aaron";  // Java: explicitly declare name is a string
```

**Python does not require this.** Just assign a value with `=` and Python figures out the type automatically. This is called **dynamic typing** (more on this in the next file).

```python
age = 25          # python figures out: this is an integer
name = "Aaron"    # python figures out: this is a string
```

## Reassignment

A variable can be reassigned to a different value any time:

```python
a = 9
a = 10            # a now points to 10. The old value 9 is gone.
print(a)          # 10
```

**What happens to the old value (9)?** Nothing points to it anymore, so Python's **garbage collector** cleans it up automatically. You don't have to think about memory management.

In Python, a variable can even change type:

```python
a = 9
a = "hello"       # totally legal. a is now a string. no error.
a = [1, 2, 3]     # now it's a list.
```

This is unusual compared to most languages and is part of what makes Python flexible.

## Variable Naming Rules

- Must start with a letter or underscore (`_`)
- Can contain letters, digits, and underscores
- Case-sensitive: `age` and `Age` are different variables
- Cannot be a Python reserved word (`if`, `for`, `class`, `def`, `True`, `None`, etc.)

```python
# valid names
name = "Aaron"
user_age = 25
_private = "hidden"
counter1 = 0

# invalid names
1counter = 0      # cannot start with a digit
user-age = 25     # hyphens not allowed
class = "math"    # 'class' is reserved
```

**Convention (PEP 8):** use `snake_case` for variable names (lowercase, words separated by underscores).

```python
first_name = "Aaron"     # good
firstName = "Aaron"      # works but not Pythonic (this is Java/JavaScript style)
FirstName = "Aaron"      # works but reserved for class names by convention
```

## The Five Basic Data Types

Python has many built-in types, but five cover almost everything you'll do at first.

### 1. Integer (`int`)

Whole numbers, positive or negative or zero. No upper limit (unlike many languages).

```python
age = 25
temperature = -10
year = 2026
big = 999999999999999999999999  # works fine, no overflow
```

### 2. Float (`float`)

Numbers with a decimal point.

```python
price = 19.99
pi = 3.14159
gravity = -9.81
small = 0.0001
```

**Math with floats can have tiny precision errors** because of how computers store them:

```python
print(0.1 + 0.2)    # 0.30000000000000004    (not exactly 0.3)
```

This is true in every programming language. For exact decimal math, use the `decimal` module (advanced).

### 3. String (`str`)

Text. Surrounded by quotes (single or double, your choice).

```python
name = "Aaron"
greeting = 'Hello'
sentence = "It's a beautiful day"   # double quotes let you use apostrophes inside
quote = 'She said "hi" to me'        # single quotes let you use double quotes inside
```

For multi-line strings, use triple quotes:

```python
poem = """Roses are red
Violets are blue
Python is cool
And so are you"""
```

### 4. Complex (`complex`)

Complex numbers, with a real and imaginary part. Written with `j` for the imaginary unit (mathematicians use `i`, but in Python it's `j` since `i` is too common as a loop variable).

```python
z = 3 + 4j
print(z.real)      # 3.0
print(z.imag)      # 4.0
```

You'll rarely use this unless you do scientific or engineering math. Mentioned because it exists and is one of Python's built-in types.

### 5. Boolean (`bool`)

Either `True` or `False`. Capitalization matters: `true` and `false` are not valid in Python.

```python
is_active = True
is_admin = False
print(5 > 3)        # True
print(5 == 6)       # False
```

Booleans come from comparisons and from logical operations. You'll use them constantly in `if` statements.

## Checking the Type: `type()`

Python has a built-in function `type()` that tells you the type of any value or variable.

```python
print(type(9))         # <class 'int'>
print(type(3.14))      # <class 'float'>
print(type("hello"))   # <class 'str'>
print(type(True))      # <class 'bool'>
print(type(3 + 4j))    # <class 'complex'>
print(type(None))      # <class 'NoneType'>
```

You can also pass a variable to `type()`:

```python
x = 42
print(type(x))         # <class 'int'>

x = "hello"
print(type(x))         # <class 'str'>  (changed because we reassigned)
```

`type()` is useful when:
- You're debugging and want to confirm what a variable holds
- You need to do something different based on the type
- A function returned something and you're not sure what

## Multiple Assignment

Python lets you assign multiple variables in one line:

```python
a, b, c = 1, 2, 3
print(a, b, c)        # 1 2 3

# all the same value
x = y = z = 0
print(x, y, z)        # 0 0 0

# swap two variables without a temporary
a, b = 5, 10
a, b = b, a           # swap
print(a, b)           # 10 5
```

That swap trick is very useful and only takes one line.

## Constants (Sort of)

Python doesn't have true constants. By **convention**, an ALL_CAPS name means "don't change this":

```python
PI = 3.14159
MAX_USERS = 1000
DATABASE_URL = "localhost:5432"
```

Python won't stop you from reassigning these, but other programmers reading your code will understand they're meant to be constant.

## `None`: The Absence of a Value

Python has a special value `None`, similar to SQL's `NULL`. It represents "no value" or "missing."

```python
result = None
print(result)         # None
print(type(result))   # <class 'NoneType'>
```

`None` is used when a function has no meaningful return value, or as a placeholder for "not set yet."

```python
favorite_color = None    # we don't know yet
if favorite_color is None:
    print("not set")
```

Always use `is None` and `is not None` to check for None (not `== None`). This is a Python convention.

## A Common Beginner Question

**Q: When I do `a = 5`, where exactly is the 5 stored?**

A: Python creates an object in memory holding the value 5, and the name `a` becomes a reference to that object.

```python
a = 5     # creates int object 5, name 'a' refers to it
b = a     # name 'b' also refers to the SAME object
b = 10    # name 'b' now refers to a different object (10). a is still 5.
```

This matters more when you get to mutable types like lists, but the mental model is useful from day one.

## Summary Table

| Type | Example | Description |
|---|---|---|
| `int` | `42`, `-7`, `0` | whole numbers, no size limit |
| `float` | `3.14`, `-0.5` | decimal numbers |
| `str` | `"hello"` | text in quotes |
| `bool` | `True`, `False` | true or false |
| `complex` | `3 + 4j` | complex numbers (math/engineering) |
| `NoneType` | `None` | absence of value |

Once you know the type of a value, you can predict what operations work on it. Numbers add, strings concat, booleans combine with `and`/`or`. The next file covers how to convert between types when you need to.
