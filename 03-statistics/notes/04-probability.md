# 04. Probability Fundamentals

## Why Probability

Descriptive statistics (Notes 02 to 03) summarizes data you have. **Probability** is the math of uncertainty, and it is the engine that powers inference: it lets you say how likely a sample result would be if some claim about the population were true. Every confidence interval, hypothesis test, and machine learning model rests on it.

A **probability** is a number between 0 and 1 measuring how likely an event is. 0 means impossible, 1 means certain, 0.5 means even odds.

## Three Ways to Get a Probability

- **Classical (theoretical):** when all outcomes are equally likely, probability is favorable outcomes divided by total outcomes. A fair die landing on 4 is 1/6.
- **Empirical (frequentist):** probability is the long-run relative frequency from repeated trials. Flip a coin 10,000 times, divide heads by 10,000.
- **Subjective:** a degree of belief based on judgment ("70 percent chance this deal closes"). This is the view behind Bayesian statistics (Note 14).

```python
# classical: P(even number on a die)
favorable = 3      # {2, 4, 6}
total = 6
favorable / total
# 0.5
```

## Sample Space and Events

- The **sample space** (S) is the set of all possible outcomes.
- An **event** is any subset of the sample space, the outcomes you care about.

```
Rolling a die:
  sample space S = {1, 2, 3, 4, 5, 6}
  event "even"   = {2, 4, 6}
  event "> 4"    = {5, 6}
```

## The Axioms

All of probability is built on three simple rules:

1. Every probability is between 0 and 1: `0 <= P(A) <= 1`
2. The whole sample space has probability 1: `P(S) = 1`
3. For **mutually exclusive** events (cannot both happen), probabilities add: `P(A or B) = P(A) + P(B)`

## Complement Rule

The **complement** of A is "A does not happen", written A'. Since A and A' cover everything:

```
P(A') = 1 - P(A)
```

This is one of the most useful shortcuts in the subject. "At least one" problems are almost always easier as 1 minus "none".

```python
# P(at least one head in 3 coin flips)
# easier as 1 - P(no heads) = 1 - P(all tails)
1 - (0.5 ** 3)
# 0.875
```

## Addition Rule (OR)

For the probability that A **or** B happens, you add and subtract the overlap so it is not counted twice:

```
P(A or B) = P(A) + P(B) - P(A and B)
```

If A and B are mutually exclusive, the overlap is 0 and it reduces to plain addition.

```python
# draw one card. P(King or Heart)?
P_king  = 4/52
P_heart = 13/52
P_king_and_heart = 1/52      # the King of Hearts, counted in both
P_king + P_heart - P_king_and_heart
# 0.3077   = 16/52
```

## Multiplication Rule (AND) and Independence

Two events are **independent** if one happening does not change the probability of the other (coin flips, separate dice). For independent events:

```
P(A and B) = P(A) * P(B)
```

```python
# two independent dice both show 6
(1/6) * (1/6)
# 0.0278   = 1/36
```

If they are **not** independent, you need the conditional version (next).

## Conditional Probability

The probability of A **given that** B has happened, written `P(A | B)`. Knowing B occurred shrinks the world to just the outcomes where B is true.

```
P(A | B) = P(A and B) / P(B)
```

The general multiplication rule follows from this: `P(A and B) = P(A | B) * P(B)`.

```python
# from a deck, P(card is a King | it is a face card)
# face cards = J, Q, K = 12 cards; kings among them = 4
P_king_and_face = 4/52
P_face = 12/52
P_king_and_face / P_face
# 0.3333   knowing it is a face card raised P(King) from 4/52 to 1/3
```

Independence has a clean test in this language: A and B are independent exactly when `P(A | B) = P(A)`, knowing B tells you nothing about A.

## Bayes' Theorem

Bayes' theorem flips a conditional around. It lets you compute `P(A | B)` from `P(B | A)`, which is huge because the one you can measure is often the reverse of the one you want.

```
P(A | B) = P(B | A) * P(A) / P(B)
```

The classic example is a **medical test**, and it produces a famously counterintuitive answer. Suppose:
- a disease affects 1 percent of people: `P(D) = 0.01`
- the test catches it 99 percent of the time: `P(+ | D) = 0.99` (sensitivity)
- it gives a false positive 5 percent of the time: `P(+ | not D) = 0.05`

You test positive. What is the chance you actually have the disease, `P(D | +)`?

```python
P_D = 0.01
P_pos_given_D = 0.99
P_pos_given_notD = 0.05

# P(+) by the law of total probability: positives from sick + positives from healthy
P_pos = P_pos_given_D * P_D + P_pos_given_notD * (1 - P_D)

P_D_given_pos = (P_pos_given_D * P_D) / P_pos
round(P_D_given_pos, 4)
# 0.1667
```

Only about **17 percent**, despite a 99 percent accurate test. The reason: the disease is rare, so the huge healthy population produces many false positives that swamp the few true positives. This is why doctors retest, and why the **base rate** (the prior `P(D)`) cannot be ignored. Ignoring it is the "base rate fallacy".

## Law of Total Probability

The denominator above used the **law of total probability**: to get the overall probability of an event, sum its probability across every disjoint scenario, weighted by how likely each scenario is.

```
P(B) = P(B | A)*P(A) + P(B | not A)*P(not A)
```

It is the standard way to find the `P(B)` that Bayes' theorem needs.

## Combinatorics: Counting Outcomes

Classical probability needs you to count outcomes, and counting by hand fails fast. Three tools:

**Factorial** `n!` is the number of ways to arrange n distinct items in order: `n! = n * (n-1) * ... * 1`.

**Permutations** count ordered arrangements of r items from n (order matters, like a race podium):

```
P(n, r) = n! / (n - r)!
```

**Combinations** count unordered selections of r from n (order does not matter, like a lottery or a poker hand):

```
C(n, r) = n! / ( r! * (n - r)! )
```

The difference is whether order matters. "Gold, silver, bronze" is a permutation (order matters). "Pick 5 lottery numbers" is a combination (the order you pick them is irrelevant).

```python
from math import factorial, perm, comb

factorial(5)     # 120
perm(5, 3)       # 60    ordered: ways to award gold/silver/bronze among 5 runners
comb(5, 3)       # 10    unordered: ways to choose a 3-person committee from 5
```

```python
# probability of a specific 6-number lottery ticket from 49 numbers
1 / comb(49, 6)
# 7.15e-08   about 1 in 14 million
```

## Summary

| Concept | Formula | Use |
|---------|---------|-----|
| Complement | P(A') = 1 - P(A) | "at least one" problems |
| Addition | P(A or B) = P(A) + P(B) - P(A and B) | union of events |
| Multiplication (independent) | P(A and B) = P(A)*P(B) | independent events |
| Conditional | P(A given B) = P(A and B) / P(B) | dependence, updating |
| Bayes | P(A given B) = P(B given A)*P(A) / P(B) | flipping a conditional |
| Total probability | P(B) = sum of P(B given Ai)*P(Ai) | the denominator for Bayes |
| Permutation | n! / (n-r)! | ordered selections |
| Combination | n! / (r!(n-r)!) | unordered selections |

Probabilities describe single events. To describe a whole numeric quantity governed by chance (a dice total, a customer's spend), you need a **random variable**, which is Note 05.

## Quick Self Check

1. P(rain) = 0.3. What is P(no rain)?
2. Draw one card. P(red or King)? (26 red, 4 kings, 2 red kings.)
3. Two fair coins. P(both heads)? Are the flips independent?
4. Why is P(disease | positive test) so low even with a 99 percent accurate test?
5. A team picks a captain and a vice-captain from 8 players. Permutation or combination, and how many ways?
6. Same 8 players, pick a 2-person subcommittee with no roles. How many ways?

<details>
<summary>Answers</summary>

1. 1 - 0.3 = 0.7.
2. 26/52 + 4/52 - 2/52 = 28/52 = 0.538.
3. 0.5 * 0.5 = 0.25. Yes, one coin's result does not affect the other.
4. The disease is rare (1 percent base rate), so the large healthy group generates many false positives that outnumber the true positives. The prior dominates.
5. Permutation (roles make order matter): perm(8, 2) = 56.
6. Combination (no roles): comb(8, 2) = 28.
</details>
