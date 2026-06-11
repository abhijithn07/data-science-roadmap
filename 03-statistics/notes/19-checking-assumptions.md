# 19. Checking Assumptions and Normality

## Why This Note Exists

Most of the tests and models in this section come with **assumptions**, conditions the data must roughly meet for the results to be valid. The t-test assumes near-normal data, regression assumes the LINE conditions (Note 13), and so on. If you run a test on data that breaks its assumptions, the p-values and confidence intervals can be wrong, and you would not even know it.

This note is the practical "before you trust the result, check these" companion to Notes 10 through 13. It is mostly about one assumption that appears everywhere, **normality**, plus equal variance and independence, and what to do when they fail.

```python
import numpy as np
from scipy import stats
np.random.seed(0)
```

## Assumption 1: Normality

Many classic tests assume the data (or, more precisely, the residuals or the sampling distribution) is approximately **normal** (the bell curve, Note 07). There are two ways to check it: look at it, and test it. Use both, but trust the visual more.

### Checking Normality Visually

**Histogram.** The fastest first look. Does it look like a symmetric bell, or is it skewed, flat, or multi-peaked?

**Q-Q plot (quantile-quantile plot).** The best visual tool for normality. It plots your data's quantiles against the quantiles a perfect normal would have. The reading is simple:

```
points fall on the straight diagonal line   -> data is approximately normal
points curve away from the line (especially at the ends) -> not normal
```

```python
import matplotlib.pyplot as plt

normal_data = np.random.normal(50, 5, 100)     # genuinely normal
fig = plt.figure(figsize=(5, 5))
stats.probplot(normal_data, dist="norm", plot=plt)  # draws the Q-Q plot
plt.title("Q-Q Plot: points on the line means normal")
# plt.show()   # in a notebook
```

A Q-Q plot that hugs the diagonal says "normal enough". A clear S-shape or curling tails says "not normal".

### Checking Normality with a Test

You can also run a formal hypothesis test for normality. The most common is the **Shapiro-Wilk test**. Read its result carefully, because the hypotheses are arranged in the way that often confuses beginners:

```
H0: the data IS normally distributed
H1: the data is NOT normal

p > 0.05  -> fail to reject H0 -> data is consistent with normal (good)
p <= 0.05 -> reject H0         -> data is NOT normal
```

So here, a **large** p-value is the "good" outcome (normality is plausible), the opposite of most tests.

```python
normal_data = np.random.normal(50, 5, 100)
skewed_data = np.random.exponential(2, 100)

print("normal data, Shapiro p =", round(stats.shapiro(normal_data).pvalue, 4))
# normal data, Shapiro p = 0.8689   p > 0.05: looks normal, good

print("skewed data, Shapiro p =", round(stats.shapiro(skewed_data).pvalue, 6))
# skewed data, Shapiro p = 0.0       p < 0.05: not normal
```

A caution that matters: with a **very large** sample, normality tests reject for tiny, harmless deviations (they become oversensitive). So for big data, lean on the Q-Q plot and the histogram rather than the test. And remember the CLT (Note 08): for large samples, tests about means are robust to non-normality anyway, because the sample mean is normal regardless.

## Assumption 2: Equal Variance (Homogeneity)

Some tests (the standard two-sample t-test, ANOVA) assume the groups being compared have roughly **equal variances** (equal spread). The check is **Levene's test**:

```
H0: the groups have equal variance
H1: the variances differ

p > 0.05  -> equal variance is plausible (assumption holds)
p <= 0.05 -> variances differ (assumption violated)
```

```python
A = np.array([72, 75, 78, 71, 69, 80, 74])
B = np.array([85, 88, 82, 90, 86, 84, 89])
print("Levene p =", round(stats.levene(A, B).pvalue, 4))
# Levene p = 0.4858   p > 0.05: equal-variance assumption is fine
```

If variances are clearly unequal, do not panic, just use **Welch's t-test** (`equal_var=False`, Note 11), which does not assume equal variance and is a safe default anyway.

## Assumption 3: Independence

The observations should be **independent**, one data point should not influence another. This one usually cannot be tested from the numbers alone, you check it from how the data was collected:

- repeated measurements on the same person are **not** independent (use a paired test instead)
- time series data has points correlated with their neighbors (autocorrelation), violating independence
- cluster or convenience sampling (Note 08) can break it

Independence is mostly a design question. If the sampling was random and each unit was measured once, you are usually fine.

## What to Do When Assumptions Fail

Failing an assumption is common and fixable. Three standard responses:

**1. Transform the data.** A skewed, positive variable (income, prices) often becomes roughly normal after a **log transform** (Note 07's log-normal). This is the most common fix.

```python
skewed = np.random.exponential(2, 100)
print("before log, Shapiro p =", round(stats.shapiro(skewed).pvalue, 6))
print("after  log, Shapiro p =", round(stats.shapiro(np.log(skewed)).pvalue, 4))
# the log version is much closer to normal
```

**2. Use a nonparametric test.** These make no normality assumption because they work on ranks (Note 11): Mann-Whitney U instead of the two-sample t-test, Wilcoxon instead of the paired t-test, Kruskal-Wallis instead of ANOVA, Spearman instead of Pearson.

**3. Lean on the CLT or robust methods.** For large samples, mean-based tests are robust to non-normality (the sample mean is normal anyway). You can also use bootstrap confidence intervals (Note 16), which assume nothing about the shape.

## A Practical Checklist

Before trusting any test or model:

```
1. Plot the data first (histogram, box plot, scatter). Always.
2. Normality needed? -> Q-Q plot, and Shapiro-Wilk for small samples.
3. Comparing groups? -> Levene's test for equal variance; use Welch if unequal.
4. Independence?     -> check how the data was collected, not the numbers.
5. If something fails -> transform, switch to a nonparametric test, or bootstrap.
```

The habit to build: **look at your data before you test it**. Most assumption violations are obvious in a quick plot, and catching them is what separates a reliable analysis from a misleading one.

## Summary

| Assumption | How to check | If it fails |
|------------|--------------|-------------|
| Normality | Q-Q plot, histogram, Shapiro-Wilk | log transform, nonparametric test, rely on CLT |
| Equal variance | Levene's test | use Welch's t-test |
| Independence | how data was collected | paired test, time-series methods |

Key reminders: for the Shapiro-Wilk and Levene tests, a **large p-value is the good outcome** (the assumption holds). Normality tests over-reject on huge samples, so trust the Q-Q plot there. And the CLT often rescues mean-based tests even when the raw data is not normal.

This is the last note in the statistics section. With descriptive stats, probability, distributions, inference, relationships, estimation, effect sizes, and assumption checking all in hand, you have the full statistical toolkit a data scientist needs before moving on to machine learning.

## Quick Self Check

1. On a Q-Q plot, what does it look like when the data is normal, and when it is not?
2. The Shapiro-Wilk test gives p = 0.60. Is the data normal or not, and why is this the "good" outcome?
3. Why should you not rely on a normality test for a very large dataset?
4. Levene's test on your two groups gives p = 0.01. What does that mean and what test should you switch to?
5. Your income data is heavily right-skewed and fails normality. Name two ways to handle it.
6. Why is independence usually checked from the study design rather than from the numbers?

<details>
<summary>Answers</summary>

1. Normal data falls along the straight diagonal line. Non-normal data curves away from it, often with an S-shape or curling at the tails.
2. The data is consistent with normal. H0 is "data is normal", and p = 0.60 > 0.05 means you fail to reject it, so normality is plausible, which is what you want.
3. Normality tests become oversensitive with large samples and reject for tiny, harmless deviations. Use the Q-Q plot and histogram, and rely on the CLT for mean-based tests.
4. The variances differ significantly (p < 0.05), violating the equal-variance assumption. Use Welch's t-test (equal_var=False).
5. Apply a log transform to make it more normal, or use a nonparametric (rank-based) test like Mann-Whitney; bootstrapping is a third option.
6. Independence is about how observations relate (repeated measures, time order, clustering), which comes from the data collection process, not something the values themselves reveal.
</details>
