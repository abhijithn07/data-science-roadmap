# 23. Matplotlib

**Matplotlib** is the foundational plotting library in Python. Most other plotting libraries (including seaborn and pandas' built-in plotting) are built on top of it.

The main module you'll use is `pyplot`, imported as `plt`.

## 1. Setup

```bash
pip install matplotlib
```

```python
import matplotlib.pyplot as plt
```

In Jupyter, use this magic to display plots inline:

```python
%matplotlib inline
```

## 2. The Simplest Plot

```python
import matplotlib.pyplot as plt

x = [1, 2, 3, 4, 5]
y = [1, 4, 9, 16, 25]

plt.plot(x, y)
plt.show()
```

`plt.show()` displays the plot. In Jupyter you usually don't need it.

## 3. Adding Labels and Title

```python
plt.plot(x, y)
plt.title("My First Plot")
plt.xlabel("X axis")
plt.ylabel("Y axis")
plt.show()
```

## 4. Plot Types

### Line plot (default)

```python
plt.plot([1, 2, 3, 4], [10, 20, 25, 30])
```

### Scatter plot

```python
x = [1, 2, 3, 4, 5]
y = [10, 25, 30, 22, 45]
plt.scatter(x, y)
```

### Bar chart

```python
categories = ["A", "B", "C", "D"]
values = [10, 25, 15, 30]
plt.bar(categories, values)
```

### Horizontal bar

```python
plt.barh(categories, values)
```

### Histogram (frequency distribution)

```python
import numpy as np
data = np.random.randn(1000)
plt.hist(data, bins=30)
```

### Box plot

```python
data = [np.random.randn(100), np.random.randn(100) * 2]
plt.boxplot(data, labels=["A", "B"])
```

### Pie chart

```python
sizes = [30, 25, 20, 15, 10]
labels = ["A", "B", "C", "D", "E"]
plt.pie(sizes, labels=labels, autopct="%1.1f%%")
```

## 5. Customizing Style

### Line styles and colors

```python
plt.plot(x, y, color="red", linewidth=2)
plt.plot(x, y, color="blue", linestyle="--")    # dashed
plt.plot(x, y, color="green", linestyle=":")    # dotted

# common shorthand
plt.plot(x, y, "r-")        # red solid
plt.plot(x, y, "b--")       # blue dashed
plt.plot(x, y, "g:")        # green dotted
plt.plot(x, y, "ko")        # black circles, no line
plt.plot(x, y, "rs--")      # red squares with dashed line
```

Color codes: `r`, `g`, `b`, `c`, `m`, `y`, `k` (black), `w` (white). Also accepts hex like `"#FF5733"` or names like `"crimson"`.

### Markers

```python
plt.plot(x, y, marker="o")        # circles at each point
plt.plot(x, y, marker="s")        # squares
plt.plot(x, y, marker="^")        # triangles
plt.plot(x, y, marker="x")        # x's
plt.plot(x, y, marker="*")        # stars
```

### Combining

```python
plt.plot(x, y,
         color="purple",
         linewidth=2,
         linestyle="--",
         marker="o",
         markersize=8,
         markerfacecolor="yellow")
```

## 6. Multiple Lines on One Plot

```python
x = range(10)
plt.plot(x, [n*n for n in x], label="squares")
plt.plot(x, [n*n*n for n in x], label="cubes")
plt.plot(x, [2**n for n in x], label="powers of 2")
plt.legend()        # show the labels
plt.show()
```

The `label` argument plus `plt.legend()` is how you add a legend.

## 7. Subplots - multiple plots in one figure

### Quick way

```python
fig, axes = plt.subplots(2, 2)     # 2x2 grid

axes[0, 0].plot([1, 2, 3], [1, 4, 9])
axes[0, 1].scatter([1, 2, 3], [3, 2, 5])
axes[1, 0].bar(["A", "B", "C"], [3, 7, 5])
axes[1, 1].hist(np.random.randn(100))

plt.tight_layout()    # avoid overlapping labels
plt.show()
```

`axes` is a 2D array of subplot objects. Each one has its own plot methods.

### Single row or column

```python
fig, axes = plt.subplots(1, 3, figsize=(15, 4))    # 1 row, 3 cols

axes[0].plot(x, y1)
axes[0].set_title("Plot 1")

axes[1].plot(x, y2)
axes[1].set_title("Plot 2")

axes[2].plot(x, y3)
axes[2].set_title("Plot 3")
```

### Figure size

```python
fig, ax = plt.subplots(figsize=(10, 6))    # width, height in inches
```

## 8. The Two Styles of Matplotlib

You'll see two patterns in matplotlib code. Both work; pick one and be consistent:

### Style A: pyplot (state-machine)

```python
plt.figure()
plt.plot(x, y)
plt.title("My Plot")
plt.xlabel("X")
plt.ylabel("Y")
plt.show()
```

Each `plt.something()` acts on the "current" plot. Simple for quick scripts.

### Style B: object-oriented (recommended for complex plots)

```python
fig, ax = plt.subplots()
ax.plot(x, y)
ax.set_title("My Plot")
ax.set_xlabel("X")
ax.set_ylabel("Y")
plt.show()
```

You work with `fig` (the figure) and `ax` (the axes). More explicit. Easier when you have multiple subplots.

The OO style is more powerful. Quick exploration is fine with pyplot. For production code, use OO.

## 9. Common Customizations

### Axis limits

```python
plt.xlim(0, 10)
plt.ylim(-5, 5)

# OR with axes object
ax.set_xlim(0, 10)
ax.set_ylim(-5, 5)
```

### Ticks

```python
plt.xticks([1, 2, 3, 4, 5])    # custom positions
plt.xticks([1, 2, 3], ["Jan", "Feb", "Mar"])    # with labels
plt.xticks(rotation=45)          # rotate labels
```

### Grid

```python
plt.grid(True)
plt.grid(True, axis="y")
plt.grid(True, linestyle="--", alpha=0.5)
```

### Annotation

```python
plt.text(2, 5, "Important point", fontsize=12)
plt.annotate("Look here!", xy=(2, 5), xytext=(3, 7),
             arrowprops=dict(arrowstyle="->"))
```

### Style sheets (quick aesthetic changes)

```python
plt.style.use("ggplot")           # R-style
plt.style.use("seaborn-v0_8")     # seaborn-like
plt.style.use("dark_background")
plt.style.use("default")

# see all available
print(plt.style.available)
```

## 10. Saving Plots

```python
plt.savefig("plot.png")
plt.savefig("plot.png", dpi=300)            # high resolution
plt.savefig("plot.pdf")                      # PDF
plt.savefig("plot.svg")                      # SVG (vector)
plt.savefig("plot.png", bbox_inches="tight") # crop whitespace
```

Save BEFORE `plt.show()`.

## 11. Working with Pandas

Pandas has built-in plotting based on matplotlib:

```python
import pandas as pd
df = pd.DataFrame({
    "year": [2020, 2021, 2022, 2023, 2024],
    "sales": [100, 120, 150, 130, 180]
})

df.plot(x="year", y="sales", kind="line")
df.plot(x="year", y="sales", kind="bar")
df["sales"].hist(bins=20)
df.plot.scatter(x="year", y="sales")
df.boxplot(column="sales")
```

This is often the quickest way to visualize a DataFrame.

## 12. Common Patterns

### Line chart with multiple series

```python
fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(years, revenue, label="Revenue", marker="o")
ax.plot(years, profit, label="Profit", marker="s")
ax.plot(years, expenses, label="Expenses", marker="^")

ax.set_title("Annual Financial Performance")
ax.set_xlabel("Year")
ax.set_ylabel("USD (thousands)")
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```

### Histogram with multiple distributions

```python
fig, ax = plt.subplots(figsize=(10, 6))

ax.hist(group_a, bins=30, alpha=0.5, label="Group A")
ax.hist(group_b, bins=30, alpha=0.5, label="Group B")
ax.set_xlabel("Value")
ax.set_ylabel("Frequency")
ax.legend()
plt.show()
```

`alpha=0.5` makes them semi-transparent so overlaps are visible.

### Bar chart with values on top

```python
fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(["A", "B", "C", "D"], [23, 45, 67, 89])

for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2, height,
            f"{height}", ha="center", va="bottom")

plt.show()
```

### Comparing distributions side by side

```python
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

axes[0].hist(data1, bins=30)
axes[0].set_title("Before")
axes[0].set_xlabel("Value")

axes[1].hist(data2, bins=30)
axes[1].set_title("After")
axes[1].set_xlabel("Value")

plt.tight_layout()
plt.show()
```

### Heatmap from a 2D array

```python
import numpy as np
data = np.random.rand(10, 12)

plt.imshow(data, cmap="hot", aspect="auto")
plt.colorbar()
plt.show()
```

(For nice statistical heatmaps, use seaborn's `heatmap` - covered next file.)

## 13. Common Mistakes

### Mistake 1: forgetting `plt.show()` (or `%matplotlib inline`)

In a script, you need `plt.show()` to actually display the plot. In Jupyter, run `%matplotlib inline` once or use the magic that gets things to display.

### Mistake 2: overwriting `plt` state

In pyplot style, every `plt.X` affects the current plot. If you want a fresh plot:

```python
plt.figure()    # start a new figure
plt.plot(...)

plt.figure()    # start ANOTHER fresh figure
plt.plot(...)
```

### Mistake 3: misaligned data

```python
x = [1, 2, 3, 4]
y = [10, 20, 30]    # different length!
plt.plot(x, y)        # error
```

x and y must be the same length.

### Mistake 4: missing labels

```python
plt.plot(data)        # no axis labels, no title - hard to interpret
```

Always add labels and a title:

```python
plt.plot(data)
plt.title("Daily Sales")
plt.xlabel("Day")
plt.ylabel("Sales ($)")
```

### Mistake 5: too small / too big figures

```python
plt.plot(x, y)             # default is often too small for slides/reports
plt.figure(figsize=(10, 6))    # before plotting
plt.plot(x, y)
```

### Mistake 6: not saving before showing

```python
plt.show()
plt.savefig("plot.png")    # may save a blank file after show
```

Save first:

```python
plt.savefig("plot.png")
plt.show()
```

## 14. Quick Reference

```python
import matplotlib.pyplot as plt

# basic
plt.plot(x, y)
plt.scatter(x, y)
plt.bar(x, y)
plt.hist(data, bins=30)
plt.boxplot(data)
plt.pie(sizes)

# labels
plt.title("Title")
plt.xlabel("X")
plt.ylabel("Y")
plt.legend()

# limits and ticks
plt.xlim(a, b)
plt.ylim(a, b)
plt.xticks(positions, labels, rotation=45)
plt.grid(True)

# subplots
fig, axes = plt.subplots(rows, cols, figsize=(w, h))
axes[i, j].plot(...)
plt.tight_layout()

# save and show
plt.savefig("file.png", dpi=300, bbox_inches="tight")
plt.show()
```

## Summary

- `import matplotlib.pyplot as plt`
- Quick: `plt.plot()`, `plt.scatter()`, `plt.bar()`, `plt.hist()`
- Always label: `title`, `xlabel`, `ylabel`, `legend`
- Multiple plots: `fig, axes = plt.subplots(rows, cols)`
- Two styles: pyplot (quick) vs object-oriented (complex)
- DataFrames have built-in `.plot()`
- Save with `plt.savefig()` BEFORE `plt.show()`

Next: [Seaborn](./24-seaborn.md) - prettier statistical plots built on matplotlib.
