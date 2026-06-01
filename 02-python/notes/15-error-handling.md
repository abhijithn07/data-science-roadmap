# 15. Error Handling

When things go wrong in Python (file missing, bad input, division by zero), an **exception** is raised. If you don't handle it, your program crashes. **Error handling** lets you catch exceptions and respond gracefully.

## 1. The Problem

Without error handling, any unexpected condition crashes your program:

```python
age = int(input("Age: "))    # user types "hello" → ValueError, program dies
result = 10 / 0               # ZeroDivisionError, program dies
f = open("missing.txt")       # FileNotFoundError, program dies
```

You want your program to handle these situations gracefully instead.

## 2. try / except

The basic pattern:

```python
try:
    # code that might fail
    age = int(input("Age: "))
    print(f"You are {age}")
except:
    # what to do if it fails
    print("That wasn't a valid number")
```

How it works:
1. Python runs the `try` block.
2. If everything succeeds, the `except` block is skipped.
3. If any exception is raised in `try`, Python jumps to `except`.

### Catch specific exceptions

A bare `except:` catches ALL exceptions, including ones you might not have intended. **Always specify which exception you mean:**

```python
try:
    age = int(input("Age: "))
except ValueError:
    print("Please enter a valid number")
```

`ValueError` is what `int()` raises when given non-numeric text.

### Multiple exception types

```python
try:
    n = int(input("Number: "))
    result = 10 / n
    print(result)
except ValueError:
    print("Not a valid number")
except ZeroDivisionError:
    print("Can't divide by zero")
```

Each except block handles one type. The first matching one runs.

### Combine multiple exception types

```python
try:
    risky_operation()
except (ValueError, TypeError):
    print("Bad input")
```

Use a tuple to catch any of several types.

### Get the exception details

Use `as` to capture the exception object:

```python
try:
    f = open("missing.txt")
except FileNotFoundError as e:
    print(f"File error: {e}")
    print(f"Type: {type(e).__name__}")
```

The exception object often has useful info like the error message and filename.

## 3. The Common Exception Types

| Exception | Raised when |
|---|---|
| `ValueError` | Wrong value (e.g., `int("hello")`) |
| `TypeError` | Wrong type (e.g., `"a" + 5`) |
| `ZeroDivisionError` | Division by zero |
| `IndexError` | List index out of range |
| `KeyError` | Dict key doesn't exist |
| `AttributeError` | Object has no such attribute/method |
| `FileNotFoundError` | File doesn't exist |
| `PermissionError` | OS denied access |
| `IOError` / `OSError` | Other IO problems |
| `ImportError` | Module not found |
| `RuntimeError` | Generic runtime issue |
| `NameError` | Variable not defined |
| `SyntaxError` | Code structure invalid (caught at parse time) |
| `Exception` | Base class for most exceptions |

Examples of when each happens:

```python
int("hello")          # ValueError
"a" + 5               # TypeError
1 / 0                 # ZeroDivisionError
[1, 2][5]             # IndexError
{}["missing"]         # KeyError
"abc".nonexistent()   # AttributeError
open("missing.txt")   # FileNotFoundError
```

## 4. else and finally

### else - runs if no exception occurred

```python
try:
    n = int(input("Number: "))
except ValueError:
    print("Not a number")
else:
    print(f"You entered {n}")    # only runs if try succeeded
```

The `else` block runs only if the try block completed without raising. Use it to keep the try block small (only the code that might fail).

### finally - always runs

```python
try:
    f = open("data.txt")
    data = f.read()
except FileNotFoundError:
    data = ""
finally:
    print("Done")    # ALWAYS runs, whether try succeeded or not
```

`finally` is useful for cleanup that must happen no matter what (closing resources, etc.). With `with` statements, you rarely need `finally` for file/resource cleanup.

### Full structure

```python
try:
    # code that might fail
except SomeError:
    # handle that specific error
except OtherError as e:
    # handle another error, with the exception object
else:
    # runs if try succeeded with no error
finally:
    # always runs
```

## 5. Raising Exceptions

You can raise your own exceptions to signal problems:

```python
def calculate_age(birth_year):
    if birth_year > 2026:
        raise ValueError("Birth year can't be in the future")
    return 2026 - birth_year

try:
    age = calculate_age(2030)
except ValueError as e:
    print(e)        # 'Birth year can't be in the future'
```

This is useful in functions to signal invalid input or impossible states.

### Re-raise an exception

Sometimes you want to catch an exception, log it, then re-raise:

```python
try:
    risky_op()
except Exception as e:
    log_error(e)
    raise           # re-raises the same exception
```

## 6. Custom Exceptions

You can define your own exception types by subclassing `Exception`:

```python
class InvalidAgeError(Exception):
    pass

def set_age(age):
    if age < 0:
        raise InvalidAgeError("Age can't be negative")
    if age > 150:
        raise InvalidAgeError("Age too large")
    return age

try:
    set_age(-5)
except InvalidAgeError as e:
    print(f"Bad age: {e}")
```

This makes error types meaningful to your application.

## 7. Common Patterns

### Validate user input until it's correct

```python
def get_age():
    while True:
        try:
            age = int(input("Enter your age: "))
            if 0 <= age <= 150:
                return age
            print("Age must be between 0 and 150")
        except ValueError:
            print("Please enter a valid number")

age = get_age()
print(f"Got age: {age}")
```

### Default value if conversion fails

```python
try:
    value = int(text)
except ValueError:
    value = 0    # fallback
```

This is so common Python has alternatives:

```python
# using a helper function
def safe_int(text, default=0):
    try:
        return int(text)
    except (ValueError, TypeError):
        return default

value = safe_int("hello")              # 0
value = safe_int("hello", default=-1)  # -1
value = safe_int("42")                  # 42
```

### Try multiple alternatives

```python
def load_data():
    try:
        return load_from_database()
    except DatabaseError:
        try:
            return load_from_file()
        except FileNotFoundError:
            return load_defaults()
```

### Suppress errors deliberately

```python
try:
    optional_step()
except Exception:
    pass    # ignore any error from this optional step
```

**Use sparingly.** Silent error swallowing makes bugs hard to find. Only do this when you genuinely don't care if it fails.

### File operations with cleanup

```python
# old style (manual cleanup)
f = None
try:
    f = open("data.txt")
    data = f.read()
except FileNotFoundError:
    data = ""
finally:
    if f is not None:
        f.close()

# modern style (with statement handles cleanup)
try:
    with open("data.txt") as f:
        data = f.read()
except FileNotFoundError:
    data = ""
```

## 8. Asking for forgiveness, not permission (EAFP)

Python's culture prefers trying and catching exceptions over checking conditions first:

```python
# LBYL - Look Before You Leap (less Pythonic)
if key in dictionary:
    value = dictionary[key]
else:
    value = default

# EAFP - Easier to Ask Forgiveness than Permission (Pythonic)
try:
    value = dictionary[key]
except KeyError:
    value = default

# or just use .get()
value = dictionary.get(key, default)
```

For files:
```python
# LBYL
if os.path.exists(filename):
    with open(filename) as f:
        ...
else:
    ...

# EAFP
try:
    with open(filename) as f:
        ...
except FileNotFoundError:
    ...
```

The EAFP approach is generally preferred because it's race-condition free: between checking with `exists()` and actually opening, the file could be deleted.

## 9. Common Mistakes

### Mistake 1: bare except catches too much

```python
try:
    do_something()
except:                  # catches EVERYTHING including KeyboardInterrupt
    pass
```

Always be specific:
```python
except ValueError:       # only ValueError
except (ValueError, TypeError):    # multiple specific
except Exception:        # most things but not system-exit / keyboard-interrupt
```

### Mistake 2: catching too broadly

```python
try:
    age = int(input())
    user.set_age(age)
except Exception as e:    # catches BOTH int conversion AND user.set_age errors
    print("error")
```

If you only meant to handle the int conversion, narrow the try block:

```python
try:
    age = int(input())
except ValueError:
    print("Invalid number")
    return

user.set_age(age)         # any errors from this won't be silently swallowed
```

### Mistake 3: swallowing errors with `pass`

```python
try:
    important_operation()
except Exception:
    pass    # bug is hidden, no idea what went wrong
```

At minimum, log it:
```python
try:
    important_operation()
except Exception as e:
    print(f"Operation failed: {e}")
```

### Mistake 4: using exceptions for normal flow

```python
# BAD - using exceptions to find the end of a list
def get_first_item(lst):
    try:
        return lst[0]
    except IndexError:
        return None

# BETTER - check the condition
def get_first_item(lst):
    return lst[0] if lst else None
```

Exceptions should be for **exceptional** cases, not normal control flow.

### Mistake 5: misordering except blocks

```python
try:
    risky()
except Exception:           # this catches everything first
    print("generic error")
except ValueError:           # NEVER reached
    print("value error")
```

More specific exceptions first, more general after.

## 10. The full picture

```python
def safe_divide(a, b):
    """
    Divide a by b, returning None on any error.
    """
    try:
        result = a / b
    except ZeroDivisionError:
        print("Can't divide by zero")
        return None
    except TypeError:
        print("Both inputs must be numbers")
        return None
    else:
        return result
    finally:
        print("Division attempt complete")

print(safe_divide(10, 2))    # Division attempt complete \n 5.0
print(safe_divide(10, 0))    # Can't divide by zero \n Division attempt complete \n None
print(safe_divide("a", 2))   # Both inputs must be numbers \n Division attempt complete \n None
```

## Summary

- `try` + `except` to handle expected errors
- Always catch specific exceptions, not bare `except:`
- `else` runs if try succeeded
- `finally` always runs (use for cleanup)
- `raise` to signal an error yourself
- Make custom exceptions by subclassing `Exception`
- Python style: try operations, catch errors, instead of pre-checking

Next: [Modules and Packages](./16-modules-and-packages.md) - organizing code across files.
