# UNIT 7: Relationships Between Variables

These topics measure how two variables move together. This is very important in machine learning for feature selection and for understanding data.

---

## 1. Correlation

**Correlation measures the strength and direction of the relationship between two variables.**

In simple words, it tells us if two things move together, and how strongly.

**Direction**

- Positive correlation: both increase together (height and weight).
- Negative correlation: one increases while the other decreases (price and demand).
- Zero correlation: no relationship.

**Value**: correlation ranges from -1 to +1.
- +1 = perfect positive, -1 = perfect negative, 0 = no linear relationship.

**Note (very important)**: correlation does NOT mean causation. Two things moving together does not mean one causes the other.

---

## 2. Pearson Correlation

**Pearson correlation measures the strength of a linear (straight-line) relationship between two numerical variables.**

In simple words, it checks how well the data fits a straight line.

**Conditions**

- Both variables are numerical.
- The relationship is linear.
- The data is roughly normal.

**Note**: Pearson is the default correlation, but it only catches straight-line relationships.

---

## 3. Spearman Correlation

**Spearman correlation measures the strength of the relationship using the rank (order) of the values instead of the actual values.**

In simple words, it checks if two variables move in the same order, even if not in a straight line.

**Use**

- When the data is ordinal.
- When the relationship is not linear but still increasing or decreasing.
- When there are outliers (it is more robust than Pearson).

**Difference (Pearson vs Spearman)**

| Pearson | Spearman |
| --- | --- |
| Uses actual values | Uses ranks |
| Needs a linear relationship | Works for any increasing or decreasing relationship |
| Affected by outliers | More robust to outliers |

---

## 4. Covariance

**Covariance measures the direction in which two variables change together.**

In simple words, it tells us if two variables increase together or move in opposite directions.

- Positive covariance: they move in the same direction.
- Negative covariance: they move in opposite directions.

**Note**: covariance only gives the direction, not the strength, and its value depends on the units. Correlation is the standardized version of covariance (it removes units and gives a clear -1 to +1 scale).

---

## 5. Multicollinearity

**Multicollinearity is a situation where two or more input features are highly correlated with each other.**

In simple words, two features carry almost the same information.

**Why it is a problem**

- It makes a regression model unstable.
- It becomes hard to tell which feature is really important.

**How to detect**: use a correlation matrix, or the Variance Inflation Factor (VIF). A VIF above 5 or 10 signals a problem.

**How to fix**: remove one of the correlated features, or combine them, or use PCA.

**Note**: multicollinearity mainly affects linear models. Tree-based models (like Random Forest) are less affected.
