# 18. Effect Size and Practical Significance

## The Problem This Note Fixes

In Note 10 you learned the p-value tells you whether an effect is **real** (unlikely to be chance). But it does **not** tell you whether the effect is **big enough to matter**. Those are two different questions, and confusing them is one of the most common mistakes in data science.

- **Statistical significance** (the p-value) answers: "is there an effect at all?"
- **Practical significance** (the effect size) answers: "is the effect large enough to care about?"

A simple story: a weight-loss pill that helps people lose an average of 0.1 kg might be **statistically significant** with a huge study (tiny p-value), yet completely **useless** in practice. The p-value said "real", the effect size says "who cares". You need both.

```python
import numpy as np
from scipy import stats
```

## Why the p-value is Not Enough

The p-value is sensitive to **sample size**. With a large enough sample, almost any difference, however trivial, becomes statistically significant. That is because more data shrinks the standard error (Note 08), which shrinks the p-value, even when the underlying effect is tiny.

```
small sample + big effect   -> may or may not be significant
huge sample  + tiny effect  -> almost always "significant" (but meaningless)
```

The fix is to always report an **effect size**, a number that measures **how big** the effect is, independent of sample size. The p-value tells you if, the effect size tells you how much.

## Effect Size for Comparing Two Means: Cohen's d

When you compare two group means (like a t-test, Note 11), the standard effect size is **Cohen's d**. It measures the difference between the two means in units of standard deviation, which makes it comparable across studies and scales.

```
Cohen's d = (mean of group B - mean of group A) / pooled standard deviation
```

The "pooled standard deviation" just combines the spread of both groups into one number. Dividing by it is what makes d unit-free: a d of 1 means "the groups are one full standard deviation apart", whatever the original units were.

```python
A = np.array([72, 75, 78, 71, 69, 80, 74])     # method A scores
B = np.array([85, 88, 82, 90, 86, 84, 89])     # method B scores

nA, nB = len(A), len(B)
# pooled standard deviation
pooled_sd = np.sqrt(((nA-1)*A.var(ddof=1) + (nB-1)*B.var(ddof=1)) / (nA + nB - 2))
d = (B.mean() - A.mean()) / pooled_sd
round(d, 3)
# 3.551   the groups are about 3.5 standard deviations apart, an enormous effect
```

How to read Cohen's d (Cohen's rough conventions):

```
|d| around 0.2   -> small effect
|d| around 0.5   -> medium effect
|d| around 0.8   -> large effect
```

So a d of 3.5 here is huge: method B is dramatically better, not just "significantly" better. Reporting d alongside the p-value gives the full picture: the difference is both real and large.

## Effect Size for Relationships: r and R-squared

You have already met the effect sizes for relationships:

- **Pearson's r** (Note 12) is itself an effect size for a linear relationship, from -1 to 1. Its rough bands: 0.1 small, 0.3 medium, 0.5 large.
- **R-squared** (Note 13) is the effect size for a regression: the fraction of variance explained. An R-squared of 0.4 means the predictors explain 40 percent of the outcome's variation.

So when you report a correlation or a regression, the effect size is built in, you just have to actually look at it, not only the p-value.

## Effect Size for Other Tests (briefly)

Each test family has its own effect size measure:

| Test | Effect size | What it measures |
|------|-------------|------------------|
| Two-sample t-test | Cohen's d | mean gap in SD units |
| Correlation | Pearson r | strength of linear relationship |
| Regression | R-squared | variance explained |
| ANOVA | eta-squared | variance explained by group |
| Chi-square | Cramer's V | strength of categorical association |
| Risk / odds | risk ratio, odds ratio | how much more likely an outcome is |

You do not need to memorize the formulas. The point is: **every test should be reported with an effect size**, not just a p-value.

## Confidence Intervals Carry Effect Size Too

A confidence interval (Note 09) for the difference between two groups is a wonderful summary because it shows **both** things at once: whether the effect is real (does the interval exclude 0?) and how big it plausibly is (the range of values). Many statisticians argue a CI is more informative than a p-value for exactly this reason.

```python
# 95% CI for the difference in means (B - A)
diff = B.mean() - A.mean()
se = np.sqrt(A.var(ddof=1)/nA + B.var(ddof=1)/nB)
t_crit = stats.t.ppf(0.975, df=nA+nB-2)
ci = (round(diff - t_crit*se, 2), round(diff + t_crit*se, 2))
diff, ci
# (12.14, (8.16, 16.12))   the gap is about 12 points, plausibly 8 to 16, and clearly not 0
```

This single line tells you the effect is real (the interval is far from 0) and meaningful (about 12 points).

## The Connection to Power and Sample Size

Effect size also feeds directly into experiment design (Notes 10 and 15). To compute the sample size for a study, you must specify the **smallest effect size worth detecting**. Bigger effects are easy to detect with little data, small effects need large samples. So effect size is not just for reporting results, it is a planning input.

## Putting It Together: How to Report a Result

A complete, honest result has three parts, not one:

```
1. Is it real?        the p-value (and the test used)
2. How big is it?     the effect size (Cohen's d, r, R-squared, ...)
3. How precise?       the confidence interval
```

Reporting only the p-value is the incomplete habit this note is meant to break.

## Summary

| Idea | Takeaway |
|------|----------|
| Statistical significance | p-value: is the effect real (not chance)? |
| Practical significance | effect size: is the effect big enough to matter? |
| Cohen's d | mean difference in standard-deviation units (0.2 / 0.5 / 0.8) |
| r and R-squared | effect sizes for correlation and regression |
| Why it matters | large samples make trivial effects "significant", effect size keeps you honest |
| Confidence interval | shows reality and magnitude together |

The headline: **a p-value without an effect size is half a result**. Always report how big, not just whether.

## Quick Self Check

1. In one sentence each, what does statistical significance tell you, and what does practical significance tell you?
2. Why can a tiny, unimportant effect still be statistically significant?
3. Cohen's d for a comparison is 0.15. Real or not aside, is the effect large or small?
4. You read a study reporting only "p < 0.001" with no effect size. What is missing and why does it matter?
5. How does a confidence interval for a difference convey both significance and effect size?

<details>
<summary>Answers</summary>

1. Statistical significance tells you whether an effect is real (unlikely due to chance). Practical significance tells you whether the effect is large enough to matter in the real world.
2. With a large sample the standard error is tiny, which shrinks the p-value, so even a trivial difference crosses the significance threshold.
3. Small (Cohen's d around 0.2 is small, and 0.15 is below that).
4. The effect size is missing. Without it you cannot tell whether the significant effect is large and meaningful or tiny and useless, which a big sample could make significant either way.
5. If the interval excludes 0 the effect is statistically significant, and the range of the interval shows how large the effect plausibly is.
</details>
