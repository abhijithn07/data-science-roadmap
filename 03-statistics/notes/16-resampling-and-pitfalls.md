# 16. Resampling and Common Statistical Pitfalls

## Two Topics, One Note

This final note covers two practical things every data scientist needs: **resampling methods** (using the computer to estimate uncertainty when formulas are hard) and the **common traps** that produce wrong conclusions. The first is a toolkit, the second is a defense.

```python
import numpy as np
from scipy import stats
np.random.seed(1)
```

## The Bootstrap

The **bootstrap** estimates the uncertainty of almost any statistic by **resampling your data with replacement**. The idea: treat your sample as a stand-in for the population, draw many new samples from it (same size, with replacement), compute the statistic each time, and use the spread of those values as the sampling distribution.

It is powerful because it needs **no formula and no normality assumption**, so it works for medians, correlations, and other statistics where the math is messy or unknown.

```python
data = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])

# resample 10,000 times, compute the mean each time
boot_means = [np.random.choice(data, size=len(data), replace=True).mean()
              for _ in range(10000)]

# the bootstrap 95% confidence interval is just the 2.5 and 97.5 percentiles
np.percentile(boot_means, [2.5, 97.5]).round(2)
# array([65.80, 81.00])   a CI for the mean with no t-distribution needed
```

The "with replacement" part is essential: it lets each resample differ from the original, which is what creates the variation you measure. The bootstrap is one of the most useful practical tools in statistics, and it underlies methods like random forests in Week 4.

## Permutation Tests

A **permutation test** is the resampling version of a hypothesis test. To test whether two groups differ, you compute the observed difference, then repeatedly **shuffle the group labels** and recompute. If the real labels rarely produce a difference as large as observed, the groups genuinely differ.

```python
A = np.array([72, 75, 78, 71, 69, 80, 74])
B = np.array([85, 88, 82, 90, 86, 84, 89])
observed = B.mean() - A.mean()             # 12.14

pooled = np.concatenate([A, B])
count = 0
for _ in range(20000):
    np.random.shuffle(pooled)
    diff = pooled[:7].mean() - pooled[7:].mean()
    if abs(diff) >= abs(observed):
        count += 1
p_value = count / 20000
round(p_value, 4)
# 0.0007   the real split is far more separated than random shuffles, groups differ
```

Like the bootstrap, it makes no distributional assumption, you build the null distribution directly from your data.

## Cross-validation (a forward link)

A third resampling idea you will use constantly in Week 4: **cross-validation** splits the data into folds, trains a model on some folds, and tests on the held-out fold, rotating through. It estimates how well a model generalizes to new data rather than how well it memorized the training set. Same family of "resample to estimate" thinking, applied to model evaluation.

## Common Statistical Pitfalls

The rest of this note is a checklist of traps. Knowing them is what separates careful analysis from confident nonsense.

### Correlation is not causation

Covered in Note 12, but it tops every list. A relationship between X and Y can come from X causing Y, Y causing X, a confounder causing both, or coincidence. Only a controlled experiment (Note 15) settles it.

### p-hacking

**p-hacking** is torturing the data until something crosses p < 0.05: trying many variables, many subgroups, many cutoffs, and reporting only what "worked". Because 5 percent of random tests are significant by chance, enough attempts guarantee a false positive. Defenses: decide your analysis before seeing the data, and report everything you tried.

### Multiple comparisons

Run 20 independent tests at alpha = 0.05 and you expect about **one** false positive even if nothing is real.

```python
# probability of at least one false positive in 20 tests, all nulls true
1 - (0.95 ** 20)
# 0.6415   a 64% chance of a spurious "significant" result
```

The fix is a **correction** that lowers the per-test threshold, like Bonferroni (divide alpha by the number of tests) or the less conservative Benjamini-Hochberg.

### Simpson's Paradox

A trend that appears in separate groups can **reverse** when the groups are combined (or vice versa), usually because of a lurking confounder and unequal group sizes.

```
Treatment A looks better than B in mild cases AND in severe cases,
but B looks better overall, because B was given to far more severe cases.
```

The lesson: always check whether a confounder or grouping variable is hiding inside an aggregate. The aggregate can lie.

### Survivorship bias

Drawing conclusions only from the things that "survived" some selection, ignoring those that did not. The classic example: reinforcing the parts of returning warplanes that had bullet holes, when the planes that were hit elsewhere never made it back, so the holes you see mark the survivable spots. In data terms: analyzing only current customers, successful startups, or completed records, and missing the ones that dropped out.

### Base rate fallacy

Ignoring the prior probability of an event, which makes rare-event predictions misleading. This is the medical-test result from Note 04: a 99 percent accurate test for a rare disease still yields mostly false positives, because the disease is rare. Always factor in the base rate.

### Regression to the mean

Extreme measurements tend to be followed by more average ones, purely by chance. A patient who felt worst on day one tends to feel better next time regardless of treatment, a top-performing fund tends to do worse next year. Mistaking this natural pull toward the average for a real effect is a common error, and it is why control groups matter.

### Overfitting (a forward link)

Building a model so complex it memorizes the noise in the training data and fails on new data. It is the modeling cousin of p-hacking, and cross-validation (above) is the main defense. This becomes a central theme in Week 4.

## Summary

| Tool / pitfall | One-line takeaway |
|----------------|-------------------|
| Bootstrap | resample with replacement to get a CI for any statistic |
| Permutation test | shuffle labels to build the null distribution directly |
| Cross-validation | resample into folds to estimate generalization |
| p-hacking | testing until something is significant, then reporting only that |
| Multiple comparisons | many tests guarantee false positives, correct alpha |
| Simpson's paradox | aggregated trends can reverse a grouped trend |
| Survivorship bias | conclusions from survivors miss the dropouts |
| Base rate fallacy | ignoring priors makes rare-event predictions wrong |
| Regression to the mean | extremes drift back to average on their own |

Resampling gives you uncertainty estimates without heavy math, and the pitfalls list keeps your conclusions honest. Together they are the practical backbone of trustworthy analysis, and they carry directly into machine learning in Week 4.

## Quick Self Check

1. What does the bootstrap resample (and with or without replacement), and what does it estimate?
2. How does a permutation test build its null distribution?
3. You run 40 hypothesis tests at alpha = 0.05 with nothing truly significant. Roughly how many false positives do you expect, and what fixes it?
4. In Simpson's paradox, why can the aggregate trend contradict the group-level trends?
5. A fund had the best returns last year and worse returns this year, with no strategy change. What statistical effect likely explains it?
6. Name the pitfall: you analyze only customers who are still active and conclude your product has high satisfaction.

<details>
<summary>Answers</summary>

1. It resamples your own data with replacement, same size, many times, and uses the spread of the recomputed statistic to estimate its sampling distribution (and thus a confidence interval).
2. By repeatedly shuffling the group labels and recomputing the test statistic, building the distribution of results expected if the groups were interchangeable (the null).
3. About 2 false positives (40 times 0.05). A multiple-comparison correction such as Bonferroni or Benjamini-Hochberg fixes it.
4. A confounding variable combined with unequal group sizes can reverse the direction when data is pooled. The aggregate mixes groups that should be compared separately.
5. Regression to the mean, an extreme result tends to be followed by a more average one by chance alone.
6. Survivorship bias, you are ignoring the churned customers who were dissatisfied.
</details>
