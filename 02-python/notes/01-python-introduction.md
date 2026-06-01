# 01. Introduction to Python

## What is Python?

Python is a **general-purpose programming language**. Unlike SQL which is limited to querying and manipulating data inside a database, Python can do almost anything: data analysis, machine learning, web development, automation, scripting, scientific computing, and more.

It was created by Guido van Rossum in 1991 and has grown into one of the most popular programming languages in the world, especially for data science.

## Why Use Python?

There are dozens of programming languages. Why is Python so popular?

- **Readable syntax.** Python looks closer to English than other languages. Code blocks use indentation instead of curly braces, which forces clean formatting.
- **Huge library ecosystem.** Tens of thousands of free libraries for every imaginable task: pandas (data), numpy (math), scikit-learn (ML), requests (web), and on and on.
- **Easy to learn.** Minimal boilerplate. You can write a useful program on day one.
- **Interpreted.** No compilation step. Write a line, run it, see the result immediately.
- **Cross-platform.** The same code runs on Windows, Mac, and Linux without changes.
- **Used everywhere.** Data science, web development, automation, devops, finance, scientific research, game scripting, education.

## Python vs SQL

You've already learned SQL. Here's how Python differs:

| | SQL | Python |
|---|---|---|
| Primary purpose | Querying / manipulating database data | General-purpose programming |
| Where it runs | Inside a database engine (MySQL, PostgreSQL) | Anywhere Python is installed |
| Variables | No (mostly) | Yes |
| Loops | No (declarative) | Yes (`for`, `while`) |
| Functions | Built-in only, limited | Anything you can write |
| File I/O | No | Yes |
| Network access | No | Yes |
| Conditional logic | `CASE WHEN` only | Full `if` / `elif` / `else` |

**Think of it this way:** SQL is a powerful question-asking tool aimed at data. Python is the complete toolbox.

In real data work you use both: SQL to pull data out of databases, Python to analyze and visualize it.

## Environment Setup

To run Python code you need:
1. Python itself installed on your computer
2. An editor or notebook to write code in

### Anaconda

[Anaconda](https://www.anaconda.com/download) is a free distribution that bundles Python plus hundreds of popular data science libraries. Install once and you have Python, NumPy, pandas, scikit-learn, Jupyter, and more ready to go.

This is the easiest way to get started for data science work.

### Jupyter Notebook

Interactive Python in your web browser. Write code in **cells** and run them one at a time, seeing output immediately.

Launch from terminal (after installing Anaconda):
```bash
jupyter notebook
```

This opens your default browser pointing to `localhost:8888`. Click "New" → "Python 3" to create a new notebook.

Jupyter is perfect for learning and for data analysis where you iterate a lot. Each cell can hold either code or markdown (notes).

### VS Code

A standalone code editor (not Python-specific). Great for writing actual `.py` scripts that you can run as full programs. Install the Python extension by Microsoft for syntax highlighting, debugging, and IntelliSense.

Download: https://code.visualstudio.com/

### The Workflow

- **Learning / exploring data:** Jupyter Notebook (interactive, instant feedback per cell)
- **Writing reusable code or actual programs:** VS Code editing `.py` files

You'll switch between these depending on what you're doing.

## Hello World

The simplest Python program is one line:

```python
print("Hello World")
```

**`print()`** is a built-in function. It writes whatever you pass to it to the console (or the cell output in Jupyter).

Try variations:

```python
print(123)               # 123
print("Hello", "World")  # Hello World     (multiple args, space-separated by default)
print(1 + 2)             # 3               (Python evaluates expressions before printing)
print("a", "b", "c", sep="-")  # a-b-c    (custom separator)
print("no newline", end=" ")   # no newline (instead of newline at the end, use space)
```

## Comments

Comments are notes inside your code that Python **ignores**. They are for humans reading the code.

```python
# This is a comment. Python skips this line entirely.
print("Hello")  # Comments can also go at the end of a line

# Use comments to explain WHY you did something,
# not what (the code should be obvious enough for what).
```

For longer explanations, you can use a multi-line string as a fake comment:

```python
"""
This is technically a string literal, not a comment.
But because it's not assigned to anything, Python evaluates and discards it,
so it acts like a comment block.
"""
```

The single-line `#` form is the idiomatic Python comment style. Use it for almost everything.

## Running Python Code

Three common ways to run Python:

### 1. Jupyter Notebook cells
Type code into a cell, press **Shift+Enter** to execute. Output appears below the cell.

### 2. Python script file
Save code as `myscript.py`, then from terminal:
```bash
python myscript.py
```

### 3. Python REPL (interactive shell)
Type `python` in your terminal. You get a `>>>` prompt where you can type Python code interactively.

```
>>> print("hi")
hi
>>> 2 + 2
4
>>> exit()
```

REPL is useful for quick experiments. Jupyter is REPL-like but with persistent cells.

## What's Next

Now that you have Python set up and ran your first line, move on to [Variables and Data Types](./02-variables-and-data-types.md) to learn about storing values.
