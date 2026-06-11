# 12. Correlation and Covariance

## From One Variable to Two

Notes 02 and 03 described a single variable. Now we ask how **two** variables move together. Do students who study more score higher? Does ad spend track with sales? Covariance and correlation quantify that relationship.

```python
import numpy as np
import pandas as pd
from scipy import stats

hours  = np.array([2, 3, 4, 5, 5, 6, 7, 8, 9, 11])
scores = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
```

## Covariance

**Covariance** measures the direction two variables vary together. When one is above its mean, is the other usually above (positive) or below (negative) its own mean?

```
cov(X, Y) = sum( (x - x-bar)(y - y-bar) ) / (n - 1)
```

```python
np.cov(hours, scores, ddof=1)[0, 1]
# 35.889   positive: more hours tends to go with higher scores
```

The sign is informative (positive = move together, negative = move oppositely, near zero = no linear link), but the **magnitude is not interpretable**, because covariance is in the product of the two units (hours times points). Change hours to minutes and the number changes wildly even though the relationship is identical. That problem is exactly what correlation fixes.

## Pearson Correlation

The **Pearson correlation coefficient (r)** is covariance standardized by both standard deviations, which strips out the units and forces the result into a fixed range.

```
r = cov(X, Y) / (sd_X * sd_Y)
```

It always lies between -1 and +1:

```
r =  1    perfect positive linear relationship
r =  0    no linear relationship
r = -1    perfect negative linear relationship
```

```python
r, p_value = stats.pearsonr(hours, scores)
round(r, 4), p_value
# (0.9935, 7.9e-09)   very strong positive linear relationship, highly significant
```

Rough reading of `|r|`: below 0.3 is weak, 0.3 to 0.7 is moderate, above 0.7 is strong. Pearson comes with a p-value testing whether the true correlation is 0.

**Pearson's key limitation:** it only captures **linear** relationships. A perfect curved (for example U-shaped) relationship can have r near 0. Always plot a scatter, never trust r alone. This is the lesson of Anscombe's Quartet: four datasets with identical r that look completely different.

## Spearman Correlation

The **Spearman rank correlation** measures **monotonic** relationships (consistently increasing or decreasing, even if curved). It is Pearson applied to the **ranks** of the data instead of the raw values. Use it when the relationship is monotonic but not linear, when the data is ordinal, or when outliers would distort Pearson.

```python
rho, p_value = stats.spearmanr(hours, scores)
round(rho, 4)
# 0.997   robust to nonlinearity and outliers
```

Pearson asks "do they move together in a straight line", Spearman asks "do they move together in the same direction at all".

## Correlation Matrix

With many variables, a **correlation matrix** shows every pairwise correlation at once. `df.corr()` is the standard tool, and a heatmap makes patterns pop out.

```python
df = pd.DataFrame({
    "hours": hours,
    "scores": scores,
    "absences": [8, 6, 5, 4, 5, 3, 2, 1, 1, 0],
})
df.corr().round(2)
#           hours  scores  absences
# hours      1.00    0.99     -0.97
# scores     0.99    1.00     -0.96
# absences  -0.97   -0.96      1.00
```

The diagonal is always 1 (a variable correlates perfectly with itself), and the matrix is symmetric. Here absences correlate negatively with both, which makes sense. Correlation matrices are a fast way to spot related features before modeling, and to catch redundant ones.

## Correlation Does Not Imply Causation

The single most important caveat in statistics. A strong correlation between X and Y can arise from several causes:

- X causes Y
- Y causes X (reverse causation)
- a third variable Z causes both (a **confounder**)
- pure coincidence (especially with many variables, Note 16)

The classic example: ice cream sales correlate with drowning deaths. Neither causes the other, hot weather (the confounder) drives both. To establish causation you need a controlled experiment (Note 15), not just a correlation.

```python
# strong correlation, but study hours did not "cause" anything here without an experiment
# it is consistent with causation, but does not prove it
round(stats.pearsonr(hours, scores)[0], 3)
# 0.994
```

## Summary

| Measure | Range | Captures | Robust to outliers? |
|---------|-------|----------|---------------------|
| **Covariance** | unbounded | direction only (units matter) | no |
| **Pearson r** | -1 to 1 | linear strength and direction | no |
| **Spearman rho** | -1 to 1 | monotonic strength and direction | yes |

Key points: covariance gives direction but its size is unreadable, Pearson standardizes it to -1..1 for linear relationships, Spearman uses ranks for monotonic ones, and correlation never proves causation. Correlation measures a relationship's strength. To actually model and predict one variable from another, you fit a line, which is regression in Note 13.

## Quick Self Check

1. Why is the magnitude of covariance hard to interpret, and what fixes it?
2. A scatter shows a clear U-shape. Pearson r is about 0. What went wrong, and which measure might do better?
3. r = -0.85 between hours of TV and exam score. Describe the relationship in words.
4. Ice cream sales correlate with drownings. Explain without claiming one causes the other.
5. When would you choose Spearman over Pearson?

<details>
<summary>Answers</summary>

1. Covariance is in the product of the two variables' units, so its size depends on scale. Standardizing by both standard deviations gives Pearson r, which is unit-free and bounded in -1..1.
2. Pearson only detects linear relationships, and a U-shape is nonlinear. A scatter plot reveals it, and Spearman or a nonlinear model would capture it better (though a symmetric U can fool Spearman too, so plotting is essential).
3. A strong negative linear relationship: more TV hours tend to go with lower exam scores.
4. A confounder, hot weather, drives both: heat raises ice cream sales and also raises swimming, which raises drownings. The two are associated but neither causes the other.
5. When the relationship is monotonic but not linear, when the data is ordinal, or when outliers would distort Pearson.
</details>
