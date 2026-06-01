# Python Notes

Detailed beginner-friendly notes covering every Python topic for the data science roadmap. Each file is a self-contained study guide for one topic.

## Roadmap

### Phase 1: Core Python Basics

1. [Introduction](./01-python-introduction.md) - what python is, why use it, vs SQL, environment setup, hello world
2. [Variables and Data Types](./02-variables-and-data-types.md) - variables, int, float, str, complex, bool, `type()`
3. [Type Casting and Typing](./03-type-casting-and-typing.md) - implicit vs explicit conversion, duck typing, dynamic typing
4. [Operators](./04-operators.md) - arithmetic, comparison, logical, assignment
5. [Input and String Formatting](./05-input-and-string-formatting.md) - `input()`, type conversion, f-strings, `.format()`, `%`
6. [Conditionals](./06-conditionals.md) - boolean evaluation, `if` / `elif` / `else`, nested if

### Phase 2: Control Flow and Collections

7. [Loops](./07-loops.md) - `for`, `while`, `range()`, `break`, `continue`, looping over collections
8. [Lists](./08-lists.md) - creation, indexing, slicing, methods, iteration, common operations
9. [Tuples and Sets](./09-tuples-and-sets.md) - tuples (immutable), unpacking, sets (unique values), set operations
10. [Dictionaries](./10-dictionaries.md) - key-value pairs, access, methods, iteration, nested dicts
11. [Strings In Depth](./11-strings-in-depth.md) - methods, slicing, common patterns
12. [Functions](./12-functions.md) - `def`, return, parameters, default args, `*args`, `**kwargs`, scope, `lambda`
13. [Comprehensions](./13-comprehensions.md) - list, dict, set, generator comprehensions
14. [File I/O](./14-file-io.md) - reading and writing files, CSV basics, the `with` statement
15. [Error Handling](./15-error-handling.md) - `try` / `except` / `else` / `finally`, raising exceptions
16. [Modules and Packages](./16-modules-and-packages.md) - `import`, `pip`, virtual environments

### Phase 3: Intermediate Python

17. [OOP Basics](./17-oop-basics.md) - classes, `__init__`, methods, inheritance
18. [Iterators and Generators](./18-iterators-and-generators.md) - `yield`, generator expressions
19. [Decorators](./19-decorators.md) - `@` syntax, common use cases
20. [Date and Time](./20-date-and-time.md) - `datetime`, `timedelta`, formatting

### Phase 4: Data Science Libraries

21. [NumPy](./21-numpy.md) - arrays, operations, broadcasting, indexing, reshaping
22. [Pandas](./22-pandas.md) - Series, DataFrame, IO, filtering, groupby, merging
23. [Matplotlib](./23-matplotlib.md) - basic plotting, subplots, customization
24. [Seaborn](./24-seaborn.md) - statistical visualization built on matplotlib
25. [SciPy](./25-scipy.md) - scientific computing, statistics, distributions, hypothesis tests

> **Machine Learning** is covered in a separate top-level folder: [`../../03-machine-learning/`](../../03-machine-learning/)

## How to use these notes

Read in order if learning from scratch. Each topic builds on the previous one. Each note has:

- Concept explanation in plain language
- Concrete code examples you can run
- Tables and comparisons where they help
- Common mistakes to watch for

For the actual code from class (without explanations), see [`../class-notes/`](../class-notes/).
