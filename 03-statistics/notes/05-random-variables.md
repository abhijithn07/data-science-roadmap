# 05. Random Variables and Probability Distributions

## What is a Random Variable?

A **random variable** is a variable whose value is a numeric outcome of a random process. Formally it maps each outcome in the sample space to a number, so instead of reasoning about "heads" and "tails" you reason about numbers you can do math on.

```
Flip 3 coins. Let X = number of heads.
X can be 0, 1, 2, or 3.
```

Random variables come in two kinds, mirroring the data types from Note 01:

- **Discrete:** countable values (number of heads, customers per hour, defects). Gaps between values.
- **Continuous:** any value in a range (height, time, temperature). No gaps.

A **probability distribution** describes how probability is spread across the values a random variable can take. It is the complete picture of the variable's behavior.

## PMF: Probability Mass Function (Discrete)

For a discrete random variable, the **PMF** gives the probability of each exact value, `P(X = x)`. Two rules always hold: every probability is between 0 and 1, and they sum to 1.

```
X = number of heads in 3 fair coin flips
P(X=0) = 1/8
P(X=1) = 3/8
P(X=2) = 3/8
P(X=3) = 1/8
        ----- sums to 1
```

```python
import numpy as np
from scipy import stats

# 3 flips, fair coin -> Binomial(n=3, p=0.5) (Note 06)
x = [0, 1, 2, 3]
pmf = stats.binom.pmf(x, n=3, p=0.5)
pmf
# array([0.125, 0.375, 0.375, 0.125])
pmf.sum()
# 1.0
```

## PDF: Probability Density Function (Continuous)

For a continuous variable, the probability of any single exact value is **0** (there are infinitely many possible values). Instead the **PDF** gives density, and probability is the **area under the curve** over a range.

```
P(a <= X <= b) = area under the PDF between a and b
P(X = exactly 5) = 0       <- a key surprise for beginners
total area under the PDF = 1
```

So for continuous variables you only ever ask about ranges ("height between 170 and 180"), never exact points. The height of the PDF is not a probability, it is density; only areas are probabilities.

## CDF: Cumulative Distribution Function (Both)

The **CDF** gives the probability that the variable is **at or below** a value: `F(x) = P(X <= x)`. It works for both discrete and continuous variables and always climbs from 0 to 1 as x increases.

```python
# P(2 or fewer heads in 3 flips)
stats.binom.cdf(2, n=3, p=0.5)
# 0.875   = P(0) + P(1) + P(2)
```

The CDF is what you use for "probability of at most / at least / between":

```
P(X <= b)        = F(b)
P(X > b)         = 1 - F(b)
P(a < X <= b)    = F(b) - F(a)
```

## Expectation (Expected Value)

The **expected value** `E[X]` is the long-run average of the random variable if you repeated the process forever. It is the distribution's centre of mass, the theoretical counterpart of the sample mean from Note 02.

For a discrete variable, weight each value by its probability and sum:

```
E[X] = sum of ( x * P(X = x) )
```

```python
# fair die: values 1..6, each with probability 1/6
x = np.arange(1, 7)
p = np.full(6, 1/6)
(x * p).sum()
# 3.5
```

The expected value of a die is 3.5, a value the die can never actually show. That is the point: expectation is the average over many rolls, not a value you expect on any single roll.

## Variance and Standard Deviation of a Random Variable

The **variance** `Var(X)` measures how far the variable spreads around its expected value. Same idea as Note 03, now weighted by probability:

```
Var(X) = E[ (X - E[X])^2 ]
       = E[X^2] - (E[X])^2          <- the handy computing form
```

The second form is usually easier: the mean of the squares minus the square of the mean. The **standard deviation** is the square root, back in the original units.

```python
x = np.arange(1, 7)
p = np.full(6, 1/6)

mean = (x * p).sum()                 # 3.5
ex2  = (x**2 * p).sum()              # E[X^2]
var  = ex2 - mean**2
var
# 2.9167   = 35/12
np.sqrt(var)
# 1.7078
```

## Properties of Expectation and Variance

These rules save enormous work, because you rarely compute from scratch once you know them.

**Expectation is linear** (always, even for dependent variables):

```
E[aX + b]   = a*E[X] + b
E[X + Y]    = E[X] + E[Y]
```

**Variance does not behave as simply.** A shift `b` does not change spread, and a scale `a` comes out **squared**:

```
Var(aX + b) = a^2 * Var(X)           <- the +b vanishes, the a is squared
Var(X + Y)  = Var(X) + Var(Y)        only if X and Y are independent
```

```python
# X is a die. Define Y = 2X + 3. Then:
# E[Y]   = 2*3.5 + 3      = 10.0
# Var(Y) = 2^2 * 2.9167   = 11.667   (the +3 has no effect on spread)
2*3.5 + 3, 4*2.9167
# (10.0, 11.6668)
```

Why squared? Variance is in squared units, so scaling the variable by `a` scales those squared units by `a^2`. Standard deviation, being a square root, scales by just `|a|`.

## Putting It Together

A distribution is fully summarized by its shape (PMF or PDF), its centre (`E[X]`), and its spread (`Var(X)`). Most real problems do not need a custom distribution, because a handful of **named distributions** describe the vast majority of situations:

- counting successes in fixed trials -> **Binomial** (Note 06)
- counting rare events in an interval -> **Poisson** (Note 06)
- measurements clustering around a mean -> **Normal** (Note 07)

Those named families are next. Each one is just a PMF or PDF with a known `E[X]` and `Var(X)`, so everything in this note applies directly to them.

## Summary

| Term | Discrete | Continuous |
|------|----------|------------|
| Probability of exact value | PMF: P(X = x) | 0 (use density) |
| Probability over a range | sum the PMF | area under the PDF |
| Cumulative | CDF: F(x) = P(X <= x) | CDF: F(x) = P(X <= x) |
| Centre | E[X] = sum x*P(x) | E[X] = integral of x*f(x) |
| Spread | Var(X) = E[X^2] - (E[X])^2 | same idea, integral form |

Key properties: `E[aX+b] = aE[X]+b`, `Var(aX+b) = a^2 Var(X)`, and expectation always adds while variance only adds for independent variables.

## Quick Self Check

1. Why is the probability that a continuous variable equals one exact value always 0?
2. For a discrete variable, what two conditions must the PMF satisfy?
3. The expected value of one die roll is 3.5, a value it can never land on. Explain.
4. If E[X] = 10 and you define Y = 3X - 2, what is E[Y]?
5. If Var(X) = 4 and Y = 5X + 1, what is Var(Y) and the SD of Y?
6. Which function answers "P(X is at most 7)", the PMF or the CDF?

<details>
<summary>Answers</summary>

1. There are infinitely many possible values, so any single one has 0 area under the PDF. Only ranges (areas) carry positive probability.
2. Each probability is between 0 and 1, and all the probabilities sum to 1.
3. Expectation is the long-run average over many rolls, not the result of any single roll. Averaging 1 through 6 gives 3.5.
4. E[Y] = 3*10 - 2 = 28.
5. Var(Y) = 5^2 * 4 = 100. SD = sqrt(100) = 10. The +1 shift does not affect spread.
6. The CDF, F(7) = P(X <= 7).
</details>
