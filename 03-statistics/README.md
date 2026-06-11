# Week 3: Statistics

The reasoning layer of the roadmap. **Statistics** is the math of describing data and drawing valid conclusions under uncertainty. SQL gets the data, Python manipulates it, and statistics tells you what it actually means and whether you can trust it.

These notes cover statistics **end to end** for data science: from describing a single column, through probability and distributions, to inference (confidence intervals, hypothesis tests), relationships (correlation, regression), and the practical topics that show up in real work (A/B testing, resampling, common traps). Broken into 16 focused notes you can work through in order.

Back to [Roadmap Home](../README.md) and [Overview](../00-overview/README.md)

---

## What You'll Learn This Week

Organized into the standard blocks used in textbooks and interviews:

| Block | What it is for | Topics |
|-------|----------------|--------|
| **Descriptive** | Summarizing data you have | central tendency, dispersion, shape, percentiles, z-scores, outliers |
| **Probability** | The language of uncertainty | events, conditional probability, Bayes, random variables, distributions |
| **Distributions** | Models for how data behaves | discrete (binomial, Poisson), continuous (normal, t, chi-square, F) |
| **Inference** | Conclusions about a population from a sample | sampling, CLT, confidence intervals, hypothesis tests |
| **Relationships** | How variables move together | covariance, correlation, simple and multiple regression |
| **Applied** | Statistics in practice | Bayesian thinking, A/B testing, bootstrap, statistical pitfalls |

## Why Statistics?

Look at the [data roles table in the overview](../00-overview/README.md#the-data-roles). Statistics underpins the Analyze and Model stages of the data lifecycle. Every model you build in Week 4 (ML) rests on these ideas: distributions, sampling, estimation, and the bias variance tradeoff are statistics. You cannot interpret an experiment, read a model's output, or defend a result without it.

## My Setup

The Python stack used throughout these notes:

| Tool | What it is |
|------|-----------|
| **NumPy** | arrays and fast numeric operations, the base for everything |
| **pandas** | tabular data, `describe()`, grouping, correlation |
| **scipy.stats** | distributions, hypothesis tests, the statistics workhorse |
| **statsmodels** | regression and detailed statistical models with full summaries |
| **matplotlib / seaborn** | plotting distributions and relationships |

Every code example uses these. Install with `pip install numpy pandas scipy statsmodels matplotlib seaborn`.

For **practice**: work each example by hand once, then in Python. Khan Academy Statistics, StatQuest on YouTube, and the "Think Stats" book are good companions.

## Notes

| # | Note | Covers | Status |
|---|------|--------|--------|
| 01 | [Introduction to Statistics](./notes/01-introduction.md) | descriptive vs inferential, population vs sample, parameter vs statistic, types of data, levels of measurement | ✅ |
| 02 | [Measures of Central Tendency](./notes/02-central-tendency.md) | mean, median, mode, weighted and trimmed mean, when to use each, effect of skew and outliers | ✅ |
| 03 | [Measures of Dispersion and Shape](./notes/03-dispersion-and-shape.md) | range, IQR, variance, standard deviation, MAD, CV, percentiles, z-scores, empirical rule, skewness, kurtosis, outliers | ✅ |
| 04 | [Probability Fundamentals](./notes/04-probability.md) | sample space, axioms, addition and multiplication rules, conditional probability, independence, Bayes theorem, combinatorics | ✅ |
| 05 | [Random Variables and Distributions](./notes/05-random-variables.md) | random variables, PMF, PDF, CDF, expectation, variance, properties of expectation | ✅ |
| 06 | [Discrete Distributions](./notes/06-discrete-distributions.md) | uniform, Bernoulli, binomial, Poisson, geometric, negative binomial, hypergeometric | ✅ |
| 07 | [Continuous Distributions](./notes/07-continuous-distributions.md) | uniform, normal, standard normal, t, chi-square, F, exponential, log-normal | ✅ |
| 08 | [Sampling and the Central Limit Theorem](./notes/08-sampling-and-clt.md) | sampling methods, sampling distribution, standard error, CLT, law of large numbers | ⏳ |
| 09 | [Estimation and Confidence Intervals](./notes/09-confidence-intervals.md) | point vs interval estimation, CI for mean and proportion, margin of error, t vs z, sample size | ⏳ |
| 10 | [Hypothesis Testing Fundamentals](./notes/10-hypothesis-testing.md) | null and alternative, type I and II errors, alpha, p-value, critical value, power, one vs two tailed | ⏳ |
| 11 | [Common Statistical Tests](./notes/11-common-tests.md) | z-test, one/two-sample/paired t-tests, ANOVA, chi-square, F-test, how to choose a test | ⏳ |
| 12 | [Correlation and Covariance](./notes/12-correlation.md) | covariance, Pearson, Spearman, correlation matrix, correlation vs causation | ⏳ |
| 13 | [Linear Regression](./notes/13-linear-regression.md) | simple and multiple regression, OLS, assumptions, R-squared, coefficients, residuals | ⏳ |
| 14 | [Bayesian Statistics](./notes/14-bayesian.md) | Bayesian vs frequentist, prior, likelihood, posterior, conjugate priors | ⏳ |
| 15 | [Experiment Design and A/B Testing](./notes/15-ab-testing.md) | controlled experiments, randomization, A/B workflow, power and significance in practice | ⏳ |
| 16 | [Resampling and Statistical Pitfalls](./notes/16-resampling-and-pitfalls.md) | bootstrap, permutation tests, Simpson's paradox, multiple comparisons, p-hacking, confounding | ⏳ |

## The Working Example

Many notes use the same small dataset so the ideas build up consistently: the exam scores of a class of 10 students, plus the hours each studied.

| student | hours_studied | exam_score |
|---------|---------------|------------|
| 1 | 2 | 55 |
| 2 | 3 | 60 |
| 3 | 4 | 64 |
| 4 | 5 | 66 |
| 5 | 5 | 70 |
| 6 | 6 | 72 |
| 7 | 7 | 78 |
| 8 | 8 | 85 |
| 9 | 9 | 88 |
| 10 | 11 | 95 |

```python
import pandas as pd
df = pd.DataFrame({
    "hours_studied": [2, 3, 4, 5, 5, 6, 7, 8, 9, 11],
    "exam_score":    [55, 60, 64, 66, 70, 72, 78, 85, 88, 95],
})
```

## Progress

- [ ] Read notes 01 to 16
- [ ] Run every example yourself in a notebook
- [ ] Work the key formulas by hand once before trusting the library
- [ ] Do the Quick Self Check questions at the end of each note
- [ ] Connect each idea to where it reappears in Week 4 (ML)
- [ ] Push notes to GitHub

---

*Part of my [Data Science Roadmap](../README.md), Week 3 of 7*
