# Class Notes: Functions, Iterators, Generators, map/reduce/filter (3 June 2026)

Topics covered in class:

1. Functions - def, return, prime function example
2. Difference between print and return
3. Iterators - iter() and next()
4. Generators - yield, fibonacci series
5. map() function
6. Lambda functions
7. reduce() function
8. filter() function

## 1. Functions

A function is a reusable block of code. You define it once and call it many times.

```
def function_name(parameters):
    # code here
    return value
```

### Simple hello function

A function that just prints something. No return value.

```python
def say_hello():
    print("Hello!")

say_hello()
```

**Output:**

```
Hello!
```

### Function with arguments and return

`return` sends a value back from the function so the caller can use it.

```python
def add(a, b):
    return a + b

result = add(3, 5)
print(result)
```

**Output:**

```
8
```

### Difference between print and return

- `print()` just shows the value on screen but the function returns `None`
- `return` sends the value back so it can be stored or used in expressions

This is one of the most common confusions for beginners.

```python
def add_with_print(a, b):
    print(a + b)        # only prints

def add_with_return(a, b):
    return a + b        # returns the value

# print version - shows result but x is None
x = add_with_print(3, 5)
print("x is:", x)

# return version - y stores the actual result
y = add_with_return(3, 5)
print("y is:", y)
```

**Output:**

```
8
x is: None
8
y is: 8
```

### Prime number function

Check whether a number is prime. A prime number is only divisible by 1 and itself.

```python
def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0:
            return False
    return True

print(is_prime(7))      # True
print(is_prime(10))     # False
print(is_prime(13))     # True
print(is_prime(1))      # False
```

**Output:**

```
True
False
True
False
```

### Function with default arguments

You can give parameters a default value. If the caller doesn't pass an argument, the default is used.

```python
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"

print(greet("Abhi"))
print(greet("Abhi", "Hi"))
```

**Output:**

```
Hello, Abhi!
Hi, Abhi!
```

## 2. Iterators

An iterator is an object that produces values one at a time. The `for` loop works on this concept behind the scenes.

- `iter(sequence)` gives you an iterator
- `next(iterator)` gives the next value
- when there are no more values, `StopIteration` error is raised

```python
l = "hello"
s = iter(l)

print(next(s))     # h
print(next(s))     # e
print(next(s))     # l
print(next(s))     # l
print(next(s))     # o
```

**Output:**

```
h
e
l
l
o
```

### How a for loop actually works

Behind the scenes, a `for` loop is calling `iter()` and then `next()` repeatedly until it hits `StopIteration`.

```python
my_list = [10, 20, 30]
it = iter(my_list)

print(next(it))    # 10
print(next(it))    # 20
print(next(it))    # 30
# next(it)         # would raise StopIteration
```

**Output:**

```
10
20
30
```

### Using try/except to handle StopIteration

Wrap `next()` in a try/except block to handle the end of an iterator gracefully.

```python
nums = [10, 20, 30]
it = iter(nums)

while True:
    try:
        value = next(it)
        print(value)
    except StopIteration:
        print("End of iterator")
        break
```

**Output:**

```
10
20
30
End of iterator
```

## 3. Generators

A generator is a special type of iterator. It uses `yield` instead of `return`.

**Why generators?**

- Memory efficient - values are produced one at a time, not all at once
- Useful for infinite sequences or very large data
- Easier to write than custom iterator classes

```python
# basic generator
def my_generator():
    yield 1
    yield 2
    yield 3

g = my_generator()

print(next(g))     # 1
print(next(g))     # 2
print(next(g))     # 3
```

**Output:**

```
1
2
3
```

### Fibonacci series using yield

A perfect use case for generators. Generate fibonacci numbers one at a time.

```python
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# loop through the generator
for num in fibonacci(10):
    print(num, end=" ")
```

**Output:**

```
0 1 1 2 3 5 8 13 21 34
```

### Difference between return and yield

- `return` exits the function and sends back one value
- `yield` pauses the function, sends back a value, and resumes from where it left off on the next call

### Countdown generator

Counts down from n to 1. Useful pattern for any decreasing sequence.

```python
def countdown(n):
    while n > 0:
        yield n
        n -= 1

for x in countdown(5):
    print(x, end=" ")
```

**Output:**

```
5 4 3 2 1
```

## 4. map() Function

`map()` applies a function to every element in a sequence and returns a new iterator with the results.

```
map(function, sequence)
```

The first argument is a function, the second is an iterable (list, tuple, etc.).

### Example: convert celsius to fahrenheit

Apply the conversion to a list of temperatures.

```python
def to_fahrenheit(c):
    return (c * 9/5) + 32

temps = [0, 22.5, 40, 100]
result = list(map(to_fahrenheit, temps))
print(result)
```

**Output:**

```
[32.0, 72.5, 104.0, 212.0]
```

### Why we use list() around map()

`map()` returns an iterator, not a list. To see the values, convert it to a list.

```python
def square(x):
    return x * x

nums = [1, 2, 3, 4, 5]

# just calling map returns an iterator object
print(map(square, nums))

# wrap with list() to see the values
print(list(map(square, nums)))
```

**Output:**

```
<map object at 0x...>
[1, 4, 9, 16, 25]
```

### Apply a string method to a list of strings

You can pass a built-in method like `str.upper` directly to `map()`.

```python
names = ["abhi", "ravi", "kiran"]

upper_names = list(map(str.upper, names))
print(upper_names)
```

**Output:**

```
['ABHI', 'RAVI', 'KIRAN']
```

## 5. Lambda Functions

A lambda is a small anonymous (unnamed) function written in one line.

```
lambda arguments: expression
```

Useful when you need a quick function for things like `map`, `filter`, `sorted`.

```python
# normal function
def add(a, b):
    return a + b

# same thing as a lambda
add_lambda = lambda a, b: a + b

print(add(3, 5))
print(add_lambda(3, 5))
```

**Output:**

```
8
8
```

### Lambda with map()

This is the most common use. Instead of defining a separate function, use a lambda inline.

```python
nums = [1, 2, 3, 4, 5]

# add 1 to each element
result = list(map(lambda x: x + 1, nums))
print(result)
```

**Output:**

```
[2, 3, 4, 5, 6]
```

```python
# square each element
nums = [1, 2, 3, 4, 5]
result = list(map(lambda x: x * x, nums))
print(result)
```

**Output:**

```
[1, 4, 9, 16, 25]
```

### Two-argument lambda

```python
# lambda can take multiple arguments
add = lambda a, b: a + b
print(add(4, 3))
```

**Output:**

```
7
```

### Sorting with a lambda key

`sorted()` takes a `key` argument that tells it how to sort. A lambda is perfect here.

```python
words = ["apple", "fig", "banana", "kiwi"]

# sort by length
sorted_by_length = sorted(words, key=lambda w: len(w))
print(sorted_by_length)
```

**Output:**

```
['fig', 'kiwi', 'apple', 'banana']
```

## 6. reduce() Function

`reduce()` applies a function cumulatively to the elements of a sequence and reduces them to a **single value**.

While `map()` produces a new list from each element, `reduce()` collapses everything into one result.

`reduce()` is not built-in. Import it from `functools`.

```python
from functools import reduce

# sum all numbers in a list
nums = [1, 2, 3, 4, 5]
total = reduce(lambda a, b: a + b, nums)
print(total)
```

**Output:**

```
15
```

### How reduce works step by step

For `nums = [1, 2, 3, 4, 5]` and `lambda a, b: a + b`:

- Step 1: a=1, b=2 -> 3
- Step 2: a=3, b=3 -> 6
- Step 3: a=6, b=4 -> 10
- Step 4: a=10, b=5 -> 15

Each step uses the previous result as `a` and the next element as `b`.

### Example: find max value using reduce

```python
from functools import reduce

nums = [4, 7, 2, 9, 1, 5]
maximum = reduce(lambda a, b: a if a > b else b, nums)
print(maximum)
```

**Output:**

```
9
```

### Example: multiply all numbers

```python
from functools import reduce

nums = [1, 2, 3, 4, 5]
product = reduce(lambda a, b: a * b, nums)
print(product)
```

**Output:**

```
120
```

### Example: concatenate strings

Reduce works on any data type that supports the operation. Here we join words into a sentence.

```python
from functools import reduce

words = ["Python", "is", "fun"]
sentence = reduce(lambda a, b: a + " " + b, words)
print(sentence)
```

**Output:**

```
Python is fun
```

## 7. filter() Function

`filter()` keeps only the elements for which the function returns `True`.

```
filter(function, sequence)
```

The function must return a boolean (True or False).

### Example: filter even numbers using a regular function

```python
def is_even(n):
    return n % 2 == 0

nums = [1, 2, 3, 4, 5, 6, 7, 8]
evens = list(filter(is_even, nums))
print(evens)
```

**Output:**

```
[2, 4, 6, 8]
```

### Same example using a lambda

Filter is most often used with a lambda since you usually need a quick condition.

```python
nums = [1, 2, 3, 4, 5, 6, 7, 8]

evens = list(filter(lambda x: x % 2 == 0, nums))
print(evens)

odds = list(filter(lambda x: x % 2 != 0, nums))
print(odds)
```

**Output:**

```
[2, 4, 6, 8]
[1, 3, 5, 7]
```

### Example: filter words by length

Keep only words with 5 or more characters.

```python
words = ["python", "is", "fun", "programming", "I", "love", "coding"]

long_words = list(filter(lambda w: len(w) >= 5, words))
print(long_words)
```

**Output:**

```
['python', 'programming', 'coding']
```

### Example: filter positive numbers

Keep only positive numbers from a list with mixed positive and negative values.

```python
nums = [-3, -1, 0, 2, 5, -7, 8]

positives = list(filter(lambda x: x > 0, nums))
print(positives)
```

**Output:**

```
[2, 5, 8]
```

## Summary

| Function | What it does | Returns |
|---|---|---|
| `map()` | applies function to each element | new iterator (use `list()` to see) |
| `filter()` | keeps elements where function returns True | new iterator (use `list()` to see) |
| `reduce()` | applies function cumulatively to collapse to one value | single value |

All three are commonly used with `lambda` expressions for short inline functions.
