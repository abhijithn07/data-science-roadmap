# UNIT 5: Feature Engineering

A machine learning model is only as good as the data we feed it. Feature engineering is the work we do on the raw columns to turn them into the best possible inputs for the model. There is a famous saying that data scientists spend most of their time here, because good features often matter more than the choice of algorithm. Feature engineering can be defined as follows.

**Feature engineering is the process of cleaning, creating, transforming and selecting the input features so that the model can learn from them effectively.**

In simple words, it is shaping the raw data into the best inputs for the model.

We will go through each part of feature engineering one by one.

---

## Missing Values

Real data almost always has gaps where a value should be but is not recorded. These are missing values, and they can be defined as follows.

**Missing values are the empty or unrecorded entries in a dataset where a value should exist.**

In simple words, they are the blanks in the data.

They matter because most machine learning algorithms cannot handle blanks at all; they either crash or produce wrong results. A tricky point is that missing values are not always shown as blank. Sometimes they are hidden as a 0 or as a value that is impossible in real life.

**Example**

In the diabetes dataset from the EDA notes, a Glucose value of 0 is impossible for a living person, so a 0 there really means the value was missing and was recorded as 0. So before handling missing values, we first replace those impossible zeros with a proper missing marker (NaN), and only then do we count and fix them.

---

## Imputation Techniques

Once we know where the missing values are, we usually fill them rather than delete the whole row. This filling is called imputation. It can be defined as follows.

**Imputation is the process of filling missing values with sensible estimates instead of leaving them blank or deleting the row.**

In simple words, it is filling the blanks with reasonable values.

There are several techniques, and the choice depends on the column.

- **Mean imputation:** fill missing numeric values with the column's mean. Good for roughly symmetric data.
- **Median imputation:** fill with the median. Better for skewed data, because the median is not dragged around by outliers.
- **Mode imputation:** fill with the most frequent value. Used for categorical columns.
- **Forward or backward fill:** use the previous or next value. Used mostly in time series data.
- **Model-based imputation:** predict the missing value from the other columns, for example using a KNN imputer or a regression model. More accurate but heavier.
- **Dropping:** if a column or row has too many missing values, sometimes it is best to remove it.

**Example**

In the diabetes data, Glucose and BloodPressure were fairly symmetric, so we filled them with the mean, while SkinThickness, Insulin and BMI were skewed, so we filled them with the median. This is exactly why skewness from the statistics notes matters: the shape of the column decides whether the mean or the median is the safer fill.

---

## Outlier Detection

An outlier is a value that sits far away from the rest of the data, and finding them is called outlier detection. It can be defined as follows.

**Outlier detection is the process of finding data points that are very different from the rest of the data.**

In simple words, it is finding the values that do not fit with the rest.

There are a few common methods.

- **IQR method:** a value is an outlier if it is below Q1 minus 1.5 times the IQR, or above Q3 plus 1.5 times the IQR. This is the box plot rule.
- **Z-score method:** for roughly normal data, a value with a z-score beyond 3 (more than 3 standard deviations from the mean) is treated as an outlier.
- **Visualization:** box plots and scatter plots make outliers easy to spot by eye.

**Example**

Suppose for a column Q1 is 60 and Q3 is 80, so the IQR is 20 and 1.5 times the IQR is 30. Then any value below 60 minus 30 = 30, or above 80 plus 30 = 110, is flagged as an outlier. A value of 250 would clearly be caught.

---

## Outlier Treatment

Finding outliers is only half the job; we then decide what to do with them. This is outlier treatment. It can be defined as follows.

**Outlier treatment is the process of deciding what to do with outliers once they are found, such as removing, capping, transforming or keeping them.**

In simple words, it is handling the outliers we found.

The options are:

- **Remove:** delete them, but only if they are clearly errors (like an age of 200).
- **Cap (winsorize):** replace an extreme value with the nearest acceptable boundary value instead of deleting it.
- **Transform:** apply a function like the log to squash the extremes so they hurt the model less.
- **Keep:** sometimes an outlier is the most important data point, so we keep it.

**Note**

Not every outlier is bad. In fraud detection, a fraudulent transaction is itself an outlier, and it is exactly the thing we want to catch. So we should understand why a value is extreme before deleting it.

---

## Scaling

Numeric features often live on very different scales, and many models get confused by that. Scaling fixes it. It can be defined as follows.

**Feature scaling is the process of bringing all numeric features onto a similar range or scale.**

In simple words, it is putting all features on the same scale.

Why it is needed: if income is in the tens of thousands and age is in the tens, a distance-based model like KNN will think income matters far more, simply because its numbers are bigger. Models that need scaling include KNN, SVM, logistic regression, neural networks, and anything using gradient descent. Tree-based models like decision trees and random forests do not need scaling, because they split on thresholds, not distances. The two main scaling methods are standardization and normalization.

---

## Standardization

Standardization is the most common scaling method. It can be defined as follows.

**Standardization rescales a feature so that it has a mean of 0 and a standard deviation of 1, using the z-score.**

In simple words, it centres the data around 0 with a spread of 1.

Formula: z = (x - mean) / standard deviation. After standardization, a value equal to the mean becomes 0, a value one standard deviation above becomes +1, and so on. The result is not bounded to any fixed range.

**Example**

If a column has mean 50 and standard deviation 10, then a value of 70 becomes (70 - 50) / 10 = 2, meaning it is two standard deviations above average. Standardization is preferred when the data is roughly normal, or for algorithms that expect centred data.

---

## Normalization

Normalization, also called min-max scaling, squeezes the data into a fixed range. It can be defined as follows.

**Normalization rescales a feature to a fixed range, usually between 0 and 1.**

In simple words, it squeezes all values to lie between 0 and 1.

Formula: x_scaled = (x - minimum) / (maximum - minimum). The smallest value becomes 0, the largest becomes 1, and everything else lands in between.

**Example**

If a column ranges from 20 to 220, then a value of 120 becomes (120 - 20) / (220 - 20) = 100 / 200 = 0.5. Normalization is useful when we need bounded values, such as for image pixel values or some neural networks. Its weakness is that it is sensitive to outliers, because one huge value stretches the whole range.

**Difference between Standardization and Normalization**

| Standardization | Normalization |
| --- | --- |
| Mean 0, standard deviation 1 | Range 0 to 1 |
| Not bounded | Bounded between 0 and 1 |
| Uses mean and standard deviation | Uses minimum and maximum |
| Better when data is normal | Better when a fixed range is needed |
| Less affected by outliers | More affected by outliers |

---

## Encoding

Models work with numbers, but many columns are text categories like city or gender. Encoding converts them. It can be defined as follows.

**Encoding is the process of converting categorical (text) data into numbers so that a model can use it.**

In simple words, it is turning labels into numbers.

The main types are:

- **Label Encoding:** give each category a number, like red = 0, blue = 1, green = 2. It is simple, but for nominal data it is risky, because the model may wrongly think green (2) is greater than red (0).
- **One-Hot Encoding:** create a separate 0 or 1 column for each category. For colors, we get a "is_red", "is_blue" and "is_green" column. This avoids any fake order, which makes it the right choice for nominal data, though it can create many columns if there are many categories.
- **Ordinal Encoding:** give numbers that respect the natural order, like small = 1, medium = 2, large = 3. This is correct for ordinal data, where the order is real.

**Example**

For a nominal column like city (Tampa, Miami, Orlando), we use one-hot encoding so the model does not assume one city is greater than another. For an ordinal column like size (small, medium, large), we use ordinal encoding because the order is genuine.

---

## Feature Transformation

Sometimes a feature is hard for the model to use because of its shape, and a mathematical function fixes it. This is feature transformation. It can be defined as follows.

**Feature transformation is changing the shape or scale of a feature using a mathematical function to make it more useful for the model.**

In simple words, it is reshaping a feature so the model learns from it better.

The most common transformations handle skew. A log transform compresses a long right tail and makes a skewed feature more symmetric. Square root and power transforms (like Box-Cox or Yeo-Johnson) do similar jobs.

**Example**

Income is usually right-skewed, with most people earning a modest amount and a few earning enormous amounts. If we take the log of income, the distribution becomes much more symmetric, which helps linear models that work better on balanced, normal-like features.

---

## Feature Selection

More features are not always better. Feature selection keeps only the useful ones. It can be defined as follows.

**Feature selection is the process of choosing only the most useful features and removing the irrelevant or redundant ones.**

In simple words, it is keeping the columns that matter and dropping the rest.

This helps because fewer features mean a faster, simpler model that is less likely to overfit and is easier to understand. There are three families of methods.

- **Filter methods:** rank features using statistics like correlation or chi-square, before any model is built. They are fast.
- **Wrapper methods:** try different subsets of features and test the model on each, such as forward selection, backward elimination, or recursive feature elimination. They are thorough but slow.
- **Embedded methods:** selection happens automatically during training, such as Lasso regression shrinking useless features to zero, or a tree giving feature importance scores.

**Example**

If two features, "loan amount in rupees" and "loan amount in dollars", carry the same information, feature selection drops one of them because it is redundant.

---

## Dimensionality Reduction

When there are too many features, even after selection, we can combine them into fewer new ones. This is dimensionality reduction. It can be defined as follows.

**Dimensionality reduction is the process of reducing the number of features by combining them into fewer new features, while keeping most of the information.**

In simple words, it is squeezing many columns into a few without losing much.

It is different from feature selection: selection keeps some of the original columns and drops the rest, while reduction creates brand-new combined columns. We need it because too many features cause the curse of dimensionality, where the data becomes sparse, models overfit, and computation slows down. The most common technique is PCA.

---

## PCA (Principal Component Analysis)

PCA is the standard dimensionality reduction method. It can be defined as follows.

**PCA is a dimensionality reduction technique that combines correlated features into a smaller set of new features, called principal components, which capture most of the variation in the data.**

In simple words, PCA finds new directions that capture the most spread in the data, and keeps only the top few.

It works by finding the directions (principal components) along which the data varies the most. The first principal component captures the largest amount of variation, the second captures the next largest, and so on. We then keep just enough components to retain most of the information, for example enough to keep 95 percent of the total variance, and drop the rest.

**Example**

The diabetes data has 8 medical features. PCA could combine them into just 2 principal components so we can plot the patients on a simple 2D chart, while still keeping most of the original information. The cost is that the new components are not as easy to interpret as the original columns like Glucose or BMI, so we trade interpretability for compactness.

---

## Data Leakage

Data leakage is one of the most dangerous and sneaky mistakes in machine learning. It can be defined as follows.

**Data leakage is when information that would not be available at prediction time accidentally gets into the training data, giving the model an unfair hint.**

In simple words, the model accidentally sees the answer during training, so it looks great in testing but fails in real life.

Common ways it happens:

- Including a feature that is basically the target in disguise, for example using a column "loan written off" while trying to predict loan default.
- Scaling or imputing using the whole dataset before splitting into train and test. The test set's information then leaks into training. The fix is to fit the scaler and imputer on the training set only, then apply them to the test set.
- Time leakage, where future information is used to predict the past.

**Note**

Leakage produces amazing test scores that completely collapse in production. The safe rule is to always split the data first, and only then do preprocessing using information from the training set.

---

## Class Imbalance

In classification, sometimes one class is far rarer than the other, which creates problems. This is class imbalance. It can be defined as follows.

**Class imbalance is when one class in a classification problem has far more examples than the other class or classes.**

In simple words, one group is much bigger than the other.

**Example**

In fraud detection, about 99 percent of transactions are legitimate and only 1 percent are fraud. A lazy model that always predicts "legitimate" would be 99 percent accurate while catching zero fraud, which is useless. This is why accuracy is misleading on imbalanced data, and we must use precision, recall and F1 instead. We handle imbalance by resampling the data (adding more minority examples or removing some majority examples), by using SMOTE, or by giving the rare class a higher weight during training.

---

## SMOTE

SMOTE is a smart way to fix class imbalance. It can be defined as follows.

**SMOTE (Synthetic Minority Oversampling Technique) is a method that creates new, synthetic examples of the minority class to balance the dataset.**

In simple words, instead of just copying the rare examples, SMOTE creates new, realistic ones that lie between existing minority points.

It works by taking a minority class point, finding its nearest minority neighbors, and creating a new point somewhere on the line between them. This adds variety, which is better than plain oversampling that simply duplicates the same rare rows and causes the model to overfit those exact points.

**Note**

SMOTE should be applied only to the training set, and only after the train-test split, otherwise synthetic data leaks into the test set and we get data leakage. This is a very common beginner mistake.
