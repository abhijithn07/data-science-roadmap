# UNIT 8: Experiments

Experiments help us find cause and effect. Companies like Netflix, Amazon and Uber run experiments every day to decide if a change actually helps.

---

## 1. A/B Testing

**A/B testing is an experiment that compares two versions (A and B) to see which one performs better.**

In simple words, show version A to one group and version B to another, then compare results.

**Steps**

1. Define the goal (example: more sign-ups).
2. Split users randomly into group A (control) and group B (treatment).
3. Show each group one version.
4. Measure the result for both groups.
5. Use a hypothesis test to check if the difference is significant.

**Example**: testing a red "Buy" button (A) against a green "Buy" button (B) to see which gets more clicks.

**Note**: random splitting is the key. It makes the two groups similar so the only difference is the version.

---

## 2. Multivariate Testing

**Multivariate testing is an experiment that tests multiple changes at the same time to see which combination works best.**

In simple words, A/B testing changes one thing, multivariate testing changes many things together.

**Example**: testing button color, headline text and image all at once, in different combinations.

**Note**: multivariate testing needs a much larger sample size because there are many combinations to compare.

---

## 3. Experiment Design

**Experiment design is the plan for how to run an experiment so the results are valid and unbiased.**

In simple words, planning the test the right way before collecting data.

**Key Parts**

- **Control group**: the group that does not get the change.
- **Treatment group**: the group that gets the change.
- **Independent variable**: the thing we change.
- **Dependent variable**: the result we measure.
- **Sample size**: must be large enough to detect a real effect.

---

## 4. Randomization

**Randomization is the process of randomly assigning subjects to groups in an experiment.**

In simple words, deciding who goes into which group purely by chance.

**Why it matters**

- It makes the groups similar on average.
- It removes selection bias.
- It allows us to claim cause and effect.

**Note**: without randomization, hidden differences between groups can fool us into a wrong conclusion.

---

## 5. Causal Inference Basics

**Causal inference is the study of finding whether one thing actually causes another, not just whether they are related.**

In simple words, it answers "does X cause Y" instead of "are X and Y related".

**Key Idea**

- Correlation only shows that two things move together.
- Causation shows that one thing makes the other happen.
- A confounder is a hidden third variable that affects both, creating a fake relationship.

**Example**: ice cream sales and drowning both go up in summer. They are correlated, but ice cream does not cause drowning. The confounder is hot weather.

**How we find causation**

- The gold standard is a randomized controlled experiment (like A/B testing).
- When experiments are not possible, special methods are used on observational data.

**Note**: this is one of the most important and hardest ideas in data science. Always ask "is this correlation or real causation?"
