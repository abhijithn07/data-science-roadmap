# 15. Experiment Design and A/B Testing

## Why Experiments

Correlation cannot prove causation (Note 12). An **experiment** can, because you actively change one thing and hold everything else constant, so any difference in the outcome can be attributed to the change. A/B testing is the everyday data science version of a controlled experiment, used to decide whether a product change actually works.

```python
import numpy as np
from scipy import stats
from statsmodels.stats.proportion import proportions_ztest
```

## The Anatomy of a Controlled Experiment

- a **control group** gets the existing version (A)
- a **treatment group** gets the new version (B)
- the **independent variable** is the change you make (the new button, the new price)
- the **dependent variable** is the outcome you measure (conversion rate, time on page)

The point is to isolate the effect of the one thing you changed.

## Randomization: the Key Ingredient

Subjects must be assigned to control or treatment **at random**. This is what makes an experiment trustworthy. Randomization balances out **confounders**, both the ones you thought of and the ones you did not, across the two groups on average.

```
Without randomization: maybe all your power users ended up in group B,
                       so B looks better for the wrong reason (confounding).
With randomization:    power users, time zones, devices, everything spreads
                       evenly, so the only systematic difference is the change.
```

A **confounder** is a variable that affects both the assignment and the outcome, creating a fake or distorted effect. Randomization is the cleanest defense against it, which is why "randomized controlled trial" is the gold standard for causal claims.

## The A/B Test Workflow

A disciplined A/B test follows the hypothesis-testing framework from Note 10:

```
1. Define the metric        e.g. conversion rate (clear, measurable, tied to the goal)
2. State the hypotheses     H0: rate_B = rate_A     H1: rate_B != rate_A
3. Set alpha and power      usually alpha = 0.05, power = 0.80
4. Compute the sample size  BEFORE running, from the effect you care about
5. Randomly assign users    to A and B
6. Run until n is reached    do not stop early based on results
7. Analyze                  the right test, then decide against alpha
8. Decide and report        with the effect size and a confidence interval
```

## Analyzing an A/B Test

Conversion is a yes/no outcome, so you compare two **proportions** with a two-proportion z-test.

```python
# A: 200 conversions out of 2000.  B: 240 out of 2000.
conversions = np.array([200, 240])
visitors    = np.array([2000, 2000])

z_stat, p_value = proportions_ztest(conversions, visitors)
round(z_stat, 3), round(p_value, 4)
# (-2.021, 0.0432)   p < 0.05: B's lift (10% -> 12%) is statistically significant
```

Always pair the significance with the **effect size**: B converts at 12 percent vs A at 10 percent, a 2 point absolute lift (20 percent relative). A tiny p-value on a trivial lift is not worth shipping, and a real lift that just missed significance may justify a bigger test.

## Sample Size and Power Up Front

The most common A/B mistake is running too small a test. You decide the sample size **before** collecting data, from three inputs: the significance level alpha, the desired power (usually 0.80), and the **minimum detectable effect** (the smallest lift worth caring about). Smaller effects need much larger samples.

```python
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize

effect = proportion_effectsize(0.12, 0.10)         # detect a 10% -> 12% lift
n = NormalIndPower().solve_power(effect_size=effect, alpha=0.05, power=0.80, ratio=1)
int(np.ceil(n))
# 3835   you need about 3,835 users per group to reliably detect that lift
```

This is why you cannot just "check the numbers after a day". Underpowered tests miss real effects (Type II errors, Note 10).

## Common A/B Testing Pitfalls

- **Peeking / early stopping:** repeatedly checking and stopping the moment p < 0.05 dramatically inflates false positives. Decide n in advance and wait, or use sequential methods built for peeking.
- **Multiple metrics / multiple variants:** testing many metrics or many variants at once multiplies the chance of a false positive (Note 16's multiple comparisons). Correct for it.
- **Novelty effect:** users react to anything new at first, then revert. Run long enough to see steady-state behavior.
- **Sample ratio mismatch:** if the A/B split is not the 50/50 you intended, the randomization is broken and results are suspect.
- **Ignoring practical significance:** statistically significant is not the same as worth doing. Weigh the effect size against the cost.

## Observational Studies (when you cannot experiment)

Sometimes you cannot randomize (you cannot randomly assign people to smoke). Then you run an **observational study** and try to control for confounders statistically (regression, matching, stratification). These can suggest causation but never nail it down as cleanly as a randomized experiment, because there is always a confounder you did not measure.

## Summary

| Concept | Meaning |
|---------|---------|
| Control vs treatment | existing version (A) vs new version (B) |
| Randomization | random assignment that balances confounders |
| Confounder | a variable affecting both assignment and outcome |
| Two-proportion z-test | the standard test for comparing conversion rates |
| Power and sample size | fixed in advance from alpha, power, and the minimum detectable effect |
| Peeking | stopping early on a significant result, which inflates false positives |

A/B testing is hypothesis testing (Note 10) applied to product decisions, with randomization providing the causal link. Get the design right (randomize, size the sample, avoid peeking) and the analysis is the easy part.

## Quick Self Check

1. What does randomization protect against, and why does that matter for causal claims?
2. Why must you compute the sample size before running an A/B test rather than after?
3. An A/B test shows p = 0.04 but the lift is 0.1 percent. Should you ship it? What do you weigh?
4. What is "peeking" and why is it dangerous?
5. You cannot randomly assign people to a treatment. What kind of study is left, and what is its main limitation?

<details>
<summary>Answers</summary>

1. It balances confounders (known and unknown) across the groups on average, so the only systematic difference is the treatment. That is what lets you attribute the outcome difference to the change.
2. To ensure adequate power. An underpowered test is likely to miss real effects, and sizing after the fact invites stopping when the result looks good (peeking).
3. Probably not. A 0.1 percent lift is statistically significant but likely not practically meaningful. Weigh the effect size and confidence interval against the cost of shipping.
4. Repeatedly checking results and stopping as soon as p < 0.05. It massively inflates the false-positive rate because you get many chances to cross the threshold by chance.
5. An observational study. Its main limitation is unmeasured confounders, so it can show association and suggest causation but cannot establish it as cleanly as a randomized experiment.
</details>
