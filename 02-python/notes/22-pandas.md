# 22. Pandas

**Pandas** is the most-used Python library for working with tabular data. If your data fits in a spreadsheet, pandas is what you'll use to analyze it.

Pandas wraps NumPy with labeled rows and columns plus tons of convenience methods. Think of it as Excel inside Python, but vastly more powerful.

## 1. Why Pandas?

Without pandas, working with tables in Python is awkward:

```python
# pure Python - awkward
data = [
    {"name": "Aaron", "age": 25, "salary": 60000},
    {"name": "Bea",   "age": 30, "salary": 75000},
    {"name": "Carl",  "age": 35, "salary": 80000},
]

# average salary
total = 0
for row in data:
    total += row["salary"]
avg = total / len(data)
```

With pandas:

```python
import pandas as pd

df = pd.DataFrame(data)
print(df["salary"].mean())   # 71666.67
```

Plus pandas can read/write CSVs, Excel, SQL, JSON, parquet; filter, group, join, pivot, time-series operations, and on and on.

## 2. Installation and Import

```bash
pip install pandas
```

Standard import:

```python
import pandas as pd
```

## 3. The Two Main Objects

### Series - a 1D labeled array

```python
import pandas as pd

s = pd.Series([10, 20, 30, 40])
print(s)
# 0    10
# 1    20
# 2    30
# 3    40
# dtype: int64

# with custom labels (index)
s = pd.Series([10, 20, 30], index=["a", "b", "c"])
print(s["b"])             # 20
print(s.values)            # [10 20 30]    (the data, like a NumPy array)
print(s.index)             # Index(['a', 'b', 'c'])    (the labels)
```

A Series is essentially one column of data with row labels.

### DataFrame - a 2D table

```python
data = {
    "name": ["Aaron", "Bea", "Carl"],
    "age": [25, 30, 35],
    "salary": [60000, 75000, 80000]
}
df = pd.DataFrame(data)
print(df)
#     name  age  salary
# 0  Aaron   25   60000
# 1    Bea   30   75000
# 2   Carl   35   80000
```

A DataFrame is like a dict of Series (each column is a Series). Each row has an index (default: 0, 1, 2, ...).

## 4. Creating DataFrames

### From a dict

```python
df = pd.DataFrame({
    "name": ["Aaron", "Bea", "Carl"],
    "age":  [25, 30, 35]
})
```

### From a list of dicts (records)

```python
records = [
    {"name": "Aaron", "age": 25},
    {"name": "Bea",   "age": 30},
]
df = pd.DataFrame(records)
```

### From a list of lists with column names

```python
data = [["Aaron", 25], ["Bea", 30]]
df = pd.DataFrame(data, columns=["name", "age"])
```

### From a CSV file (most common in practice)

```python
df = pd.read_csv("data.csv")
```

## 5. Reading and Writing Files

### CSV

```python
# read
df = pd.read_csv("data.csv")
df = pd.read_csv("data.csv", sep=";")             # custom separator
df = pd.read_csv("data.csv", header=None)         # no header row
df = pd.read_csv("data.csv", nrows=100)           # only first 100 rows
df = pd.read_csv("data.csv", usecols=["a", "b"])  # only specific columns
df = pd.read_csv("data.csv", parse_dates=["date"]) # parse a column as dates

# write
df.to_csv("out.csv", index=False)    # don't write the row index
```

### Excel

```python
df = pd.read_excel("data.xlsx", sheet_name="Sheet1")
df.to_excel("out.xlsx", index=False)
```

(Requires `openpyxl`: `pip install openpyxl`)

### JSON

```python
df = pd.read_json("data.json")
df.to_json("out.json", orient="records", indent=2)
```

### From a database

```python
import sqlite3
conn = sqlite3.connect("my.db")
df = pd.read_sql("SELECT * FROM customers", conn)
df.to_sql("new_table", conn, if_exists="replace")
```

## 6. Inspecting Data

After loading, ALWAYS explore the data first.

```python
df.head()                # first 5 rows
df.head(10)              # first 10 rows
df.tail()                # last 5 rows

df.shape                 # (rows, columns)
df.info()                # column types and missing values
df.describe()            # statistical summary of numeric columns
df.dtypes                # data type of each column
df.columns               # list of column names
df.index                 # the row index
```

Most useful first thing to do with any new data:

```python
print(df.shape)           # how big?
print(df.head())          # what does it look like?
print(df.info())          # what types? any nulls?
print(df.describe())      # what's the distribution?
```

## 7. Selecting Columns

```python
df["name"]               # one column - returns a Series
df[["name", "age"]]      # multiple columns - returns a DataFrame (note double brackets!)
```

### Dot notation (works for valid Python names only)

```python
df.name                  # works
df.age                   # works
# df.column with space   # doesn't work, use df["column with space"]
```

Stick with `df["col"]` for consistency.

## 8. Selecting Rows

### `.loc` - by label/index

```python
df.loc[0]                # row with index label 0
df.loc[0:2]              # rows 0 through 2 (INCLUSIVE both ends!)
df.loc[[0, 2, 4]]        # specific rows
```

### `.iloc` - by integer position (always 0-based)

```python
df.iloc[0]               # first row
df.iloc[0:3]             # first 3 rows (exclusive end, like normal Python)
df.iloc[-1]              # last row
df.iloc[[0, 2, 4]]       # specific rows
```

### Both rows AND columns

```python
df.loc[0, "name"]           # value at row 0, column 'name'
df.loc[0:2, ["name", "age"]]
df.iloc[0:3, 0:2]            # first 3 rows, first 2 columns
```

## 9. Filtering with Boolean Indexing

```python
df[df["age"] > 30]                 # rows where age > 30
df[df["name"] == "Aaron"]
df[df["salary"].between(60000, 80000)]
df[df["name"].isin(["Aaron", "Bea"])]
df[df["name"].str.startswith("A")]
df[df["age"].isna()]               # rows with missing age
```

### Multiple conditions

Use `&` (and), `|` (or), `~` (not). Each condition in parens.

```python
df[(df["age"] > 25) & (df["salary"] > 70000)]
df[(df["name"] == "Aaron") | (df["age"] > 30)]
df[~(df["age"] > 30)]               # NOT older than 30
```

`and` / `or` / `not` don't work here (they're for plain booleans). Use the symbols.

## 10. Adding and Modifying Columns

```python
# new column
df["bonus"] = df["salary"] * 0.1

# from a calculation
df["age_in_5_years"] = df["age"] + 5

# conditional
df["senior"] = df["age"] > 30

# from a function
df["name_length"] = df["name"].apply(len)
df["name_upper"] = df["name"].str.upper()
```

### Modify existing column

```python
df["salary"] = df["salary"] * 1.05    # 5% raise for everyone
```

### Delete a column

```python
df = df.drop("bonus", axis=1)
# or in place
df.drop("bonus", axis=1, inplace=True)
```

## 11. Sorting

```python
df.sort_values("age")                 # ascending
df.sort_values("age", ascending=False)
df.sort_values(["age", "salary"])     # multi-column sort
df.sort_index()                        # sort by row index
```

## 12. Missing Data

NaN (Not a Number) represents missing data in pandas.

```python
df.isna()                # boolean DataFrame: True where missing
df.isna().sum()          # count missing per column
df.dropna()              # drop rows with any missing
df.dropna(subset=["age"])  # only drop if 'age' is missing
df.fillna(0)             # fill missing with 0
df["age"].fillna(df["age"].mean())   # fill with mean
df.fillna(method="ffill")   # forward-fill (use previous value)
```

A common workflow:

```python
# check what's missing
print(df.isna().sum())

# drop columns mostly empty
df = df.dropna(thresh=len(df)*0.5, axis=1)

# fill remaining with sensible defaults
df["age"] = df["age"].fillna(df["age"].median())
df["category"] = df["category"].fillna("Unknown")
```

## 13. GroupBy - the powerhouse

GroupBy splits data by some key, applies a function, and combines the results. Equivalent to SQL's GROUP BY.

```python
# total salary per department
df.groupby("department")["salary"].sum()

# multiple aggregations
df.groupby("department")["salary"].agg(["sum", "mean", "max"])

# group by multiple columns
df.groupby(["department", "level"])["salary"].mean()

# multiple columns, multiple aggregations
df.groupby("department").agg({
    "salary": ["mean", "max"],
    "age":    "mean",
    "name":   "count"
})
```

### `.size()` vs `.count()`

```python
df.groupby("dept").size()        # rows per group (including NaN)
df.groupby("dept").count()        # count non-null per column
```

### Iterate through groups (rare but useful)

```python
for name, group in df.groupby("department"):
    print(f"--- {name} ---")
    print(group.head())
```

### Aggregate then ungroup

```python
df.groupby("dept")["salary"].mean().reset_index()
# returns a regular DataFrame instead of grouped Series
```

## 14. Merging and Joining

Like SQL JOINs.

```python
users = pd.DataFrame({"id": [1, 2, 3], "name": ["A", "B", "C"]})
orders = pd.DataFrame({"user_id": [1, 1, 2], "amount": [100, 200, 300]})

# inner join (default)
pd.merge(users, orders, left_on="id", right_on="user_id")

# left/right/outer
pd.merge(users, orders, left_on="id", right_on="user_id", how="left")
pd.merge(users, orders, left_on="id", right_on="user_id", how="right")
pd.merge(users, orders, left_on="id", right_on="user_id", how="outer")

# if column names match, simpler
pd.merge(users, orders, on="id")    # only if 'id' is in both
```

### Concatenation (stacking)

```python
# stack vertically (same columns)
combined = pd.concat([df1, df2])

# stack horizontally (same rows)
combined = pd.concat([df1, df2], axis=1)
```

## 15. Apply - run a function on data

```python
# apply to a Series (column)
df["name_length"] = df["name"].apply(len)

# apply with lambda
df["category"] = df["age"].apply(lambda x: "senior" if x > 60 else "junior")

# apply to entire row (axis=1)
df["full_name"] = df.apply(lambda row: f"{row['first']} {row['last']}", axis=1)
```

`.apply()` is flexible but slower than built-in vectorized methods. Prefer:

```python
# slow
df["upper_name"] = df["name"].apply(lambda x: x.upper())

# fast
df["upper_name"] = df["name"].str.upper()
```

## 16. Working with Strings - `.str` accessor

```python
df["name"].str.upper()
df["name"].str.lower()
df["name"].str.contains("aar", case=False)
df["name"].str.startswith("A")
df["name"].str.replace("aaron", "AARON")
df["email"].str.split("@").str[1]    # get domain
df["text"].str.len()                  # length of each string
```

These work just like Python string methods, but vectorized across the column.

## 17. Working with Dates - `.dt` accessor

If a column is a datetime, use `.dt`:

```python
df["date"] = pd.to_datetime(df["date"])

df["year"] = df["date"].dt.year
df["month"] = df["date"].dt.month
df["day"] = df["date"].dt.day
df["weekday"] = df["date"].dt.dayofweek
df["weekday_name"] = df["date"].dt.day_name()

# filter by date
df[df["date"] >= "2024-01-01"]
df[df["date"].dt.year == 2024]
```

## 18. Common Patterns

### Quick data check after loading

```python
df = pd.read_csv("data.csv")
print(df.shape)
print(df.dtypes)
print(df.head())
print(df.isna().sum())
print(df.describe())
```

### Counting unique values in a column

```python
df["category"].value_counts()        # counts per category, sorted
df["category"].nunique()              # number of distinct values
df["category"].unique()               # array of unique values
```

### Pivot tables (Excel-style)

```python
df.pivot_table(
    values="sales",
    index="region",
    columns="year",
    aggfunc="sum"
)
```

### Top N rows by some column

```python
df.nlargest(5, "salary")    # top 5 by salary
df.nsmallest(5, "age")      # bottom 5 by age
```

### Quick stats by group

```python
df.groupby("department")["salary"].describe()
# count, mean, std, min, 25%, 50%, 75%, max
```

### Save common workflow

```python
df = pd.read_csv("input.csv")
df = df.dropna(subset=["important_col"])
df["new_col"] = df["a"] + df["b"]
result = df.groupby("category")["new_col"].mean()
result.to_csv("output.csv")
```

## 19. Common Mistakes

### Mistake 1: SettingWithCopyWarning

```python
filtered = df[df["age"] > 30]
filtered["new_col"] = 100         # SettingWithCopyWarning
```

Use `.copy()` to be explicit:

```python
filtered = df[df["age"] > 30].copy()
filtered["new_col"] = 100         # no warning
```

### Mistake 2: `and`/`or` in filter conditions

```python
df[(df["a"] > 0) and (df["b"] < 10)]    # ERROR
df[(df["a"] > 0) & (df["b"] < 10)]      # CORRECT
```

Always use `&`, `|`, `~` with parens around each condition.

### Mistake 3: confusing `.loc` and `.iloc`

```python
df.loc[5]      # row with INDEX LABEL 5
df.iloc[5]     # 6th row (position-based)
```

If the index is 0, 1, 2, ... they're the same. Once you have a custom index, they differ.

### Mistake 4: forgetting to assign back

```python
df.dropna()                  # creates a new dropped df, doesn't modify original
print(df.isna().sum())       # still has NaN!

df = df.dropna()             # actually update df
# or
df.dropna(inplace=True)
```

### Mistake 5: huge memory usage

For big files, read in chunks:

```python
for chunk in pd.read_csv("huge.csv", chunksize=10000):
    process(chunk)
```

## Summary

- `import pandas as pd`
- `Series` is 1D labeled, `DataFrame` is 2D labeled
- `pd.read_csv()` for loading data
- `df.head()`, `.info()`, `.describe()` for inspection
- Select columns: `df["col"]`, `df[["a", "b"]]`
- Select rows: `.loc[label]`, `.iloc[position]`
- Filter: `df[df["col"] > value]`
- Combine conditions with `&`, `|`, `~` and parens
- New columns: `df["new"] = ...`
- Missing data: `.isna()`, `.dropna()`, `.fillna()`
- `groupby()` for aggregation by category
- `merge()` for SQL-like joins
- `.apply()` for custom functions
- `.str` and `.dt` accessors for strings and dates

Pandas has hundreds more methods. The 20% covered here gets you 80% of the way. Look up specific operations as you need them.

Next: [Matplotlib](./23-matplotlib.md) - making plots.
