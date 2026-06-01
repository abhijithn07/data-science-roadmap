# 16. Modules and Packages

As your projects grow, you'll split code across multiple files. A **module** is a Python file you can import into other files. A **package** is a folder of modules.

Importing also gives you access to Python's huge **standard library** plus third-party packages like numpy and pandas.

## 1. The Basics of `import`

### Import the whole module

```python
import math

print(math.pi)              # 3.141592653589793
print(math.sqrt(16))         # 4.0
print(math.floor(4.7))       # 4
```

`math` is a built-in standard library module. After `import math`, you access its contents with `math.something`.

### Import specific names from a module

```python
from math import pi, sqrt

print(pi)                    # 3.141592653589793
print(sqrt(16))              # 4.0
# math.floor(4.7)            # NameError: math wasn't imported
```

You can now use the names directly without the `math.` prefix.

### Import with an alias

Common with libraries that have long names:

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
```

These specific aliases are conventions you'll see in every data science codebase.

### Rename specific imports

```python
from math import sqrt as square_root

print(square_root(25))       # 5.0
```

### Import everything (avoid)

```python
from math import *

print(pi, sqrt(16))
```

**Don't use this in real code.** It dumps all the module's names into your namespace, potentially causing collisions. Bad for readability too - readers can't tell where names come from.

## 2. Useful Standard Library Modules

Python comes with a "batteries included" standard library. A few you'll use often:

### `math` - mathematical functions

```python
import math

math.pi                      # 3.14159...
math.e                       # 2.71828...
math.sqrt(16)                # 4.0
math.floor(4.7)              # 4
math.ceil(4.1)               # 5
math.log(100)                # natural log
math.log10(100)              # 2.0
math.sin(0)                  # 0.0
math.factorial(5)            # 120
```

### `random` - random numbers

```python
import random

random.random()              # float between 0 and 1
random.randint(1, 6)         # int between 1 and 6, inclusive
random.choice([1, 2, 3])     # pick one element
random.shuffle(my_list)      # shuffle in place
random.sample(my_list, 3)    # pick 3 without replacement
```

### `datetime` - dates and times (full coverage in note 20)

```python
from datetime import datetime, date, timedelta

now = datetime.now()
today = date.today()
tomorrow = today + timedelta(days=1)
```

### `os` and `pathlib` - file system operations

```python
import os
from pathlib import Path

# os module (older style)
os.path.exists("file.txt")
os.listdir(".")
os.makedirs("new_folder", exist_ok=True)

# pathlib (newer, cleaner)
p = Path("data") / "file.txt"
p.exists()
list(Path(".").iterdir())
```

### `json` - read/write JSON

```python
import json

# string to dict
data = json.loads('{"name": "Aaron"}')

# dict to string
text = json.dumps({"name": "Aaron"})

# read/write files
with open("data.json") as f:
    data = json.load(f)
with open("out.json", "w") as f:
    json.dump(data, f, indent=2)
```

### `collections` - useful data structures

```python
from collections import Counter, defaultdict, deque

# Counter for counting things
words = "apple banana apple cherry".split()
counts = Counter(words)
print(counts)                # Counter({'apple': 2, 'banana': 1, 'cherry': 1})
print(counts.most_common(2)) # [('apple', 2), ('banana', 1)]

# defaultdict for grouping
groups = defaultdict(list)
groups["fruits"].append("apple")   # no KeyError even if key didn't exist

# deque for fast appends/pops at both ends
q = deque([1, 2, 3])
q.appendleft(0)              # deque([0, 1, 2, 3])
q.pop()                       # deque([0, 1, 2])
```

### `itertools` - iteration helpers

```python
import itertools

# combinations and permutations
list(itertools.combinations([1, 2, 3], 2))   # [(1,2), (1,3), (2,3)]
list(itertools.permutations([1, 2, 3], 2))   # all ordered pairs

# infinite counter
counter = itertools.count(1)
# next(counter), next(counter)... 1, 2, 3, ...

# repeat a pattern
list(itertools.cycle(["a", "b"]))   # infinite, careful!
```

### `re` - regular expressions

```python
import re

re.search(r"\d+", "abc123def").group()    # '123'
re.findall(r"\d+", "abc123 def456")        # ['123', '456']
re.sub(r"\s+", "_", "hello world")         # 'hello_world'
```

### `sys` - system / interpreter info

```python
import sys

print(sys.argv)              # command-line args
print(sys.version)           # Python version
sys.exit(0)                  # quit the program
```

### `csv` - CSV reading/writing (covered in note 14)

### `time` - time-related functions

```python
import time

time.time()                  # current Unix timestamp (seconds since 1970)
time.sleep(2)                # pause for 2 seconds

start = time.time()
# ... do something ...
elapsed = time.time() - start
print(f"Took {elapsed:.2f} seconds")
```

## 3. Creating Your Own Module

A module is just any `.py` file. Create `mymath.py`:

```python
# mymath.py

def add(a, b):
    return a + b

def multiply(a, b):
    return a * b

PI = 3.14159
```

Now in another file in the same directory:

```python
# main.py
import mymath

print(mymath.add(2, 3))       # 5
print(mymath.PI)              # 3.14159

# or
from mymath import add, multiply
print(add(2, 3))
```

When you `import mymath`, Python looks for `mymath.py` in the current directory, then in standard library paths.

## 4. Creating a Package

A package is a folder containing multiple modules, plus an `__init__.py` file that marks the folder as a package.

```
mypackage/
    __init__.py
    math_utils.py
    string_utils.py
```

You can then:

```python
import mypackage.math_utils
from mypackage.string_utils import slugify
```

In `__init__.py` you can export things at the package level:

```python
# __init__.py
from .math_utils import add, multiply
from .string_utils import slugify
```

Now users can:
```python
from mypackage import add, slugify
```

## 5. The `if __name__ == "__main__":` pattern

When you create a script that's also meant to be importable as a module:

```python
# script.py

def main():
    print("Running as a script")

def helper():
    return 42

if __name__ == "__main__":
    main()
```

When you run `python script.py`, the special variable `__name__` is `"__main__"`, so `main()` runs.

When another file does `import script`, `__name__` is `"script"`, so `main()` does NOT auto-run. You can still access `script.helper()`.

This is how you make a file that's both a standalone tool and a reusable library.

## 6. `pip` - installing packages

Standard library modules come with Python. For everything else (numpy, pandas, requests, etc.), you use `pip`:

```bash
pip install numpy
pip install pandas matplotlib seaborn
pip install requests
```

After installing, you can `import` them in your code:

```python
import numpy as np
import pandas as pd
```

### Common pip commands

```bash
pip install <name>           # install
pip install <name>==1.2.3    # specific version
pip install --upgrade <name> # upgrade
pip uninstall <name>         # remove
pip list                     # see what's installed
pip show <name>              # info about a package
pip freeze > requirements.txt    # save the current packages
pip install -r requirements.txt  # install from a file
```

## 7. Virtual Environments

A **virtual environment** is an isolated Python setup for a single project. Different projects can have different package versions without interfering.

### Creating one

```bash
python -m venv myenv          # create
# Windows
myenv\Scripts\activate
# Mac/Linux
source myenv/bin/activate

# now pip installs only affect this env
pip install numpy

deactivate                    # exit the env
```

You'll see `(myenv)` in your terminal prompt when active.

### Anaconda alternative

Anaconda has its own version called `conda`:

```bash
conda create -n myenv python=3.11
conda activate myenv
conda install numpy pandas
conda deactivate
```

If you're using Anaconda, use conda commands. Otherwise use venv + pip.

### Why bother?

- Project A uses pandas 1.5, project B needs pandas 2.0
- You want to test if your code works without a particular library
- You want to share an exact environment with someone else

Use virtual environments for any serious project.

## 8. The Module Search Order

When you write `import x`, Python looks for `x` in this order:

1. **Built-in modules** (like `sys`, `math`)
2. **The current directory** (where you ran the script from)
3. **Directories in `PYTHONPATH`** environment variable
4. **Site-packages** (where pip installs things)

Run this to see all paths:
```python
import sys
print(sys.path)
```

If `import` fails, it's usually because:
- The package isn't installed (`pip install` it)
- You're in the wrong directory
- You're in the wrong virtual environment

## 9. Common Patterns

### Group imports by category at the top

```python
# standard library
import os
import json
from datetime import datetime

# third-party
import numpy as np
import pandas as pd
import requests

# your own modules
from myproject.utils import helper
from myproject.config import settings
```

This is a convention from PEP 8 (Python style guide).

### Conditional imports

```python
try:
    import ujson as json    # faster json library if available
except ImportError:
    import json             # fall back to standard
```

### Importing once at the top vs inside functions

```python
# top-level (preferred)
import pandas as pd

def process_data():
    df = pd.read_csv("...")

# inside function (sometimes used to delay slow imports)
def expensive_operation():
    import tensorflow as tf
    ...
```

For most cases, import at the top. Only delay imports if there's a real reason (slow startup, optional dependency).

## 10. Common Mistakes

### Mistake 1: import from wrong location

```python
# you have my_utils.py in a different folder
import my_utils    # ImportError
```

Make sure the file is in the same directory, or properly packaged, or on `sys.path`.

### Mistake 2: circular imports

```python
# file_a.py
from file_b import thing

# file_b.py
from file_a import other_thing    # circular!
```

Restructure your code or move shared things to a third module.

### Mistake 3: name collision with built-ins

```python
# do not name your file random.py, json.py, etc.
# it shadows the standard library
```

### Mistake 4: forgetting to install before importing

```python
import numpy    # ModuleNotFoundError if not installed
```

```bash
pip install numpy
```

### Mistake 5: confusing `import x` and `from x import y`

```python
import math
print(sqrt(16))           # NameError - math not "from-imported"

from math import sqrt
print(sqrt(16))           # works
```

## Summary

- `import module` - access via `module.name`
- `from module import name` - access directly
- `import module as alias` - rename for convenience
- `from module import name as alias` - rename specific names
- Standard library has tons of useful modules (math, random, datetime, json, os, re, collections, itertools)
- Your own files in the same directory can be imported
- `pip install` for third-party packages
- Use virtual environments for project isolation
- The `if __name__ == "__main__":` pattern for dual script/module files

This wraps up Phase 2. Next phase covers OOP, generators, decorators, and datetime, then data science libraries.
