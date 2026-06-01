# 21. NumPy

**NumPy** (Numerical Python) is the foundation of the entire scientific Python ecosystem. Pandas, scikit-learn, TensorFlow, PyTorch - they all build on NumPy arrays.

The core thing NumPy gives you: **fast, efficient arrays of numbers** with vectorized operations.

## 1. Why NumPy?

You already know Python lists. Why do we need NumPy?

```python
# pure Python
nums = [1, 2, 3, 4, 5]
squared = [n * n for n in nums]
print(squared)               # [1, 4, 9, 16, 25]

# NumPy
import numpy as np
nums = np.array([1, 2, 3, 4, 5])
squared = nums ** 2
print(squared)               # [ 1  4  9 16 25]
```

The NumPy version is:
- **Shorter**: `nums ** 2` instead of a list comprehension
- **Faster**: 10-100x faster for large arrays (uses optimized C code under the hood)
- **More memory-efficient**: numbers stored compactly
- **Multi-dimensional**: supports 2D, 3D, etc.

For numerical work on more than a few hundred items, NumPy is the way.

## 2. Installation and Import

```bash
pip install numpy
# or with conda
conda install numpy
```

Always imported as `np` by convention:

```python
import numpy as np
```

## 3. Creating Arrays

### From a list

```python
import numpy as np

a = np.array([1, 2, 3, 4, 5])
print(a)                  # [1 2 3 4 5]
print(type(a))            # <class 'numpy.ndarray'>
```

### From nested lists (2D array)

```python
m = np.array([[1, 2, 3], [4, 5, 6]])
print(m)
# [[1 2 3]
#  [4 5 6]]
print(m.shape)            # (2, 3)  - 2 rows, 3 columns
```

### Pre-filled arrays

```python
np.zeros(5)               # [0. 0. 0. 0. 0.]
np.zeros((3, 4))          # 3x4 array of zeros
np.ones((2, 3))           # 2x3 array of ones
np.full((2, 2), 7)        # 2x2 array filled with 7
np.eye(3)                  # 3x3 identity matrix
```

### Range arrays

```python
np.arange(10)             # [0 1 2 3 4 5 6 7 8 9]    like range()
np.arange(2, 10, 2)       # [2 4 6 8]
np.linspace(0, 1, 5)      # [0.  0.25  0.5  0.75  1. ]  - 5 evenly spaced
```

### Random arrays

```python
np.random.rand(5)              # 5 random floats in [0, 1)
np.random.rand(3, 3)            # 3x3 random floats
np.random.randn(5)              # 5 normal-distributed floats
np.random.randint(0, 10, 5)     # 5 random ints in [0, 10)
np.random.choice([1, 2, 3], 10) # 10 random choices from the list

# reproducible: set the seed
np.random.seed(42)
np.random.rand(3)         # always returns the same numbers
```

## 4. Array Attributes

```python
a = np.array([[1, 2, 3], [4, 5, 6]])

print(a.shape)            # (2, 3)   - dimensions
print(a.size)             # 6        - total elements
print(a.ndim)             # 2        - number of dimensions
print(a.dtype)            # int64    - data type of elements
```

NumPy arrays have a **single data type** across all elements. This is what makes them fast.

### Data types

```python
np.array([1, 2, 3]).dtype           # int64
np.array([1.0, 2.0]).dtype          # float64
np.array([True, False]).dtype       # bool
np.array(["a", "b"]).dtype          # <U1

# specify the type
np.array([1, 2, 3], dtype=np.float64)
np.array([1.5, 2.5], dtype=np.int32)    # truncates to [1, 2]

# convert types
a = np.array([1.5, 2.5, 3.5])
a.astype(int)                       # array([1, 2, 3])
```

## 5. Indexing and Slicing

Just like lists, but extended for multi-dimensional arrays.

### 1D

```python
a = np.array([10, 20, 30, 40, 50])

print(a[0])              # 10
print(a[-1])             # 50
print(a[1:4])            # [20 30 40]
print(a[::-1])           # [50 40 30 20 10]
```

### 2D - row, column

```python
m = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

print(m[0])              # [1 2 3]      first row
print(m[1, 2])           # 6            row 1, column 2
print(m[:, 0])           # [1 4 7]      first column
print(m[1, :])           # [4 5 6]      second row (same as m[1])
print(m[0:2, 1:3])       # [[2 3] [5 6]]  sub-matrix
```

The syntax is `m[row_selector, column_selector]`. Each can be an index, slice, or list.

### Boolean indexing

```python
a = np.array([1, 2, 3, 4, 5, 6])

mask = a > 3
print(mask)              # [False False False  True  True  True]
print(a[mask])           # [4 5 6]

# or directly
print(a[a > 3])          # [4 5 6]
print(a[a % 2 == 0])     # [2 4 6]
```

This is **massively useful** for filtering data.

### Modify with boolean indexing

```python
a = np.array([1, 2, 3, 4, 5])
a[a > 3] = 0
print(a)                 # [1 2 3 0 0]
```

## 6. Vectorized Operations

The killer feature of NumPy: do math on entire arrays at once, no loops.

### Element-wise math

```python
a = np.array([1, 2, 3, 4])
b = np.array([10, 20, 30, 40])

print(a + b)             # [11 22 33 44]
print(b - a)             # [ 9 18 27 36]
print(a * b)             # [10 40 90 160]
print(b / a)             # [10. 10. 10. 10.]
print(a ** 2)            # [ 1  4  9 16]

# scalar with array
print(a + 100)           # [101 102 103 104]
print(a * 5)             # [ 5 10 15 20]
```

### Comparison operations

```python
a = np.array([1, 2, 3, 4, 5])

print(a > 3)             # [False False False  True  True]
print(a == 3)            # [False False  True False False]
```

### Math functions

```python
a = np.array([1, 4, 9, 16, 25])

print(np.sqrt(a))        # [1. 2. 3. 4. 5.]
print(np.log(a))         # natural log
print(np.exp(a))         # e^a
print(np.sin(a))         # sine
```

## 7. Aggregate Functions

Compute summary statistics across an array:

```python
a = np.array([1, 2, 3, 4, 5])

print(a.sum())           # 15
print(a.mean())          # 3.0
print(a.median())        # ERROR - use np.median(a)
print(np.median(a))      # 3.0
print(a.min())           # 1
print(a.max())           # 5
print(a.std())           # 1.41 (standard deviation)
print(a.var())           # 2.0  (variance)
print(a.argmin())        # 0    (index of min)
print(a.argmax())        # 4    (index of max)
```

### 2D - across rows or columns

```python
m = np.array([[1, 2, 3], [4, 5, 6]])

print(m.sum())           # 21       (entire array)
print(m.sum(axis=0))     # [5 7 9]  (sum each column)
print(m.sum(axis=1))     # [6 15]   (sum each row)

print(m.mean(axis=0))    # column means
print(m.mean(axis=1))    # row means
```

Remember: **axis 0 is rows**, **axis 1 is columns**. `axis=0` collapses down rows (giving you one value per column).

## 8. Reshaping

```python
a = np.arange(12)
print(a)                 # [0 1 2 3 4 5 6 7 8 9 10 11]
print(a.shape)           # (12,)

m = a.reshape(3, 4)
print(m)
# [[ 0  1  2  3]
#  [ 4  5  6  7]
#  [ 8  9 10 11]]
print(m.shape)           # (3, 4)

# -1 means "figure it out"
a.reshape(2, -1)         # shape (2, 6)
a.reshape(-1, 3)         # shape (4, 3)

# flatten back to 1D
m.flatten()              # [0 1 2 ... 11]
m.ravel()                # similar, but returns a view (faster)
```

The total number of elements must stay the same.

### Transpose

```python
m = np.array([[1, 2, 3], [4, 5, 6]])
print(m.T)
# [[1 4]
#  [2 5]
#  [3 6]]
```

`.T` swaps rows and columns.

## 9. Broadcasting

NumPy can do math between arrays of different shapes by "broadcasting" the smaller one. This is hugely useful but takes a minute to wrap your head around.

### Simple case: scalar + array

```python
a = np.array([1, 2, 3])
print(a + 10)            # [11 12 13]
```

The `10` is "broadcast" to each element.

### 1D + 2D

```python
m = np.array([[1, 2, 3], [4, 5, 6]])
v = np.array([10, 20, 30])

print(m + v)
# [[11 22 33]
#  [14 25 36]]
```

The 1D array (length 3) gets broadcast across each row.

### Column vector + matrix

```python
m = np.array([[1, 2, 3], [4, 5, 6]])
v = np.array([[100], [200]])    # column vector, shape (2,1)

print(m + v)
# [[101 102 103]
#  [204 205 206]]
```

### Broadcasting rules

Two arrays are compatible for broadcasting if, for each dimension, the sizes are either equal OR one of them is 1.

```python
(3, 4) + (4,)    # OK: (4,) becomes (1, 4), broadcast to (3, 4)
(3, 4) + (3, 1)  # OK: column broadcast across columns
(3, 4) + (3,)    # ERROR: shapes don't align
```

If broadcasting confuses you, just check with `.shape` and try it out.

## 10. Common Patterns in Data Work

### Normalize values to 0-1 range

```python
data = np.array([10, 20, 30, 40, 50])
normalized = (data - data.min()) / (data.max() - data.min())
print(normalized)        # [0.  0.25 0.5  0.75 1. ]
```

### Standardize (z-score)

```python
data = np.array([10, 20, 30, 40, 50])
z = (data - data.mean()) / data.std()
print(z)
```

### Filter values

```python
data = np.array([3, 1, 4, 1, 5, 9, 2, 6, 5])
print(data[data > 4])    # [5 9 6 5]
```

### Count matching values

```python
data = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
count = (data > 5).sum()    # True is 1, False is 0
print(count)             # 4
```

### Replace values

```python
data = np.array([1, -2, 3, -4, 5])
data[data < 0] = 0       # replace negatives with 0
print(data)              # [1 0 3 0 5]
```

### Generate dummy data

```python
# 100 random normal values
data = np.random.randn(100)

# 100 random integers 0-9
labels = np.random.randint(0, 10, 100)

# random 5x3 matrix
matrix = np.random.rand(5, 3)
```

## 11. Useful Functions Reference

### Creation
```python
np.array(list)
np.zeros(shape), np.ones(shape), np.full(shape, value)
np.arange(start, stop, step)
np.linspace(start, stop, num)
np.eye(n)                          # identity matrix
np.random.rand(shape)              # uniform [0, 1)
np.random.randn(shape)             # standard normal
np.random.randint(low, high, size)
```

### Math (element-wise)
```python
np.sqrt(a), np.log(a), np.exp(a)
np.sin(a), np.cos(a), np.tan(a)
np.abs(a), np.round(a)
np.power(a, b)                     # a ** b
```

### Reduction (across axis or all)
```python
np.sum(a), np.mean(a), np.median(a)
np.min(a), np.max(a)
np.std(a), np.var(a)
np.argmin(a), np.argmax(a)
np.cumsum(a), np.cumprod(a)
np.unique(a)
```

### Manipulation
```python
np.reshape(a, shape)
np.transpose(a) or a.T
np.concatenate([a, b])
np.stack([a, b])
np.split(a, n)
np.sort(a)
np.where(condition, x, y)          # vectorized if/else
```

### `np.where` - vectorized conditional

```python
a = np.array([1, 2, 3, 4, 5])
result = np.where(a > 3, "high", "low")
print(result)            # ['low' 'low' 'low' 'high' 'high']
```

Like an if/else for each element.

## 12. Common Mistakes

### Mistake 1: confusing `*` (element-wise) with `@` (matrix multiplication)

```python
a = np.array([[1, 2], [3, 4]])
b = np.array([[5, 6], [7, 8]])

print(a * b)             # element-wise:   [[5 12] [21 32]]
print(a @ b)             # matrix multiply: [[19 22] [43 50]]
print(a.dot(b))          # same as @
```

For real matrix math, use `@` (or `.dot()`).

### Mistake 2: forgetting axis=0 vs axis=1

```python
m = np.array([[1, 2, 3], [4, 5, 6]])
m.sum(axis=0)            # [5 7 9]    - sum each column
m.sum(axis=1)            # [6 15]     - sum each row
```

Trick: axis=0 reduces the FIRST dimension (rows), so you get a result the shape of the second dimension.

### Mistake 3: modifying a view, not a copy

```python
a = np.array([1, 2, 3, 4, 5])
b = a[1:3]               # this is a VIEW, not a copy
b[0] = 99
print(a)                 # [1 99 3 4 5]    surprise! changed!

# explicit copy
b = a[1:3].copy()
b[0] = 99
print(a)                 # [1 2 3 4 5]   unchanged
```

Slicing returns a view that shares memory. Use `.copy()` if you need independence.

### Mistake 4: shape errors

```python
a = np.array([1, 2, 3])
b = np.array([[1, 2, 3], [4, 5, 6]])
a + b                    # works due to broadcasting

c = np.array([1, 2])
a + c                    # ValueError: shapes mismatch
```

Check `.shape` when you get broadcasting errors.

### Mistake 5: treating NumPy arrays exactly like lists

```python
a = np.array([1, 2, 3])
a.append(4)              # AttributeError - no append!
```

Use `np.append(a, 4)` but note this creates a NEW array. NumPy isn't designed for growing dynamically. If you need that, use a list and convert later.

## Summary

- `import numpy as np`
- `np.array(list)` creates an array
- Arrays support fast element-wise operations: `a + b`, `a * 2`, `np.sqrt(a)`
- Multi-dimensional: `m[row, col]`, `m[row, :]`, `m[:, col]`
- Reshape with `.reshape(rows, cols)`
- Boolean indexing for filtering: `a[a > 0]`
- Aggregates: `.sum()`, `.mean()`, `.max()`, etc. with optional `axis` parameter
- Broadcasting lets arrays of different shapes work together
- NumPy is the foundation - pandas, scikit-learn, etc. all use it internally

Next: [Pandas](./22-pandas.md) - tabular data manipulation, the workhorse of data analysis.
