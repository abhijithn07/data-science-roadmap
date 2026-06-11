# 01. Introduction to Statistics

## What is Statistics?

**Statistics** is the science of collecting, organizing, analyzing, and interpreting data so you can make decisions when you do not have perfect information. The whole field exists because of one problem: you almost never have data on everything you care about, so you have to reason from a piece of it to the whole.

It splits into two big branches:

- **Descriptive statistics** summarizes the data you already have. Averages, spread, charts. It describes, it does not generalize beyond the data in front of you.
- **Inferential statistics** uses a sample to draw conclusions about a larger group you did not fully measure. This is where probability, confidence intervals, and hypothesis tests live.

```
Descriptive  -> "The 10 students I measured scored 73 on average."
Inferential  -> "Based on these 10, the whole class likely averages between 68 and 78."
```

You almost always do descriptive work first (look at the data), then inferential work (make a claim about the wider world).

## Population vs Sample

This is the single most important distinction in the subject.

- A **population** is the entire group you want to know about: every customer, every transaction, all students in the country.
- A **sample** is the subset you actually collect data from.

You study the sample because measuring the whole population is usually impossible, too slow, or too expensive. The goal of inference is to use the sample to say something trustworthy about the population.

```
Population: all 50,000 customers
Sample:     2,000 customers you surveyed
```

A sample is only useful if it is **representative**, meaning it looks like the population in the ways that matter. A biased sample (for example, only surveying customers who called support) leads to wrong conclusions no matter how much math you do afterward. Good sampling beats clever analysis.

## Parameter vs Statistic

These two words are easy to mix up, and interviewers love the distinction.

- A **parameter** is a number that describes the **population**. Usually unknown, because you cannot measure the whole population.
- A **statistic** is a number computed from the **sample**. You can always calculate it, and you use it to estimate the parameter.

| Quantity | Population (parameter) | Sample (statistic) |
|----------|------------------------|--------------------|
| Mean | mu | x-bar |
| Standard deviation | sigma | s |
| Proportion | p | p-hat |
| Size | N | n |

Memory hook: **p**arameter goes with **p**opulation, **s**tatistic goes with **s**ample. The sample statistic is your best guess at the population parameter, and inference is the process of going from one to the other while being honest about the uncertainty.

## What is a Variable?

A **variable** is any characteristic that can be measured or recorded and that can differ from one thing to the next. Age, city, salary, and exam score are all variables. They are called variables precisely because their value **varies** across the things you observe.

The thing you measure is an **observation** (also called a record, a row, or a case). In a table, each row is one observation and each column is one variable.

```
       variables ->   age    city      exam_score
observation 1   |      20    Tampa         85
observation 2   |      22    New York      78
observation 3   |      19    Tampa         91
```

So a dataset is just a set of observations measured on the same variables. The 10 students in the working example are 10 observations, and `hours_studied` and `exam_score` are two variables measured on each of them.

### Dependent vs Independent Variables

When you study how one thing affects another, you label the variables by their role:

- an **independent variable** is the input, the thing you change or use to explain. Also called a **predictor** or **feature** in machine learning.
- a **dependent variable** is the output, the thing you measure and try to explain or predict. Also called the **target** or **response**.

```
hours_studied (independent / feature)  ->  exam_score (dependent / target)
            the cause/input                       the effect/output
```

The names line up with the rest of the roadmap: in regression (Note 13) and in ML (Week 4) you predict the dependent variable (target) from the independent variables (features). Getting this direction right is the whole setup of a modeling problem.

### A Few More Terms

- **Datum / data:** a **datum** is a single recorded value (one measurement). **Data** is the plural, the whole collection of values. So "the data are" is technically plural, though everyday usage often treats "data" as singular.
- **Experiment vs observational study:** in an **experiment** you actively control or change something (assign people to a treatment vs a control group) and measure the effect. In an **observational study** you only observe and record what already happens, without intervening. Experiments can establish cause, observational studies usually can only show association (more in Note 15).
- **Parameter vs statistic:** covered above. Parameter describes the population, statistic describes the sample.

## Types of Data

Before any analysis, you classify each variable, because the type decides which summaries and tests are valid.

```
Data
├── Numerical (quantitative): numbers you can do math on
│   ├── Discrete: countable, whole values     -> number of children, defects, logins
│   └── Continuous: any value in a range       -> height, temperature, time, salary
│
└── Categorical (qualitative): labels, not magnitudes
    ├── Nominal: categories with no order       -> color, city, gender
    └── Ordinal: categories with a clear order   -> small/medium/large, ratings 1 to 5
```

- **Discrete** comes from counting, so it lands on separate whole numbers. You can have 0, 1, or 2 children, never 1.5.
- **Continuous** comes from measuring, so between any two values there is always another. Height can be 170.0 or 170.43 cm.
- **Nominal** labels have no inherent order. Red is not greater than blue.
- **Ordinal** labels have an order but the gaps are not necessarily equal. The difference between "good" and "very good" is not a measurable 1 unit.

Why it matters: you can take a mean of numerical data but not of nominal data ("the average color" is meaningless). You can rank ordinal data but should not average it blindly. The data type also picks your chart (bar chart for categorical, histogram for numerical) and your test (chi-square for categorical, t-test for numerical).

## Levels of Measurement

A slightly finer classification, often asked about, that ranks how much information a variable carries.

| Level | Order? | Equal gaps? | True zero? | Example |
|-------|--------|-------------|------------|---------|
| **Nominal** | no | no | no | eye color, country |
| **Ordinal** | yes | no | no | survey rating, class rank |
| **Interval** | yes | yes | no | temperature in C or F, calendar year |
| **Ratio** | yes | yes | yes | height, weight, age, income |

The key idea is the **true zero**. Ratio data has a meaningful zero that means "none of it", so ratios make sense: 20 kg is genuinely twice 10 kg. Interval data has no true zero, so ratios do not work: 20 degrees C is not "twice as hot" as 10 degrees C, because 0 C is just a label, not the absence of temperature. Each level up supports more operations, and ratio carries the most information.

The four levels form a ladder. Each one keeps everything the level below it can do and adds one new ability, so as you climb you can do more math.

### Nominal (labels only)

Nominal data is just **names or categories with no order**. The values are different, but no value is "more" or "higher" than another.

- Examples: eye color, country, gender, blood type, payment method.
- Valid operations: check equal or not equal, count how many fall in each category, find the **mode**.
- Not valid: ordering, averaging, subtracting. "The average country" is meaningless.
- Charts: bar chart, pie chart. Summary: counts and proportions.

Even when nominal categories are stored as numbers (1 = cash, 2 = card, 3 = UPI), the numbers are just labels. Adding or averaging them is a mistake, since 2 is not "more" than 1 in any real sense.

### Ordinal (ordered, but uneven gaps)

Ordinal data has a **clear order, but the distances between values are not equal or not known**.

- Examples: survey ratings (poor, fair, good, excellent), class rank (1st, 2nd, 3rd), T-shirt size (S, M, L), education level, pain scale 1 to 10.
- Valid operations: everything nominal allows, plus ordering, and the **median** and percentiles.
- Not valid (strictly): treating the gaps as equal. The jump from "good" to "excellent" is not guaranteed to equal the jump from "poor" to "fair", so the mean is technically improper, though in practice people often average Likert scales anyway and note the caveat.
- Charts: ordered bar chart. Summary: median, mode, quartiles.

The defining limit: you know the **order** but not the **size of the gaps**.

### Interval (equal gaps, no true zero)

Interval data is numeric with **equal, meaningful gaps**, but its zero is arbitrary, just a point on the scale, not "none of the quantity".

- Examples: temperature in Celsius or Fahrenheit, calendar years, IQ scores, dates.
- Valid operations: everything ordinal allows, plus addition and subtraction, and now the **mean** and standard deviation are valid because gaps are equal. The difference between 20 and 30 degrees equals the difference between 30 and 40.
- Not valid: ratios and "twice as much" statements. 40 C is not twice as hot as 20 C, and year 2000 is not "twice" year 1000, because 0 does not mean the absence of temperature or time.
- Summary: mean, standard deviation, plus everything below.

The defining limit: gaps are equal, but because zero is arbitrary you cannot multiply or divide values meaningfully.

### Ratio (equal gaps and a true zero)

Ratio data is the richest level: numeric with **equal gaps and a true zero** that genuinely means "none".

- Examples: height, weight, age, income, distance, time duration, count of anything.
- Valid operations: everything, including **ratios**. 20 kg is twice 10 kg, 0 income means no income, a 100 percent increase is well defined.
- Summary: all of them, including the geometric mean and coefficient of variation (Note 03).

The defining feature: a real zero point, which is what unlocks multiplication and division ("twice as heavy", "half the price").

### Why It Matters in Practice

The level decides which summaries and tests are legitimate:

```
nominal   -> counts, mode, bar chart, chi-square test
ordinal   -> median, percentiles, rank-based tests (Spearman, Mann-Whitney)
interval  -> mean, standard deviation, correlation, t-tests
ratio     -> all of the above, plus ratios, CV, geometric mean
```

A quick way to place a variable: ask three questions in order. Is there an **order**? If no, nominal. If yes, are the **gaps equal**? If no, ordinal. If yes, is there a **true zero** so ratios make sense? No means interval, yes means ratio.

## A Quick First Look in Python

Loading data and getting a first description is the practical starting point. `describe()` is the fastest way to see the shape of every numeric column at once.

```python
import pandas as pd

df = pd.DataFrame({
    "hours_studied": [2, 3, 4, 5, 5, 6, 7, 8, 9, 11],
    "exam_score":    [55, 60, 64, 66, 70, 72, 78, 85, 88, 95],
})

df.describe()
#        hours_studied  exam_score
# count      10.000000   10.000000
# mean        6.000000   73.300000
# std         2.788867   12.953335
# min         2.000000   55.000000
# 25%         4.250000   64.500000
# 50%         5.500000   71.000000
# 75%         7.750000   83.250000
# max        11.000000   95.000000
```

`count` is the sample size, `mean` and `std` describe centre and spread, and the percentiles describe the distribution. The next two notes break down exactly what each of these numbers means.

## How This Connects to the Rest of the Roadmap

Statistics is the bridge between data and decisions. Descriptive stats (notes 02 to 03) is what `df.describe()` and your dashboards report. Probability and distributions (04 to 07) are the foundation under every machine learning model in Week 4. Inference (08 to 11) is how you decide whether a result is real or just noise, which is the core of A/B testing and model evaluation. Regression (13) is both a statistical tool and your first ML model.

## Quick Self Check

1. You survey 500 of a company's 40,000 employees. What is the population, what is the sample?
2. Average satisfaction computed from those 500 is a parameter or a statistic? Which symbol, x-bar or mu?
3. Classify each: number of bedrooms, shirt size (S/M/L), temperature in Fahrenheit, annual salary.
4. Why can you take ratios of ratio data but not interval data?
5. Why does a biased sample ruin an analysis even if the math is correct?
6. To predict house price from square footage, which is the dependent (target) variable and which is the independent (feature)?

<details>
<summary>Answers</summary>

1. Population is all 40,000 employees, sample is the 500 surveyed.
2. A statistic (from a sample), written x-bar. It estimates the population parameter mu.
3. Bedrooms = discrete numerical (ratio). Shirt size = ordinal categorical. Temperature in F = interval. Salary = continuous numerical (ratio).
4. Ratio data has a true zero meaning "none", so 20 is genuinely twice 10. Interval data has an arbitrary zero, so ratios are meaningless.
5. Inference assumes the sample represents the population. If the sample is systematically off, every conclusion about the population is off, and more math cannot fix bad data.
6. House price is the dependent variable (target), square footage is the independent variable (feature). You use footage to predict price.
</details>
