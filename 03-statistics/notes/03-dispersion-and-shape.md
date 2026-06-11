# 03. Measures of Dispersion and Shape

## Measures of Dispersion

Central tendency (Note 02) tells you the centre. **Dispersion** tells you how spread out the data is around that centre. They are equally important: two datasets can share an identical mean yet behave completely differently.

```python
import numpy as np
a = np.array([49, 50, 51])        # mean 50, tightly packed
b = np.array([10, 50, 90])        # mean 50, wildly spread
a.mean(), b.mean()
# (50.0, 50.0)   same centre, very different data
```

If these were two suppliers' delivery times, both average 50, but `a` is reliable and `b` is a gamble. Spread is what captures that.

## Range

The **range** is the simplest measure: max minus min.

```python
scores = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
scores.max() - scores.min()
# 40
```

Quick to compute, but it only uses two values and is extremely sensitive to outliers. One freak value makes the range meaningless. Useful as a first glance, not as a serious summary.

## Quartiles, Percentiles, and IQR

**Percentiles** split sorted data into 100 parts. The p-th percentile is the value below which p percent of the data falls. The 50th percentile is the median.

**Quartiles** are the 25th, 50th, and 75th percentiles:
- **Q1** (25th): a quarter of the data is below it
- **Q2** (50th): the median
- **Q3** (75th): three quarters below it

The **interquartile range (IQR)** is Q3 minus Q1, the spread of the middle 50 percent of the data.

```python
q1, q2, q3 = np.percentile(scores, [25, 50, 75])
q1, q2, q3
# (64.5, 71.0, 83.25)

iqr = q3 - q1
iqr
# 18.75
```

The IQR is **robust**: it ignores the extreme 25 percent on each end, so outliers do not affect it. That is why it is the backbone of the **box plot** and of outlier detection (below).

## Variance

The **variance** measures the average squared distance from the mean. Squaring does two things: it makes all distances positive (so they do not cancel), and it punishes large deviations more than small ones.

```
population variance:  sigma^2 = sum( (x - mu)^2 ) / N
sample variance:      s^2     = sum( (x - x-bar)^2 ) / (n - 1)
```

The big subtlety is the denominator. For a **sample** you divide by **n - 1**, not n. This is **Bessel's correction**. The reason: the sample mean sits closer to the sample's own points than the true population mean would, so squared deviations come out a little too small. Dividing by n - 1 instead of n inflates the estimate just enough to correct that bias.

```python
scores.var()           # numpy default divides by N (population)
# 151.01

scores.var(ddof=1)     # ddof=1 divides by n-1 (sample) <- use this for a sample
# 167.7889

import pandas as pd
pd.Series(scores).var() # pandas defaults to sample (n-1)
# 167.7889
```

Note the trap: **NumPy defaults to population variance (ddof=0), pandas defaults to sample variance (ddof=1).** When in doubt for real sample data, use the sample version.

## Standard Deviation

Variance is in squared units (squared exam points), which is hard to interpret. The **standard deviation** is just the square root of the variance, which brings it back to the original units.

```
sigma = sqrt(variance)
```

```python
scores.std()           # population
# 12.29

scores.std(ddof=1)     # sample <- usually what you want
# 12.95
```

So a typical exam score sits about 13 points away from the mean of 73.3. The standard deviation is the most used measure of spread because it is in the same units as the data and feeds directly into z-scores, the normal distribution, and nearly everything later.

## Mean Absolute Deviation (MAD)

The **MAD** is the average absolute distance from the mean. It is an alternative to standard deviation that does not square, so it is less swayed by extreme values and a bit easier to explain.

```python
np.mean(np.abs(scores - scores.mean()))
# 10.56
```

Standard deviation is far more common because of its mathematical properties, but MAD is more robust and shows up in robust statistics.

## Coefficient of Variation (CV)

The **CV** is the standard deviation divided by the mean, usually as a percent. It is a **relative** measure of spread, which lets you compare variability between datasets on different scales.

```
CV = (standard deviation / mean) * 100
```

```python
(scores.std(ddof=1) / scores.mean()) * 100
# 17.67 %
```

Example use: comparing the variability of house prices (hundreds of thousands) against shoe sizes (single digits). Their standard deviations are not comparable, but their CVs are.

## Z-scores and Standardization

A **z-score** says how many standard deviations a value is from the mean. It strips away the original units and centre, putting any value on a common scale.

```
z = (x - mean) / standard deviation
```

```python
mean, sd = scores.mean(), scores.std(ddof=1)
(95 - mean) / sd
# 1.68   <- the top score is 1.68 standard deviations above average

(55 - mean) / sd
# -1.41  <- the lowest score is 1.41 SDs below average
```

A positive z is above the mean, negative is below, and the magnitude is the distance. **Standardizing** a whole column (subtract mean, divide by SD) is one of the most common preprocessing steps in machine learning, because it puts features with different scales on equal footing.

## The Empirical Rule (68-95-99.7)

For data that is roughly **normal** (bell shaped, Note 07), standard deviation has a clean interpretation:

```
about 68% of values fall within 1 standard deviation of the mean
about 95% within 2 standard deviations
about 99.7% within 3 standard deviations
```

So if exam scores were normal with mean 73 and SD 13, about 95 percent of students would score between 47 and 99. A value beyond 3 SDs (z > 3 or z < -3) is rare, roughly 0.3 percent, which is one practical definition of an outlier.

## Symmetric vs Asymmetric Distributions

Before measuring shape, the first question is whether a distribution is **symmetric** or **asymmetric**.

- A **symmetric** distribution looks the same on both sides of its centre: fold it at the mean and the two halves match. The normal bell curve is the classic example, and here the mean, median, and mode all sit at the same point.
- An **asymmetric** distribution leans to one side, with one tail longer than the other. Income and house prices are asymmetric (a long right tail of high values).

The numeric measure of this asymmetry is **skewness**.

## Skewness: the Shape's Lean

**Skewness** measures asymmetry, which way the tail leans.

```
skew = 0    symmetric (balanced tails)
skew > 0    right-skewed / positive (long tail to the right, e.g. income)
skew < 0    left-skewed / negative (long tail to the left, e.g. exam scores with a floor)
```

```python
from scipy import stats
stats.skew(scores)
# 0.29   <- mild right skew, a couple of higher scores stretch the right side
```

This connects back to Note 02: in right-skewed data the mean sits above the median, because the long right tail pulls the mean.

## Kurtosis: the Shape's Tails

**Kurtosis** measures how heavy the tails are, that is, how prone the data is to extreme values, compared to a normal distribution.

```
high kurtosis (leptokurtic):  heavy tails, more outliers than normal
low kurtosis  (platykurtic):  light tails, fewer extremes
normal:                       reference point
```

scipy reports **excess kurtosis** (kurtosis minus 3), so a normal distribution reads 0.

```python
stats.kurtosis(scores)
# -1.06   <- negative, lighter tails than a normal distribution
```

In finance and risk, high kurtosis is a warning: extreme events happen more often than a normal model would predict.

## Detecting Outliers

Two standard rules, each tied to a measure above.

**1. The IQR rule** (robust, used by box plots). A point is an outlier if it falls below `Q1 - 1.5*IQR` or above `Q3 + 1.5*IQR`.

```python
q1, q3 = np.percentile(scores, [25, 75])
iqr = q3 - q1
low, high = q1 - 1.5*iqr, q3 + 1.5*iqr
low, high
# (36.375, 111.375)   any score outside this range is flagged; none here
```

**2. The z-score rule** (assumes roughly normal). Flag points with `|z| > 3` (sometimes 2).

```python
mean, sd = scores.mean(), scores.std(ddof=1)
z = (scores - mean) / sd
scores[np.abs(z) > 3]
# array([], ...)   no outliers by this rule either
```

Prefer the IQR rule when the data is skewed, since z-scores themselves get distorted by the very outliers you are hunting.

## Summary

| Measure | What it captures | Robust to outliers? | Units |
|---------|------------------|---------------------|-------|
| **Range** | total spread (max - min) | no | original |
| **IQR** | spread of middle 50% | yes | original |
| **Variance** | avg squared deviation | no | squared |
| **Std deviation** | typical distance from mean | no | original |
| **MAD** | avg absolute deviation | somewhat | original |
| **CV** | relative spread (SD/mean) | no | unitless % |
| **Skewness** | asymmetry / tail direction | no | unitless |
| **Kurtosis** | tail heaviness | no | unitless |

Centre plus spread plus shape gives a full descriptive picture of one variable. To reason about data you have not fully measured, you need probability, which is Note 04.

## Quick Self Check

1. Why divide by n - 1 instead of n for a sample variance?
2. NumPy's `.std()` and pandas' `.std()` give different numbers on the same data. Why?
3. A value has z = -2.5. Is it above or below the mean, and by how much?
4. Two datasets: SD 5 with mean 10, and SD 5 with mean 1000. Which is more variable in relative terms?
5. Mean = 50, median = 35. Positive or negative skew? Where is the long tail?
6. Why prefer the IQR rule over z-scores for finding outliers in skewed data?

<details>
<summary>Answers</summary>

1. Bessel's correction. The sample mean hugs its own data, making squared deviations too small, so dividing by n - 1 corrects the downward bias and gives an unbiased estimate of the population variance.
2. NumPy defaults to population (ddof=0, divide by N), pandas defaults to sample (ddof=1, divide by n-1).
3. Below the mean, by 2.5 standard deviations.
4. The first (CV = 50%) is far more variable relatively than the second (CV = 0.5%), even though both have SD 5.
5. Positive (right) skew, since mean > median. The long tail is on the right (high) side.
6. Outliers inflate the mean and standard deviation, which distorts z-scores themselves. The IQR uses quartiles, which the outliers do not move, so it stays reliable.
</details>
