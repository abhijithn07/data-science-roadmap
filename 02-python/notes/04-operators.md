# 04. Operators

An **operator** is a symbol that performs a computation on one or more values (the **operands**). Python has four main categories:

1. **Arithmetic** - math: `+`, `-`, `*`, `/`, `//`, `%`, `**`
2. **Comparison** - compare values: `==`, `!=`, `<`, `>`, `<=`, `>=`
3. **Logical** - combine booleans: `and`, `or`, `not`
4. **Assignment** - assign and modify variables: `=`, `+=`, `-=`, etc.

## 1. Arithmetic Operators

| Operator | Meaning | Example | Result |
|---|---|---|---|
| `+` | addition | `10 + 3` | `13` |
| `-` | subtraction | `10 - 3` | `7` |
| `*` | multiplication | `10 * 3` | `30` |
| `/` | division | `10 / 3` | `3.333...` |
| `//` | floor division | `10 // 3` | `3` |
| `%` | modulo (remainder) | `10 % 3` | `1` |
| `**` | exponent | `10 ** 3` | `1000` |

### Important detail: `/` vs `//`

In Python 3, **regular division `/` always returns a float**, even when the result is a whole number:

```python
print(10 / 5)    # 2.0  (NOT 2)
print(10 / 3)    # 3.3333333333333335
```

**Floor division `//`** drops the decimal and returns an integer (if both operands are ints):

```python
print(10 // 3)   # 3
print(10 // 5)   # 2
print(-7 // 2)   # -4   (rounds DOWN, not toward zero)
```

### Modulo (`%`) - extremely useful

`%` gives the remainder after division. Many practical uses:

```python
# is a number even or odd?
n = 7
if n % 2 == 0:
    print("even")
else:
    print("odd")     # this runs

# is a year a leap year? (simplified)
year = 2024
if year % 4 == 0:
    print("possibly leap")

# every 5th iteration of something
for i in range(20):
    if i % 5 == 0:
        print(i)         # 0, 5, 10, 15
```

### Exponent (`**`)

```python
print(2 ** 10)       # 1024
print(2 ** 0.5)      # 1.4142...   (square root)
print(10 ** -1)      # 0.1
```

Use `**` for powers, not `^`. The `^` symbol in Python is bitwise XOR (different thing entirely).

### Order of operations

Python follows the standard math order: parentheses, exponents, multiplication/division, addition/subtraction. Use parentheses to control:

```python
print(2 + 3 * 4)       # 14    (3*4 first, then +2)
print((2 + 3) * 4)     # 20    (parens force +)
print(2 ** 3 ** 2)     # 512   (** is right-associative: 3**2 first = 9, then 2**9)
```

### Strings can use some arithmetic too

```python
print("ab" + "cd")     # "abcd"   concat
print("ab" * 3)        # "ababab" repeat
# print("ab" - "a")    # ERROR: subtraction not defined for strings
```

## 2. Comparison Operators

These compare two values and return `True` or `False`.

| Operator | Meaning | Example | Result |
|---|---|---|---|
| `==` | equal to | `5 == 5` | `True` |
| `!=` | not equal to | `5 != 3` | `True` |
| `>` | greater than | `5 > 3` | `True` |
| `<` | less than | `5 < 3` | `False` |
| `>=` | greater or equal | `5 >= 5` | `True` |
| `<=` | less or equal | `5 <= 4` | `False` |

### `=` vs `==`

This is the classic beginner trap:

- `=` is **assignment** (set a variable)
- `==` is **comparison** (check equality)

```python
x = 5         # ASSIGN 5 to x
x == 5        # CHECK if x equals 5 (returns True)
```

```python
if x = 5:     # SYNTAX ERROR
if x == 5:    # correct
```

### Chained comparisons (Python is unique here)

Python lets you chain comparison operators in a natural way:

```python
x = 15
if 10 < x < 20:
    print("between 10 and 20")
```

This is equivalent to `10 < x and x < 20`. Most languages don't allow this; in Java or C you'd have to write the longer form.

### Comparing strings

Strings compare alphabetically (technically by character code):

```python
print("apple" < "banana")    # True   (a comes before b)
print("Apple" < "apple")     # True   (uppercase letters come before lowercase in ASCII)
print("abc" == "abc")        # True
```

### Comparing across types

```python
print(5 == 5.0)         # True   (int and float can be compared, Python converts)
print(5 == "5")         # False  (int vs str, different types, never equal)
print(True == 1)        # True   (booleans ARE numbers in Python, True == 1)
print(False == 0)       # True
```

## 3. Logical Operators

Combine boolean values. Result is `True` or `False`.

| Operator | What it does |
|---|---|
| `and` | True if BOTH sides are True |
| `or` | True if at least one side is True |
| `not` | flips True/False |

```python
x = True
y = False

print(x and y)    # False  (both must be True)
print(x or y)     # True   (at least one is True)
print(not x)      # False  (flips True to False)
print(not y)      # True   (flips False to True)
```

### Combining comparisons

This is where logical operators really shine:

```python
age = 25
has_id = True

if age >= 18 and has_id:
    print("can enter the venue")

if age < 13 or age > 60:
    print("free entry")

if not has_id:
    print("show your ID at the door")
```

### Truth tables

`and` returns True only if both inputs are True:

| A | B | A and B |
|---|---|---|
| T | T | T |
| T | F | F |
| F | T | F |
| F | F | F |

`or` returns True if either input is True:

| A | B | A or B |
|---|---|---|
| T | T | T |
| T | F | T |
| F | T | T |
| F | F | F |

### Short-circuit evaluation

Python evaluates logical expressions from left to right and **stops as soon as the answer is determined**:

```python
# 'and' short-circuits on the first False
False and expensive_function()   # expensive_function is NEVER called
True and expensive_function()    # expensive_function IS called

# 'or' short-circuits on the first True
True or expensive_function()     # expensive_function is NEVER called
False or expensive_function()    # expensive_function IS called
```

This is useful for safe checks:

```python
# don't crash if name is None
name = None
if name is not None and name.startswith("A"):
    print("starts with A")
# 'name is not None' is False, so the startswith() is skipped (no crash)
```

### Logical operators with non-booleans

`and` and `or` actually return one of the operands, not a strict True/False:

```python
print(5 and 10)      # 10   (both truthy, returns last)
print(0 and 10)      # 0    (first is falsy, returns first)
print(5 or 10)       # 5    (first is truthy, returns first)
print(0 or 10)       # 10   (first is falsy, returns second)
print(0 or "")       # ""   (both falsy, returns last)
```

You can use this for default values:

```python
name = user_input or "Anonymous"   # if user_input is empty/None, use "Anonymous"
```

This is concise but can be surprising. When you want a strict boolean, use `bool()`.

## 4. Assignment Operators

Beyond simple `=`, Python has **compound assignment** operators that combine an operation with assignment.

| Operator | Equivalent to | Example |
|---|---|---|
| `=` | (simple assign) | `x = 5` |
| `+=` | `x = x + ...` | `x += 3` |
| `-=` | `x = x - ...` | `x -= 2` |
| `*=` | `x = x * ...` | `x *= 4` |
| `/=` | `x = x / ...` | `x /= 2` |
| `//=` | `x = x // ...` | `x //= 3` |
| `%=` | `x = x % ...` | `x %= 2` |
| `**=` | `x = x ** ...` | `x **= 2` |

Example walkthrough:

```python
x = 10

x += 5      # x is now 15  (10 + 5)
x -= 2      # x is now 13  (15 - 2)
x *= 2      # x is now 26  (13 * 2)
x /= 4      # x is now 6.5 (26 / 4)
x //= 2     # x is now 3.0 (6.5 // 2)
x **= 2     # x is now 9.0 (3 ** 2)
x %= 4      # x is now 1.0 (9 % 4)
```

These are just shortcuts. `x += 5` does the same thing as `x = x + 5`. The shorter form is preferred when you're modifying a variable in place.

### Compound assignment with strings

`+=` works with strings as a "append" operation:

```python
greeting = "Hello"
greeting += " World"        # same as greeting = greeting + " World"
print(greeting)             # "Hello World"
```

`*=` works as repeat:

```python
line = "-"
line *= 20                  # 20 dashes
print(line)                 # "--------------------"
```

## Operator Precedence (Order of Evaluation)

When you mix operators, Python evaluates them in this order (high to low priority):

1. `**` (exponent)
2. `+x`, `-x` (unary plus/minus)
3. `*`, `/`, `//`, `%`
4. `+`, `-`
5. `<`, `<=`, `>`, `>=`, `==`, `!=`
6. `not`
7. `and`
8. `or`

**When in doubt, use parentheses.** This is true in every language. Readability beats remembering precedence.

```python
# unclear (depends on memory of precedence)
result = x + 5 * 2 > 10 and not y == 3

# clear (explicit grouping)
result = ((x + (5 * 2)) > 10) and (not (y == 3))
```

## Summary Table

| Category | Operators | Example | Result type |
|---|---|---|---|
| Arithmetic | `+ - * / // % **` | `5 + 3` | number |
| Comparison | `== != < > <= >=` | `5 > 3` | bool |
| Logical | `and or not` | `True and False` | bool |
| Assignment | `= += -= *= /= //= %= **=` | `x += 1` | (modifies variable) |

## Common Mistakes

### Mistake 1: `=` instead of `==`

```python
if x = 5:           # ERROR: syntax
if x == 5:          # correct
```

### Mistake 2: `^` for exponent

`^` is bitwise XOR in Python, not exponent. Use `**`:

```python
print(2 ^ 3)     # 1   (bitwise XOR, not what you want)
print(2 ** 3)    # 8   (exponent)
```

### Mistake 3: forgetting `/` is always float

```python
total = 10 / 2          # 5.0, not 5
items_per_page = 100 / 10    # 10.0
```

Use `//` if you specifically want an integer.

### Mistake 4: bad chaining

```python
if 1 < x < 10:        # works in Python (chained comparison)
if 1 < x and x < 10:  # equivalent, also works

# common mistake from other languages:
if 1 < x and < 10:    # SYNTAX ERROR (forgot the x)
```

Next: [Input and String Formatting](./05-input-and-string-formatting.md) - getting data from users and building output strings.
