# 14. Bayesian Statistics

## Two Schools of Thought

Everything so far has been **frequentist** statistics: parameters are fixed unknowns, probability is long-run frequency, and you reason with p-values and confidence intervals. **Bayesian** statistics takes a different view: you express your belief about a parameter as a probability distribution and **update** it as data arrives.

| | Frequentist | Bayesian |
|---|-------------|----------|
| A parameter is | a fixed unknown constant | a random variable with a distribution |
| Probability means | long-run frequency | degree of belief |
| Uses prior knowledge | no | yes, explicitly |
| Main output | p-value, confidence interval | posterior distribution, credible interval |

Neither is "correct", they answer slightly different questions. Bayesian methods shine when you have prior information, small data, or want a direct probability statement about a hypothesis.

```python
import numpy as np
from scipy import stats
```

## Prior, Likelihood, Posterior

Bayesian inference is built from Bayes' theorem (Note 04), now read as an updating rule:

```
posterior  is proportional to  likelihood  *  prior

P(theta | data) = P(data | theta) * P(theta) / P(data)
```

The three pieces:

- the **prior** `P(theta)` is your belief about the parameter **before** seeing the data
- the **likelihood** `P(data | theta)` is how probable the observed data is for each possible parameter value
- the **posterior** `P(theta | data)` is your updated belief **after** combining the two

The whole process is "start with a prior, see data, get a posterior". That posterior becomes the prior for the next batch of data, so learning is continuous.

## A Worked Example: Is a Coin Fair?

Suppose you want the bias `theta` (probability of heads) of a coin. The **Beta distribution** is the natural prior for a probability, and it pairs perfectly with coin flips (a **conjugate prior**, see below).

```python
# prior: Beta(1, 1), which is flat = "I have no idea, any bias 0..1 is equally likely"
# data: you flip 10 times and get 7 heads, 3 tails

# with a Beta(a, b) prior and h heads, t tails, the posterior is simply:
a_post = 1 + 7      # prior a + heads
b_post = 1 + 3      # prior b + tails

posterior_mean = a_post / (a_post + b_post)
round(posterior_mean, 4)
# 0.6667   your updated best estimate of P(heads) is about 0.67
```

Before the data, your best guess was 0.5 (the flat prior's mean). After seeing 7 of 10 heads, the posterior pulls toward the data, landing at 0.67. With more flips it would tighten further. If you had started with a strong prior belief that the coin was fair, the posterior would sit between 0.5 and the data, the prior and data each get a say.

## Conjugate Priors

A **conjugate prior** is a prior that, combined with the likelihood, yields a posterior in the **same family**, so the update is a clean formula instead of hard integration. The Beta prior with binomial data is the classic pair: Beta in, Beta out. A few standard conjugate pairs:

| Data (likelihood) | Conjugate prior | Posterior |
|-------------------|-----------------|-----------|
| Binomial (success counts) | Beta | Beta |
| Poisson (event counts) | Gamma | Gamma |
| Normal (known variance) | Normal | Normal |

Conjugacy is why simple Bayesian problems have tidy closed-form answers. Harder models drop conjugacy and use computational methods (MCMC) instead.

## Credible Interval vs Confidence Interval

The Bayesian counterpart to a confidence interval is a **credible interval**, and crucially it has the interpretation people *wish* a confidence interval had.

```python
# 95% credible interval from the posterior Beta(8, 4)
stats.beta.ppf([0.025, 0.975], a_post, b_post)
# array([0.390, 0.891])
```

- a **95 percent credible interval** means: given the data and prior, there is a 95 percent probability the parameter lies in this range. A direct probability statement about the parameter.
- a **95 percent confidence interval** (Note 09) means: 95 percent of intervals built this way would contain the fixed parameter. A statement about the method, not this interval.

The credible interval says what most people incorrectly assume a confidence interval says. That intuitive interpretation is a big part of Bayesian appeal.

## Where Bayesian Helps in Data Science

- **A/B testing:** "probability that variant B beats A" is a natural Bayesian output, easier to act on than a p-value (Note 15).
- **Small data:** a sensible prior stabilizes estimates when you have few observations.
- **Sequential updating:** you can update beliefs continuously as data streams in, without the "peeking" problem that plagues frequentist tests.
- **Spam filters, recommendation systems, medical diagnosis:** all use Bayesian updating under the hood (naive Bayes is in Week 4).

The cost is choosing a prior, which is subjective, and heavier computation for complex models. With lots of data, Bayesian and frequentist answers usually converge, because the data overwhelms the prior.

## Summary

| Concept | Meaning |
|---------|---------|
| Prior | belief about a parameter before data |
| Likelihood | probability of the data given a parameter value |
| Posterior | updated belief after data, proportional to likelihood times prior |
| Conjugate prior | prior whose posterior stays in the same family (clean update) |
| Credible interval | range with a stated probability of containing the parameter |

The core loop is prior plus data gives posterior. Bayesian thinking reframes inference as updating beliefs, and it underpins the A/B testing and several models ahead.

## Quick Self Check

1. In Bayesian terms, what are the prior, likelihood, and posterior?
2. What is the practical difference in interpretation between a 95 percent credible interval and a 95 percent confidence interval?
3. You start with a flat prior and observe 9 heads in 10 flips. Will the posterior mean be closer to 0.5 or 0.9?
4. What is a conjugate prior and why is it convenient?
5. With a very large dataset, how do Bayesian and frequentist estimates tend to compare?

<details>
<summary>Answers</summary>

1. Prior = belief about the parameter before data, likelihood = probability of the observed data for each parameter value, posterior = updated belief after combining prior and likelihood.
2. A credible interval gives a direct probability that the parameter is in the range. A confidence interval describes the long-run capture rate of the method, not this specific interval.
3. Closer to 0.9, the data pulls the flat prior strongly toward the observed proportion (posterior mean 10/12 = 0.83).
4. A prior that yields a posterior in the same distribution family, so updating is a simple formula instead of hard integration.
5. They tend to converge, because a large amount of data overwhelms the influence of the prior.
</details>
