# UNIT 3: Probability

Probability is the foundation of inferential statistics and machine learning. It is the language we use to talk about uncertainty and chance.

---

## 1. Probability Fundamentals

**Probability is a number between 0 and 1 that tells us how likely an event is to happen.**

In simple words, it measures the chance of something happening.

Formula: probability of an event = (number of favorable outcomes) / (total number of outcomes)

- Probability 0 means impossible, probability 1 means certain.
- The probabilities of all possible outcomes add up to 1.

**Example**: probability of getting heads in a coin toss = 1/2 = 0.5.

---

## 2. Sample Space

**Sample space is the set of all possible outcomes of an experiment.**

In simple words, it is the list of everything that can happen.

**Example**

- Coin toss: sample space = {Heads, Tails}
- Rolling a die: sample space = {1, 2, 3, 4, 5, 6}

---

## 3. Events

**An event is one outcome or a group of outcomes from the sample space.**

In simple words, an event is the result we are interested in.

**Example**: rolling a die, the event "even number" = {2, 4, 6}.

**Types**

- Simple event: a single outcome (getting a 3).
- Compound event: more than one outcome (getting an even number).

---

## 4. Probability Rules

**Probability rules are the basic formulas used to combine the probabilities of events.**

In simple words, they tell us how to find the chance of "not A", "A or B", and "A and B".

- **Complement Rule**: P(not A) = 1 - P(A). The chance an event does NOT happen.
- **Addition Rule (OR)**: P(A or B) = P(A) + P(B) - P(A and B). If A and B cannot happen together (mutually exclusive), then P(A or B) = P(A) + P(B).
- **Multiplication Rule (AND)**: P(A and B) = P(A) x P(B given A). If A and B are independent, then P(A and B) = P(A) x P(B).

**Example**: drawing one card, P(king or heart) = P(king) + P(heart) - P(king of hearts) = 4/52 + 13/52 - 1/52 = 16/52.

---

## 5. Conditional Probability

**Conditional probability is the probability of an event happening given that another event has already happened.**

In simple words, it is the chance of B when we already know A happened.

Formula: P(B given A) = P(A and B) / P(A)
- Written as P(B|A).

**Example**: probability that a card is a king, given that it is a face card.

---

## 6. Independent Events

**Two events are independent if one event does not affect the probability of the other.**

In simple words, the result of one has no effect on the other.

- For independent events: P(A and B) = P(A) x P(B)

**Example**: tossing a coin twice. The first toss does not change the second.

---

## 7. Dependent Events

**Two events are dependent if the result of one event affects the probability of the other.**

In simple words, one event changes the chance of the other.

**Example**: drawing two cards without replacement. The first card changes what is left for the second.

**Difference (Independent vs Dependent)**

| Independent | Dependent |
| --- | --- |
| One does not affect the other | One affects the other |
| P(A and B) = P(A) x P(B) | P(A and B) = P(A) x P(B given A) |
| Coin tosses | Cards without replacement |

---

## 8. Bayes Theorem

Bayes theorem helps us update a probability after we get new information.

**Bayes theorem gives the probability of a cause given an observed effect, using prior knowledge.**

In simple words, it flips a conditional probability around, from P(A given B) to P(B given A).

Formula: P(A given B) = [ P(B given A) x P(A) ] / P(B)

- P(A) is the prior (what we believed before).
- P(A given B) is the posterior (what we believe after the evidence).

**Use**: spam filters, medical diagnosis, Naive Bayes classifier in machine learning.

---

## 9. Joint Probability

**Joint probability is the probability of two events happening together.**

In simple words, the chance of A and B both occurring.

- Written as P(A and B).

**Example**: probability that a person is both a student and owns a laptop.

---

## 10. Marginal Probability

**Marginal probability is the probability of a single event on its own, ignoring the other variables.**

In simple words, the chance of just A, no matter what happens with B.

- Written as P(A).

**Note**: it is called marginal because in a probability table it is found by adding across a row or column (the margin of the table).

---

## 11. Expected Value (Expectation)

**Expected value is the long-run average value of a random variable if the experiment is repeated many times.**

In simple words, the average outcome you expect over many tries.

Formula: E(X) = sum of (each value x its probability)

**Example**: a fair die. E(X) = (1 + 2 + 3 + 4 + 5 + 6) / 6 = 3.5.

**Note**: the expected value need not be a possible outcome (3.5 is not on a die). It is used heavily in machine learning loss functions and in decision making.

---

## 12. Law of Large Numbers

**The Law of Large Numbers says that as the number of trials increases, the sample average gets closer to the true (expected) value.**

In simple words, the more data you collect, the closer your average gets to the truth.

**Example**: flip a fair coin. With 10 flips you might get 70 percent heads, but with 10,000 flips you get very close to 50 percent.

**Note**: the Law of Large Numbers is about a single average becoming stable. The Central Limit Theorem (Unit 5) is about the bell shape of many sample means. They are different but related ideas.
