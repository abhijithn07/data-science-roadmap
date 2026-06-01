# 14. File I/O

Reading from and writing to files is essential for data work. You'll read CSVs, save results, log output, parse logs, etc.

## 1. Opening a File

The basic pattern uses `open()` with a path and a mode:

```python
f = open("data.txt", "r")    # open for reading
content = f.read()
f.close()                     # ALWAYS close when done
```

### File modes

| Mode | What it does |
|---|---|
| `"r"` | read (default) - file must exist |
| `"w"` | write - creates or **overwrites** the file |
| `"a"` | append - adds to end of existing file |
| `"x"` | exclusive create - fails if file exists |
| `"r+"` | read and write |
| `"rb"`, `"wb"` | binary mode (for images, etc.) |

### The `with` statement (preferred)

Using `with` automatically closes the file when the block ends, even if an error occurs:

```python
with open("data.txt", "r") as f:
    content = f.read()
# f is automatically closed here
```

**Always use `with`.** Manual `open/close` is error-prone.

## 2. Reading a File

### Read entire content as a string

```python
with open("data.txt", "r") as f:
    content = f.read()
print(content)
```

OK for small files. Don't use for huge files (loads everything into memory).

### Read line by line

```python
with open("data.txt", "r") as f:
    for line in f:
        print(line.strip())   # strip removes the trailing newline
```

This is memory-efficient even for huge files. The file is read line at a time.

### Read all lines into a list

```python
with open("data.txt", "r") as f:
    lines = f.readlines()    # list of strings
```

Each line includes the trailing `\n` newline character. Often you want to strip it.

### Read one line at a time manually

```python
with open("data.txt", "r") as f:
    first_line = f.readline()
    second_line = f.readline()
```

Less common. Usually you just loop with `for line in f`.

## 3. Writing to a File

### Write a string

```python
with open("output.txt", "w") as f:
    f.write("Hello\n")
    f.write("World\n")
```

`"w"` mode **overwrites** the file. If output.txt existed before, its contents are erased.

### Append to a file

```python
with open("log.txt", "a") as f:
    f.write("New log entry\n")
```

`"a"` mode adds to the end of an existing file (or creates it if it doesn't exist).

### Write multiple lines

```python
lines = ["apple", "banana", "cherry"]
with open("output.txt", "w") as f:
    for fruit in lines:
        f.write(fruit + "\n")

# or use writelines
with open("output.txt", "w") as f:
    f.writelines(line + "\n" for line in lines)
```

Note: `writelines()` does NOT add newlines automatically. You have to include them yourself.

### Use print() to a file

A convenient alternative:

```python
with open("output.txt", "w") as f:
    print("Hello", file=f)
    print("World", file=f)
```

`print()` adds the newline automatically.

## 4. File Paths

### Absolute vs relative paths

```python
# absolute
open("/home/user/data.txt")
open("C:/Users/Aaron/data.txt")

# relative (to where the script is run from)
open("data.txt")              # in current dir
open("subdir/data.txt")        # in subdirectory
open("../data.txt")            # in parent dir
```

### Use forward slashes (work on all OS) or raw strings on Windows

```python
# all of these work
path = "data/file.txt"
path = r"C:\data\file.txt"     # raw string, backslashes left alone
path = "C:\\data\\file.txt"    # escaped backslashes
```

### Use `pathlib` for modern path handling

```python
from pathlib import Path

p = Path("data") / "file.txt"     # OS-appropriate separator
print(p.exists())                  # True/False
print(p.is_file())                 # True/False
print(p.stem)                      # 'file'
print(p.suffix)                    # '.txt'
print(p.parent)                    # Path('data')

# read/write
content = p.read_text()
p.write_text("hello")
```

`pathlib` is cleaner than dealing with strings. Recommended for new code.

## 5. CSV Files

CSV (comma-separated values) is the most common data file format. Python's `csv` module handles it properly (dealing with quoted fields, commas inside values, etc.):

### Reading a CSV

```python
import csv

with open("people.csv", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)
# ['name', 'age', 'city']
# ['Aaron', '25', 'Tampa']
# ['Bea', '30', 'Miami']
```

`csv.reader` gives you a list per row. All values are strings - you'll need to cast numbers manually.

### Reading as dicts (with headers)

```python
with open("people.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row)
# {'name': 'Aaron', 'age': '25', 'city': 'Tampa'}
# {'name': 'Bea',   'age': '30', 'city': 'Miami'}
```

This is usually more convenient because you can access fields by name.

### Writing a CSV

```python
import csv

data = [
    ["name", "age", "city"],
    ["Aaron", 25, "Tampa"],
    ["Bea",   30, "Miami"]
]

with open("output.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(data)
```

The `newline=""` argument prevents extra blank lines on Windows.

### Writing dicts

```python
data = [
    {"name": "Aaron", "age": 25, "city": "Tampa"},
    {"name": "Bea",   "age": 30, "city": "Miami"}
]

with open("output.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["name", "age", "city"])
    writer.writeheader()
    writer.writerows(data)
```

## 6. JSON Files

JSON (JavaScript Object Notation) is the standard format for structured data, especially from APIs.

### Reading JSON

```python
import json

with open("data.json", "r") as f:
    data = json.load(f)
# data is a Python dict (or list, depending on the JSON)
print(data["name"])
```

### Writing JSON

```python
data = {
    "name": "Aaron",
    "age": 25,
    "scores": [90, 85, 95]
}

with open("data.json", "w") as f:
    json.dump(data, f, indent=2)    # indent for pretty printing
```

### JSON strings (no file)

```python
# dict to JSON string
json_str = json.dumps({"name": "Aaron"})
print(json_str)              # '{"name": "Aaron"}'

# JSON string to dict
data = json.loads('{"name": "Aaron"}')
print(data["name"])          # 'Aaron'
```

Memory aid: `dump`/`load` is for files. `dumps`/`loads` is for strings (the `s` stands for "string").

## 7. Common Patterns

### Read a config file

```python
config = {}
with open("config.txt") as f:
    for line in f:
        if "=" in line:
            key, value = line.strip().split("=", 1)
            config[key.strip()] = value.strip()
```

### Process a log file

```python
errors = 0
with open("app.log") as f:
    for line in f:
        if "ERROR" in line:
            errors += 1
print(f"Found {errors} errors")
```

### Copy a file

```python
with open("source.txt") as src, open("dest.txt", "w") as dst:
    dst.write(src.read())
```

For binary files use `"rb"` and `"wb"`.

### Count lines

```python
with open("file.txt") as f:
    line_count = sum(1 for _ in f)
print(line_count)
```

### Read a CSV with type conversion

```python
import csv

people = []
with open("people.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        people.append({
            "name": row["name"],
            "age":  int(row["age"]),       # convert string to int
            "city": row["city"]
        })
```

### Write only every Nth line of a huge file

```python
with open("huge.txt") as src, open("sample.txt", "w") as dst:
    for i, line in enumerate(src):
        if i % 100 == 0:                    # every 100th line
            dst.write(line)
```

## 8. Encoding

By default Python uses your system's default text encoding (usually UTF-8 on modern systems). For non-ASCII text, specify explicitly:

```python
with open("data.txt", "r", encoding="utf-8") as f:
    content = f.read()
```

If you get a `UnicodeDecodeError`, the file isn't UTF-8. Try `"latin-1"` or check the source encoding.

## 9. File Existence and Errors

### Check if a file exists

```python
import os
if os.path.exists("data.txt"):
    print("file exists")

# pathlib version
from pathlib import Path
if Path("data.txt").exists():
    print("file exists")
```

### Handle missing files gracefully

```python
try:
    with open("data.txt") as f:
        content = f.read()
except FileNotFoundError:
    content = ""
    print("file not found, using empty default")
```

(More on `try/except` in note 15.)

## Common Mistakes

### Mistake 1: forgetting to close (without `with`)

```python
f = open("data.txt")
content = f.read()
# forgot to close
```

The file handle leaks. Always use `with`.

### Mistake 2: writing without proper newlines

```python
with open("output.txt", "w") as f:
    f.write("line1")
    f.write("line2")
# file contains: "line1line2" (no separation)
```

Add `\n`:

```python
f.write("line1\n")
f.write("line2\n")
```

### Mistake 3: `"w"` overwriting accidentally

```python
with open("important.txt", "w") as f:    # ERASES existing content!
    f.write("oops")
```

Use `"a"` if you want to append, or check first.

### Mistake 4: extra blank lines in CSV (Windows)

```python
with open("out.csv", "w") as f:           # missing newline=""
    csv.writer(f).writerow(["a", "b"])
# may produce extra blank lines on Windows
```

Fix:
```python
with open("out.csv", "w", newline="") as f:
    csv.writer(f).writerow(["a", "b"])
```

### Mistake 5: reading entire huge file into memory

```python
with open("huge.txt") as f:
    content = f.read()           # could use gigabytes of RAM
```

For huge files, iterate line by line:
```python
with open("huge.txt") as f:
    for line in f:
        process(line)
```

## Summary

- Use `with open(path, mode) as f:` for automatic closing
- Modes: `"r"` (read), `"w"` (write, overwrites), `"a"` (append)
- `f.read()` for whole file, iterate `f` for line-by-line
- CSV: use `csv.reader` or `csv.DictReader`
- JSON: `json.load(f)` and `json.dump(data, f)`
- `pathlib.Path` for modern path handling

Next: [Error Handling](./15-error-handling.md) - dealing with things that can go wrong.
