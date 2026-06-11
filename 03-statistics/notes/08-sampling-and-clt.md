# 08. Sampling and the Central Limit Theorem

## Why This Note Matters

Everything from here on is **inference**: using a sample to say something about a population (Note 01). This note explains why that works at all. The key insight is that a sample statistic, like the sample mean, is itself a random variable with its own distribution, and that distribution turns out to be predictable. That predictability is what makes confidence intervals and hypothesis tests possible.

```python
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
```

## Sampling Methods

How you pick the sample decides whether your conclusions are valid. The goal is a **representative** sample.

- **Simple random sampling:** every member has an equal chance of selection. The gold standard, but needs a full list of the population.
- **Stratified sampling:** split the population into groups (strata) like age bands, then sample from each in proportion. Guarantees every group is represented.
- **Cluster sampling:** split into clusters (like cities), randomly pick whole clusters, and sample everyone in them. Cheaper when the population is spread out.
- **Systematic sampling:** pick every k-th member from an ordered list (every 10th customer). Simple, but risky if the list has a hidden pattern.
- **Convenience sampling:** take whoever is easy to reach. Fast but **biased**, and the source of most bad surveys.

## Sampling Error vs Bias

Two different problems:

- **Sampling error** is the natural variation between a sample statistic and the true parameter, just from picking a random subset. It shrinks as the sample grows and is unavoidable but measurable.
- **Bias** is a systematic error that pushes estimates consistently in one direction (a bad sampling method, a leading survey question). It does **not** shrink with sample size, a bigger biased sample is just confidently wrong.

The famous lesson: more data fixes sampling error, never bias.

## The Sampling Distribution

Take a sample, compute its mean. Take another sample, compute its mean. Those means differ. The **sampling distribution of the mean** is the distribution of `x-bar` over all possible samples of size n. It has two crucial properties:

- its centre is the population mean `mu` (the sample mean is an unbiased estimator)
- its spread is the **standard error**, smaller than the population's spread

## Standard Error

The **standard error (SE)** is the standard deviation of the sampling distribution, how much the sample mean bounces around from sample to sample.

```
SE = sigma / sqrt(n)
```

The `sqrt(n)` is everything: to halve the standard error you need **four times** the data. Precision improves with sample size, but with diminishing returns.

```python
sigma = 15        # population SD
for n in (25, 100, 400):
    print(f"n={n:4d}  SE = {sigma/np.sqrt(n):.2f}")
# n=  25  SE = 3.00
# n= 100  SE = 1.50
# n= 400  SE = 0.75      four times the data halves the SE
```

Do not confuse SE with SD. The **standard deviation** describes spread of individual data points. The **standard error** describes spread of a sample statistic. SE is always the smaller of the two.

## The Central Limit Theorem (CLT)

The most important theorem in statistics:

> For a large enough sample size, the sampling distribution of the mean is approximately **normal**, no matter what shape the original population has.

So even if the underlying data is skewed, uniform, or bizarre, the **averages** of samples from it pile up into a normal curve centred at `mu` with standard deviation `SE = sigma/sqrt(n)`. A common rule of thumb is `n >= 30` is "large enough", though heavily skewed populations need more.

```python
# population is heavily right-skewed (exponential), nothing like a normal
pop = np.random.exponential(scale=2.0, size=100000)

# take 2000 samples of size 50, record each sample's mean
means = [np.random.choice(pop, 50).mean() for _ in range(2000)]

print("population skew:", round(stats.skew(pop), 2))      # about 2.0, very skewed
print("sample-means skew:", round(stats.skew(means), 2))  # near 0, normal-shaped
# the skewed population produced near-normal sample means: the CLT in action
```

Why it matters: the CLT is the license to use the normal distribution (and the t, its small-sample cousin) for inference about means, even when the raw data is not normal. Confidence intervals and t-tests rest entirely on it.

## The Law of Large Numbers (LLN)

A related but distinct idea: as the sample size grows, the **sample mean converges to the population mean**.

```python
pop_mean = 3.5     # a fair die
running = np.cumsum(np.random.randint(1, 7, 5000)) / np.arange(1, 5001)
print("after 100 rolls :", round(running[99], 3))
print("after 5000 rolls:", round(running[4999], 3))   # very close to 3.5
```

LLN vs CLT, the common confusion: the **LLN** says where the sample mean ends up (it converges to `mu`). The **CLT** says how the sample mean is distributed around `mu` for a given n (approximately normal with spread `SE`). LLN is about the destination, CLT is about the shape of the journey.

## Summary

| Concept | What it says |
|---------|--------------|
| Sampling distribution | the distribution of a statistic over all samples of size n |
| Standard error | SE = sigma/sqrt(n), the spread of the sample mean |
| Central Limit Theorem | sample means are approximately normal for large n, any population |
| Law of Large Numbers | the sample mean converges to mu as n grows |
| Bias vs sampling error | bias is systematic and persists, sampling error shrinks with n |

The CLT tells us the sample mean is normal with a known spread. That is exactly what we need to put an honest range around an estimate, which is the confidence interval in Note 09.

## Quick Self Check

1. You quadruple your sample size from 100 to 400. What happens to the standard error?
2. A poll of 50,000 people is still wrong because it only surveyed one political forum. Is that sampling error or bias? Does more data fix it?
3. In one line, what does the Central Limit Theorem let you assume about the sample mean?
4. The population of incomes is heavily right-skewed. Can you still use a normal-based confidence interval for the mean income? Why?
5. What is the difference between the standard deviation and the standard error?

<details>
<summary>Answers</summary>

1. It halves. SE = sigma/sqrt(n), and sqrt(400)/sqrt(100) = 2, so SE drops by a factor of 2.
2. Bias (the forum is not representative). More data does not fix it, a bigger biased sample is just confidently wrong.
3. For a large enough n, the sample mean is approximately normally distributed with mean mu and standard deviation sigma/sqrt(n), regardless of the population's shape.
4. Yes, by the CLT. The skewed raw data does not matter, the sample mean is approximately normal for a large enough sample.
5. SD measures spread of individual data points. SE measures spread of a sample statistic (like the mean) across samples. SE = SD/sqrt(n).
</details>
