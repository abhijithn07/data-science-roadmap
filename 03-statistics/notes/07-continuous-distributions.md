# 07. Continuous Probability Distributions

## Setup

A continuous distribution is described by a PDF (Note 05), where probability is **area under the curve** and any single exact value has probability 0. As with discrete distributions, a few named families cover almost everything.

```python
import numpy as np
from scipy import stats
```

For continuous distributions, `.pdf(x, ...)` gives the density, `.cdf(x, ...)` gives P(X <= x), and `.ppf(q, ...)` is the inverse CDF (the value below which q of the probability lies, used for critical values and percentiles).

## Continuous Uniform

Every value in a range `[a, b]` is **equally likely**, so the PDF is flat.

```
PDF = 1 / (b - a)   for a <= x <= b
mean = (a + b) / 2      variance = (b - a)^2 / 12
```

```python
# uniform on [0, 10]; scipy uses loc=a, scale=b-a
stats.uniform.mean(loc=0, scale=10), stats.uniform.var(loc=0, scale=10)
# (5.0, 8.3333)
```

Use it to model "no value is more likely than another in this range", or for random number generation.

## The Normal Distribution

The most important distribution in statistics: the symmetric **bell curve**. Countless real measurements (heights, errors, test scores) are approximately normal, and the Central Limit Theorem (Note 08) makes sample means normal regardless of the original shape, which is why it powers most inference.

It has two parameters: the mean `mu` (centre) and the standard deviation `sigma` (width).

```
PDF peaks at mu, is symmetric, and tails off on both sides
mean = mu       variance = sigma^2
```

```python
# heights ~ Normal(mean=170, sd=10). P(height <= 180)?
stats.norm.cdf(180, loc=170, scale=10)
# 0.8413

# P(160 <= height <= 180), one SD each side
stats.norm.cdf(180, 170, 10) - stats.norm.cdf(160, 170, 10)
# 0.6827   <- the famous 68%
```

Key properties: symmetric, so mean = median = mode all at `mu`. Its shape is fixed; only the centre and width change with `mu` and `sigma`.

## The Standard Normal and Z-scores

The **standard normal** is the special normal with `mu = 0` and `sigma = 1`, written Z. Any normal variable can be converted to it by the **z-score** (Note 03):

```
z = (x - mu) / sigma
```

This **standardization** is why one table or one function handles every normal distribution: convert to z, then look up the probability once. A z-score says how many standard deviations a value is from the mean.

```python
# x = 130 from Normal(100, 15). Its z-score:
z = (130 - 100) / 15
z
# 2.0

# probability of being below it, two equivalent ways:
stats.norm.cdf(130, loc=100, scale=15)   # 0.9772  (original scale)
stats.norm.cdf(2.0)                        # 0.9772  (standardized)
```

Both give 0.9772, confirming the z-score carries the same information. Z-scores also let you compare values from different normal distributions on one scale (a test score vs a height).

## The Empirical Rule (68-95-99.7)

For any normal distribution, fixed percentages of the data fall within whole numbers of standard deviations of the mean. This is the **empirical rule** (introduced in Note 03), and it follows directly from the standard normal.

```
within 1 SD of the mean:  about 68%      (z between -1 and +1)
within 2 SD:              about 95%      (z between -2 and +2)
within 3 SD:              about 99.7%    (z between -3 and +3)
```

```python
for k in (1, 2, 3):
    p = stats.norm.cdf(k) - stats.norm.cdf(-k)
    print(k, round(p, 4))
# 1 0.6827
# 2 0.9545
# 3 0.9973
```

So on a normal IQ scale (mean 100, SD 15), about 95 percent of people score between 70 and 130, and a score beyond 145 (z > 3) is rarer than 0.3 percent. Anything past 2 to 3 SDs is a common working definition of an outlier.

## The t-Distribution

Looks like the normal (symmetric, bell shaped) but with **heavier tails**, controlled by its **degrees of freedom (df)**. It is what you use instead of the normal when the sample is **small** and the population standard deviation is **unknown** (you estimate it from the sample, which adds uncertainty, so the tails are fatter).

```python
# t with 5 df vs the normal: the t has more probability in the tails
stats.t.pdf(0, df=5), stats.norm.pdf(0)
# (0.3796, 0.3989)   lower peak, heavier tails
```

As df grows (large samples), the t-distribution converges to the standard normal. It is central to the t-tests and confidence intervals in Notes 09 and 11.

## The Chi-square Distribution

The distribution of a **sum of squared standard normal variables**. It is right-skewed, only takes non-negative values, and is parameterized by degrees of freedom. You meet it in tests about **variances** and about **categorical data** (the chi-square goodness-of-fit and independence tests, Note 11).

```python
# mean of a chi-square equals its df
stats.chi2.mean(df=4)
# 4.0
```

## The F-Distribution

The distribution of a **ratio of two scaled chi-square variables**, so it compares two variances. Right-skewed, non-negative, with two df parameters (numerator and denominator). It is the distribution behind **ANOVA** (comparing means across several groups) and the overall significance test in regression (Note 13).

## The Exponential Distribution

Models the **time between events** in a Poisson process, the continuous partner of the Poisson. Parameterized by a rate `lambda`, so the average wait is `1/lambda`. It is right-skewed and, like the geometric, **memoryless**.

```
PDF = lambda * e^(-lambda * x)   for x >= 0
mean = 1 / lambda       variance = 1 / lambda^2
```

```python
# events arrive at rate lambda = 0.5 per minute -> mean wait 2 minutes
# scipy uses scale = 1/lambda
stats.expon.mean(scale=1/0.5)
# 2.0
# P(wait <= 1 minute)
stats.expon.cdf(1, scale=1/0.5)
# 0.3935
```

Examples: time until the next customer arrives, time until a machine fails.

## The Log-normal Distribution (briefly)

A variable whose **logarithm** is normally distributed. It is right-skewed and only positive, which makes it a good fit for things that cannot go below zero and have a long upper tail: incomes, stock prices, file sizes, city populations. If data looks right-skewed, taking the log often makes it roughly normal and easier to model.

## Summary

| Distribution | Models | Shape | Key parameters |
|--------------|--------|-------|----------------|
| **Uniform** | equally likely values in a range | flat | a, b |
| **Normal** | natural measurements, sample means | symmetric bell | mu, sigma |
| **Standard normal (Z)** | standardized normal | bell, centred at 0 | none (mu=0, sigma=1) |
| **t** | small-sample means, unknown sigma | bell, heavy tails | df |
| **Chi-square** | sums of squared normals, variance and categorical tests | right-skewed, >= 0 | df |
| **F** | ratio of variances, ANOVA | right-skewed, >= 0 | df1, df2 |
| **Exponential** | time between events | right-skewed, >= 0 | lambda |
| **Log-normal** | positive, right-skewed quantities | right-skewed | mu, sigma of the log |

How to choose: bell-shaped measurements are **normal**, standardized values are **Z**, small samples use **t**, waiting times are **exponential**, and chi-square and F show up inside the tests of Notes 11 and 13.

With distributions in hand, the next step is inference: how a sample's statistics behave, which is sampling and the Central Limit Theorem in Note 08.

## Quick Self Check

1. Why is the probability of a continuous variable taking one exact value always 0?
2. Convert x = 85 from Normal(mean=70, sd=10) to a z-score. How many SDs from the mean is it?
3. Under the empirical rule, what percent of a normal distribution lies within 2 SDs of the mean?
4. When do you use the t-distribution instead of the normal?
5. Events happen at rate 4 per hour. What is the average wait between events, and which distribution describes that wait?
6. You have right-skewed income data. What transformation often makes it roughly normal?

<details>
<summary>Answers</summary>

1. There are infinitely many possible values, so any single one has zero area under the PDF. Only ranges (areas) have positive probability.
2. z = (85 - 70) / 10 = 1.5. It is 1.5 standard deviations above the mean.
3. About 95 percent.
4. When the sample is small and the population standard deviation is unknown (estimated from the sample). The extra uncertainty gives the t heavier tails.
5. Mean wait = 1/lambda = 1/4 hour = 15 minutes. The exponential distribution.
6. Take the logarithm. If the log is roughly normal, the data is log-normal.
</details>
