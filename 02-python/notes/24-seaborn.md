# 24. Seaborn

**Seaborn** is a statistical plotting library built on top of matplotlib. It produces prettier plots with much less code, and it's designed to work directly with pandas DataFrames.

If you find yourself writing 10 lines of matplotlib for a chart, seaborn probably does it in 1.

## 1. Setup

```bash
pip install seaborn
```

```python
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
```

The convention is `sns` (some say it stands for the original author's initials).

## 2. Why Seaborn?

Compare these two for the same plot:

```python
# matplotlib
plt.scatter(df["x"], df["y"], c=df["category"].map({"A": "red", "B": "blue"}))
plt.xlabel("X value")
plt.ylabel("Y value")
plt.title("Scatter by Category")
# need to manually build a legend, etc.

# seaborn
sns.scatterplot(data=df, x="x", y="y", hue="category")
```

Seaborn handles the color mapping, legend, and labels automatically. And the default style looks better.

## 3. Sample Data

Seaborn comes with built-in example datasets:

```python
import seaborn as sns

tips = sns.load_dataset("tips")
print(tips.head())
#    total_bill   tip     sex smoker  day    time  size
# 0       16.99  1.01  Female     No  Sun  Dinner     2
# 1       10.34  1.66    Male     No  Sun  Dinner     3

iris = sns.load_dataset("iris")
penguins = sns.load_dataset("penguins")
```

These are great for practicing.

## 4. Common Plot Types

### Histogram - `histplot`

```python
sns.histplot(data=tips, x="total_bill", bins=20)
plt.show()
```

With KDE (smoothed curve):

```python
sns.histplot(data=tips, x="total_bill", kde=True)
```

By category:

```python
sns.histplot(data=tips, x="total_bill", hue="sex", multiple="stack")
```

### Box plot - `boxplot`

Shows the distribution (median, quartiles, outliers):

```python
sns.boxplot(data=tips, x="day", y="total_bill")
```

By a category:

```python
sns.boxplot(data=tips, x="day", y="total_bill", hue="sex")
```

### Violin plot - `violinplot`

Like a box plot but shows the full distribution shape:

```python
sns.violinplot(data=tips, x="day", y="total_bill")
```

### Scatter plot - `scatterplot`

```python
sns.scatterplot(data=tips, x="total_bill", y="tip")

# with categories
sns.scatterplot(data=tips, x="total_bill", y="tip", hue="time", style="sex")

# size proportional to a variable
sns.scatterplot(data=tips, x="total_bill", y="tip", size="size")
```

`hue` colors points by category. `style` changes marker shape. `size` changes marker size.

### Line plot - `lineplot`

For time series or trends:

```python
flights = sns.load_dataset("flights")
sns.lineplot(data=flights, x="year", y="passengers", hue="month")
```

Automatically computes confidence intervals if there are multiple values per x.

### Bar plot - `barplot`

Aggregate bar chart (default: mean per group with confidence interval):

```python
sns.barplot(data=tips, x="day", y="total_bill")
```

Just counts (like a count of rows per category):

```python
sns.countplot(data=tips, x="day")
```

### Heatmap - `heatmap`

Great for correlation matrices:

```python
# correlation between numeric columns
corr = tips.select_dtypes(include="number").corr()
sns.heatmap(corr, annot=True, cmap="coolwarm", fmt=".2f")
```

`annot=True` writes the values in cells. `fmt=".2f"` formats them.

### Pair plot - `pairplot`

Plot every numeric variable against every other (quick exploration):

```python
sns.pairplot(iris)
sns.pairplot(iris, hue="species")    # color by category
```

This is one of seaborn's killer features. Use it whenever you're exploring a new dataset.

### Joint plot - `jointplot`

Scatter plot plus histograms on the margins:

```python
sns.jointplot(data=tips, x="total_bill", y="tip", kind="scatter")
sns.jointplot(data=tips, x="total_bill", y="tip", kind="reg")    # with regression line
sns.jointplot(data=tips, x="total_bill", y="tip", kind="hex")    # hexbin density
```

### Regression plot - `regplot`

Scatter plot with a regression line:

```python
sns.regplot(data=tips, x="total_bill", y="tip")
```

For multiple groups, use `lmplot`:

```python
sns.lmplot(data=tips, x="total_bill", y="tip", hue="smoker")
```

## 5. Customization

### Set the style

```python
sns.set_style("whitegrid")    # white background with grid
sns.set_style("darkgrid")      # dark background with grid
sns.set_style("white")
sns.set_style("dark")
sns.set_style("ticks")
```

### Set the context (sizing for slides, paper, etc.)

```python
sns.set_context("paper")     # small
sns.set_context("notebook")  # default
sns.set_context("talk")      # bigger
sns.set_context("poster")    # biggest
```

### Color palettes

```python
sns.set_palette("pastel")
sns.set_palette("dark")
sns.set_palette("colorblind")    # accessible

# specific palettes
sns.scatterplot(data=tips, x="total_bill", y="tip", hue="day",
                palette="viridis")
```

Common palettes: `deep`, `muted`, `bright`, `pastel`, `dark`, `colorblind`, `viridis`, `plasma`, `coolwarm`, `mako`.

### Size and aspect

```python
sns.scatterplot(data=tips, x="total_bill", y="tip")
plt.figure(figsize=(10, 6))    # set figure size

# or for sns plots that return a Figure (like jointplot)
g = sns.jointplot(data=tips, x="total_bill", y="tip", height=8)
```

### Labels and title

Seaborn returns matplotlib objects, so you customize with matplotlib:

```python
ax = sns.scatterplot(data=tips, x="total_bill", y="tip")
ax.set_title("Tips vs Total Bill")
ax.set_xlabel("Total Bill ($)")
ax.set_ylabel("Tip ($)")
plt.show()
```

## 6. Faceting - small multiples

### `FacetGrid` - grid of plots, one per category

```python
g = sns.FacetGrid(tips, col="time", row="sex", height=4)
g.map(sns.scatterplot, "total_bill", "tip")
```

This creates a 2x2 grid: rows by sex, columns by time of day.

### Quick faceting with `catplot` or `relplot`

```python
sns.relplot(data=tips, x="total_bill", y="tip",
            col="time", row="sex", kind="scatter")

sns.catplot(data=tips, x="day", y="total_bill",
            kind="box", col="sex")
```

`relplot` is for relational plots (scatter, line). `catplot` is for categorical plots (box, violin, bar, etc.).

## 7. Common Patterns

### Quick exploration of a DataFrame

```python
import seaborn as sns
import pandas as pd

df = pd.read_csv("data.csv")

# 1. Distributions of each numeric column
df.hist(bins=30, figsize=(12, 8))
plt.tight_layout()
plt.show()

# 2. Correlations between numeric columns
corr = df.select_dtypes(include="number").corr()
sns.heatmap(corr, annot=True, cmap="coolwarm")
plt.show()

# 3. Pairwise relationships
sns.pairplot(df, hue="target_column")
plt.show()

# 4. Box plot per category
sns.boxplot(data=df, x="category", y="value")
plt.show()
```

### Comparison by category

```python
sns.boxplot(data=df, x="group", y="metric", hue="subgroup")
plt.title("Metric by Group and Subgroup")
plt.show()
```

### Time series visualization

```python
df["date"] = pd.to_datetime(df["date"])
sns.lineplot(data=df, x="date", y="value", hue="category")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

### Correlation matrix nicely

```python
corr = df.select_dtypes(include="number").corr()

mask = np.triu(np.ones_like(corr, dtype=bool))    # mask upper triangle
sns.heatmap(corr, mask=mask, annot=True, cmap="coolwarm",
            vmin=-1, vmax=1, center=0, fmt=".2f")
```

The mask hides the redundant upper triangle (since correlation matrices are symmetric).

### Distribution comparison

```python
sns.kdeplot(data=tips, x="total_bill", hue="time", fill=True)
```

Smoothed density curves are great for comparing distributions.

## 8. Seaborn vs Matplotlib

When should you use which?

| Task | Use |
|---|---|
| Quick statistical plot from DataFrame | seaborn |
| Histograms, box plots, scatter with categories | seaborn |
| Heatmap, pair plot | seaborn |
| Complete custom control over every element | matplotlib |
| Non-statistical plots (gauges, dashboards) | matplotlib |
| Combining many subplots in one figure | matplotlib (with sns plots inside axes) |

You'll usually use both. Common pattern: build the plot with seaborn, then customize with matplotlib functions.

```python
fig, ax = plt.subplots(figsize=(10, 6))
sns.scatterplot(data=tips, x="total_bill", y="tip", hue="time", ax=ax)
ax.set_title("Tips Analysis")
ax.set_xlabel("Total Bill ($)")
ax.set_ylabel("Tip ($)")
ax.axhline(y=tips["tip"].mean(), color="red", linestyle="--", label="Mean")
ax.legend()
plt.tight_layout()
plt.savefig("tips.png", dpi=300)
plt.show()
```

## 9. Common Mistakes

### Mistake 1: not using `data=df`

```python
# old style (still works but verbose)
sns.scatterplot(x=df["total_bill"], y=df["tip"])

# preferred
sns.scatterplot(data=df, x="total_bill", y="tip")
```

The `data=df, x="col", y="col"` form is cleaner and lets you use `hue=`, `size=`, etc.

### Mistake 2: too many categories with `hue`

```python
# if a column has 50 categories, hue makes a 50-color rainbow - hard to read
sns.scatterplot(data=df, x="x", y="y", hue="user_id")    # 50 colors!
```

Group small categories together or pick a different visualization.

### Mistake 3: missing `plt.show()` or `plt.tight_layout()`

```python
sns.boxplot(...)
# labels might be cut off or plot not shown
```

```python
sns.boxplot(...)
plt.tight_layout()
plt.show()
```

### Mistake 4: forgetting to import matplotlib

```python
import seaborn as sns        # not enough alone
# need:
import matplotlib.pyplot as plt
```

You'll need `plt.show()`, `plt.savefig()`, `plt.tight_layout()`, etc.

### Mistake 5: heavy plots on huge data

```python
# 1M points scatter plot - slow and unreadable
sns.scatterplot(data=huge_df, x="a", y="b")
```

For large data:
- Sample first: `df.sample(1000)`
- Use hexbin or 2D density instead of scatter
- Use `alpha=0.1` to see density through transparency

## 10. Quick Reference

```python
import seaborn as sns
import matplotlib.pyplot as plt

# distributions
sns.histplot(data=df, x="col")
sns.kdeplot(data=df, x="col")
sns.boxplot(data=df, x="cat", y="num")
sns.violinplot(data=df, x="cat", y="num")

# relationships
sns.scatterplot(data=df, x="a", y="b", hue="cat")
sns.lineplot(data=df, x="time", y="val", hue="cat")
sns.regplot(data=df, x="a", y="b")

# categorical
sns.barplot(data=df, x="cat", y="num")
sns.countplot(data=df, x="cat")

# multi-variable
sns.pairplot(df, hue="target")
sns.heatmap(df.corr(), annot=True, cmap="coolwarm")

# faceting
sns.relplot(data=df, x="a", y="b", col="cat", row="other_cat")
sns.catplot(data=df, x="cat", y="val", kind="box", col="group")

# style
sns.set_style("whitegrid")
sns.set_context("notebook")
sns.set_palette("colorblind")
```

## Summary

- Seaborn is built on matplotlib and made for statistical plots
- Pass DataFrame with `data=df`, columns by name with `x=`, `y=`
- `hue=` for color by category, `style=` for marker shape, `size=` for size
- Plot types: `histplot`, `boxplot`, `violinplot`, `scatterplot`, `lineplot`, `barplot`, `countplot`, `heatmap`, `pairplot`, `jointplot`
- Seaborn returns matplotlib axes/figures - customize further with plt
- Use seaborn for quick statistical plots, matplotlib for full custom control

Next: [SciPy](./25-scipy.md) - scientific computing functions including statistics.
