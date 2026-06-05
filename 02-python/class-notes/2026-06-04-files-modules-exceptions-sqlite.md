# 2026-06-04: File Operations, Modules, Exceptions, SQLite

Notebooks: `File_Operations_4.ipynb`, `Python_5.ipynb`

Covered file handling, the standard-library modules, error and exception handling, and basic database work with sqlite3.

---

## Working with Text Files

### Writing to a file ("w" mode)

"w" creates the file if it does not exist and overwrites it if it does.

```python
with open("sample.txt", "w") as f:
    f.write("Hello, this is a sample text file.\n")
    f.write("It has multiple lines.\n")
    f.write("hi hello world\n")
    f.write('hello this is python testing file operations commands')
```

### Reading from a file ("r" mode)

`read()` pulls the whole file in as one string.

```python
with open("sample.txt", "r") as f:
    content = f.read()
    print("File content:")
    print(content)
```

### Append ("a" mode)

Adds content at the end without erasing what is already there.

```python
with open("example.txt", "a") as file:
    file.write("Line 5: This is appended.\n")
    file.write("Line 6: This is python session 5\n")
```

### Reading first N characters

Pass a number to `read()` to limit how much you read.

```python
with open("example.txt", "r") as file:
    print("First 10 characters:", file.read(10))
```

### Read line by line

Looping over the file object gives one line at a time. `strip()` removes the trailing newline.

```python
with open("example.txt", "r") as f:
    for line in f:
        print("Line:", line.strip())
```

### readline()

Reads one line per call, so each call moves to the next line.

```python
with open("example.txt", "r") as file:
    print("Line 1:", file.readline().strip())
    print("Line 2:", file.readline().strip())
    print("Line 3:", file.readline().strip())
```

### readlines()

Reads every line into a list, one string per line (newlines kept).

```python
with open("example.txt", "r") as file:
    lines = file.readlines()
    print(lines)
# ['this is boring sessions...\n', 'Line 6: This is python session 5\n', '\n']
```

### Copy a file

Open the source in read mode and the destination in write mode in the same `with`, then write each line across.

```python
with open("example.txt", "r") as src, open("copy_sample.txt", "w") as dest:
    for line in src:
        dest.write(line)

with open("copy_sample.txt", "r") as f:
    content = f.read()
    print("File content:")
    print(content)
```

### r+ mode and seek()

"r+" opens for both reading and writing. `seek(n)` moves the cursor to byte position n, so the next write lands there instead of at the start.

```python
with open("example.txt", "r+") as file:
    content = file.read()
    file.seek(35)
    file.write("chandler bing")
```

---

## Working with Excel Files (.xlsx)

Use pandas. Build a DataFrame, write it out with `to_excel`, read it back with `read_excel`. `index=False` stops pandas from writing the row numbers as a column.

```python
import pandas as pd

data = {
    "Name": ["Alice", "Bob", "Charlie", "ruchik", "sushma", "Thauja", "max", "karthik"],
    "Marks": [85, 90, 78, 87, 11, 44, 0, 21]
}
df = pd.DataFrame(data)

# Writing to an Excel file
df.to_excel("students.xlsx", index=False)

# Reading from an Excel file
df_read = pd.read_excel("students.xlsx")
print("Data from Excel:")
print(df_read)
```

---

## Modules, Libraries, Packages

A module is just a Python file with a `.py` extension that holds a set of functions. You bring it in with `import`. A module loads only once per run: if it gets imported again, Python reuses the already-loaded copy, so its top-level variables behave like a singleton.

### math

```python
import math

print(math.ceil(25.7))    # 26, rounds up
print(math.floor(25.7))   # 25, rounds down
print(math.sqrt(16))      # 4.0
print(math.factorial(5))  # 120
print(math.pi)            # 3.141592653589793  (no parentheses, it is a value)
```

### random

```python
import random

print(random.randint(1, 10))         # random int between 1 and 10
print(random.choice(['a', 'b', 'c'])) # random pick from the list
```

### datetime

`strftime` formats the date into a readable string using format codes (%Y year, %m month, %d day, %H hour, %M minute, %S second).

```python
from datetime import datetime

now = datetime.now()
print("Current Time:", now.strftime("%Y-%m-%d %H:%M:%S"))
# Current Time: 2026-06-04 23:06:01
```

### os

```python
import os

print(os.getcwd())   # current working directory
print(os.listdir())  # files in the current directory
```

### sys

```python
import sys

print(sys.version)  # Python version
print(sys.path)     # list of paths Python searches for imports
```

### statistics

```python
import statistics

data = [10, 20, 30, 40, 50, 70]
print(statistics.mean(data))    # 36.6666...
print(statistics.median(data))  # 35.0
```

### dir() and help()

`dir(module)` lists everything inside a module. `help(function)` prints the docs for a specific function. Useful for exploring something new.

```python
print(dir(math))   # lists all functions and attributes in math
help(math.floor)   # shows the docstring for floor
```

### Custom module (mymath.py)

Any `.py` file you write can be imported the same way as a built-in.

```python
# mymath.py
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b
```

```python
import mymath

print(mymath.add(2, 3))       # 5
print(mymath.subtract(5, 2))  # 3
```

---

## Errors and Exception Handling

An exception is an error that happens while the code is running, even when the syntax is correct. Without handling, it stops the whole program. `try`/`except` lets the code keep going.

A quick syntax-error example caught with a bare except:

```python
try:
    printf(Hello)
except:
    print('syntax issue')
```

### try and except

Code that might fail goes in `try`. The handling goes in `except`. You can target a specific exception type, and an optional `else` runs only when no exception happened.

```python
try:
    f = open('testfile.txt', 'w')
    f.write('Test write this')
except IOError:
    print("Error: Could not find file or read data")
else:
    print("Content written successfully")
    f.close()
```

Writing to a file opened in read mode throws an error:

```python
f = open('testfile.txt', 'r')
f.write('Test write this')
# UnsupportedOperation: not writable
```

Catching that case so the program keeps running:

```python
try:
    f = open('testfile.txt', 'r')
    f.write('Test write this')
except IOError:
    print("Error: you are opening file in read mode and writing the data")
else:
    print("Content written successfully")
    f.close()
# Error: you are opening file in read mode and writing the data
```

Using a bare `except` catches any exception when you are not sure which one to expect:

```python
try:
    f = open('testfile', 'r')
    f.write('Test write this')
except:
    print("Error: Could not find file or read data")
else:
    print("Content written successfully")
    f.close()
```

### finally

The `finally` block always runs, exception or not. Good for cleanup.

```python
try:
    f = open("testfile.txt", "w")
    f.write("Test write statement")
finally:
    print("Always execute finally code blocks")
# Always execute finally code blocks
```

### try / except / finally together

The `askint` example: ask for an integer, catch the case where the input is not one, and always print the finally message.

```python
def askint():
    try:
        val = int(input("Please enter an integer: "))
    except:
        print("Looks like you did not enter an integer!")
    finally:
        print("Finally, I executed!")
    # print(val)  # would error here since val was never assigned

askint()
# Please enter an integer: asdfsdfdhfgh
# Looks like you did not enter an integer!
# Finally, I executed!
```

Note: `val` is only assigned if the `int()` call succeeds, so printing it after a failed attempt would itself raise an error.

---

## Database Connectivity with Python (sqlite3)

`sqlite3` is built into Python, no install needed. Connect to a database file, run SQL through `execute()`, and save changes with `commit()`.

```python
#!/usr/bin/python
import sqlite3

# connect to the database (creates the file if it does not exist)
db = sqlite3.connect("my_database3.db")

# drop the table if it already exists
db.execute("drop table if exists grades1")

# create the table
db.execute("create table grades1(id int, name text, score int)")

# insert values
db.execute("insert into grades1(id, name, score) values(101, 'John', 99)")
db.execute("insert into grades1(id, name, score) values(102, 'Gary', 90)")
db.execute("insert into grades1(id, name, score) values(103, 'James', 80)")
db.execute("insert into grades1(id, name, score) values(104, 'Cathy', 85)")
db.execute("insert into grades1(id, name, score) values(105, 'ruchik', 95)")

db.commit()  # save the changes
```

Querying the table. `execute()` returns rows you can loop over:

```python
results = db.execute("select * from grades1 order by id")
for row in results:
    print(row)
print("-" * 60)

results = db.execute("select * from grades1 where name = 'ruchik' ")
for row in results:
    print(row)
print("-" * 60)

results = db.execute("select * from grades1 where score >= 90 ")
for row in results:
    print(row)
print("-" * 60)
```

Each row comes back as a tuple, for example `(101, 'John', 99)`.
