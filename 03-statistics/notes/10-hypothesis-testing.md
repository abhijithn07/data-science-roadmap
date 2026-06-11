# 10. Hypothesis Testing Fundamentals

## The Idea

A **hypothesis test** is a formal procedure for deciding whether the data gives enough evidence to support a claim about a population. It is how you separate a real effect from random noise: did the new website design actually improve conversions, or could that lift have happened by chance?

The logic is like a courtroom. You assume "innocent" (no effect) by default, and only reject that assumption if the evidence against it is strong enough.

```python
import numpy as np
from scipy import stats
```

## Null and Alternative Hypotheses

Every test sets up two competing claims:

- the **null hypothesis (H0)** is the default, the "no effect / no difference / status quo" claim. You assume it is true unless the data forces you to abandon it.
- the **alternative hypothesis (H1 or Ha)** is what you are trying to find evidence for, the "there is an effect" claim.

```
H0: the new design has no effect on conversion (mu_new = mu_old)
H1: the new design changes conversion          (mu_new != mu_old)
```

You never "prove" H0. You either **reject** it (evidence is strong) or **fail to reject** it (evidence is weak). Failing to reject is not proof of no effect, just absence of strong evidence, the same way "not guilty" is not "proven innocent".

## One-tailed vs Two-tailed

The alternative decides the direction of the test:

- **two-tailed:** H1 is "different" (`!=`), you care about a change in either direction. The default and the safer choice.
- **one-tailed:** H1 is "greater than" (`>`) or "less than" (`<`), you only care about one direction. More powerful, but you must commit to the direction before seeing the data.

```
two-tailed:  H1: mu != 100      (any change)
one-tailed:  H1: mu > 100       (increase only)
```

## Type I and Type II Errors

Because you decide from a sample, you can be wrong in two ways:

| | H0 is actually true | H0 is actually false |
|---|---|---|
| **Reject H0** | Type I error (false positive) | correct |
| **Fail to reject H0** | correct | Type II error (false negative) |

- a **Type I error** is rejecting a true null: you claim an effect that is not real (a false alarm). Its probability is **alpha**.
- a **Type II error** is failing to reject a false null: you miss a real effect. Its probability is **beta**.

There is a tradeoff: lowering alpha (being stricter about false positives) raises beta (more missed effects), for a fixed sample size. The only way to reduce both is more data.

## Significance Level (alpha)

The **significance level alpha** is the threshold you set in advance for how much Type I error risk you will accept. The convention is **alpha = 0.05** (a 5 percent false-positive rate), with 0.01 for stricter settings. It is a choice, not a law of nature.

## The p-value

The **p-value** is the probability of observing data **at least as extreme** as yours, **if the null hypothesis were true**.

```
small p-value  -> the data would be surprising under H0  -> evidence against H0
large p-value  -> the data is consistent with H0          -> no strong evidence
```

The decision rule:

```
if p-value <= alpha:  reject H0      (statistically significant)
if p-value >  alpha:  fail to reject H0
```

**What the p-value is not** (the classic traps):
- it is **not** the probability that H0 is true
- it is **not** the probability your result happened by chance
- a small p-value does **not** mean a large or important effect, only an unlikely-under-H0 one. With a huge sample, a trivial effect can be highly significant. Always report the effect size alongside the p-value.

## Critical Value Approach

An equivalent route to the same decision. Instead of a p-value, you compare your **test statistic** to a **critical value** (the cutoff from the relevant distribution at level alpha). If the statistic falls in the **rejection region** beyond the critical value, you reject H0. The p-value and critical-value approaches always agree.

```python
# two-tailed test at alpha = 0.05: critical z values
stats.norm.ppf(0.975), stats.norm.ppf(0.025)
# (1.96, -1.96)   reject H0 if the test statistic is beyond +/- 1.96
```

## Statistical Power

**Power** is the probability of correctly rejecting a false null, that is, detecting a real effect when one exists. It equals `1 - beta`.

```
power = 1 - beta = P(reject H0 | H0 is false)
```

A study with low power is likely to miss real effects. Power increases with a larger sample size, a larger true effect, and a higher alpha. Designing for adequate power (commonly 0.80) is why you compute a required sample size **before** running an experiment (Notes 09 and 15).

## The Steps of a Hypothesis Test

A reliable recipe you can apply to any test:

```
1. State H0 and H1, and pick one-tailed or two-tailed.
2. Choose the significance level alpha (usually 0.05).
3. Pick the right test and compute the test statistic (Note 11).
4. Find the p-value (or compare to the critical value).
5. Decide: p <= alpha -> reject H0, else fail to reject.
6. State the conclusion in plain language, with the effect size.
```

```python
# example: is a coin fair? 60 heads in 100 flips.
# H0: p = 0.5,  H1: p != 0.5,  alpha = 0.05
result = stats.binomtest(60, 100, 0.5, alternative='two-sided')
round(result.pvalue, 4)
# 0.0569   p > 0.05, so we fail to reject H0: not quite enough evidence the coin is biased
```

## Summary

| Term | Meaning |
|------|---------|
| H0 / H1 | null (no effect) vs alternative (effect) |
| alpha | accepted Type I error rate, the significance threshold (0.05) |
| Type I error | reject a true H0 (false positive), probability alpha |
| Type II error | fail to reject a false H0 (false negative), probability beta |
| p-value | P(data this extreme or more, given H0 is true) |
| power | 1 - beta, the chance of detecting a real effect |

Decision rule: reject H0 when p <= alpha. The framework is the same for every test, what changes is how the test statistic and p-value are computed, which is Note 11.

## Quick Self Check

1. What does failing to reject H0 mean, and what does it not mean?
2. In plain words, what is a p-value?
3. You reject a null that was actually true. Which error type, and what is its probability called?
4. A result has p = 0.001 but the effect is tiny. How is that possible, and what should you also report?
5. You lower alpha from 0.05 to 0.01 with the sample size fixed. What happens to the Type II error rate and to power?

<details>
<summary>Answers</summary>

1. It means the evidence was not strong enough to reject the null. It does not mean the null is true or that there is no effect, only that you did not detect one.
2. The probability of seeing data at least as extreme as yours if the null hypothesis were true.
3. A Type I error (false positive). Its probability is alpha.
4. With a large sample, even a trivial effect can be statistically significant. Report the effect size and a confidence interval, not just the p-value.
5. Type II error rate (beta) goes up and power (1 - beta) goes down. Being stricter about false positives makes you miss more real effects.
</details>
