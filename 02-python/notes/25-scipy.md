# 25. SciPy

**SciPy** (Scientific Python) is a library that builds on NumPy and provides advanced scientific computing tools: statistics, optimization, signal processing, linear algebra, distance metrics, and more.

For data science work, the most important submodule is `scipy.stats`. The rest you'll dip into as needed.

## 1. Setup

```bash
pip install scipy
```

```python
import scipy
from scipy import stats        # most common
from scipy import optimize
from scipy.spatial import distance
```

You usually import specific submodules rather than `scipy` itself.

## 2. SciPy vs NumPy

A common question: do I use NumPy or SciPy?

| NumPy | SciPy |
|---|---|
| The array (`ndarray`) | Specialized algorithms |
| Basic math (sum, mean, std, dot) | Statistical tests, distributions |
| Basic linear algebra | Advanced linear algebra |
| Element-wise operations | Optimization, integration, interpolation |

Rule of thumb: if it's basic, NumPy has it. For statistics, hypothesis testing, specialized math, you go to SciPy.

## 3. The Submodules

SciPy has many submodules. You'll mostly use:

| Submodule | What it does |
|---|---|
| `scipy.stats` | Statistics: distributions, tests, descriptive stats |
| `scipy.optimize` | Optimization: finding minima, curve fitting |
| `scipy.spatial.distance` | Distance metrics between points |
| `scipy.linalg` | Linear algebra beyond NumPy |
| `scipy.interpolate` | Interpolating between known values |
| `scipy.signal` | Signal processing (filters, FFT) |
| `scipy.sparse` | Sparse matrices |

We'll focus on the first few, which are most relevant for data science.

## 4. `scipy.stats` - Statistics

This is THE module you'll use for statistics in Python. It has:
- Descriptive statistics
- Probability distributions (40+)
- Hypothesis tests
- Correlation measures

### Descriptive Statistics

NumPy has `.mean()`, `.std()`, etc. SciPy adds more nuanced stats:

```python
from scipy import stats
import numpy as np

data = np.array([1, 2, 2, 3, 3, 3, 4, 5, 5, 6, 100])

# basics (also available in NumPy)
print(np.mean(data))           # 12.18
print(np.median(data))         # 3.0
print(np.std(data))            # 28.34

# from SciPy
print(stats.mode(data))                # mode: most common value
print(stats.gmean(data))               # geometric mean
print(stats.hmean(data))               # harmonic mean
print(stats.trim_mean(data, 0.1))      # trimmed mean (drop 10% from each end)
print(stats.skew(data))                # skewness (asymmetry)
print(stats.kurtosis(data))            # kurtosis (tail heaviness)

# describe gives everything
print(stats.describe(data))
# DescribeResult(nobs=11, minmax=(1, 100), mean=12.18,
#                variance=903.36, skewness=2.81, kurtosis=6.93)
```

### Quartiles and Percentiles

```python
np.percentile(data, 25)        # 25th percentile (Q1)
np.percentile(data, 50)        # 50th percentile (median, Q2)
np.percentile(data, 75)        # 75th percentile (Q3)
np.percentile(data, [25, 50, 75])    # multiple at once

# interquartile range (IQR)
q3, q1 = np.percentile(data, [75, 25])
iqr = q3 - q1
```

## 5. Probability Distributions

SciPy has dozens of probability distributions, all with the same interface.

### Normal Distribution

```python
from scipy import stats

# create a distribution object (mean=0, std=1 by default)
norm = stats.norm

# probability density function (PDF) - height of the curve
print(norm.pdf(0))             # 0.399    peak of standard normal

# cumulative distribution function (CDF) - area to the left
print(norm.cdf(0))             # 0.5      half the area
print(norm.cdf(1.96))          # 0.975    95% to the left of 1.96

# inverse CDF (percent point function, ppf) - what value has X% to the left
print(norm.ppf(0.5))           # 0        the median
print(norm.ppf(0.975))         # 1.959... critical value for 95% confidence

# generate random samples
samples = norm.rvs(size=1000, random_state=42)
```

### With custom parameters

```python
# normal with mean=100, std=15 (like IQ scores)
iq = stats.norm(loc=100, scale=15)

# probability of IQ above 130
prob = 1 - iq.cdf(130)
print(f"{prob:.4f}")           # 0.0228    (about 2.3%)

# 90% confidence interval
print(iq.ppf([0.05, 0.95]))    # values containing the middle 90%
```

### Other common distributions

```python
# Uniform (between a and b)
stats.uniform(loc=0, scale=10)   # uniform from 0 to 10

# t-distribution (for small samples)
stats.t(df=10)

# chi-squared
stats.chi2(df=3)

# F-distribution
stats.f(dfn=5, dfd=10)

# binomial (n trials, probability p)
stats.binom(n=10, p=0.5)
binom = stats.binom(n=10, p=0.5)
print(binom.pmf(5))            # probability of exactly 5 successes
print(binom.cdf(5))            # probability of 5 or fewer

# Poisson
stats.poisson(mu=3)

# exponential
stats.expon(scale=2)
```

All distributions support `.pdf()` (or `.pmf()` for discrete), `.cdf()`, `.ppf()`, `.rvs()`, `.mean()`, `.std()`, etc.

## 6. Hypothesis Tests

This is where SciPy really shines for data analysis.

### t-test - compare means

```python
group_a = [10, 12, 14, 11, 13, 15, 12, 14]
group_b = [18, 20, 22, 19, 21, 23, 20, 22]

# independent samples t-test
t_stat, p_value = stats.ttest_ind(group_a, group_b)
print(f"t = {t_stat:.4f}, p = {p_value:.4f}")
# t = -10.7541, p = 0.0000

if p_value < 0.05:
    print("Significant difference between groups")
```

### Paired t-test (same subjects, before/after)

```python
before = [85, 90, 78, 92, 88]
after  = [89, 95, 82, 94, 91]
t_stat, p_value = stats.ttest_rel(before, after)
```

### One-sample t-test (compare a sample to a known mean)

```python
sample = [98, 102, 101, 99, 103]
t_stat, p_value = stats.ttest_1samp(sample, popmean=100)
```

### Chi-squared test (categorical data)

For testing if observed frequencies match expected:

```python
# survey: do people prefer A or B?  observed counts
observed = [60, 40]
expected = [50, 50]    # if no preference

chi2, p_value = stats.chisquare(observed, expected)
print(f"chi2 = {chi2:.4f}, p = {p_value:.4f}")
```

### Independence test for contingency tables

```python
# is there a relationship between two categorical variables?
table = [[10, 20, 30],
         [15, 25, 35]]
chi2, p_value, dof, expected = stats.chi2_contingency(table)
```

### Mann-Whitney U test (non-parametric alternative to t-test)

Use when data isn't normally distributed:

```python
u_stat, p_value = stats.mannwhitneyu(group_a, group_b)
```

### ANOVA - compare 3+ group means

```python
group_a = [10, 12, 14]
group_b = [15, 17, 18]
group_c = [11, 13, 15]
f_stat, p_value = stats.f_oneway(group_a, group_b, group_c)
```

### Shapiro-Wilk test (is data normal?)

```python
stat, p_value = stats.shapiro(data)
# if p > 0.05, data is consistent with being normally distributed
```

### Kolmogorov-Smirnov test (compare distributions)

```python
stat, p_value = stats.ks_2samp(sample1, sample2)
# tests if two samples come from the same distribution
```

### Interpreting p-values

The p-value is the probability of seeing the observed result (or more extreme) IF the null hypothesis (no effect) were true.

- `p < 0.05` → traditionally "statistically significant"
- `p > 0.05` → not enough evidence to reject the null

This is a simplification - read about p-values critically before relying on them.

## 7. Correlation

```python
x = [1, 2, 3, 4, 5]
y = [2, 4, 5, 4, 5]

# Pearson correlation (linear)
r, p = stats.pearsonr(x, y)
print(f"r = {r:.4f}, p = {p:.4f}")

# Spearman (rank-based, captures monotonic but not necessarily linear)
r, p = stats.spearmanr(x, y)

# Kendall's tau (another rank correlation)
r, p = stats.kendalltau(x, y)
```

For multiple variables, use pandas:

```python
df.corr()                    # pearson by default
df.corr(method="spearman")
df.corr(method="kendall")
```

## 8. Linear Regression

```python
x = [1, 2, 3, 4, 5]
y = [2.1, 3.9, 6.1, 8.0, 10.2]

slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
print(f"y = {slope:.4f} * x + {intercept:.4f}")
print(f"R² = {r_value**2:.4f}, p = {p_value:.4f}")

# predict new values
import numpy as np
x_new = np.array([6, 7, 8])
y_pred = slope * x_new + intercept
```

For more sophisticated regression, you'd use `scikit-learn` or `statsmodels` (covered in the ML folder).

## 9. `scipy.optimize` - Finding Minima and Curve Fitting

### Find the minimum of a function

```python
from scipy.optimize import minimize_scalar

# find x that minimizes (x - 3)^2
def f(x):
    return (x - 3) ** 2

result = minimize_scalar(f)
print(result.x)                # 3.0 (approximately)
print(result.fun)              # 0.0 (the minimum value)
```

### Multi-variable optimization

```python
from scipy.optimize import minimize

# minimize x^2 + y^2 + (z-1)^2
def f(params):
    x, y, z = params
    return x**2 + y**2 + (z - 1)**2

x0 = [0, 0, 0]    # initial guess
result = minimize(f, x0)
print(result.x)                # [0, 0, 1]
```

### Curve fitting

Fit a function to data points:

```python
from scipy.optimize import curve_fit
import numpy as np

# the function we want to fit
def model(x, a, b):
    return a * x + b

# noisy data
x = np.linspace(0, 10, 50)
y_true = 2 * x + 3
y_noisy = y_true + np.random.normal(0, 1, 50)

# fit
params, covariance = curve_fit(model, x, y_noisy)
a_fit, b_fit = params
print(f"a = {a_fit:.4f}, b = {b_fit:.4f}")    # should be near 2 and 3
```

This works for any function shape, not just linear:

```python
def exponential(x, a, b):
    return a * np.exp(b * x)

params, _ = curve_fit(exponential, x, y_data)
```

## 10. `scipy.spatial.distance` - Distances Between Points

Useful in clustering, nearest-neighbor algorithms, similarity:

```python
from scipy.spatial import distance

point_a = [1, 2, 3]
point_b = [4, 5, 6]

print(distance.euclidean(point_a, point_b))    # straight line distance
print(distance.cityblock(point_a, point_b))    # Manhattan (L1)
print(distance.chebyshev(point_a, point_b))    # max abs diff
print(distance.cosine(point_a, point_b))        # cosine distance (1 - similarity)
```

### Distance matrix for many points

```python
from scipy.spatial.distance import cdist, pdist, squareform

points = [[1, 2], [3, 4], [5, 6]]

# all pairwise distances
dist_matrix = cdist(points, points)
print(dist_matrix)
# [[0.         2.828      5.657]
#  [2.828      0.         2.828]
#  [5.657      2.828      0.   ]]

# more memory-efficient: condensed form
condensed = pdist(points)
square = squareform(condensed)    # convert back to full matrix
```

## 11. `scipy.linalg` - Linear Algebra Beyond NumPy

NumPy has basic linear algebra. SciPy adds:

```python
from scipy import linalg
import numpy as np

A = np.array([[1, 2], [3, 4]])

# determinant (numpy has this too)
print(linalg.det(A))           # -2.0

# inverse
print(linalg.inv(A))

# eigenvalues and eigenvectors
eigenvalues, eigenvectors = linalg.eig(A)

# solve linear system Ax = b
A = np.array([[3, 1], [1, 2]])
b = np.array([9, 8])
x = linalg.solve(A, b)
print(x)                        # [2. 3.]

# singular value decomposition (used in PCA, etc.)
U, s, Vt = linalg.svd(A)
```

For most basic linear algebra needs, `numpy.linalg` is enough. Use `scipy.linalg` when you need more advanced methods or better numerical stability.

## 12. Common Patterns

### Quick statistical summary

```python
from scipy import stats

def describe_data(data):
    return {
        "n":      len(data),
        "mean":   np.mean(data),
        "median": np.median(data),
        "std":    np.std(data),
        "skew":   stats.skew(data),
        "kurt":   stats.kurtosis(data),
        "q1":     np.percentile(data, 25),
        "q3":     np.percentile(data, 75),
        "iqr":    np.percentile(data, 75) - np.percentile(data, 25)
    }
```

### Test if data follows a normal distribution

```python
def check_normality(data, alpha=0.05):
    stat, p_value = stats.shapiro(data)
    if p_value > alpha:
        print(f"p = {p_value:.4f} - data likely normal")
    else:
        print(f"p = {p_value:.4f} - data likely NOT normal")

check_normality(my_data)
```

### Compare two groups

```python
from scipy import stats

def compare_groups(a, b, alpha=0.05):
    # first check normality
    _, p_a = stats.shapiro(a)
    _, p_b = stats.shapiro(b)
    
    if p_a > alpha and p_b > alpha:
        # both normal: use t-test
        stat, p = stats.ttest_ind(a, b)
        test = "t-test"
    else:
        # not normal: use Mann-Whitney
        stat, p = stats.mannwhitneyu(a, b)
        test = "Mann-Whitney"
    
    print(f"{test}: stat={stat:.4f}, p={p:.4f}")
    return p < alpha

compare_groups(group1, group2)
```

### Find percentile rank of a value

```python
data = np.random.normal(100, 15, 1000)
my_score = 130
percentile = stats.percentileofscore(data, my_score)
print(f"Score of {my_score} is at the {percentile:.1f}th percentile")
```

### Confidence interval for the mean

```python
def mean_confidence_interval(data, confidence=0.95):
    n = len(data)
    mean = np.mean(data)
    sem = stats.sem(data)              # standard error of the mean
    h = sem * stats.t.ppf((1 + confidence) / 2, n - 1)
    return mean, mean - h, mean + h

mean, lower, upper = mean_confidence_interval(data)
print(f"Mean = {mean:.2f}, 95% CI: [{lower:.2f}, {upper:.2f}]")
```

## 13. Common Mistakes

### Mistake 1: confusing PDF and PMF

- **PDF (Probability Density Function)** - for continuous distributions (normal, t, etc.). The value is a *density*, not a probability.
- **PMF (Probability Mass Function)** - for discrete distributions (binomial, Poisson). The value IS a probability.

```python
stats.norm.pdf(0)              # density, can be > 1 in tall narrow distributions
stats.binom(n=10, p=0.5).pmf(5)  # actual probability of getting exactly 5
```

### Mistake 2: misinterpreting p-values

- p < 0.05 does NOT mean the alternative is true with 95% probability
- Small p-values with huge sample sizes can be practically meaningless
- p > 0.05 doesn't mean "no effect" - just "not enough evidence"

### Mistake 3: t-test when assumptions violated

t-test assumes data is normally distributed and groups have equal variance. For badly skewed data or unequal variances:

```python
# Welch's t-test (doesn't assume equal variance)
stats.ttest_ind(a, b, equal_var=False)

# or use a non-parametric test
stats.mannwhitneyu(a, b)
```

### Mistake 4: forgetting `loc` and `scale`

```python
# WRONG - using "mean=100, std=15"
stats.norm(mean=100, std=15)   # TypeError

# RIGHT - use loc and scale
stats.norm(loc=100, scale=15)   # loc is mean, scale is std for normal
```

The exact meaning of `loc` and `scale` depends on the distribution. For normal: loc=mean, scale=std. For exponential: scale=mean. Read the docs for each.

### Mistake 5: confusing scipy.stats and statistics module

Python has a built-in `statistics` module for basic stuff. SciPy is more powerful but heavier. For complex work always use SciPy.

## 14. Quick Reference

```python
from scipy import stats

# descriptive
stats.describe(data)
stats.mode(data)
stats.gmean(data), stats.hmean(data)
stats.skew(data), stats.kurtosis(data)
stats.zscore(data)

# distributions (replace 'norm' with any distribution name)
stats.norm.pdf(x, loc, scale)
stats.norm.cdf(x, loc, scale)
stats.norm.ppf(q, loc, scale)
stats.norm.rvs(loc, scale, size)

# hypothesis tests
stats.ttest_ind(a, b)              # independent samples
stats.ttest_rel(a, b)               # paired samples
stats.ttest_1samp(a, popmean)       # one sample vs mean
stats.f_oneway(a, b, c)             # ANOVA
stats.chisquare(observed, expected)
stats.chi2_contingency(table)
stats.shapiro(data)                  # normality
stats.mannwhitneyu(a, b)            # non-parametric t-test
stats.ks_2samp(a, b)                # compare distributions

# correlation
stats.pearsonr(x, y)
stats.spearmanr(x, y)
stats.kendalltau(x, y)
stats.linregress(x, y)

# optimization
from scipy.optimize import minimize, curve_fit
minimize(f, x0)
curve_fit(model, x, y)
```

## Summary

- SciPy builds on NumPy with advanced scientific tools
- `scipy.stats` is the workhorse for statistics: distributions, tests, correlations
- All distributions have the same interface (`.pdf`, `.cdf`, `.ppf`, `.rvs`)
- Common tests: t-test (`ttest_ind`), ANOVA (`f_oneway`), chi-squared (`chi2_contingency`), correlation (`pearsonr`, `spearmanr`)
- `scipy.optimize` for finding minima and curve fitting
- `scipy.spatial.distance` for distance metrics between points
- For most basic linear algebra, NumPy is enough. SciPy has more advanced methods.

## This completes Phase 4

You now have notes covering:
- **Phase 1 (1-6):** Python fundamentals
- **Phase 2 (7-16):** Control flow, collections, functions, comprehensions, file I/O, errors, modules
- **Phase 3 (17-20):** OOP, iterators/generators, decorators, datetime
- **Phase 4 (21-25):** NumPy, pandas, matplotlib, seaborn, scipy

Next step is the new `03-machine-learning/` folder which will have its own roadmap covering scikit-learn, statistics, feature engineering, model evaluation, etc.
