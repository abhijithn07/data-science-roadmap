# UNIT 4: Optimization

A natural question is, how does a model actually learn? The answer is that it keeps adjusting itself to make its predictions as close to the truth as possible. To do this, it needs two things: a way to measure how wrong it is (the loss and cost functions), and a method to reduce that wrongness (gradient descent). This whole process of reducing the error is called optimization.

---

## Loss Function

Before a model can improve, it must know how wrong each prediction is. That is what a loss function does. It can be defined as follows.

**A loss function is a measure of how wrong a single prediction is, by comparing the predicted value with the actual value.**

In simple words, the loss tells us how far off one prediction is.

**Example**

Suppose the model predicts a house price of 50 lakh but the actual price is 55 lakh. The error is 5 lakh. A common loss for regression is the squared error, which would be 5 squared = 25. We square it so that being too high or too low both count as positive error, and so that big mistakes are punished much more than small ones. For classification problems, a common loss is log loss (also called cross-entropy), which punishes a confident wrong answer heavily.

---

## Cost Function

A single prediction's error is not enough; we care about the model's error across all the data. That is the cost function. It can be defined as follows.

**A cost function is the average of the loss over the whole training dataset.**

In simple words, the cost is the overall error of the model across all examples.

The difference is small but worth remembering: loss is for one example, and cost is the average loss over all examples. The entire goal of training is to find the model settings that make this cost as small as possible.

**Example**

If we compute the squared error for every house in the training set and then take the average, that average is the Mean Squared Error cost. A cost of 25 means the model is, on average, off by about 5 (since 5 squared is 25). Training tries to push this number down.

---

## Gradient Descent

Now that we can measure the cost, we need a method to reduce it. The most important method is gradient descent. It can be defined as follows.

**Gradient descent is an optimization method that adjusts the model's parameters step by step to reduce the cost, by always moving in the direction that decreases the cost the most.**

In simple words, it is like walking downhill to reach the lowest point of the error.

**The analogy**

Imagine you are standing on a foggy hill and you want to reach the bottom, which is the point of lowest cost. You cannot see far, but you can feel the slope under your feet. So you take a step in the steepest downhill direction, then feel the slope again, take another step, and repeat until the ground is flat, meaning you have reached the lowest point. The slope is the gradient (the derivative of the cost), and each step updates the parameters.

The update rule is: new weight = old weight minus (learning rate times the gradient). We keep repeating this until the cost stops decreasing, which means we have reached the minimum.

---

## Learning Rate

The learning rate controls how big each downhill step is, and choosing it well is very important. It can be defined as follows.

**The learning rate is the size of the step that gradient descent takes each time it updates the parameters.**

In simple words, it is how big a step we take downhill.

If the learning rate is too high, the steps are so big that we jump right over the lowest point and bounce around, never settling, and the cost may even increase. If the learning rate is too low, the steps are tiny, so the model learns correctly but extremely slowly and may take forever. The right learning rate is in between, big enough to make good progress but small enough to settle into the minimum.

---

## Types of Gradient Descent

All three types do the same downhill walk, but they differ in how much data they use to compute each single step.

**1. Batch Gradient Descent**

Batch gradient descent can be defined as follows. **Batch gradient descent uses the entire training dataset to compute the gradient for each update.** In simple words, it looks at all the data before taking one step. This gives a stable and accurate direction, but it is very slow and memory-heavy on large datasets, because every single step must process every example.

**2. Stochastic Gradient Descent (SGD)**

Stochastic gradient descent can be defined as follows. **Stochastic gradient descent uses only one randomly chosen training example to compute the gradient for each update.** In simple words, it takes a step after looking at just one example. It is very fast and can handle huge datasets, and its randomness can even help it escape bad spots, but its path to the minimum is noisy and it jumps around rather than going straight down.

**3. Mini-Batch Gradient Descent**

Mini-batch gradient descent can be defined as follows. **Mini-batch gradient descent uses a small batch of examples (such as 32 or 64) to compute the gradient for each update.** In simple words, it takes a step after looking at a small group of examples. It is the middle ground: faster than batch and more stable than pure SGD. This is the method used in practice almost everywhere, especially in deep learning.

**Difference between the three types**

| Type | Data used per step | Speed | Stability |
| --- | --- | --- | --- |
| Batch | All examples | Slow | Very stable |
| Stochastic (SGD) | One example | Very fast | Noisy, jumps around |
| Mini-batch | A small group (32, 64) | Fast | Fairly stable |

The key idea across all of optimization is simple: measure the error with a cost function, then use gradient descent to walk downhill and make that error as small as possible.
