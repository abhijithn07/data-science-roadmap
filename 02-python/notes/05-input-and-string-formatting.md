# 05. Input and String Formatting

This file covers two related skills:

1. **Reading input** from the user with `input()`
2. **Formatting strings** for output: f-strings, `.format()`, and `%` formatting

## 1. `input()` - reading from the user

The built-in `input()` function pauses your program, waits for the user to type something and press Enter, then returns what they typed.

```python
name = input("What is your name? ")
print("Hello", name)
```

When you run this, the program prints `What is your name? ` and waits. The user types their name and hits Enter. Whatever they typed becomes the value of `name`.

### The argument to `input()` is the prompt

```python
input()                      # no prompt, just waits silently (not user-friendly)
input("Enter name: ")        # shows "Enter name: " and waits
```

The prompt is just text shown before the cursor. Always include a clear prompt so the user knows what's expected.

### `input()` ALWAYS returns a string

This is the most important thing to remember:

```python
age = input("Enter your age: ")
print(type(age))      # <class 'str'>
print(age + 1)        # ERROR: can only concatenate str (not "int") to str
```

Even if the user types `25`, Python receives `"25"` as a string. The user typed a sequence of characters; Python doesn't try to interpret them as numbers.

### Convert with `int()`, `float()`, or `bool()`

To use input as a number, cast it:

```python
age = int(input("Enter your age: "))    # cast immediately
print(age + 1)                            # works now, age is an int
```

Or for floats:

```python
price = float(input("Enter the price: "))
```

If the user types something that can't be converted, you get a `ValueError`:

```python
# User types "hello" when asked for age:
age = int(input("Enter your age: "))     # ValueError: invalid literal for int()
```

Handling this gracefully needs `try/except`, which is a later topic.

### Reading multiple values

A simple pattern: ask for each value on a separate line.

```python
first = input("First name: ")
last = input("Last name: ")
age = int(input("Age: "))
print(f"Hi {first} {last}, you are {age}")
```

If you want multiple values on one line (e.g., the user types "5 10 15"), you can split:

```python
text = input("Enter three numbers separated by spaces: ")
parts = text.split()       # ["5", "10", "15"]
a = int(parts[0])
b = int(parts[1])
c = int(parts[2])
```

Or in one line with multiple assignment:

```python
a, b, c = map(int, input("Enter three numbers: ").split())
```

(That uses `split()` and `map()`, which you'll meet later. For now, the multi-step version is clearer.)

## 2. String Formatting - inserting variables into text

You almost always want to print messages that mix fixed text with variable values. There are three main ways to do this.

### Way A: Concatenation with `+` (the hard way)

```python
name = "Aaron"
age = 25
print("My name is " + name + " and I am " + str(age) + " years old")
```

This works but is awkward:
- You have to add spaces manually inside the strings
- You have to cast non-strings with `str()`
- Hard to read for long messages

For these reasons, **don't use this**. Use one of the methods below.

### Way B: f-strings (preferred, modern Python)

f-strings were added in Python 3.6 and are now the standard way to format strings. Prefix the string with `f` and put variable names inside `{ }`:

```python
name = "Aaron"
age = 25
print(f"My name is {name} and I am {age} years old")
```

Output: `My name is Aaron and I am 25 years old`

You can also put **expressions** inside the braces:

```python
print(f"Next year I will be {age + 1}")
print(f"Half my age is {age / 2}")
print(f"My name has {len(name)} letters")
```

Output:
```
Next year I will be 26
Half my age is 12.5
My name has 5 letters
```

### Way B+: f-string format specifiers

You can control how values are formatted using `:` inside the braces.

**Decimal places:**
```python
pi = 3.14159265
print(f"Pi is roughly {pi:.2f}")     # "Pi is roughly 3.14"
print(f"Pi is roughly {pi:.4f}")     # "Pi is roughly 3.1416"
```

The `.2f` means "float with 2 decimal places."

**Width and padding:**
```python
for i in range(1, 6):
    print(f"|{i:>5}|")               # right-align in 5 chars
# |    1|
# |    2|
# ...

print(f"|{42:<10}|")                  # left-align in 10 chars: |42        |
print(f"|{42:^10}|")                  # center in 10 chars:     |    42    |
print(f"|{42:05}|")                   # zero-pad to 5 digits:   |00042|
```

**Thousands separator:**
```python
n = 1234567
print(f"{n:,}")                       # "1,234,567"
```

**Percentage:**
```python
rate = 0.0825
print(f"{rate:.2%}")                  # "8.25%"
```

**Date formatting:**
```python
from datetime import datetime
now = datetime.now()
print(f"{now:%Y-%m-%d %H:%M}")        # "2026-05-29 10:30"
```

### Way C: `.format()` method (older but still common)

Before f-strings, the `.format()` method was the recommended way. You'll still see it a lot in older code.

```python
name = "Aaron"
age = 25
print("My name is {} and I am {} years old".format(name, age))
```

Curly braces `{}` are placeholders that get filled in order from the `.format()` arguments.

**With named placeholders:**

```python
print("My name is {n} and I am {a} years old".format(n=name, a=age))
```

**With format specifiers:**

```python
pi = 3.14159265
print("Pi is {:.2f}".format(pi))      # "Pi is 3.14"
```

Most things you can do with f-strings, you can do with `.format()` too. f-strings are just shorter and more readable, so prefer them.

### Way D: `%` formatting (oldest, C-style)

The original Python string formatting. Looks like C's `printf`:

```python
name = "Aaron"
age = 25
print("My name is %s and I am %d years old" % (name, age))
```

- `%s` is for strings
- `%d` is for integers
- `%f` is for floats (with `%.2f` for 2 decimals)

This style is rarely used in new code, but you'll see it in older Python codebases. Recognize it but don't write new code with it.

## Quick Comparison

```python
name = "Aaron"
age = 25

# f-string (preferred)
print(f"My name is {name} and I am {age}")

# .format() (older)
print("My name is {} and I am {}".format(name, age))

# % (oldest)
print("My name is %s and I am %d" % (name, age))

# concatenation (avoid)
print("My name is " + name + " and I am " + str(age))
```

All four produce the same output. **Use f-strings for new code.**

## Common Patterns

### Pattern 1: greeting from user input

```python
name = input("What's your name? ")
print(f"Hello, {name}!")
```

### Pattern 2: calculate and display

```python
weight_kg = float(input("Your weight in kg: "))
height_m = float(input("Your height in meters: "))
bmi = weight_kg / (height_m ** 2)
print(f"Your BMI is {bmi:.1f}")
```

### Pattern 3: build a multi-line message

```python
name = "Aaron"
age = 25
job = "engineer"

message = f"""
Name:  {name}
Age:   {age}
Job:   {job}
"""
print(message)
```

Triple-quoted f-strings let you build multi-line output cleanly.

### Pattern 4: table-style output

```python
items = ["apple", "banana", "cherry"]
prices = [1.50, 0.75, 3.99]

for item, price in zip(items, prices):
    print(f"{item:<10} ${price:>6.2f}")

# apple      $  1.50
# banana     $  0.75
# cherry     $  3.99
```

This uses the alignment specifiers we covered above.

## Common Mistakes

### Mistake 1: forgetting `int()` after input

```python
age = input("Age: ")           # age is "25" (string)
if age > 18:                    # ERROR: can't compare str and int
    print("adult")
```

Fix:
```python
age = int(input("Age: "))
if age > 18:
    print("adult")
```

### Mistake 2: forgetting the `f` prefix

```python
name = "Aaron"
print("Hello {name}")           # prints literally: "Hello {name}"
print(f"Hello {name}")           # prints: "Hello Aaron"
```

### Mistake 3: missing `str()` for old-style concat

```python
age = 25
print("Age: " + age)             # ERROR
print("Age: " + str(age))        # works
print(f"Age: {age}")             # works (f-string auto-converts)
```

f-strings handle the type conversion for you, which is one more reason to prefer them.

### Mistake 4: `input()` with no prompt

```python
name = input()              # works, but user sees blank prompt and is confused
name = input("Name: ")      # better
```

Always include a clear prompt.

## Summary

- `input()` reads a line from the user. Always returns a string.
- To get a number from input, wrap in `int()` or `float()`.
- For output, use f-strings: `f"text {variable} more text"`.
- f-strings support format specifiers: `{value:.2f}`, `{value:>10}`, etc.
- `.format()` is older but equivalent.
- `%` formatting is the oldest style, rarely used in new code.

Next: [Conditionals](./06-conditionals.md) - making decisions in code with `if`, `elif`, and `else`.
