# 03. Type Casting and Typing

This file covers four related concepts:

1. **Implicit type conversion** - Python converts types automatically when safe
2. **Explicit type conversion (casting)** - you convert types manually
3. **Duck typing** - Python's "if it acts like X, treat it as X" philosophy
4. **Dynamic typing** - variables don't have fixed types

## 1. Implicit Type Conversion

When you mix types in an expression, Python sometimes converts them automatically to make the operation work.

```python
a = 9            # int
b = 3.5          # float
print(a + b)     # 12.5
print(type(a + b))   # <class 'float'>
```

What happened? Python knows `int + float` doesn't fit cleanly into an int (you'd lose the decimal). So it **promotes** the int to a float, then adds. Result is a float.

This works in any direction where there's a "wider" type that can hold both:

```python
print(5 + 2.0)       # 7.0    (int promoted to float)
print(True + 1)      # 2      (bool promoted to int, since True is treated as 1)
print(False * 5)     # 0      (False is treated as 0)
```

Implicit conversion is convenient. You don't have to think about it. But it only happens when the conversion is **safe** (no information lost).

**When implicit conversion does NOT happen:**

```python
print("5" + 5)       # ERROR: can only concatenate str (not "int") to str
```

Python won't guess whether you want `"55"` (string concat) or `10` (number addition). You have to be explicit.

## 2. Explicit Type Conversion (Casting)

When implicit conversion won't work, or when you want to force a conversion, you **cast** manually using one of Python's built-in functions.

### `int(x)` - convert to integer

```python
int("10")            # 10        (string of digits to int)
int(3.9)             # 3         (float to int: drops the decimal, does NOT round)
int(-3.9)            # -3        (drops decimal, same direction)
int(True)            # 1
int(False)           # 0
int("3.14")          # ERROR: cannot convert decimal string directly to int
int("hello")         # ERROR: not a valid number
```

**Watch out:** `int()` truncates floats toward zero. It doesn't round:

```python
int(3.5)     # 3, not 4
int(3.9)     # 3, not 4
int(-3.9)    # -3, not -4
```

To round properly, use `round()`:

```python
round(3.5)   # 4
round(3.9)   # 4
round(-3.9)  # -4
```

### `float(x)` - convert to float

```python
float("3.14")        # 3.14
float("3")           # 3.0
float(5)             # 5.0
float(True)          # 1.0
float("hello")       # ERROR
```

### `str(x)` - convert to string

Almost anything can be converted to a string:

```python
str(123)             # "123"
str(3.14)            # "3.14"
str(True)            # "True"
str([1, 2, 3])       # "[1, 2, 3]"
```

This is essential when you need to combine numbers with text:

```python
age = 25
# print("I am " + age)        # ERROR: can't concat str and int
print("I am " + str(age))     # "I am 25"
```

### `bool(x)` - convert to boolean

This one is interesting because it follows the **truthiness** rules (more on this in the conditionals file):

```python
bool(0)              # False
bool(0.0)            # False
bool("")             # False  (empty string)
bool([])             # False  (empty list)
bool(None)           # False
bool(1)              # True
bool(-5)             # True   (any non-zero number is truthy)
bool("hello")        # True   (any non-empty string is truthy)
bool("False")        # True   (this is a non-empty string, not the boolean False!)
```

## Casting Chain Example

```python
# Get a number from the user
user_input = input("Enter your age: ")     # input() always returns a string
age = int(user_input)                       # cast to int so we can do math
next_year = age + 1
print("Next year you will be " + str(next_year))   # cast back to str to concat
```

Or more concisely:
```python
age = int(input("Enter your age: "))
print(f"Next year you will be {age + 1}")
```

## 3. Duck Typing

Python has a philosophy called **duck typing**:

> "If it walks like a duck and quacks like a duck, treat it as a duck."

What this means in practice: Python doesn't care what **type** an object is. It only cares whether the object can do the **operations** you're asking of it.

Example:
```python
def show_length(thing):
    print(len(thing))

show_length("hello")           # 5    (string supports len)
show_length([1, 2, 3])         # 3    (list supports len)
show_length({"a": 1, "b": 2})  # 2    (dict supports len)
show_length(42)                # ERROR: int does not support len
```

The `show_length` function doesn't say "I only accept strings" or "only accept lists." It just tries `len()`. If the object supports `len()`, great. If not, error.

This is different from languages like Java where you'd have to declare exactly what types a function accepts. Python's approach is more flexible.

**You won't use duck typing actively day one** but it's important context for how Python "thinks" about types.

## 4. Dynamic Typing

Dynamic typing means **variables don't have a fixed type**. The type is determined by whatever value is currently assigned.

```python
x = 5             # x is an int
x = "hello"       # x is now a str
x = [1, 2, 3]     # x is now a list
x = True          # x is now a bool
```

Compare to a **statically typed** language like Java:

```java
int x = 5;        // x is declared as int, MUST always be int
x = "hello";      // ERROR: compiler refuses
```

In Python you have flexibility. You can change a variable's type any time. The cost: bugs sometimes hide because Python doesn't catch type mismatches until runtime.

```python
def calculate(a, b):
    return a + b

calculate(5, 10)           # 15
calculate("hi", "there")   # "hithere"   (works, but maybe not what you wanted)
calculate(5, "hi")         # ERROR at runtime, not at definition time
```

In Java the third call would be caught at compile time. In Python you only find out when you actually run that line.

This is why **type hints** were added in Python 3.5+ as an optional feature:

```python
def calculate(a: int, b: int) -> int:
    return a + b
```

Type hints don't enforce anything at runtime, but they document intent and tools like mypy can check them statically. You'll see these later. They're a good practice but not required.

## Putting It Together

These four concepts are related:

- **Implicit conversion** is Python being helpful when types can be safely converted.
- **Explicit casting** is you taking control when you want a specific type.
- **Duck typing** is the philosophy: focus on behavior, not type names.
- **Dynamic typing** is the underlying mechanism: variables can hold any type.

## Common Mistakes

### Mistake 1: forgetting to cast input()

```python
age = input("Enter your age: ")    # always a string
if age > 18:                        # ERROR: can't compare str and int
    print("adult")
```

Fix:
```python
age = int(input("Enter your age: "))
```

### Mistake 2: concatenating string and number

```python
score = 95
print("Your score is: " + score)    # ERROR
```

Fix:
```python
print("Your score is: " + str(score))
# OR use f-string (preferred)
print(f"Your score is: {score}")
```

### Mistake 3: assuming int() rounds

```python
price = 9.7
whole_dollars = int(price)          # 9, not 10
```

Fix:
```python
whole_dollars = round(price)        # 10
```

### Mistake 4: thinking `"True"` and `True` are the same

```python
flag = "False"      # a string, not the boolean False
if flag:
    print("hi")     # this DOES print, because "False" is a non-empty string (truthy)
```

The boolean is `True`/`False` (no quotes). `"True"` and `"False"` are just strings.

## Summary

| Concept | What it is |
|---|---|
| Implicit conversion | Python converts types automatically when safe (int + float → float) |
| Explicit conversion (casting) | You convert manually with `int()`, `float()`, `str()`, `bool()` |
| Duck typing | Python cares about what an object can DO, not what it IS |
| Dynamic typing | Variables don't have fixed types; type is set by current value |

Next: [Operators](./04-operators.md) - all the symbols you use to manipulate values.
