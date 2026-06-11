# 02. Measures of Central Tendency

## The Idea

A **measure of central tendency** is a single number that represents the "centre" or typical value of a dataset. It answers "if I had to summarize all these values with one number, what would it be?" The three classics are the **mean**, the **median**, and the **mode**, and the whole skill is knowing which one to trust for a given dataset.

We use the working example: exam scores of 10 students.

```python
import numpy as np
import pandas as pd

scores = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
```

## The Mean

The **mean** (arithmetic average) is the sum of all values divided by how many there are. It is the balance point of the data.

```
mean = (sum of all values) / (number of values)
```

```python
scores.mean()
# 73.3

# by hand: 733 / 10 = 73.3
```

Two notations matter for the population vs sample distinction from Note 01:

- population mean is **mu** = (sum of x) / N
- sample mean is **x-bar** = (sum of x) / n

The formula is identical, the symbol just signals whether you measured everyone or a sample.

**Strength:** uses every value, has nice mathematical properties, and is the basis for variance, regression, and most of statistics.

**Weakness:** very sensitive to **outliers**. One extreme value drags it. Watch what happens if the top student scored 195 by some grading error:

```python
bad = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 195])
bad.mean()
# 83.3   <- one wrong value pulled the "typical" score up by 10 points
```

## The Median

The **median** is the middle value when the data is sorted. Half the values sit below it, half above.

- odd count: the single middle value
- even count: the average of the two middle values

Our 10 scores are already sorted, so the median is the average of the 5th and 6th values (70 and 72).

```python
np.median(scores)
# 71.0   <- average of 70 and 72

np.median(bad)
# 71.0   <- unchanged by the 195 outlier
```

That last line is the key insight: the median barely moved when one value blew up, because it only cares about position, not magnitude. The median is **robust** to outliers.

This is why income and house prices are almost always reported as medians. A few billionaires pull the mean income far above what a typical person earns, while the median stays representative.

## The Mode

The **mode** is the value that appears most often. It is the only measure of central tendency that works on **categorical** data (the most common color, the most frequent product).

```python
from scipy import stats
stats.mode([1, 2, 2, 3, 3, 3, 4], keepdims=False)
# ModeResult(mode=3, count=3)
```

A dataset can have:
- one mode (**unimodal**)
- two modes (**bimodal**), often a sign two different groups are mixed together
- no mode, if every value is unique

For continuous data the raw mode is rarely useful (values almost never repeat exactly), so you talk about the modal **bin** of a histogram instead, the tallest bar.

## Mean vs Median vs Mode: Which to Use

The relationship between the three tells you about the **shape** of the distribution.

```
Symmetric:          mean = median = mode        (the normal bell curve)
Right-skewed:       mode < median < mean         (long tail to the right, e.g. income)
Left-skewed:        mean < median < mode         (long tail to the left)
```

The mean gets pulled toward the long tail, the median resists. So a mean much larger than the median is a quick signal of right skew and likely outliers.

Practical rule:
- **symmetric, no outliers** -> use the mean, it uses all the information
- **skewed or has outliers** -> use the median, it stays representative
- **categorical data** -> use the mode, it is the only option

```python
df = pd.DataFrame({"exam_score": scores})
print("mean  ", df.exam_score.mean())     # 73.3
print("median", df.exam_score.median())   # 71.0
# mean slightly above median -> mild right skew, a couple of high scorers
```

## Weighted Mean

When values do not all count equally, use a **weighted mean**: multiply each value by its weight, sum, and divide by the total weight.

```
weighted mean = (sum of w*x) / (sum of w)
```

The classic case is a course grade where assignments are worth different percentages.

```python
grades  = np.array([85, 90, 78])          # exam, project, homework
weights = np.array([0.5, 0.3, 0.2])       # their weights

np.average(grades, weights=weights)
# 85.1   = 0.5*85 + 0.3*90 + 0.2*78
```

A plain mean would give 84.33 and treat all three equally, which would be wrong here.

## Trimmed Mean

A **trimmed mean** removes a percentage of the smallest and largest values before averaging. It is a compromise: more robust than the mean, but still uses most of the data. Judges in scored sports (drop the highest and lowest) use this idea.

```python
from scipy import stats
stats.trim_mean(bad, 0.1)   # trim 10% from each end
# 72.875   <- close to the median, the 195 outlier was trimmed off
```

## Summary

| Measure | Formula idea | Best for | Weakness |
|---------|--------------|----------|----------|
| **Mean** | sum / count | symmetric numeric data | sensitive to outliers |
| **Median** | middle of sorted data | skewed data, outliers | ignores actual magnitudes |
| **Mode** | most frequent value | categorical, finding peaks | unstable for continuous data |
| **Weighted mean** | sum(w*x) / sum(w) | values with different importance | needs correct weights |
| **Trimmed mean** | mean after cutting the tails | mild outliers | discards data, choose trim % |

The central value is only half the story. Two datasets can have the same mean and look completely different, one tightly clustered and one wildly spread out. That spread is the subject of Note 03.

## Quick Self Check

1. A dataset is [10, 12, 14, 16, 500]. Which is more representative of a typical value, the mean or the median? Why?
2. Your company reports a mean salary of 120k and a median of 80k. What does that gap tell you about the salary distribution?
3. Why is the mode the only one of the three that works for "favorite ice cream flavor"?
4. Compute the weighted mean of scores [70, 90] with weights [0.25, 0.75].
5. If mean > median, is the data more likely left-skewed or right-skewed?

<details>
<summary>Answers</summary>

1. The median (14). The single value 500 is an outlier that drags the mean up to about 110, which represents none of the data well.
2. Mean far above median means right skew: a smaller number of high earners pull the mean up while most people earn nearer the median.
3. Flavors are nominal categorical data. You cannot add or rank them, so mean and median are undefined, but you can count which appears most.
4. 0.25*70 + 0.75*90 = 17.5 + 67.5 = 85.
5. Right-skewed. The long right tail pulls the mean above the median.
</details>
