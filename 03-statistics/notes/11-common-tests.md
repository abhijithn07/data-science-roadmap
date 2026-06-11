# 11. Common Statistical Tests

## Choosing the Right Test

Note 10 gave the framework. This note gives the specific tests and, just as important, how to pick one. The choice depends on the data type and what you are comparing.

```python
import numpy as np
from scipy import stats
```

A practical decision guide:

```
Comparing a mean to a known value?              -> one-sample t-test
Comparing the means of two independent groups?  -> two-sample (independent) t-test
Comparing two measurements on the same units?   -> paired t-test
Comparing means of three or more groups?        -> ANOVA
Testing relationships between categories?       -> chi-square test
Comparing two variances?                        -> F-test
```

Most mean-based tests assume the data is roughly normal (or the sample is large enough for the CLT) and, for two groups, similar variances. When those fail, use the rank-based nonparametric versions noted at the end.

## z-test vs t-test

Both test a mean. Use the **z-test** when the population standard deviation is known and n is large (rare). Use the **t-test** when sigma is unknown and estimated from the sample (almost always). In practice you reach for the t-test by default. The mechanics are the same, the t just uses the t-distribution with `n - 1` degrees of freedom.

## One-Sample t-test

Tests whether a sample mean differs from a known or claimed value.

```
H0: mu = mu_0      H1: mu != mu_0
```

```python
# class scores; is the true mean different from 70?
scores = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
t_stat, p = stats.ttest_1samp(scores, popmean=70)
round(t_stat, 3), round(p, 4)
# (0.806, 0.4412)   p > 0.05: no evidence the mean differs from 70
```

## Two-Sample (Independent) t-test

Tests whether two **separate** groups have different means.

```
H0: mu_A = mu_B      H1: mu_A != mu_B
```

```python
group_A = np.array([72, 75, 78, 71, 69, 80, 74])     # method A
group_B = np.array([85, 88, 82, 90, 86, 84, 89])     # method B

# equal_var=False is Welch's t-test, safer when variances may differ
t_stat, p = stats.ttest_ind(group_A, group_B, equal_var=False)
round(t_stat, 3), round(p, 5)
# (-6.644, 3.6e-05)   p << 0.05: the two methods differ significantly
```

Welch's version (`equal_var=False`) does not assume equal variances and is the safer default.

## Paired t-test

Tests two measurements on the **same** units (before vs after, left vs right). Pairing removes individual differences, making it more powerful than the two-sample test when it applies.

```
H0: mean difference = 0      H1: mean difference != 0
```

```python
before = np.array([80, 75, 88, 92, 70, 85])
after  = np.array([85, 78, 90, 95, 76, 88])      # same people, after training

t_stat, p = stats.ttest_rel(before, after)
round(t_stat, 3), round(p, 4)
# (-5.966, 0.0019)   p < 0.05: the training produced a real change
```

The signal is "same subjects measured twice" -> paired. "Two different groups" -> independent.

## ANOVA (Analysis of Variance)

Tests whether **three or more** group means differ. You cannot just run many t-tests, because each adds Type I error risk (Note 16's multiple comparisons). ANOVA does it in one test using the **F-statistic**, the ratio of between-group variance to within-group variance.

```
H0: all group means are equal      H1: at least one differs
```

```python
g1 = np.array([85, 86, 88, 75, 78])
g2 = np.array([91, 92, 93, 85, 87])
g3 = np.array([79, 78, 88, 94, 92])

f_stat, p = stats.f_oneway(g1, g2, g3)
round(f_stat, 3), round(p, 4)
# (2.0, 0.178)   p > 0.05: no significant difference among the three groups
```

A significant ANOVA tells you *some* group differs, not which. You follow up with **post-hoc** tests (like Tukey's HSD) to find the specific pairs.

## Chi-square Tests

For **categorical** data. Two flavors:

- **Goodness of fit:** does one categorical variable match an expected distribution? (Is a die fair?)
- **Test of independence:** are two categorical variables related? (Is purchase related to gender?)

```python
# goodness of fit: a die rolled 60 times, expected 10 per face
observed = np.array([8, 11, 9, 12, 7, 13])
expected = np.array([10, 10, 10, 10, 10, 10])
chi2, p = stats.chisquare(observed, expected)
round(chi2, 3), round(p, 4)
# (2.8, 0.7308)   p > 0.05: consistent with a fair die
```

```python
# test of independence: gender vs product preference
table = np.array([[30, 10],     # men: like, dislike
                  [20, 40]])     # women: like, dislike
chi2, p, dof, expected = stats.chi2_contingency(table)
round(chi2, 3), round(p, 5)
# (15.042, 0.0001)   p < 0.05: preference and gender are related
```

Chi-square uses the chi-square distribution (Note 07) and needs reasonably large expected counts in each cell (a common rule is at least 5).

## F-test for Variances

Tests whether two populations have **equal variances**, using the ratio of the two sample variances against the F-distribution (Note 07). It also appears inside ANOVA and regression.

```python
a = np.array([12, 15, 14, 10, 13, 11])
b = np.array([22, 28, 19, 30, 25, 21])
F = a.var(ddof=1) / b.var(ddof=1)
df1, df2 = len(a)-1, len(b)-1
p = 2 * min(stats.f.cdf(F, df1, df2), 1 - stats.f.cdf(F, df1, df2))
round(F, 4), round(p, 4)
# (0.1927, 0.0949)   p ~ 0.09: not significant at 0.05, though the variances look quite different
```

## Nonparametric Alternatives

When normality or equal-variance assumptions fail, use rank-based tests that make fewer assumptions:

| Parametric test | Nonparametric version |
|-----------------|------------------------|
| one-sample / paired t-test | Wilcoxon signed-rank |
| two-sample t-test | Mann-Whitney U |
| one-way ANOVA | Kruskal-Wallis |
| Pearson correlation | Spearman correlation (Note 12) |

## Summary

| Test | Use when | scipy function |
|------|----------|----------------|
| One-sample t | one mean vs a value | `ttest_1samp` |
| Two-sample t | two independent group means | `ttest_ind` |
| Paired t | two measurements on same units | `ttest_rel` |
| ANOVA | 3+ group means | `f_oneway` |
| Chi-square GoF | one categorical vs expected | `chisquare` |
| Chi-square independence | two categorical variables | `chi2_contingency` |
| F-test | two variances | via `scipy.stats.f` |

The workflow is always Note 10: state H0/H1, pick the test from this table, compute the statistic and p-value, then decide against alpha.

## Quick Self Check

1. You measure the same patients' blood pressure before and after a drug. Independent or paired t-test?
2. Why not run three separate t-tests to compare three group means instead of one ANOVA?
3. A significant ANOVA tells you what, and what does it not tell you?
4. Which test checks whether customer region and product choice (both categorical) are related?
5. Your two groups are small and clearly not normal. What kind of test should you switch to?

<details>
<summary>Answers</summary>

1. Paired, because the same patients are measured twice (before and after).
2. Each t-test carries a Type I error risk, and running several inflates the overall false-positive rate (multiple comparisons). ANOVA tests all groups at once at a single alpha.
3. It tells you at least one group mean differs. It does not tell you which one(s), you need post-hoc tests for that.
4. The chi-square test of independence (`chi2_contingency`).
5. A nonparametric, rank-based test such as the Mann-Whitney U test.
</details>
