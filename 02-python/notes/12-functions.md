# 12. Functions

A **function** is a named block of code you can run repeatedly. Functions are how you organize code, avoid repetition, and make your programs readable.

## 1. Defining a Function

```python
def greet():
    print("Hello!")
    print("Welcome to Python")

greet()              # Hello!
                     # Welcome to Python
```

Syntax:
- `def` keyword
- function name (follow same naming rules as variables)
- parentheses `()`
- colon `:`
- indented body

You **define** with `def`, you **call** with `name()`. Just defining doesn't run the code - calling does.

## 2. Parameters and Arguments

A **parameter** is a placeholder name in the function definition. An **argument** is the actual value passed in.

```python
def greet(name):              # name is a parameter
    print(f"Hello, {name}!")

greet("Aaron")                # "Aaron" is an argument
greet("Bea")                  # "Bea"   is an argument
```

### Multiple parameters

```python
def add(a, b):
    print(a + b)

add(5, 3)            # 8
add(10, 20)          # 30
```

## 3. Return Values

`return` sends a value back to the caller.

```python
def add(a, b):
    return a + b

result = add(5, 3)
print(result)        # 8
```

Without `return`, a function returns `None`:

```python
def no_return():
    pass

x = no_return()
print(x)             # None
```

You can return multiple values (actually a tuple):

```python
def get_min_max(numbers):
    return min(numbers), max(numbers)

lo, hi = get_min_max([3, 1, 4, 1, 5])
print(lo, hi)        # 1 5
```

## 4. Default Parameter Values

Give a parameter a default value, and callers can omit it:

```python
def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

greet("Aaron")                    # Hello, Aaron!
greet("Aaron", "Hi")              # Hi, Aaron!
greet("Aaron", greeting="Hey")    # Hey, Aaron!
```

Default-valued parameters must come **after** required parameters:

```python
def bad(x=10, y):    # SyntaxError
    pass
```

## 5. Keyword Arguments

You can pass arguments by name (keyword) instead of position:

```python
def describe(name, age, city):
    print(f"{name}, {age}, from {city}")

# positional
describe("Aaron", 25, "Tampa")

# keyword (order doesn't matter)
describe(name="Aaron", age=25, city="Tampa")
describe(city="Tampa", age=25, name="Aaron")

# mixed (positional must come first)
describe("Aaron", age=25, city="Tampa")
```

Keyword arguments are great for clarity, especially when you have many parameters:

```python
# unclear
plot(data, True, False, 10, "red")

# clear
plot(data, show_legend=True, grid=False, line_width=10, color="red")
```

## 6. `*args` - variable number of positional arguments

If you want a function to accept any number of arguments, use `*`:

```python
def add(*numbers):
    total = 0
    for n in numbers:
        total += n
    return total

print(add(1, 2))             # 3
print(add(1, 2, 3, 4, 5))    # 15
print(add())                 # 0
```

`numbers` becomes a tuple of all the arguments. The name `args` is convention but the asterisk is what matters.

### Unpacking a list as arguments

```python
nums = [1, 2, 3, 4, 5]
print(add(*nums))            # 15
```

The `*` here "spreads" the list into positional arguments.

## 7. `**kwargs` - variable number of keyword arguments

Similarly, `**` collects keyword arguments into a dict:

```python
def show_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

show_info(name="Aaron", age=25, city="Tampa")
# name: Aaron
# age: 25
# city: Tampa
```

### Combining everything

```python
def process(required, optional="default", *args, **kwargs):
    print(f"required: {required}")
    print(f"optional: {optional}")
    print(f"args:     {args}")
    print(f"kwargs:   {kwargs}")

process(1, 2, 3, 4, x=10, y=20)
# required: 1
# optional: 2
# args:     (3, 4)
# kwargs:   {'x': 10, 'y': 20}
```

You'll mostly use this when wrapping other functions or for flexible APIs.

## 8. Scope - Local vs Global

Variables defined inside a function are **local** - they only exist inside that function.

```python
def my_func():
    x = 10                   # local variable
    print(x)

my_func()                    # 10
print(x)                     # NameError: x is not defined outside
```

Variables defined outside are **global** - accessible everywhere:

```python
x = 10                       # global

def show():
    print(x)                 # can read global

show()                       # 10
```

But you can't ASSIGN to a global without declaring it:

```python
x = 10

def change():
    x = 99                   # this creates a NEW LOCAL x, doesn't affect global
    
change()
print(x)                     # 10   (global unchanged)
```

To actually modify a global:

```python
x = 10

def change():
    global x
    x = 99

change()
print(x)                     # 99
```

**Best practice:** avoid `global` when possible. Pass values in and return new ones instead. Globals make code harder to reason about.

## 9. Type Hints (Optional)

You can document expected types using type hints (Python 3.5+):

```python
def add(a: int, b: int) -> int:
    return a + b
```

Type hints don't enforce anything at runtime - they're for humans and tools like mypy. But they're a good habit, especially in larger projects.

```python
def greet(name: str, age: int = 0) -> str:
    return f"{name}, age {age}"

def process(items: list) -> dict:
    return {item: 0 for item in items}
```

## 10. Docstrings - documenting your function

Add a string right after the def line to document what the function does:

```python
def add(a, b):
    """
    Add two numbers and return the result.
    
    Args:
        a: first number
        b: second number
    
    Returns:
        The sum of a and b.
    """
    return a + b

# access via __doc__ or help()
print(add.__doc__)
help(add)
```

Docstrings show up in IDE tooltips, generated documentation, and the `help()` function.

## 11. Lambda Functions (Anonymous Functions)

A `lambda` is a tiny one-line function with no name. Used when you need a small function temporarily.

```python
# regular function
def square(x):
    return x * x

# equivalent lambda
square = lambda x: x * x
print(square(5))             # 25
```

Lambdas can have multiple parameters:
```python
add = lambda a, b: a + b
print(add(3, 4))             # 7
```

But they can only contain a single expression (no statements, no multiple lines).

### When to use lambdas

Mostly with functions that take another function as an argument:

```python
people = [
    {"name": "Aaron",  "age": 30},
    {"name": "Bea",    "age": 25},
    {"name": "Carlos", "age": 35},
]

# sort by age
people.sort(key=lambda p: p["age"])

# filter for adults
adults = list(filter(lambda p: p["age"] >= 30, people))

# transform - get just names
names = list(map(lambda p: p["name"], people))
```

For anything more complex than one expression, use a regular `def` function.

## 12. Functions are First-Class

In Python, functions are values just like any other. You can:

- Assign them to variables
- Pass them as arguments
- Return them from other functions
- Store them in collections

```python
def greet(name):
    return f"Hello, {name}!"

# assign to a variable
hello = greet
print(hello("Aaron"))        # 'Hello, Aaron!'

# pass as argument
def apply(func, value):
    return func(value)

print(apply(greet, "Bea"))   # 'Hello, Bea!'

# store in a list
operations = [str.upper, str.lower, str.title]
for op in operations:
    print(op("hello world"))
# HELLO WORLD
# hello world
# Hello World
```

This becomes powerful with decorators (covered in note 19).

## 13. Common Patterns

### Function that validates and converts input

```python
def get_age():
    while True:
        try:
            age = int(input("Age: "))
            if 0 < age < 150:
                return age
            print("Out of range")
        except ValueError:
            print("Not a number")
```

### Function that wraps a calculation

```python
def calculate_bmi(weight_kg, height_m):
    return weight_kg / (height_m ** 2)

bmi = calculate_bmi(70, 1.75)
print(f"BMI: {bmi:.1f}")
```

### Function with default config

```python
def send_email(to, subject, body="", priority="normal", html=False):
    print(f"To: {to}")
    print(f"Subject: {subject}")
    print(f"Priority: {priority}")
    print(f"Body: {body}")

send_email("aaron@example.com", "Hi")
send_email("aaron@example.com", "Hi", priority="high")
```

### Function returning multiple values

```python
def divide_with_remainder(a, b):
    quotient = a // b
    remainder = a % b
    return quotient, remainder

q, r = divide_with_remainder(17, 5)
print(f"{q} remainder {r}")    # '3 remainder 2'
```

## Common Mistakes

### Mistake 1: forgetting to return

```python
def add(a, b):
    a + b               # computes but throws away

result = add(2, 3)
print(result)           # None
```

Add `return`:
```python
def add(a, b):
    return a + b
```

### Mistake 2: mutable default arguments

```python
def add_to_list(item, lst=[]):     # DANGEROUS
    lst.append(item)
    return lst

print(add_to_list(1))               # [1]
print(add_to_list(2))               # [1, 2]   surprise! same list!
print(add_to_list(3))               # [1, 2, 3]
```

The default `[]` is created once when the function is defined, not each time it's called. Fix:

```python
def add_to_list(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst
```

### Mistake 3: assignment inside function doesn't modify outer

```python
count = 0

def increment():
    count = count + 1   # UnboundLocalError

increment()
```

Either use `global` (not recommended) or pass and return:

```python
def increment(count):
    return count + 1

count = increment(count)
```

### Mistake 4: calling instead of passing

```python
people.sort(key=len("Aaron"))     # WRONG: calls len, passes 5
people.sort(key=len)              # correct: passes the function len itself
```

When you want to pass a function as an argument, no parens.

## When to Make Something a Function

A piece of code should become a function when:
- It's used in more than one place (DRY: Don't Repeat Yourself)
- It does one specific thing you can name
- It would be clearer if you replaced it with a name in the calling code

**Naming matters.** A well-named function makes code self-documenting:

```python
# unclear
result = (price * 1.0875) - (price * 0.05)

# clear
result = calculate_after_tax_and_discount(price)
```

## Summary

- `def name(params):` defines a function
- `return` sends a value back
- Default values: `def f(x=10):`
- `*args` collects positional args, `**kwargs` collects keyword args
- Lambdas: one-line anonymous functions
- Local variables die when function returns
- Functions are first-class - pass them, store them, return them
- Watch out for mutable default arguments

Next: [Comprehensions](./13-comprehensions.md) - compact one-line ways to build collections.
