# UNIT 3: Bias, Variance, Overfitting and Underfitting

When we train a model, it can fail in two opposite ways: it can be too simple to understand the data, or too complex and obsessed with the training data. Bias and variance are the two ideas that explain these two failures, and understanding them is the key to building a model that works on new data.

---

## Bias

Bias is the error that appears when a model is too simple to capture the real pattern in the data. It can be defined as follows.

**Bias is the error that comes from a model making wrong or oversimplified assumptions about the data.**

In simple words, bias is the model being too simple and missing the real relationship.

A high-bias model pays too little attention to the training data and assumes a pattern that is simpler than reality. It makes large errors on both the training data and new data, because it never really learned the pattern in the first place.

**Example**

Suppose house prices actually rise in a curved way as size increases, but we force a straight line to fit them. The straight line is too simple to follow the curve, so it is wrong for small houses and wrong for large houses. That consistent wrongness is high bias. The model underfits.

---

## Variance

Variance is the opposite problem: the model is too sensitive to the exact training data it saw. It can be defined as follows.

**Variance is the error that comes from a model being too sensitive to the specific training data, so it changes a lot if the training data changes.**

In simple words, variance is the model memorizing the training data, including its random noise, so it fails on new data.

A high-variance model is so flexible that it bends to fit every tiny detail and even the noise in the training set. It looks excellent on the training data but performs badly on new data, because the noise it memorized does not repeat.

**Example**

Imagine a very wiggly curve that bends to pass exactly through every single training house price. On the training data it has almost zero error, which looks amazing. But a new house, slightly different from the training ones, lands in a strange wiggle and gets a badly wrong prediction. That is high variance. The model overfits.

**A simple analogy (the dartboard)**

Think of throwing darts at a target. High bias is like all your darts landing together but far from the bullseye, because your aim is consistently off. High variance is like your darts scattered all over the board, sometimes near the centre and sometimes far, because you are inconsistent. A good model has low bias and low variance: darts grouped tightly around the bullseye.

---

## Bias-Variance Tradeoff

Bias and variance pull in opposite directions, and we cannot make both zero at the same time. This balance is called the bias-variance tradeoff. It can be defined as follows.

**The bias-variance tradeoff is the balance between a model being too simple (high bias) and too complex (high variance), with the goal of achieving the lowest total error.**

In simple words, we want a model that is neither too simple nor too complex, but just right.

As we make a model more complex, its bias goes down (it can follow the data better) but its variance goes up (it starts memorizing noise). As we make it simpler, variance goes down but bias goes up. The total error first falls and then rises, forming a U-shape, and the best model sits at the bottom of that U, where the sum of bias and variance is smallest.

---

## Underfitting

Underfitting is the visible result of high bias. It can be defined as follows.

**Underfitting happens when a model is too simple and performs poorly on both the training data and new data.**

In simple words, the model has not learned enough, so it is bad at both training and testing.

The cause is high bias, a model that is too simple for the problem. The clear sign of underfitting is low training accuracy and low test accuracy together, both poor.

**Example and fix**

Using a straight line to predict prices that curve gives low accuracy everywhere, which is underfitting. We fix it by using a more powerful model, adding more useful features, or training longer so the model can actually capture the pattern.

---

## Overfitting

Overfitting is the visible result of high variance, and it is the more common trap. It can be defined as follows.

**Overfitting happens when a model is too complex and learns the training data so well, including its noise, that it performs poorly on new data.**

In simple words, the model memorized the training data and cannot handle anything new.

The cause is high variance, a model that is too complex. The clear sign of overfitting is high training accuracy but low test accuracy, a big gap between the two.

**Example and fix**

In the EDA notes, the KNN model with k = 1 scored perfectly on the training data but lower on the test data, which is overfitting in action: it memorized the training points. We fix overfitting by collecting more data, using a simpler model, applying regularization (which penalizes complexity), using cross validation, or, in deep learning, using techniques like dropout.

---

## Difference between Underfitting and Overfitting

| Underfitting | Overfitting |
| --- | --- |
| Model too simple | Model too complex |
| High bias | High variance |
| Low training accuracy | High training accuracy |
| Low test accuracy | Low test accuracy |
| Misses the real pattern | Memorizes noise |
| Fix: bigger model, more features | Fix: more data, simpler model, regularization |

The goal of every machine learning project is to land in the middle, between these two, where the model has learned the real pattern but not the noise.
