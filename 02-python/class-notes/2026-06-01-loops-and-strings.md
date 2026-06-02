# Class Notes: Loops and Strings (1 June 2026)

Topics covered in class:

1. For loops - basic, with examples (sum, product, print multiple)
2. While loops - basic, with examples
3. Break and continue
4. Range and containers
5. Iterating over a string
6. String indexing - positive and negative
7. String slicing - `s[start:stop:step]`
8. String operators - `+`, `*`, `in`
9. Basic string methods - `upper`, `lower`, `split`, `strip`, `count`, `find`
10. String check methods - `isalpha`, `isalnum`, `isdigit`, `isspace`, `islower`, `isupper`
11. `partition()` method

> **Assignment:** different ways to reverse a string (see assignments folder)

## 1. For Loops

A `for` loop runs a block of code once for each item in a sequence (a list, string, range, etc.).

```
for variable in sequence:
    # code that runs each iteration
```

```python
# basic for loop over a range of numbers
for i in range(5):
    print(i)
```

### Example: Sum of numbers

```python
numbers = [3, 7, 12, 8, 15]
total = 0
for n in numbers:
    total += n
print(f"Sum: {total}")
```

### Example: Product of numbers

```python
numbers = [2, 3, 4, 5]
product = 1
for n in numbers:
    product *= n
print(f"Product: {product}")
```

### Example: Print multiple numbers

```python
numbers = [10, 25, 30, 45, 50]
for n in numbers:
    print(n)
```

## 2. While Loops

A `while` loop runs as long as a condition is True.

```
while condition:
    # code that runs as long as condition is True
```

**Important:** make sure the condition can eventually become False, or you create an infinite loop.

```python
# basic while loop
count = 0
while count < 5:
    print(count)
    count += 1
```

### Example: Sum using a while loop

```python
numbers = [3, 7, 12, 8, 15]
total = 0
i = 0
while i < len(numbers):
    total += numbers[i]
    i += 1
print(f"Sum: {total}")
```

## 3. Break and Continue

- `break` exits the loop immediately
- `continue` skips the rest of the current iteration

```python
# break - stop at the first even number
for n in [1, 3, 5, 4, 7, 9]:
    if n % 2 == 0:
        print(f"Found even number: {n}")
        break
    print(f"Checking {n}")
```

```python
# continue - skip even numbers
for n in range(10):
    if n % 2 == 0:
        continue
    print(n)
```

## 4. Range

`range()` generates a sequence of numbers. Three forms:

- `range(stop)` - 0 up to (not including) stop
- `range(start, stop)` - from start up to stop
- `range(start, stop, step)` - with step

Range is a **container** that produces values on demand. Wrap with `list()` to see them all.

```python
print(list(range(5)))           # [0, 1, 2, 3, 4]
print(list(range(2, 8)))        # [2, 3, 4, 5, 6, 7]
print(list(range(0, 10, 2)))    # [0, 2, 4, 6, 8]
print(list(range(10, 0, -1)))   # countdown 10 to 1
```

## 5. Iterating Over a String

A string is a sequence of characters. You can loop through it just like a list.

```python
word = "python"
for letter in word:
    print(letter)
```

```python
# count vowels
text = "Hello World"
count = 0
for char in text.lower():
    if char in "aeiou":
        count += 1
print(f"Vowel count: {count}")
```

## 6. String Indexing

Each character has a position (index):

- Positive indices count from the start: `0, 1, 2, ...`
- Negative indices count from the end: `-1, -2, -3, ...`

```
s = "python"
     ^^^^^^
     012345  (positive)
    -6-5-4-3-2-1  (negative)
```

```python
s = "python"

print(s[0])       # 'p'   first character
print(s[1])       # 'y'
print(s[2])       # 't'
print(s[3])       # 'h'
print(s[-1])      # 'n'   last character
print(s[-2])      # 'o'   second to last
```

## 7. String Slicing

Syntax: `s[start:stop:step]`

- `start` is inclusive (default 0)
- `stop` is exclusive (default length)
- `step` is the increment (default 1)

```python
s = "python"

print(s[0:3])     # 'pyt'    indices 0, 1, 2
print(s[:3])      # 'pyt'    same as above
print(s[3:])      # 'hon'    from index 3 to end
print(s[:])       # 'python' the whole string
print(s[::2])     # 'pto'    every 2nd character
print(s[::-1])    # 'nohtyp' reversed (using step -1)
```

## 8. String Operators

- `+` concatenates two strings
- `*` repeats a string
- `in` checks if a substring is present

```python
# concatenation
first = "Hello"
last = "World"
greeting = first + " " + last
print(greeting)
```

```python
# repetition
line = "-" * 20
print(line)

print("ha" * 3)               # 'hahaha'
```

```python
# 'in' operator
text = "hello world"

print("world" in text)        # True
print("python" in text)       # False
print("xyz" not in text)      # True
```

## 9. Basic String Methods

String methods return a **new** string. The original is unchanged (strings are immutable).

### `upper()` and `lower()`

```python
s = "Hello World"

print(s.upper())              # 'HELLO WORLD'
print(s.lower())              # 'hello world'
print(s)                       # 'Hello World'  (original unchanged)
```

### `split()` - split into a list

Without arguments, splits on whitespace. With an argument, splits on that character.

```python
sentence = "the quick brown fox"
words = sentence.split()
print(words)                  # ['the', 'quick', 'brown', 'fox']
```

```python
csv = "apple,banana,cherry,date"
fruits = csv.split(",")
print(fruits)                 # ['apple', 'banana', 'cherry', 'date']
```

### `strip()` - remove whitespace from both sides

```python
raw = "   hello world   "
clean = raw.strip()
print(repr(raw))              # '   hello world   '
print(repr(clean))            # 'hello world'
```

### `count()` - count occurrences

```python
text = "banana"

print(text.count("a"))        # 3
print(text.count("n"))        # 2
print(text.count("na"))       # 2
```

### `find()` - position of substring

Returns the index of the first occurrence, or -1 if not found.

```python
text = "hello world"

print(text.find("world"))     # 6
print(text.find("hello"))     # 0
print(text.find("python"))    # -1 (not found)
```

## 10. String Check Methods

These return `True` or `False`.

| Method | Checks for |
|---|---|
| `isalpha()` | only letters |
| `isalnum()` | letters or digits |
| `isdigit()` | only digits |
| `isspace()` | only whitespace |
| `islower()` | letters are all lowercase |
| `isupper()` | letters are all uppercase |

```python
# isalpha - only letters
print("hello".isalpha())          # True
print("hello world".isalpha())    # False (space is not a letter)
print("abc123".isalpha())         # False
```

```python
# isalnum - letters or digits
print("abc123".isalnum())         # True
print("hello world".isalnum())    # False (space is not alnum)
```

```python
# isdigit - only digits
print("12345".isdigit())          # True
print("123.45".isdigit())         # False
print("abc".isdigit())            # False
```

```python
# isspace - only whitespace
print("   ".isspace())            # True
print("hello".isspace())          # False
```

```python
# islower / isupper
print("hello".islower())          # True
print("HELLO".isupper())          # True
print("Hello".islower())          # False
print("Hello".isupper())          # False
```

## 11. `partition()` - split into 3 parts

`partition(separator)` splits the string at the FIRST occurrence of the separator and returns a 3-tuple:

- the part before the separator
- the separator itself
- the part after the separator

```python
email = "user@example.com"
parts = email.partition("@")
print(parts)                  # ('user', '@', 'example.com')

username = parts[0]
domain = parts[2]
print(f"Username: {username}")
print(f"Domain: {domain}")
```

```python
# partition only splits on FIRST occurrence
text = "key1:value1:value2"
print(text.partition(":"))    # ('key1', ':', 'value1:value2')

# compare with split which finds all
print(text.split(":"))        # ['key1', 'value1', 'value2']
```
