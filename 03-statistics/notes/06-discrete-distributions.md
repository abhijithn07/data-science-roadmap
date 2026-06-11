# 06. Discrete Probability Distributions

## Setup

A discrete distribution is a PMF (Note 05) for a countable random variable, with a known formula, mean `E[X]`, and variance `Var(X)`. Instead of building one from scratch, you recognize the situation and reach for the right named family. This note covers the ones you actually meet in data science.

```python
import numpy as np
from scipy import stats
```

`scipy.stats` gives every distribution the same methods: `.pmf(k, ...)` for P(X = k), `.cdf(k, ...)` for P(X <= k), `.mean(...)`, `.var(...)`, and `.rvs(size=...)` to draw random samples.

## Discrete Uniform

Every outcome is **equally likely**. A fair die is the textbook case: each of 1 to 6 has probability 1/6.

```
P(X = x) = 1 / n        for each of the n equally likely values
mean = (a + b) / 2      variance = (n^2 - 1) / 12
```

```python
# fair die, values 1..6
stats.randint.pmf(3, 1, 7)     # P(X=3), upper bound is exclusive
# 0.1667
stats.randint.mean(1, 7), stats.randint.var(1, 7)
# (3.5, 2.9166...)
```

Use it when outcomes are genuinely interchangeable: a fair die, a random pick from a list.

## Bernoulli

A **single trial with two outcomes**, success (1) or failure (0), with success probability `p`. The simplest distribution there is, and the building block for the binomial.

```
P(X = 1) = p        P(X = 0) = 1 - p
mean = p            variance = p(1 - p)
```

```python
# one biased coin, P(heads) = 0.3
stats.bernoulli.pmf(1, 0.3)        # 0.3
stats.bernoulli.mean(0.3)          # 0.3
stats.bernoulli.var(0.3)           # 0.21   = 0.3 * 0.7
```

Examples: one coin flip, did a single user click or not, is one email spam or not.

## Binomial

The number of **successes in n independent Bernoulli trials**, each with the same success probability `p`. This is the workhorse for "how many out of n".

```
P(X = k) = C(n, k) * p^k * (1 - p)^(n - k)
mean = n*p          variance = n*p*(1 - p)
```

The three pieces: `C(n, k)` counts the ways to place k successes among n trials (Note 04 combinations), `p^k` is the probability of those k successes, and `(1-p)^(n-k)` the probability of the rest failing.

```python
# flip a fair coin 10 times. P(exactly 5 heads)?
stats.binom.pmf(5, n=10, p=0.5)
# 0.2461

# mean and variance
stats.binom.mean(10, 0.5), stats.binom.var(10, 0.5)
# (5.0, 2.5)

# P(3 or fewer successes) when n=10, p=0.3
stats.binom.cdf(3, n=10, p=0.3)
# 0.6496
```

Conditions to use it: fixed number of trials `n`, each trial independent, each with the same `p`, and only two outcomes per trial. Examples: number of conversions out of 100 visitors, number of defective items in a batch.

## Poisson

The number of times a **rare event happens in a fixed interval** of time or space, given an average rate `lambda` (lambda). Used for counts where there is no fixed n, just a rate.

```
P(X = k) = (lambda^k * e^-lambda) / k!
mean = lambda       variance = lambda      <- mean equals variance, a Poisson signature
```

```python
# a website gets on average 3 errors per hour. P(exactly 2 in an hour)?
stats.poisson.pmf(2, mu=3)
# 0.2240

# P(at most 1 error in an hour)
stats.poisson.cdf(1, mu=3)
# 0.1991
```

The giveaway that data is Poisson: the mean and variance are roughly equal. Examples: calls to a support line per hour, typos per page, customers arriving per minute. The binomial approaches the Poisson when n is large and p is small (many trials, rare success).

## Geometric

The number of **trials until the first success** (each trial independent with probability `p`). Answers "how long until it works".

```
P(X = k) = (1 - p)^(k - 1) * p        (k = 1, 2, 3, ...)
mean = 1 / p
```

```python
# roll a die until the first 6. P(first 6 on the 3rd roll)?
stats.geom.pmf(3, p=1/6)
# 0.1157
stats.geom.mean(1/6)
# 6.0   on average it takes 6 rolls to get a 6
```

It is **memoryless**: past failures do not change the probability of success on the next trial.

## Negative Binomial and Hypergeometric (briefly)

Two more that round out the family:

- **Negative binomial:** the number of trials until the **r-th** success (the geometric is the special case r = 1). Used for counts that are "overdispersed", where the variance exceeds the mean, so it is a common alternative to Poisson.
- **Hypergeometric:** like the binomial, but sampling **without replacement** from a finite population, so trials are not independent. Example: drawing cards from a deck without putting them back, or quality-checking a batch by pulling items out.

```python
# hypergeometric: 5 defective in a box of 20, draw 4. P(exactly 2 defective)?
# scipy params: M=total, n=successes in population, N=draws
stats.hypergeom.pmf(2, M=20, n=5, N=4)
# 0.2167
```

## Summary

| Distribution | Models | Key parameters | Mean | Variance |
|--------------|--------|----------------|------|----------|
| **Discrete uniform** | equally likely outcomes | a, b | (a+b)/2 | (n^2-1)/12 |
| **Bernoulli** | one success/failure trial | p | p | p(1-p) |
| **Binomial** | successes in n trials | n, p | np | np(1-p) |
| **Poisson** | rare events in an interval | lambda | lambda | lambda |
| **Geometric** | trials until first success | p | 1/p | (1-p)/p^2 |
| **Hypergeometric** | successes, sampling without replacement | M, n, N | N(n/M) | depends |

How to choose: two outcomes once is **Bernoulli**, count successes in a fixed n is **binomial**, count rare events per interval is **Poisson**, wait for the first success is **geometric**, and sampling without replacement is **hypergeometric**.

Continuous distributions (normal, t, and friends) are Note 07.

## Quick Self Check

1. A quiz has 8 true/false questions answered by random guessing. Which distribution models the number correct, and what are its mean and variance?
2. A call center averages 5 calls per minute. Which distribution gives the chance of exactly 7 calls in a minute?
3. What is the signature relationship between mean and variance for a Poisson?
4. You draw cards from a deck without replacement. Binomial or hypergeometric, and why?
5. On average how many rolls of a die until the first 6, and which distribution is that?

<details>
<summary>Answers</summary>

1. Binomial(n=8, p=0.5). Mean = 8*0.5 = 4, variance = 8*0.5*0.5 = 2.
2. Poisson with lambda = 5: `stats.poisson.pmf(7, 5)`.
3. They are equal: mean = variance = lambda.
4. Hypergeometric, because without replacement the trials are not independent and p changes after each draw. Binomial needs constant p and independence.
5. 1/p = 1/(1/6) = 6 rolls. Geometric distribution.
</details>
