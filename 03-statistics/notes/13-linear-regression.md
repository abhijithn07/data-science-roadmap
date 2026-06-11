# 13. Linear Regression

## Why Regression

Correlation (Note 12) measures how strongly two variables relate. **Regression** goes further: it fits an equation so you can **predict** one variable from others and **quantify** the effect of each. It is both a core statistical tool and your first machine learning model, the bridge into Week 4.

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm

hours  = np.array([2, 3, 4, 5, 5, 6, 7, 8, 9, 11])
scores = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
```

## Simple Linear Regression

**Simple linear regression** fits a straight line through the data with one predictor:

```
y = b0 + b1 * x  +  error
```

- `y` is the **dependent** variable (target) you predict
- `x` is the **independent** variable (feature/predictor)
- `b0` is the **intercept**: the predicted y when x = 0
- `b1` is the **slope**: how much y changes per one-unit increase in x

## Ordinary Least Squares (OLS)

How is the "best" line chosen? **OLS** picks the line that minimizes the sum of squared **residuals**, where a residual is the vertical gap between an actual point and the line.

```
residual = actual y  -  predicted y
OLS minimizes sum( residual^2 )
```

Squaring keeps positive and negative errors from cancelling and penalizes big misses more. The result is one unique best-fit line.

```python
X = sm.add_constant(hours)        # adds the intercept term
model = sm.OLS(scores, X).fit()

model.params
# const    45.614     <- intercept b0
# x1        4.614     <- slope b1
```

## Interpreting the Coefficients

This is the whole payoff, so read it carefully.

- **slope b1 = 4.614:** each additional hour of study is associated with about **4.6 more exam points**. The sign and size of the slope is usually the headline result.
- **intercept b0 = 45.614:** a student who studied 0 hours is predicted to score about 45.6. Interpret the intercept only if x = 0 is meaningful and within your data range, otherwise it is just where the line crosses the axis.

```python
# predict the score for 6 hours of study
b0, b1 = model.params
b0 + b1 * 6
# 73.30
```

## R-squared: Goodness of Fit

**R-squared** is the fraction of the variation in y that the model explains, from 0 to 1. R-squared of 0.80 means the predictors explain 80 percent of the variance in the target, leaving 20 percent unexplained.

```python
round(model.rsquared, 4)
# 0.9870   the model explains about 99% of the variation in scores
```

For simple regression, R-squared is just the square of the Pearson correlation from Note 12 (0.9935^2 = 0.987). Higher is better, but a high R-squared does not mean the model is correct or that the relationship is causal, only that the line fits these points well.

## The Full Summary

`statsmodels` prints a complete diagnostic table. The pieces you read most:

```python
print(model.summary())
# coef      each b0, b1
# std err   uncertainty in each coefficient
# t, P>|t|  test of whether each coefficient is really nonzero (p < 0.05 = significant)
# R-squared overall fit
# [0.025  0.975]  a 95% confidence interval for each coefficient
```

So a coefficient comes with its own hypothesis test (Note 10): is this predictor's effect significantly different from zero? A low p-value on the slope means the relationship is unlikely to be noise.

## Multiple Linear Regression

Real problems have several predictors. **Multiple regression** extends the line to a plane (or hyperplane):

```
y = b0 + b1*x1 + b2*x2 + ... + bk*xk  +  error
```

```python
df = pd.DataFrame({
    "hours":    hours,
    "absences": [8, 6, 5, 4, 5, 3, 2, 1, 1, 0],
    "scores":   scores,
})
X = sm.add_constant(df[["hours", "absences"]])
m2 = sm.OLS(df["scores"], X).fit()
m2.params.round(3)
# const       46.633
# hours        4.512
# absences    -0.116    (small and, here, not significant: hours dominates)
```

Each coefficient now means the effect of that predictor **holding the others constant**. That "controlling for" interpretation is what makes multiple regression so useful: it isolates one variable's effect from the others. Watch for **multicollinearity**, when predictors are strongly correlated with each other (here hours and absences are), which makes individual coefficients unstable and hard to interpret.

## The Assumptions (LINE)

OLS inference is valid only if these roughly hold. The mnemonic is **LINE**:

- **L, Linearity:** the relationship between predictors and target is actually linear. Check a scatter or residual plot.
- **I, Independence:** residuals are independent of each other (a concern with time series).
- **N, Normality:** residuals are approximately normally distributed (matters for p-values and intervals, less for prediction).
- **E, Equal variance (homoscedasticity):** residual spread is constant across the range of predictions. A funnel shape in the residual plot signals a violation.

## Residual Analysis

The residuals are where you check the assumptions. Plotting residuals against predicted values is the key diagnostic.

```python
predicted = model.predict(X if False else sm.add_constant(hours))
residuals = scores - predicted
round(residuals.mean(), 6)
# 0.0   OLS residuals always sum to (essentially) zero
```

What you want to see: residuals scattered randomly around 0 with no pattern. What signals trouble: a curve (nonlinearity), a funnel (unequal variance), or clear outliers pulling the line. A good residual plot is "boring", which is exactly the goal.

## Summary

| Term | Meaning |
|------|---------|
| Intercept (b0) | predicted y when all x = 0 |
| Slope (b1) | change in y per one-unit change in x |
| OLS | fits the line by minimizing sum of squared residuals |
| Residual | actual y minus predicted y |
| R-squared | fraction of variance in y explained (0 to 1) |
| Multiple regression | several predictors, each interpreted "holding others constant" |
| LINE | linearity, independence, normality, equal variance assumptions |

Regression both predicts and explains, which is why it sits at the boundary of statistics and machine learning. In Week 4 the same OLS line becomes "linear regression, the model", and the assumptions and residual checks carry straight over.

## Quick Self Check

1. In `score = 45.6 + 4.6 * hours`, what does the 4.6 mean in plain words?
2. R-squared is 0.0. What does that say about the model?
3. Why does OLS square the residuals instead of just summing them?
4. In multiple regression, how do you interpret a single coefficient?
5. You plot residuals vs predicted values and see a funnel shape (spreading out). Which LINE assumption is violated?
6. A model has R-squared 0.95. Does that prove the predictor causes the target?

<details>
<summary>Answers</summary>

1. Each additional hour of study is associated with about 4.6 more exam points, on average.
2. The model explains none of the variance in y, the predictors are useless for predicting the target with this linear fit.
3. Squaring stops positive and negative residuals from cancelling and penalizes large errors more heavily, giving one unique best-fit line.
4. As the effect of that predictor on the target while holding all the other predictors constant.
5. Equal variance (homoscedasticity). The spread of residuals should be constant, not fan out.
6. No. High R-squared means a good fit, not causation. Causation needs a controlled experiment (Note 15).
</details>
