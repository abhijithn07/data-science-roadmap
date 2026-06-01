# 19. Decorators

A **decorator** is a function that takes another function and returns a modified version of it. Decorators let you "wrap" a function with extra behavior without changing the function itself.

You'll see `@something` lines often in Python codebases - those are decorators in action.

## 1. The Foundation: Functions are Values

Remember from the functions note: functions are first-class objects in Python. You can:
- Assign them to variables
- Pass them as arguments
- Return them from other functions

```python
def greet(name):
    return f"Hello {name}"

# pass as argument
def call(func, arg):
    return func(arg)

print(call(greet, "Aaron"))    # Hello Aaron

# return from another function
def make_greeter():
    def greet(name):
        return f"Hello {name}"
    return greet

g = make_greeter()
print(g("Bea"))                # Hello Bea
```

This is what makes decorators possible.

## 2. The Basic Decorator Pattern

A decorator is a function that:
1. Takes a function as input
2. Wraps it with some extra behavior
3. Returns a new function

```python
def log_calls(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Done with {func.__name__}")
        return result
    return wrapper


def add(a, b):
    return a + b


# manually decorate
add = log_calls(add)

print(add(3, 4))
# Calling add
# Done with add
# 7
```

What happened:
1. `log_calls(add)` returns a new function `wrapper` that wraps `add`.
2. We replace `add` with that wrapper.
3. Now when you call `add(3, 4)`, you're calling the wrapper, which prints, calls the real add, then prints again.

## 3. The `@` Syntax

The `@decorator` syntax is just a cleaner way to write this:

```python
@log_calls
def add(a, b):
    return a + b


# equivalent to:
def add(a, b):
    return a + b
add = log_calls(add)
```

The `@log_calls` on the line above `def add` automatically applies the decorator.

```python
print(add(3, 4))
# Calling add
# Done with add
# 7
```

## 4. The Standard Decorator Template

Most decorators follow this pattern:

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        # do something BEFORE the function
        result = func(*args, **kwargs)
        # do something AFTER the function
        return result
    return wrapper
```

`*args, **kwargs` means the wrapper accepts any arguments and passes them through to `func`. This makes the decorator work with any function.

## 5. Common Decorator Examples

### Timer - measure how long a function takes

```python
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.4f} seconds")
        return result
    return wrapper


@timer
def slow_function():
    time.sleep(1)
    return "done"

slow_function()
# slow_function took 1.0012 seconds
```

### Cache results

```python
def memoize(func):
    cache = {}
    def wrapper(*args):
        if args in cache:
            return cache[args]
        result = func(*args)
        cache[args] = result
        return result
    return wrapper


@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


print(fibonacci(35))         # would be slow without memoize, fast with it
```

(In practice use `from functools import lru_cache`.)

### Require login

```python
def require_login(func):
    def wrapper(user, *args, **kwargs):
        if not user.get("logged_in"):
            raise PermissionError("Login required")
        return func(user, *args, **kwargs)
    return wrapper


@require_login
def view_profile(user):
    return f"Profile of {user['name']}"


user = {"name": "Aaron", "logged_in": True}
print(view_profile(user))    # works

user = {"name": "Aaron", "logged_in": False}
# print(view_profile(user))  # PermissionError
```

### Retry on failure

```python
def retry(times=3):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for attempt in range(times):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print(f"Attempt {attempt + 1} failed: {e}")
            raise RuntimeError(f"Failed after {times} attempts")
        return wrapper
    return decorator


@retry(times=3)
def flaky_operation():
    import random
    if random.random() < 0.7:
        raise ValueError("Random failure")
    return "success"


print(flaky_operation())
```

This is a **decorator with arguments**. The outer function `retry(times=3)` returns the actual decorator.

## 6. Preserving Function Metadata - `functools.wraps`

A subtle problem: decorators replace the function, which loses its name and docstring:

```python
@log_calls
def add(a, b):
    """Add two numbers."""
    return a + b

print(add.__name__)         # 'wrapper'      not 'add'!
print(add.__doc__)          # None           not the docstring!
```

Fix with `functools.wraps`:

```python
from functools import wraps

def log_calls(func):
    @wraps(func)            # ← this preserves func's metadata
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper


@log_calls
def add(a, b):
    """Add two numbers."""
    return a + b

print(add.__name__)         # 'add'
print(add.__doc__)          # 'Add two numbers.'
```

Always use `@wraps(func)` in your decorators. It's free and important.

## 7. Stacking Decorators

You can apply multiple decorators to one function:

```python
@timer
@log_calls
def my_function():
    time.sleep(0.5)
    return "done"
```

Decorators apply bottom-up:
1. `log_calls(my_function)` is applied first.
2. Then `timer(log_calls(my_function))`.

So calling `my_function()`:
- Timer starts
- log_calls wrapper prints "Calling..."
- Real function runs
- log_calls prints "Done with..."
- Timer ends and prints elapsed

## 8. Built-in Decorators You'll See

### `@property` - turns a method into an attribute

Already covered in OOP basics:

```python
class Circle:
    def __init__(self, radius):
        self.radius = radius
    
    @property
    def area(self):
        return 3.14159 * self.radius ** 2


c = Circle(5)
print(c.area)            # 78.5    (no parens!)
```

### `@staticmethod` - method that doesn't use self

```python
class MathUtils:
    @staticmethod
    def square(x):
        return x * x


print(MathUtils.square(5))    # 25
# can call on the class, no instance needed
```

### `@classmethod` - method that gets the class, not the instance

```python
class Person:
    count = 0
    
    def __init__(self, name):
        self.name = name
        Person.count += 1
    
    @classmethod
    def get_count(cls):
        return cls.count


Person("Aaron")
Person("Bea")
print(Person.get_count())     # 2
```

### `@functools.lru_cache` - automatic memoization

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


print(fibonacci(50))     # fast, even though it's recursive
```

`lru_cache` keeps the last N calls cached so repeats are instant. Useful for expensive pure functions.

### `@dataclass` - auto-generate methods for data classes

```python
from dataclasses import dataclass

@dataclass
class Person:
    name: str
    age: int
    city: str = "Tampa"      # default value


p = Person("Aaron", 25)
print(p)                  # Person(name='Aaron', age=25, city='Tampa')
```

Decorator generates `__init__`, `__repr__`, `__eq__` automatically. Saves boilerplate.

## 9. When NOT to Use Decorators

Decorators add a layer of indirection. Don't use them when:
- The behavior is unique to one function (just inline the code)
- It makes the code harder to understand
- You only need it once and not for cross-cutting concerns

Use them when:
- You'd apply the same wrapping to multiple functions (logging, timing, auth, caching)
- You're implementing a cross-cutting concern (something orthogonal to the function's main purpose)

## 10. Common Mistakes

### Mistake 1: forgetting to call `func` inside wrapper

```python
def log_calls(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        # forgot to actually call func!
    return wrapper

@log_calls
def add(a, b):
    return a + b

print(add(3, 4))         # None    (and no error)
```

### Mistake 2: forgetting `@wraps`

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def my_func():
    """My docstring."""

print(my_func.__name__)        # 'wrapper'   not 'my_func'
```

Add `@wraps(func)` to the wrapper.

### Mistake 3: confusing decorators with decorator factories

```python
def retry(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            ...
        return wrapper
    return decorator


# usage - note the parens
@retry(times=3)           # call retry first to get the decorator
def my_func():
    pass


# without parens this would error
@retry                    # WRONG: applies retry directly to my_func
def my_func():
    pass
```

### Mistake 4: mutating shared state across calls

```python
def add_arg(func):
    args_log = []
    def wrapper(*args):
        args_log.append(args)        # accumulates across calls
        print(args_log)
        return func(*args)
    return wrapper
```

This is fine if intentional, but be aware that the wrapper's local closure state persists across calls to the decorated function.

## Summary

- A decorator wraps a function with extra behavior
- `@decorator` is sugar for `func = decorator(func)`
- Use `*args, **kwargs` in the wrapper to pass any arguments through
- Use `@functools.wraps(func)` to preserve metadata
- Decorators with arguments are functions that return a decorator
- Stack decorators with multiple `@` lines (applies bottom-up)
- Common uses: logging, timing, auth, caching, validation
- Built-ins: `@property`, `@staticmethod`, `@classmethod`, `@lru_cache`, `@dataclass`

Next: [Date and Time](./20-date-and-time.md) - working with dates, times, and durations.
