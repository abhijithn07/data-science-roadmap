# 06. Conditionals

Conditionals let your code **make decisions**: do one thing if a condition is true, something else otherwise. This is the foundation of all interesting programs.

## 1. Boolean Evaluation

Every condition in an `if` statement evaluates to either `True` or `False`. So before getting into `if`, you need to understand what Python considers True and False.

### `True` and `False`

The two boolean values, written with capitals:

```python
is_active = True
is_admin = False
```

### Booleans come from comparisons

Comparison operators produce booleans:

```python
print(5 > 3)        # True
print(5 == 6)       # False
print("a" < "b")    # True
```

So you can use any comparison directly inside an `if`:

```python
age = 20
if age >= 18:
    print("adult")
```

### Truthy and Falsy values

Here's where it gets interesting. In Python, **any value** can be used as a condition, not just `True`/`False`. Some non-boolean values are treated as False (called **falsy**), everything else as True (called **truthy**).

**Falsy values:**

| Value | Type | Why falsy |
|---|---|---|
| `False` | bool | obviously |
| `0` | int | the number zero |
| `0.0` | float | zero |
| `""` | str | empty string |
| `[]` | list | empty list |
| `{}` | dict | empty dict |
| `()` | tuple | empty tuple |
| `None` | NoneType | absence of value |

**Everything else is truthy**:

```python
bool(1)           # True
bool(-5)          # True   (any non-zero number)
bool(0.001)       # True
bool("hello")     # True   (non-empty string)
bool(" ")         # True   (space is a character, so non-empty)
bool([0])         # True   (a list with one element, even if it's zero)
bool("False")     # True   (a string containing the word False, not the boolean False)
```

### Why this matters

You can write concise conditions by relying on truthiness:

```python
name = input("Name: ")
if name:                    # True if name is non-empty
    print(f"Hello {name}")
else:
    print("you didn't enter a name")
```

```python
items = []
if not items:               # True if list is empty
    print("the list is empty")

items = [1, 2, 3]
if items:                   # True if list has anything in it
    print(f"got {len(items)} items")
```

This is more Pythonic than:

```python
if len(name) > 0:           # works, but verbose
if items != []:             # works, but verbose
```

### Watch out

The string `"False"` is **not** the boolean `False`. It's just a string:

```python
flag = "False"              # a string
if flag:
    print("hi")             # this DOES print, "False" is a truthy string
```

The boolean `False` has no quotes. `"False"` and `False` are different things.

## 2. The `if` Statement

Basic syntax:

```python
if condition:
    # code to run if condition is True
    do_something()
```

Two critical syntax rules:

1. The `if` line ends with a **colon** `:`
2. The block underneath is **indented** (4 spaces, by convention)

```python
age = 18

if age >= 18:
    print("you can vote")
    print("you can drive")
```

**Indentation matters in Python.** Unlike SQL or JavaScript or Java where you use braces, Python uses indentation to define code blocks. The two `print` lines above are inside the `if` because they're indented. A line that comes back to the original indent level is no longer inside the `if`.

```python
age = 18

if age >= 18:
    print("inside the if")        # this is inside
    print("also inside")          # this is inside
print("outside the if")           # this is outside, runs no matter what
```

## 3. `if` / `else`

`else` runs when the `if` condition is False:

```python
age = 15

if age >= 18:
    print("can vote")
else:
    print("too young to vote")
```

Either the `if` block runs, or the `else` block runs. Never both. Never neither.

## 4. `if` / `elif` / `else`

For more than two cases, use `elif` (short for "else if"):

```python
age = 25

if age < 13:
    print("child")
elif age < 18:
    print("teen")
elif age < 60:
    print("adult")
else:
    print("senior")
```

How this works:
- Check the first `if`. If True, run that block and skip the rest.
- Otherwise check each `elif` in order. The first that's True wins.
- If none matched, run the `else` (if there is one).

You can have as many `elif` branches as you want. `else` is optional.

### Important: only ONE branch runs

```python
score = 95

if score >= 60:
    print("passed")          # this runs
elif score >= 90:
    print("excellent")       # this does NOT run, even though 95 >= 90
```

Even though score is 95, the `elif` is never checked because the first `if` matched. **Order matters.** Put more specific conditions first:

```python
score = 95

if score >= 90:
    print("excellent")       # this runs
elif score >= 60:
    print("passed")
else:
    print("failed")
```

## 5. Comparing Multiple Conditions

Combine conditions with `and`, `or`, `not`:

```python
age = 25
has_id = True

if age >= 18 and has_id:
    print("can enter the venue")

if age < 13 or age > 60:
    print("special discount applies")

if not has_id:
    print("show ID to enter")
```

You can group with parentheses for clarity:

```python
if (age >= 18 and has_id) or is_vip:
    print("welcome")
```

### Python's chained comparisons

A special Python feature: you can chain comparisons in a natural mathematical way.

```python
age = 25

if 18 <= age <= 65:           # same as: 18 <= age and age <= 65
    print("working age")

if 0 < x < 100:               # same as: 0 < x and x < 100
    print("two-digit number")
```

Most languages don't allow this; you'd have to write the longer `and` form. In Python it just works.

## 6. Nested `if`

You can put `if` statements **inside** other `if` statements:

```python
age = 20
has_id = True
is_member = False

if age >= 18:
    if has_id:
        if is_member:
            print("VIP entry")
        else:
            print("regular entry")
    else:
        print("need ID")
else:
    print("too young")
```

Each level of nesting adds 4 more spaces of indentation.

### When nesting is OK vs when it's bad

Nesting is fine for **truly hierarchical** logic where you can't check the inner condition until the outer one passes:

```python
if user is not None:           # have to check this first
    if user.is_active:          # because user might be None
        send_email(user.email)
```

But nesting **gets bad fast**. Three levels is usually too deep. Often you can replace nested `if`s with combined conditions:

```python
# nested (harder to read)
if age >= 18:
    if has_id:
        print("can enter")

# combined (easier)
if age >= 18 and has_id:
    print("can enter")
```

Or with early returns (when inside a function):

```python
# nested (deep pyramid)
def check_user(user):
    if user is not None:
        if user.is_active:
            if user.has_permission:
                return "allowed"
    return "denied"

# flat (early return)
def check_user(user):
    if user is None: return "denied"
    if not user.is_active: return "denied"
    if not user.has_permission: return "denied"
    return "allowed"
```

The flat version is easier to read and easier to extend.

## 7. The Ternary Expression (One-Line if/else)

For simple if/else assignments, Python has a ternary form:

```python
# instead of this
if age >= 18:
    status = "adult"
else:
    status = "minor"

# you can write this
status = "adult" if age >= 18 else "minor"
```

Read it as: *(value if true) if (condition) else (value if false)*.

It's only worth using when:
- The condition is simple
- Both result values are simple
- The whole thing fits on one line

Don't nest ternaries. If your if/else needs more than one line, use the regular form.

## 8. Common Patterns

### Pattern 1: input validation

```python
age = int(input("Enter your age: "))
if age < 0 or age > 150:
    print("That doesn't seem right")
else:
    print(f"OK, you are {age}")
```

### Pattern 2: range bucketing

```python
score = int(input("Score (0-100): "))

if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
elif score >= 60:
    grade = "D"
else:
    grade = "F"

print(f"Grade: {grade}")
```

### Pattern 3: multiple conditions

```python
day = input("Day of week: ").lower()

if day in ("saturday", "sunday"):
    print("Weekend! No work.")
elif day in ("monday", "tuesday", "wednesday", "thursday", "friday"):
    print("Weekday. Go to work.")
else:
    print("That's not a day of the week.")
```

The `in` operator checks if a value is in a collection. Combined with `if`, it's a clean way to check multiple specific values.

### Pattern 4: existence check

```python
name = input("Name (optional): ")

if name:
    print(f"Hello, {name}!")
else:
    print("Hello, stranger!")
```

Using truthiness directly is cleaner than `if name != "":` or `if len(name) > 0:`.

### Pattern 5: combined boolean logic

```python
age = int(input("Age: "))
has_license = input("Have license? (y/n): ").lower() == "y"
has_car = input("Have car? (y/n): ").lower() == "y"

if age >= 16 and has_license and has_car:
    print("You can drive!")
elif age >= 16 and has_license:
    print("You can drive but you need a car.")
elif age >= 16:
    print("Get a license first.")
else:
    print("Wait until you're 16.")
```

## 9. Common Mistakes

### Mistake 1: forgetting the colon

```python
if x > 5         # SYNTAX ERROR: missing colon
    print("big")

if x > 5:        # correct
    print("big")
```

### Mistake 2: wrong indentation

```python
if x > 5:
print("big")     # SYNTAX ERROR: needs indentation
```

```python
if x > 5:
    print("big")
        print("hi")    # INDENTATION ERROR: extra indent for no reason
```

### Mistake 3: `=` instead of `==`

```python
if x = 5:        # SYNTAX ERROR
    print("five")

if x == 5:       # correct
    print("five")
```

### Mistake 4: assuming string conversion in conditions

```python
answer = input("Continue? (yes/no): ")
if answer == "yes" or "y":     # WRONG: "y" alone is always truthy, so this is always True
    continue_program()

if answer == "yes" or answer == "y":   # correct
    continue_program()

if answer in ("yes", "y"):              # even cleaner
    continue_program()
```

This is a famous gotcha. `if answer == "yes" or "y"` is parsed as `if (answer == "yes") or ("y")`. The string `"y"` is truthy, so the whole condition is always True regardless of `answer`.

### Mistake 5: branches that can't both run

```python
score = 75
if score >= 60:
    print("passed")
elif score >= 90:        # this elif is never reached
    print("excellent")
```

Put specific conditions first, general conditions last.

## Summary

- Conditions are boolean expressions that evaluate to True or False.
- Python treats `0`, `""`, `[]`, `None` (and other empty things) as **falsy**. Everything else is **truthy**.
- `if` runs a block if the condition is True.
- `elif` chains alternative conditions.
- `else` runs if nothing else matched.
- Indentation defines blocks (4 spaces is standard).
- Combine conditions with `and`, `or`, `not`.
- Python supports chained comparisons: `18 <= age <= 65`.
- Nested `if`s work but flatten them when you can with `and` or early returns.
- Ternary form `x if condition else y` for simple one-line if/else.

You now have all the basics of Python's day 1 material. Next steps (when you cover them in class):

- **Loops:** `for` and `while` to repeat actions
- **Lists, tuples, dicts, sets:** Python's built-in collection types
- **Functions:** organizing code into reusable units
- **File I/O:** reading and writing files
- **Modules and packages:** organizing larger programs

Each of these will get its own note file as you cover them in class.
