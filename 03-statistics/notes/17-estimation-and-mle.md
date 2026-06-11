# 17. Estimation and Maximum Likelihood

## Start Here: What is Estimation?

Remember the core problem from Note 01: you cannot measure the whole population, so you use a sample to **guess** a population parameter (like the true mean `mu` or a true proportion `p`). That guessing is called **estimation**, and this note explains how statisticians decide on a good guess in a principled way, ending with the single most important method in all of modern data science: **maximum likelihood**.

Two words that sound the same but are different:

- an **estimator** is the **rule or formula** you use (for example, "take the sample mean")
- an **estimate** is the **actual number** you get when you plug your data into that rule (for example, 73.3)

Think of the estimator as a recipe and the estimate as the finished dish. The same recipe gives a different dish each time you use new ingredients (a new sample).

```python
import numpy as np
from scipy import stats
```

## What Makes an Estimator "Good"?

Not all guessing rules are equally trustworthy. Statisticians judge an estimator by three properties. You do not need the heavy math, just the intuition.

**1. Unbiased.** On average, across many samples, the estimator hits the true value. It does not systematically aim too high or too low. The sample mean is unbiased for the population mean. (This is also why sample variance divides by `n - 1`, Note 03, to remove a bias.)

```
biased     -> like a scale that always reads 2 kg heavy
unbiased   -> like a scale that is right on average
```

**2. Consistent.** As the sample grows, the estimate closes in on the true value. More data, better guess. This is the Law of Large Numbers from Note 08 in disguise.

**3. Efficient.** Among unbiased estimators, the efficient one has the **smallest spread** (variance), so it bounces around the truth less from sample to sample. Given two unbiased rules, you prefer the one that is more tightly clustered on the truth.

A good estimator is unbiased, consistent, and efficient: right on average, improving with data, and not jumpy.

## Method of Moments (the simple idea first)

The oldest estimation method, shown briefly so MLE has context. The **method of moments** just sets the sample's summary equal to the population's and solves. To estimate the population mean, use the sample mean. To estimate the population variance, use the sample variance. Intuitive, but it does not always give the best estimator. The better, more general method is next.

## Maximum Likelihood Estimation (MLE): the Big Idea

Here is the question MLE answers, in plain English:

> Of all the possible values the parameter could be, which value makes the data I actually observed the **most likely** to have happened?

That is the entire intuition. You saw some data. Different parameter values would make that data more or less probable. MLE picks the parameter value under which your data is the **least surprising**.

An analogy: you hear a noise in the attic. A mouse would make that exact noise fairly often, an elephant almost never. Without other information, you guess "mouse", because it is the cause under which what you heard is most likely. MLE formalizes exactly that reasoning.

## The Likelihood Function

Step by step:

1. Pick a model with a parameter (say a coin with unknown probability of heads `p`).
2. The **likelihood** is the probability of your observed data, written as a function of the parameter.
3. MLE finds the parameter value that **maximizes** that likelihood.

For independent observations, the likelihood is the product of each observation's probability (because independent probabilities multiply, Note 04).

```
Likelihood(p) = P(observed data | p) = P(x1|p) * P(x2|p) * ... * P(xn|p)
```

## Worked Example 1: Estimating a Coin's Bias

You flip a coin 10 times and get **7 heads, 3 tails**. What is the most likely value of `p` (the probability of heads)?

Intuitively the answer should be 0.7, and MLE proves it. The likelihood for a given `p` is:

```
Likelihood(p) = p^7 * (1 - p)^3
```

Let us compute this likelihood across many candidate values of `p` and see which is largest.

```python
p_values = np.linspace(0, 1, 1001)            # candidate values 0.000 to 1.000
likelihood = p_values**7 * (1 - p_values)**3  # probability of 7 heads, 3 tails

best_p = p_values[np.argmax(likelihood)]      # the p that maximizes it
round(best_p, 3)
# 0.7   exactly the observed proportion, 7/10
```

So the MLE of `p` is **0.7**, the sample proportion. This is a general result: for counting successes, the MLE is just `successes / trials`. The math (taking a derivative and setting it to zero) confirms what intuition said.

## The Log-Likelihood (a practical trick)

Multiplying many small probabilities gives a tiny, hard-to-handle number. So in practice we maximize the **log-likelihood** instead. Because `log` turns products into sums and is always increasing, the parameter that maximizes the log-likelihood is the same one that maximizes the likelihood, just easier to compute.

```
log-Likelihood = log(P(x1)) + log(P(x2)) + ... + log(P(xn))
```

```python
log_like = 7*np.log(p_values) + 3*np.log(1 - p_values)
round(p_values[np.argmax(log_like)], 3)
# 0.7   same answer, computed more stably
```

You will almost always see "log-likelihood" in software and papers for this reason.

## Worked Example 2: MLE for the Normal Distribution

If you assume your data came from a normal distribution and ask MLE for the best mean and variance, the answers are reassuringly familiar:

- the MLE of the mean `mu` is the **sample mean**
- the MLE of the variance is the average squared deviation (dividing by `n`, the population formula)

```python
data = np.array([55, 60, 64, 66, 70, 72, 78, 85, 88, 95])
print("MLE of mean    :", data.mean())          # 73.3, the sample mean
print("MLE of variance:", round(data.var(), 3)) # 151.01, dividing by n
```

So MLE recovers the everyday formulas you already know, which is part of why it is trusted. (Note the MLE variance divides by `n`, while the unbiased sample variance divides by `n - 1`, a small reminder that an MLE is not always perfectly unbiased.)

## Why MLE is Everywhere in Data Science

This is the payoff. Almost every model you meet later is **trained by maximum likelihood**, even when it is not called that:

- **Logistic regression** (Week 4) finds the coefficients that maximize the likelihood of the observed yes/no labels.
- **Linear regression** under normal errors gives the same answer as OLS (Note 13), because least squares **is** the MLE there.
- Naive Bayes, many neural network loss functions ("cross-entropy" is negative log-likelihood), and most of classical statistics all rest on MLE.

When a model "learns from data", under the hood it is very often searching for the parameters that make the observed data most likely. Understanding MLE means understanding what almost every model is actually doing.

## Summary

| Concept | Meaning |
|---------|---------|
| Estimator | the rule/formula for guessing a parameter |
| Estimate | the actual number the rule produces |
| Unbiased | correct on average across samples |
| Consistent | converges to the truth as n grows |
| Efficient | smallest variance among unbiased estimators |
| Likelihood | probability of the observed data as a function of the parameter |
| MLE | the parameter value that maximizes the likelihood (makes the data least surprising) |
| Log-likelihood | the log of the likelihood, easier to maximize, same answer |

The one-sentence takeaway: **MLE chooses the parameter under which your data was most likely to occur**, and it is the engine behind most models in the rest of the roadmap.

## Quick Self Check

1. In plain words, what does maximum likelihood estimation do?
2. What is the difference between an estimator and an estimate?
3. You flip a coin 20 times and get 12 heads. What is the MLE of p, and what formula did you use?
4. Why do we usually maximize the log-likelihood instead of the likelihood directly?
5. Name one property of a "good" estimator and explain it in one sentence.
6. Why does MLE matter for machine learning?

<details>
<summary>Answers</summary>

1. It picks the parameter value that makes the observed data most likely (least surprising) under the model.
2. An estimator is the rule or formula (like "use the sample mean"); an estimate is the specific number it produces from a given sample.
3. MLE of p = 12/20 = 0.6, using successes/trials (the MLE for a proportion).
4. Multiplying many small probabilities is numerically unstable and awkward; the log turns the product into a sum and, being increasing, has its maximum at the same parameter value.
5. Unbiased: on average across many samples it equals the true parameter, with no systematic over- or under-estimation. (Consistent or efficient are also valid.)
6. Most models, including logistic regression and many neural network losses, are trained by finding the parameters that maximize the likelihood of the observed data.
</details>
