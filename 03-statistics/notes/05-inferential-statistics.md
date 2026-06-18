# UNIT 5: Inferential Statistics

Inferential statistics uses a sample to make conclusions about a population, and it tells us how confident we can be in those conclusions.

---

## 1. Sampling

**Sampling is the process of selecting a small group (sample) from a large group (population) for study.**

In simple words, picking a few to represent the many.

**Why**: it is faster, cheaper and often the only possible way to study a large population.

---

## 2. Sampling Methods

Sampling methods are of two types: probability sampling (everyone has a known chance) and non-probability sampling (selection is not random).

**Probability Sampling Methods**

- **Simple Random Sampling**: every member has an equal chance (like a lottery).
- **Systematic Sampling**: pick every kth member from a list (every 10th person).
- **Stratified Sampling**: divide the population into groups (strata) and sample from each group. Used when groups differ.
- **Cluster Sampling**: divide into clusters, then pick whole clusters at random. Used when the population is spread out.

**Non-Probability Sampling Methods**

- **Convenience Sampling**: pick whoever is easy to reach. High risk of bias.
- **Quota Sampling**: fill fixed quotas for each group.

**Note**: probability sampling is preferred because it reduces bias and lets us measure uncertainty.

---

## 3. Sampling Error

**Sampling error is the random difference between a sample value and the true population value, caused only because we used a subset.**

In simple words, it is normal luck-based error.

**Note**: it gets smaller as the sample size gets bigger, and it averages out over many samples.

---

## 4. Sampling Bias

**Sampling bias is a fixed, one-sided error caused by selecting the sample in a wrong way.**

In simple words, the sample is tilted and does not represent the population.

**Note**: a bigger sample does NOT fix bias. We fix it by improving how we select the sample.

---

## 5. Central Limit Theorem (CLT)

**The Central Limit Theorem says that if we take many samples and find their means, the distribution of those means will be approximately normal, no matter the shape of the original data.**

In simple words, the average of many sample means follows a bell curve, even if the data itself is not bell-shaped.

**Key Points**

- It works well when the sample size is large (usually n is 30 or more).
- The mean of the sample means equals the population mean.
- The spread of the sample means (called standard error) = sigma / square root of n.

**Note**: CLT is the reason we can use the normal distribution for tests and confidence intervals. It is one of the most important ideas in statistics.

---

## 6. Point Estimate vs Interval Estimate

**A point estimate is a single value used to estimate a population parameter. An interval estimate is a range of values used to estimate it.**

In simple words, a point estimate is one number, an interval estimate is a range.

**Example**: point estimate "the average height is 170 cm". Interval estimate "the average height is between 168 and 172 cm".

**Note**: interval estimates are safer because they show the uncertainty. A confidence interval is an interval estimate.

---

## 7. Confidence Intervals

**A confidence interval is a range of values that is likely to contain the true population value.**

In simple words, instead of one guess, we give a range and say how sure we are.

Formula: confidence interval = sample estimate plus or minus (margin of error)

**Example**: "the average height is 170 cm plus or minus 2 cm, with 95 percent confidence."

**Meaning of 95 percent confidence**: if we repeated the sampling many times, about 95 percent of such intervals would contain the true value.

---

## 8. Margin of Error

**Margin of error is the amount we add and subtract around the sample estimate to form the confidence interval.**

In simple words, it is the "plus or minus" part.

**Note**: a bigger sample gives a smaller margin of error (more precise). A higher confidence level gives a bigger margin of error (wider range).

---

## 9. Bootstrapping and Resampling

**Bootstrapping is a method of estimating uncertainty by repeatedly resampling the data with replacement.**

In simple words, we make many fake samples from our one sample to see how much the result varies.

**Steps**

- Take many random samples (with replacement) from the original data.
- Compute the statistic (mean, median, etc.) for each fake sample.
- Look at the spread of those values to build a confidence interval.

**Use**: building confidence intervals when the math formula is hard or the assumptions do not hold.

**Note**: bootstrapping needs no assumption about the distribution, which makes it very flexible. It is common in modern data science.

---

## 10. Maximum Likelihood Estimation (MLE)

**MLE is a method of finding the parameter values that make the observed data most likely.**

In simple words, pick the values that best explain the data we actually saw.

**Example**: estimating the probability p of a coin landing heads by choosing the p that makes the observed flips most probable.

**Note**: MLE is the foundation of many machine learning models, including logistic regression.

---

## 11. Hypothesis Testing

**Hypothesis testing is a method to decide whether a claim about a population is supported by the sample data.**

In simple words, it is a way to test if an idea is true using data.

**Steps**

1. Write the null hypothesis and alternative hypothesis.
2. Choose a significance level (alpha), usually 0.05.
3. Collect data and calculate a test statistic.
4. Find the p-value.
5. Compare the p-value with alpha and make a decision.

---

## 12. Null and Alternative Hypothesis

**The Null Hypothesis (H0) is the default statement that says there is no effect or no difference.**

**The Alternative Hypothesis (H1) is the statement we want to prove, that says there is an effect or a difference.**

In simple words, H0 is "nothing is happening" and H1 is "something is happening."

**Example**: H0 = the new medicine has no effect. H1 = the new medicine has an effect.

**Note**: we either reject H0 or fail to reject H0. We never "accept" H0.

---

## 13. One-Tailed vs Two-Tailed Tests

**A one-tailed test checks for an effect in one direction only. A two-tailed test checks for an effect in either direction.**

In simple words, one-tailed asks "is it greater?" (or "is it less?"), two-tailed asks "is it different?".

**Example**: one-tailed: "is the new method better than the old one?". Two-tailed: "is the new method different (better or worse)?".

**Note**: use a one-tailed test only when you care about one direction. The two-tailed test is the safer default.

---

## 14. P-Value

**The p-value is the probability of getting a result as extreme as the observed one, assuming the null hypothesis is true.**

In simple words, it tells us how surprising our data is if nothing is really happening.

**Decision Rule**

- If p-value is less than or equal to alpha (0.05), reject H0 (result is significant).
- If p-value is greater than alpha, fail to reject H0 (not significant).

**Note**: a small p-value means strong evidence against the null hypothesis.

---

## 15. Statistical Significance

**A result is statistically significant if it is unlikely to have happened just by chance.**

In simple words, the effect is probably real, not random luck.

**Note**: statistical significance does not always mean the effect is large or important in real life. A tiny effect can be significant with a huge sample.

---

## 16. Type I Error

**A Type I error is rejecting the null hypothesis when it is actually true.**

In simple words, it is a false alarm (saying there is an effect when there is none).

- The chance of a Type I error is alpha (usually 0.05).

**Example**: saying a healthy person has a disease.

---

## 17. Type II Error

**A Type II error is failing to reject the null hypothesis when it is actually false.**

In simple words, it is a miss (saying there is no effect when there really is one).

- The chance of a Type II error is called beta.

**Example**: saying a sick person is healthy.

**Difference (Type I vs Type II)**

| Type I Error | Type II Error |
| --- | --- |
| Reject true H0 | Fail to reject false H0 |
| False alarm | Missed detection |
| Probability = alpha | Probability = beta |

---

## 18. Statistical Power

**Statistical power is the probability of correctly rejecting a false null hypothesis.**

In simple words, it is the ability of a test to detect a real effect.

Formula: power = 1 - beta

**Note**: power increases with a larger sample size and a larger real effect. We usually want power of at least 0.80 (80 percent).

---

## 19. Degrees of Freedom

**Degrees of freedom is the number of values in a calculation that are free to vary.**

In simple words, how many values can change before the rest are fixed.

**Example**: if 5 numbers must add up to a fixed total, only 4 are free to change, the 5th is forced. So degrees of freedom = 4.

**Use**: t-tests, chi-square tests and ANOVA (Unit 6) all use degrees of freedom to choose the correct distribution. For a sample of size n, degrees of freedom is often n - 1.

**Note**: this is also why the sample variance divides by (n - 1), to use the correct degrees of freedom.
