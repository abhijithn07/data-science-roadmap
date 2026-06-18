# UNIT 6: Statistical Tests

A statistical test is a method that uses sample data to decide between the null and alternative hypothesis. Choosing the right test depends on the data type and the number of groups.

Tests are of two kinds: parametric tests (assume the data is normal) and non-parametric tests (do not assume normal data).

---

## 1. Z-Test

**A z-test checks if the sample mean is different from a known population mean, when the population standard deviation is known and the sample is large.**

In simple words, used for large samples (n is 30 or more) when we know sigma.

Formula: z = (x-bar - mu) / (sigma / square root of n)

**Use**: comparing a large sample mean to a known value.

---

## 2. T-Test

**A t-test checks if the sample mean is different from a value, when the population standard deviation is unknown or the sample is small.**

In simple words, used for small samples when we do not know sigma.

**Types of t-test**

- **One-sample t-test**: compare one sample mean to a known value.
- **Two-sample (independent) t-test**: compare the means of two different groups.

**Use**: comparing means with small samples (n less than 30).

---

## 3. Paired T-Test

**A paired t-test compares two related measurements taken on the same group.**

In simple words, used for before-and-after data on the same people.

**Example**: blood pressure of patients before and after a medicine.

**Note**: the two samples are dependent (same subjects), which is why it is "paired".

---

## 4. ANOVA (Analysis of Variance)

**ANOVA checks if there is a significant difference between the means of three or more groups.**

In simple words, a t-test compares two groups, ANOVA compares three or more.

**Example**: comparing the average marks of students from three different teaching methods.

**Note**: ANOVA tells us that at least one group is different, but not which one. We use post-hoc tests to find which.

---

## 5. Chi-Square Test

**A chi-square test checks if there is a relationship between two categorical variables.**

In simple words, it tests whether two categories are linked.

**Types**

- **Goodness of fit**: checks if observed data matches an expected distribution.
- **Test of independence**: checks if two categorical variables are related.

**Example**: is there a relationship between gender and product preference?

**Note**: chi-square is used for categorical (count) data, not for numerical means.

---

## 6. Mann-Whitney U Test

**The Mann-Whitney U test is a non-parametric test that compares two independent groups when the data is not normal.**

In simple words, it is the non-parametric version of the two-sample t-test.

**Use**: comparing two groups when the data is ordinal or not normally distributed.

---

## 7. Wilcoxon Test

**The Wilcoxon signed-rank test is a non-parametric test that compares two related groups when the data is not normal.**

In simple words, it is the non-parametric version of the paired t-test.

**Use**: before-and-after data that is not normally distributed.

---

## 8. Kolmogorov-Smirnov (KS) Test

**The KS test checks whether a sample follows a particular distribution, or whether two samples come from the same distribution.**

In simple words, it tests if data fits a distribution (like normal) or if two datasets have the same shape.

**Use**: checking normality, and in machine learning, detecting data drift (comparing new data to old data).

---

## Quick Reference: Which Test to Use

| Situation | Test |
| --- | --- |
| One mean, large sample, sigma known | Z-test |
| One or two means, small sample | T-test |
| Before vs after, same group | Paired t-test |
| Three or more group means | ANOVA |
| Two categorical variables | Chi-square |
| Two groups, not normal | Mann-Whitney U |
| Before vs after, not normal | Wilcoxon |
| Check distribution or drift | KS test |
