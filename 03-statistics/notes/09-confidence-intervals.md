# 09. Estimation and Confidence Intervals

## Point vs Interval Estimation

When you estimate a population parameter from a sample, you can do it two ways:

- a **point estimate** is a single best guess (the sample mean x-bar estimates mu). Simple, but it gives no sense of how uncertain it is.
- an **interval estimate** gives a range, with a stated confidence, that likely contains the parameter. This is a **confidence interval (CI)**, and it is almost always the better way to report a result because it carries the uncertainty with it.

```python
import numpy as np
from scipy import stats
```

## What a Confidence Interval Means

A 95 percent confidence interval is built by a procedure that, repeated over many samples, captures the true parameter 95 percent of the time.

The careful wording matters. A 95 percent CI does **not** mean "there is a 95 percent probability the true mean is in this particular interval". The true mean is fixed, it is either in or out. The 95 percent refers to the long-run success rate of the **method**: 95 of every 100 such intervals would contain the parameter. This is the single most misstated idea in statistics.

## The General Form

Every confidence interval has the same shape:

```
estimate  +/-  (critical value) * (standard error)
                  \________________________________/
                        margin of error
```

- the **estimate** is the sample statistic (x-bar, p-hat)
- the **critical value** comes from the relevant distribution (z or t) and the confidence level
- the **standard error** is the spread of the statistic (Note 08)
- their product is the **margin of error**, the half-width of the interval

Higher confidence means a larger critical value and a wider interval. There is no free lunch: to be more confident, you must be less precise.

## CI for a Mean (sigma known): the z-interval

If the population standard deviation `sigma` is known (rare in practice), use the normal critical value. For 95 percent confidence that value is **1.96** (Note 07's empirical rule, the z that leaves 2.5 percent in each tail).

```
CI = x-bar  +/-  z * (sigma / sqrt(n))
```

```python
x_bar, sigma, n = 100.0, 15.0, 36
z = stats.norm.ppf(0.975)            # 1.96 for 95% confidence
se = sigma / np.sqrt(n)
margin = z * se
(x_bar - margin, x_bar + margin)
# (95.1, 104.9)
```

Common critical values: 90 percent uses 1.645, 95 percent uses 1.96, 99 percent uses 2.576.

## CI for a Mean (sigma unknown): the t-interval

In real data you almost never know `sigma`, so you estimate it with the sample standard deviation `s`. That extra uncertainty means you use the **t-distribution** (Note 07) instead of the normal, with `n - 1` degrees of freedom. The t has heavier tails, giving a slightly wider, more honest interval.

```
CI = x-bar  +/-  t * (s / sqrt(n))        with df = n - 1
```

```python
data = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
x_bar = data.mean()
s = data.std(ddof=1)
n = len(data)

t = stats.t.ppf(0.975, df=n-1)       # 2.262 for 95% with 9 df
margin = t * (s / np.sqrt(n))
(round(x_bar - margin, 2), round(x_bar + margin, 2))
# (64.03, 82.57)

# scipy one-liner that does the same thing
stats.t.interval(0.95, df=n-1, loc=x_bar, scale=stats.sem(data))
# (64.03..., 82.57...)
```

For large n (say n > 30) the t and z intervals nearly coincide, because the t converges to the normal. Use t whenever sigma is estimated, which is almost always.

## CI for a Proportion

For a proportion (a yes/no outcome), the estimate is `p-hat` and its standard error has its own form:

```
SE = sqrt( p-hat * (1 - p-hat) / n )
CI = p-hat  +/-  z * SE
```

```python
# 540 of 1000 surveyed prefer option A -> p-hat = 0.54
p_hat, n = 0.54, 1000
z = stats.norm.ppf(0.975)
se = np.sqrt(p_hat * (1 - p_hat) / n)
margin = z * se
(round(p_hat - margin, 4), round(p_hat + margin, 4))
# (0.5091, 0.5709)   so 54% +/- about 3 points, the classic poll margin
```

## Margin of Error and Sample Size

The **margin of error** is the `+/-` part. Since it is `critical * SE` and SE shrinks with sqrt(n), you can solve for the sample size needed to hit a target margin `E`:

```
n = ( z * sigma / E )^2          for a mean
```

```python
# how many samples for a margin of 2, with sigma=15 at 95% confidence?
z, sigma, E = 1.96, 15, 2
n = (z * sigma / E) ** 2
int(np.ceil(n))
# 217
```

This is how pollsters and experiment designers decide sample sizes before collecting data. Note the squared term: to cut the margin in half you need four times the sample, the same sqrt(n) law from Note 08.

## Summary

| Situation | Critical value | Standard error |
|-----------|----------------|----------------|
| Mean, sigma known | z (1.96 at 95%) | sigma / sqrt(n) |
| Mean, sigma unknown | t (df = n-1) | s / sqrt(n) |
| Proportion | z | sqrt(p-hat(1-p-hat)/n) |

Key ideas: a CI is estimate +/- margin of error, the confidence level is a property of the method not of one interval, use t when sigma is estimated, and widen the interval to gain confidence or grow n to gain precision.

A confidence interval estimates a parameter. The flip side is testing a specific claim about a parameter, which is hypothesis testing in Note 10. The two are deeply connected: a value outside the 95 percent CI is exactly a value that would be rejected at the 5 percent level.

## Quick Self Check

1. A 95 percent CI for the mean is (48, 52). True or false: there is a 95 percent probability the true mean is between 48 and 52. Explain.
2. Why use the t-distribution instead of the normal for a CI when sigma is unknown?
3. You want a narrower confidence interval. Name two ways to get one and the cost of each.
4. The z critical value for 95 percent confidence is what number?
5. To halve your margin of error, by what factor must you increase the sample size?

<details>
<summary>Answers</summary>

1. False. The true mean is fixed, not random, so it is either in (48, 52) or not. The 95 percent describes the method: 95 percent of intervals built this way capture the true mean.
2. Estimating sigma from the sample adds uncertainty. The t-distribution's heavier tails account for it, giving a slightly wider, more honest interval.
3. Lower the confidence level (smaller critical value, but you are less sure) or increase the sample size (smaller SE, but it costs more data).
4. 1.96.
5. Four times, because the margin depends on sqrt(n).
</details>
