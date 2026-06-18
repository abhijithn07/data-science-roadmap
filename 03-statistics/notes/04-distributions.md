# UNIT 4: Probability Distributions

A probability distribution shows how the probabilities are spread across all possible values of a variable. In simple words, it tells us which values are common and which are rare.

Distributions are of two kinds: discrete (for countable values, like number of heads) and continuous (for measured values, like height).

---

## 1. Probability Functions (PMF, PDF, CDF)

These three functions describe a distribution.

- **PMF (Probability Mass Function)**: used for discrete data. It gives the probability of each exact value. In simple words, the chance of getting exactly that value. Example: P(exactly 5 heads in 10 tosses).
- **PDF (Probability Density Function)**: used for continuous data. It is the smooth curve whose area gives probability. The probability of any exact value is 0, so we only ask about ranges. In simple words, probability = area under the curve between two points, and the total area is 1.
- **CDF (Cumulative Distribution Function)**: gives the probability of getting a value less than or equal to x. In simple words, it adds up probability from the left. Example: P(height is less than or equal to 180).

**Note**: discrete distributions use a PMF, continuous distributions use a PDF, and both have a CDF.

---

## 2. Uniform Distribution

**A uniform distribution is one where every outcome has an equal chance of happening.**

In simple words, all values are equally likely.

- The shape is a flat, straight line (rectangle). Mean = (a + b) / 2.

**Example**: rolling a fair die. Each face (1 to 6) has probability 1/6.

---

## 3. Normal Distribution

**A normal distribution is a bell-shaped, symmetric distribution where most values are near the mean.**

In simple words, values cluster around the average, and fewer values appear as we move away.

**Properties**

- Bell-shaped and symmetric around the mean.
- Mean = median = mode.
- Defined by two values: mean (center) and standard deviation (spread).

**Empirical Rule (68-95-99.7)**

- About 68 percent of data is within 1 standard deviation of the mean.
- About 95 percent is within 2 standard deviations.
- About 99.7 percent is within 3 standard deviations.
- A value beyond 3 standard deviations (z greater than 3) is a common definition of an outlier.

**Example**: heights, weights, exam scores often follow a normal distribution.

**Note**: the normal distribution is the most important one, because many tests and the Central Limit Theorem are based on it.

---

## 4. Standard Normal Distribution

**The standard normal distribution is a normal distribution with mean 0 and standard deviation 1.**

In simple words, it is the normal distribution put on a common scale, written as Z.

**Z-score**: we convert any normal value into a standard normal value using a z-score.

Formula: z = (x - mean) / standard deviation

- The z-score tells us how many standard deviations a value is away from the mean.
- Positive z is above the mean, negative z is below.

**Example**: if mean = 50, standard deviation = 10, a value of 70 has z = (70 - 50) / 10 = 2 (two standard deviations above the mean).

**Note**: z-scores let us compare values from different normal distributions, and standardizing with z-scores is a very common machine learning preprocessing step.

---

## 5. Bernoulli Distribution

**The Bernoulli distribution describes a single trial with only two outcomes: success (1) or failure (0), with success probability p.**

In simple words, it is one yes/no event, like a single coin flip.

- Mean = p
- Variance = p(1 - p)

**Example**: one coin flip where P(heads) = 0.5.

**Note**: the Bernoulli is the building block of the binomial. A binomial is just many Bernoulli trials added together.

---

## 6. Binomial Distribution

**The binomial distribution gives the probability of getting a fixed number of successes in n independent Bernoulli trials.**

In simple words, it counts how many successes happen out of n tries.

**Conditions**

- Fixed number of trials (n).
- Each trial has only two outcomes (success or failure).
- The probability of success (p) is the same each time.
- Trials are independent.

- Mean = n x p
- Variance = n x p x (1 - p)

**Example**: tossing a coin 10 times and counting the number of heads.

---

## 7. Poisson Distribution

**The Poisson distribution gives the probability of a number of rare events happening in a fixed time or space, given an average rate lambda.**

In simple words, it counts how many times something happens in a period.

- Signature property: mean = variance = lambda.

**Example**: number of calls a call center gets in one hour, number of errors per hour on a website.

**Note**: Poisson is used for counts of events, while binomial is used for successes out of a fixed number of trials.

---

## 8. Exponential Distribution

**The exponential distribution gives the probability of the time we wait until the next event happens.**

In simple words, it models the waiting time between events.

**Example**: time until the next customer arrives, time until a machine fails.

**Note**: Poisson counts how many events happen, exponential measures the time between events. They are linked.
