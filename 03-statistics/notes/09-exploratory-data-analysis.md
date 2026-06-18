# UNIT 9: Exploratory Data Analysis (EDA)

EDA is where statistics meets real data. After learning the concepts (central tendency, spread, distributions), we now apply them to a real dataset from start to finish: load it, clean it, understand it with statistics and plots, then build a simple model.

**EDA (Exploratory Data Analysis) is the process of understanding a dataset before modeling, by cleaning it and examining it using statistics and visualizations.**

In simple words, EDA is getting to know your data before doing anything with it.

**Why EDA is important**

- It finds data quality problems (missing values, wrong values, outliers).
- It shows the shape and relationships in the data.
- It tells us which features matter and how to prepare them for a model.

**The full EDA pipeline (steps)**

1. Load and inspect the data
2. Descriptive statistics
3. Find and fix missing values
4. Impute the missing values
5. Visualize distributions and relationships
6. Scale the features
7. Train/test split and cross validation
8. Build a model
9. Evaluate the model

(Example used in class: the Pima Indians Diabetes dataset. Each patient has 8 medical measurements, and `Outcome` is 1 for diabetes, 0 for no diabetes.)

---

## 1. Load and Inspect the Data

The first step is to load the data and look at it.

- **`head()`**: shows the first 5 rows, to see what the data looks like.
- **`info()`**: shows the data types, the non-null count per column, and memory usage. The quickest way to spot missing values.
- **`describe()`**: gives the summary statistics (count, mean, std, min, quartiles, max) for every numeric column at once. This is the descriptive statistics from Unit 2 applied to the whole table.

```python
import pandas as pd
df = pd.read_csv('diabetes.csv')
df.head()           # first 5 rows
df.info()           # dtypes and null counts
df.describe().T     # summary stats (.T transposes for easier reading)
```

**Note**: `describe()` is the fastest way to spot a problem, because the min and max values often reveal bad data.

---

## 2. Find Missing Values

Missing data is not always shown as blank. Sometimes a missing value is hidden as a 0 or some other impossible value.

In the diabetes data, a value of 0 is impossible for a living person in columns like Glucose, BloodPressure, SkinThickness, Insulin and BMI. So a 0 there really means the value was missing.

**The fix**: replace those impossible zeros with NaN (the proper "missing" marker), then count them.

```python
import numpy as np
cols = ['Glucose', 'BloodPressure', 'SkinThickness', 'Insulin', 'BMI']
df[cols] = df[cols].replace(0, np.nan)   # mark impossible zeros as missing
df.isnull().sum()                        # count missing values per column
```

**Note**: always check whether 0 is a real value or a hidden missing value. (Pregnancies and Outcome can genuinely be 0, so we leave them alone.)

---

## 3. Impute the Missing Values

**Imputation is the process of filling missing values with sensible estimates.**

In simple words, replacing the blanks with a reasonable number.

**The rule (uses skewness from Unit 2)**

- If a column is roughly symmetric, fill with the **mean**.
- If a column is skewed, fill with the **median** (because the median is not distorted by outliers).

```python
# symmetric columns -> mean
df['Glucose'] = df['Glucose'].fillna(df['Glucose'].mean())
df['BloodPressure'] = df['BloodPressure'].fillna(df['BloodPressure'].mean())
# skewed columns -> median
df['SkinThickness'] = df['SkinThickness'].fillna(df['SkinThickness'].median())
df['Insulin'] = df['Insulin'].fillna(df['Insulin'].median())
df['BMI'] = df['BMI'].fillna(df['BMI'].median())
df.isnull().sum()   # should all be 0 now
```

**Note**: this is exactly why we learned skewness. The shape of the column decides whether we use the mean or the median.

---

## 4. Visualize Distributions and Relationships

After cleaning, we look at the data with plots. Each plot answers a different question.

- **Histogram (`df.hist()`)**: shows the shape (distribution) of each column. Used to check if a column is symmetric or skewed.
- **missingno bar (`msno.bar(df)`)**: a visual check that no missing values are left (full bars = complete).
- **Class balance (`df.Outcome.value_counts()`)**: counts how many of each target class. If one class is much bigger, the data is **imbalanced**, which matters for splitting and evaluation.
- **Scatter matrix**: plots every feature against every other, with histograms on the diagonal. A fast scan of all pairwise relationships.
- **Pair plot (`sns.pairplot(df, hue='Outcome')`)**: the prettier version, colored by the target. Where the colors separate, that feature helps tell the classes apart.
- **Correlation heatmap (`sns.heatmap(df.corr(), annot=True)`)**: shows the Pearson correlation between every pair of columns. Look down the target row to find the features most related to the outcome. (In the diabetes data, Glucose has the strongest correlation with Outcome.)
- **Q-Q plot (`scipy.stats.probplot`)**: plots the data's quantiles against the quantiles of a normal distribution. If the points fall close to a straight line, the data is roughly normal. In simple words, it is a visual test for normality, useful before tests that assume normal data.

```python
import seaborn as sns
df.hist(figsize=(20, 20))               # distribution of each column
df.Outcome.value_counts()               # class balance
sns.pairplot(df, hue='Outcome')         # relationships, colored by class
sns.heatmap(df.corr(), annot=True)      # correlation heatmap
```

**Note**: a class imbalance (here about 65 percent class 0, 35 percent class 1) must be remembered later when we split and evaluate.

---

## 5. Feature Scaling (Standardization)

Features are often on very different scales (Insulin in the hundreds, DiabetesPedigreeFunction below 1). Many models work better when all features are on the same scale.

**Standardization rescales each column to have mean 0 and standard deviation 1, using the z-score.**

In simple words, it puts every feature on the same scale.

Formula: z = (x - mean) / standard deviation

```python
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X = pd.DataFrame(sc.fit_transform(df.drop(['Outcome'], axis=1)),
                 columns=df.drop(['Outcome'], axis=1).columns)
y = df['Outcome']
```

**Note**: scaling uses the z-score from Unit 4. We scale the features (X) but not the target (y). KNN and other distance-based models need scaling.

---

## 6. Train/Test Split and Cross Validation

We must test a model on data it has never seen, to get an honest score.

- **Train/Test Split**: split the data into a training part (to learn) and a test part (to check). In simple words, study on one part, exam on another.
- **Cross Validation**: split the data into k folds and rotate which fold is the test fold, so the score does not depend on one lucky split. In simple words, test many times and average.
- **Stratify**: keeps the same class proportion in both train and test sets. Important when the data is imbalanced.

```python
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=1/3, random_state=42, stratify=y)
```

**Note**: cross validation guards against overfitting (model memorizes training data) and underfitting (model is too simple).

---

## 7. Build a Model (KNN Example)

**K Nearest Neighbors (KNN) classifies a point by looking at its k closest neighbors and taking the majority vote.**

In simple words, you are like your nearest neighbors.

**Choosing k**: try several values of k and pick the one with the best test accuracy.

- At k = 1 the train accuracy is perfect (the model just memorizes), but the test accuracy is lower. That gap is **overfitting**.
- The right k balances train and test accuracy.

```python
from sklearn.neighbors import KNeighborsClassifier
test_scores = []
for i in range(1, 15):
    knn = KNeighborsClassifier(i)
    knn.fit(X_train, y_train)
    test_scores.append(knn.score(X_test, y_test))
best_k = int(np.argmax(test_scores)) + 1
knn = KNeighborsClassifier(best_k)
knn.fit(X_train, y_train)
```

---

## 8. Evaluate the Model

Accuracy alone is not enough, because it hides what kind of mistakes the model makes.

**Confusion Matrix**

The confusion matrix splits the predictions into four boxes.

| | Predicted Positive | Predicted Negative |
| --- | --- | --- |
| Actual Positive | TP (true positive) | FN (false negative) |
| Actual Negative | FP (false positive) | TN (true negative) |

- TP: predicted yes, actually yes
- TN: predicted no, actually no
- FP: predicted yes, actually no (this is a **Type I error**)
- FN: predicted no, actually yes (this is a **Type II error**)

In a medical setting, a false negative (missing a real patient) is usually the most costly.

**Precision, Recall, F1**

- **Precision = TP / (TP + FP)**: of those predicted positive, how many really were. High precision means few false alarms.
- **Recall = TP / (TP + FN)**: of those who are actually positive, how many we caught. High recall means few missed cases.
- **F1 score = harmonic mean of precision and recall**: one balanced number, useful when the data is imbalanced.

**ROC and AUC**

- **ROC curve**: plots the true positive rate against the false positive rate as the decision threshold changes.
- **AUC (area under the curve)**: one number from 0.5 (random guessing) to 1.0 (perfect). Higher AUC means the model separates the classes better.

```python
from sklearn.metrics import confusion_matrix, classification_report, roc_auc_score
y_pred = knn.predict(X_test)
print(confusion_matrix(y_test, y_pred))
print(classification_report(y_test, y_pred))   # precision, recall, f1
proba = knn.predict_proba(X_test)[:, 1]
print('AUC:', roc_auc_score(y_test, proba))
```

---

## 9. Hyperparameter Tuning (GridSearchCV)

**GridSearchCV tries every value in a grid using cross validation, and picks the best one based on an averaged score.**

In simple words, it automatically tests many settings and chooses the best.

```python
from sklearn.model_selection import GridSearchCV
param_grid = {'n_neighbors': np.arange(1, 50)}
knn_cv = GridSearchCV(KNeighborsClassifier(), param_grid, cv=5)
knn_cv.fit(X, y)
print('Best k:', knn_cv.best_params_, ' Best Score:', knn_cv.best_score_)
```

**Note**: grid search is more reliable than a single split (it averages over folds), but it is slower because it fits a model for every combination.

---

## Recap (EDA is statistics in disguise)

1. **Load and inspect**: head, info, describe
2. **Data quality**: find impossible zeros, mark them as missing
3. **Impute**: mean for symmetric columns, median for skewed
4. **Explore**: histograms, class balance, scatter matrix, pair plot, correlation heatmap
5. **Scale**: standardize to mean 0, SD 1 (z-score)
6. **Split**: stratified train/test plus cross validation
7. **Model**: KNN, tune k
8. **Evaluate**: confusion matrix, precision/recall/F1, ROC AUC

Notice how much of this is plain statistics: `describe()` is descriptive statistics, median imputation uses skewness, scaling is the z-score, and the heatmap is correlation. EDA is where the statistics you learned meets real data.
