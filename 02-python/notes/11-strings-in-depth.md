# 11. Strings In Depth

You've seen strings since day 1. This note covers the operations you'll use constantly when working with text data.

A string is a sequence of characters. Like a list, you can index and slice it. Unlike a list, **strings are immutable** - you can't change a character in place.

## 1. Creating Strings

```python
s = "hello"
s = 'hello'              # single quotes work too
s = """multi-line
string"""                # triple quotes for multi-line
s = '''same thing'''

# escape characters
s = "she said \"hi\""    # \" for literal quote
s = "line1\nline2"       # \n for newline
s = "col1\tcol2"         # \t for tab
s = "back\\slash"        # \\ for literal backslash

# raw strings (no escape processing)
s = r"C:\Users\name"     # backslashes left as-is
```

## 2. Indexing and Slicing

Just like lists:

```python
s = "hello world"

print(s[0])              # 'h'
print(s[-1])             # 'd'    last char
print(s[0:5])            # 'hello'
print(s[6:])             # 'world'
print(s[::-1])           # 'dlrow olleh'   (reversed)
print(s[::2])            # 'hlowrd'        (every 2nd char)
```

**Strings are immutable:**

```python
s = "hello"
s[0] = "H"               # TypeError: 'str' object does not support item assignment
```

To "change" a string, build a new one:

```python
s = "hello"
s = "H" + s[1:]          # 'Hello'
```

## 3. String Methods

Strings have many built-in methods. None of them modify the original (since strings are immutable) - they all return a **new** string.

### Case methods

```python
s = "Hello World"

print(s.upper())          # 'HELLO WORLD'
print(s.lower())          # 'hello world'
print(s.title())          # 'Hello World'
print(s.capitalize())     # 'Hello world'   (only first char)
print(s.swapcase())       # 'hELLO wORLD'
```

### Whitespace

```python
s = "   hello   "

print(s.strip())          # 'hello'         removes both sides
print(s.lstrip())         # 'hello   '      left only
print(s.rstrip())         # '   hello'      right only

# strip specific characters (not just whitespace)
print("###hello###".strip("#"))    # 'hello'
print("00012345".lstrip("0"))       # '12345'
```

### Searching

```python
s = "hello world"

# find: returns index, or -1 if not found
print(s.find("world"))    # 6
print(s.find("xyz"))      # -1

# index: same but raises ValueError if not found
print(s.index("world"))   # 6
# s.index("xyz")           # ValueError

# count occurrences
print(s.count("l"))       # 3
print(s.count("xyz"))     # 0

# does it start/end with something?
print(s.startswith("hello"))   # True
print(s.endswith("world"))     # True
```

### Replace

```python
s = "hello world"

print(s.replace("world", "python"))      # 'hello python'
print(s.replace("l", "L"))                # 'heLLo worLd'
print(s.replace("l", "L", 2))             # 'heLLo world'   (max 2 replacements)
```

### Split and join - very common in data work

```python
# split into a list
csv = "apple,banana,cherry"
parts = csv.split(",")
print(parts)              # ['apple', 'banana', 'cherry']

# split by whitespace (any amount, including tabs)
text = "  hello   world   python  "
print(text.split())        # ['hello', 'world', 'python']

# split with max splits
"a,b,c,d".split(",", 2)   # ['a', 'b', 'c,d']

# split by lines
multi = "line1\nline2\nline3"
print(multi.splitlines())  # ['line1', 'line2', 'line3']

# join: opposite of split
parts = ["apple", "banana", "cherry"]
print(",".join(parts))    # 'apple,banana,cherry'
print(" ".join(parts))    # 'apple banana cherry'
print("\n".join(parts))   # apple<newline>banana<newline>cherry
```

`split()` and `join()` are the workhorses of text processing.

### Checking content

```python
print("hello".isalpha())       # True   (only letters)
print("12345".isdigit())       # True   (only digits)
print("abc123".isalnum())      # True   (letters or digits)
print("   ".isspace())         # True   (only whitespace)
print("Hello".isupper())       # False
print("HELLO".isupper())       # True
print("hello".islower())       # True
print("Hello World".istitle()) # True
```

## 4. Padding and Alignment

```python
s = "hi"

print(s.ljust(10))             # 'hi        '
print(s.rjust(10))             # '        hi'
print(s.center(10))            # '    hi    '

# pad with a specific character
print("5".zfill(3))            # '005'    (zero-fill)
print(s.rjust(10, "*"))        # '********hi'
print(s.center(10, "-"))       # '----hi----'
```

These are useful for creating aligned text output.

## 5. Common Operations

### Reverse a string

```python
s = "hello"
print(s[::-1])                  # 'olleh'
```

### Check palindrome

```python
def is_palindrome(s):
    s = s.lower().replace(" ", "")
    return s == s[::-1]

print(is_palindrome("racecar"))            # True
print(is_palindrome("hello"))              # False
print(is_palindrome("A man a plan"))       # False (without proper cleaning)
```

### Count specific characters

```python
text = "hello world"
print(text.count("l"))         # 3

# count vowels
vowels = "aeiou"
count = sum(1 for c in text.lower() if c in vowels)
print(count)                   # 3
```

### Remove vowels

```python
text = "hello world"
vowels = "aeiouAEIOU"
no_vowels = "".join(c for c in text if c not in vowels)
print(no_vowels)               # 'hll wrld'
```

### Capitalize each word manually

```python
text = "hello world"
print(text.title())            # 'Hello World'

# manual version
words = text.split()
result = " ".join(word.capitalize() for word in words)
```

## 6. String Formatting (Recap)

See note 5 for full coverage. Quick reminders:

```python
name = "Aaron"
age = 25

# f-string (preferred)
print(f"Name: {name}, Age: {age}")

# format method
print("Name: {}, Age: {}".format(name, age))

# format specifiers
print(f"Pi: {3.14159:.2f}")    # 'Pi: 3.14'
print(f"|{42:>10}|")            # '|        42|'    right-align
print(f"|{42:<10}|")            # '|42        |'    left-align
print(f"|{42:^10}|")            # '|    42    |'    center
print(f"{1234567:,}")           # '1,234,567'
print(f"{0.0825:.2%}")          # '8.25%'
```

## 7. String Concatenation

```python
a = "hello"
b = "world"

# + operator
c = a + " " + b              # 'hello world'

# join (more efficient for many pieces)
parts = ["hello", "world", "python"]
result = " ".join(parts)     # 'hello world python'

# * for repetition
line = "-" * 20              # 20 dashes
```

For combining many strings, `.join()` is much faster than repeated `+`.

## 8. Strings and Numbers

```python
# str to int
n = int("42")                # 42
n = int("-17")               # -17
# int("3.14")                # ValueError - won't auto-convert decimals
# int("hello")               # ValueError

# str to float
f = float("3.14")            # 3.14
f = float("1e6")             # 1000000.0

# number to str
s = str(42)                  # "42"
s = str(3.14)                # "3.14"
s = f"{42}"                  # "42"

# safe conversion with try/except (covered in note 15)
try:
    n = int("abc")
except ValueError:
    n = 0
```

## 9. Regular Expressions (Brief)

For complex pattern matching, use the `re` module:

```python
import re

text = "My phone is 555-1234 and zip is 33620"

# find all matches
phones = re.findall(r"\d{3}-\d{4}", text)
print(phones)                # ['555-1234']

# find first match
match = re.search(r"\d{5}", text)
if match:
    print(match.group())     # '33620'

# replace
clean = re.sub(r"\d", "X", text)
print(clean)                 # 'My phone is XXX-XXXX and zip is XXXXX'

# split on a pattern
re.split(r"\s+", "hello   world  python")    # ['hello', 'world', 'python']
```

Common regex patterns:
- `\d` - any digit (0-9)
- `\w` - word character (letter, digit, underscore)
- `\s` - whitespace
- `.` - any char
- `*` - 0 or more
- `+` - 1 or more
- `?` - optional
- `{n}` - exactly n
- `^` - start
- `$` - end
- `[abc]` - any of a, b, c

Use raw strings (`r"..."`) for regex patterns to avoid escape issues.

## 10. Common Patterns

### Read CSV data manually

```python
csv = "name,age,city\nAaron,25,Tampa\nBea,30,Miami"
lines = csv.split("\n")
headers = lines[0].split(",")
for line in lines[1:]:
    values = line.split(",")
    row = dict(zip(headers, values))
    print(row)
# {'name': 'Aaron', 'age': '25', 'city': 'Tampa'}
# {'name': 'Bea', 'age': '30', 'city': 'Miami'}
```

(In practice, use the `csv` module or pandas - covered later.)

### Clean user input

```python
raw = "  Hello World  "
clean = raw.strip().lower()
print(clean)                 # 'hello world'
```

### Extract email domain

```python
email = "aaron@example.com"
domain = email.split("@")[1]
print(domain)                # 'example.com'
```

### Pad numbers for display

```python
for i in range(1, 6):
    print(f"Item {i:02}")
# Item 01
# Item 02
# Item 03
# Item 04
# Item 05
```

## Common Mistakes

### Mistake 1: trying to modify a string

```python
s = "hello"
s[0] = "H"                   # TypeError
```

Build a new one:
```python
s = "H" + s[1:]              # 'Hello'
```

### Mistake 2: forgetting strings are immutable methods

```python
s = "hello"
s.upper()                    # returns 'HELLO' but doesn't change s!
print(s)                     # still 'hello'
```

Reassign:
```python
s = s.upper()                # now s is 'HELLO'
```

### Mistake 3: using `+` for many strings

```python
# slow for many concatenations
result = ""
for word in words:
    result += word + " "     # creates a new string each iteration
```

Use `.join()`:
```python
result = " ".join(words)
```

### Mistake 4: `==` vs `is` for strings

```python
a = "hello"
b = "hello"
print(a == b)                # True (compare values)
print(a is b)                # might be True due to Python optimization, but DON'T rely on this
```

Always use `==` to compare strings (or any values). Use `is` only for `None` checks (`x is None`).

## Summary

- Strings are immutable sequences of characters
- Slicing and indexing work like lists
- Common methods: `.lower()`, `.upper()`, `.strip()`, `.split()`, `.join()`, `.replace()`, `.find()`
- f-strings for formatting
- Use `.join()` (not `+`) when combining many strings
- `re` module for complex patterns

Next: [Functions](./12-functions.md) - the most important way to organize code.
