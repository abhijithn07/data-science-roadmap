# UNIT 1: Machine Learning Introduction

## What is Artificial Intelligence (AI)?

For a long time, computers could only do exactly what a programmer told them to do, step by step. They could not handle situations the programmer did not think of. Artificial Intelligence is the attempt to go beyond that and make machines behave smartly. AI can be defined as follows.

**Artificial Intelligence is the branch of computer science that builds machines able to perform tasks that normally require human intelligence, such as understanding language, recognizing images and making decisions.**

In simple words, AI is making machines think and act smartly like humans.

AI is the biggest umbrella. It includes simple rule-based systems where a human writes all the rules (like an old chess program that follows fixed instructions), as well as modern systems that learn from data on their own. Anything that makes a machine appear intelligent falls under AI.

**Example**

When a voice assistant like Alexa understands your spoken command and replies, that is AI. When your email automatically moves a junk message into the spam folder, that is AI too. Both are machines doing something that would normally need a human brain.

---

## What is Machine Learning (ML)?

The problem with writing fixed rules is that for many tasks it is impossible. Nobody can write down every rule needed to recognize a cat in a photo, because cats appear in millions of poses, colors and lightings. Machine Learning solves this by letting the machine learn the rules itself from examples. ML can be defined as follows.

**Machine Learning is a branch of AI where machines learn patterns from data and improve their performance without being explicitly programmed with rules.**

In simple words, instead of writing the rules ourselves, we show the machine many examples and it learns the rules by itself.

The difference from traditional programming is important. In traditional programming, we give the computer data and rules, and it produces answers. In machine learning, we give the computer data and answers (examples), and it produces the rules, which we call the model. After that, the model can answer new questions it has never seen.

**Example**

To build a spam detector the old way, you would try to write rules like "if the email contains the word lottery, mark it spam", which fails quickly. With machine learning, instead we give the model 10,000 emails that are already labeled spam or not spam. The model studies them and learns on its own which words and patterns usually mean spam. When a new email arrives, it predicts spam or not spam based on what it learned.

---

## What is Deep Learning (DL)?

Ordinary machine learning often needs a human to decide which features of the data matter. For very complex data like images, audio and language, even that becomes too hard. Deep Learning handles this using brain-inspired networks. DL can be defined as follows.

**Deep Learning is a branch of ML that uses artificial neural networks with many layers to learn complex patterns directly from large amounts of data.**

In simple words, deep learning is machine learning using brain-like networks with many layers, and it is very good at complex data such as images, audio and text.

The key advantage is that deep learning learns the features by itself, layer by layer, instead of a human designing them. The cost is that it needs a lot of data and a lot of computing power, usually special hardware called GPUs.

**Example**

Face recognition that unlocks your phone, the system behind ChatGPT, and the vision system of a self-driving car are all deep learning. Each one learns directly from huge amounts of raw images or text, without a human listing the rules.

---

## What is Data Science?

Building a model is only one part of working with data. Before that we have to collect it, clean it, explore it, and after that we have to explain the results. Data Science is the name for this whole journey. It can be defined as follows.

**Data Science is the field that uses statistics, programming and domain knowledge together to extract useful insights and value from data.**

In simple words, data science is the whole process of turning raw data into useful knowledge and decisions.

Data science is broader than machine learning. It includes gathering data, cleaning it, doing statistics and visualization, and sometimes building ML models. So machine learning is one powerful tool that sits inside the larger field of data science.

**Example**

A data scientist at a streaming company studies viewing data to find which shows to recommend, to understand why some users cancel their subscription, and to advise the business on what to produce next. Some of that uses ML models, and some of it is just careful analysis and explanation.

---

## What is Data Analytics?

Data Analytics is closely related to data science, but its focus is a little different. It can be defined as follows.

**Data Analytics is the field that examines data to find patterns, answer questions and support decisions, mostly about what has already happened.**

In simple words, data analytics is looking at data to understand what happened and why.

Data analytics leans more towards describing and reporting, using dashboards, summaries and key numbers (KPIs). Data science leans more towards predicting the future and building models. There is a big overlap, but the simplest way to remember it is that analytics explains the past and present, while data science also tries to predict the future.

**Difference between Data Analytics and Data Science**

| Data Analytics | Data Science |
| --- | --- |
| Focus on past and present | Focus on prediction and the future |
| Mostly reports, dashboards, KPIs | Builds models, sometimes ML |
| Answers "what happened and why" | Answers "what will happen and what should we do" |

---

## AI vs ML vs DL

These three words are often used as if they mean the same thing, but they are actually nested inside one another, like circles inside circles. AI is the biggest circle. Machine learning is a smaller circle inside AI. Deep learning is an even smaller circle inside machine learning.

So every deep learning system is machine learning, and every machine learning system is AI, but not the other way round. A simple rule-based chess program is AI but not ML, because it does not learn. A spam filter trained on examples is ML. A face recognition network is DL.

**Difference between AI, ML and DL**

| AI | ML | DL |
| --- | --- | --- |
| Broadest field | A subset of AI | A subset of ML |
| Any smart machine behavior | Learns patterns from data | Learns using deep neural networks |
| Can use fixed rules or learning | Needs data and answers | Needs a lot of data and computing power |
| Example: voice assistant | Example: spam filter | Example: ChatGPT, face recognition |

---

## Types of Machine Learning

Machine learning is divided into four main types, based on what kind of data we have and how the model learns.

**1. Supervised Learning**

Supervised learning can be defined as follows. **Supervised learning is a type of ML where the model learns from labeled data, meaning each example has both the input and the correct output.** In simple words, we teach the model using questions along with their correct answers, and it learns to answer new questions. Supervised learning has two sub-types: regression, where we predict a number (like house price), and classification, where we predict a category (like spam or not spam).

For example, to predict the price of a house, we give the model thousands of past houses with their size, location and the price they sold for. The price is the answer (label), so this is supervised. Once trained, it can predict the price of a new house. Predicting whether a tumor is benign or malignant from its measurements is also supervised, but it is classification because the answer is a category.

**2. Unsupervised Learning**

Unsupervised learning can be defined as follows. **Unsupervised learning is a type of ML where the model learns from unlabeled data, finding hidden patterns or groups on its own.** In simple words, we give the data without any answers, and the model discovers the structure by itself. Its main tasks are clustering (grouping similar items) and dimensionality reduction (simplifying the data).

For example, an online store gives the model the buying behavior of all its customers, but with no labels telling who belongs to which group. The model finds, on its own, that there are groups such as "budget shoppers", "frequent buyers" and "weekend shoppers". Nobody told it these groups existed; it discovered them from the patterns. This is clustering.

**3. Semi-Supervised Learning**

Semi-supervised learning can be defined as follows. **Semi-supervised learning is a type of ML that uses a small amount of labeled data together with a large amount of unlabeled data.** In simple words, we label only a few examples by hand, and let the model use the many unlabeled ones to learn better. It is used when labeling data is expensive or slow.

For example, suppose we have 100,000 photos but labeling them by hand is costly, so we only label 1,000 of them. A semi-supervised model uses those 1,000 labeled photos plus the 99,000 unlabeled ones to learn a better classifier than it could from the 1,000 alone.

**4. Reinforcement Learning**

Reinforcement learning can be defined as follows. **Reinforcement learning is a type of ML where an agent learns by interacting with an environment and receiving rewards for good actions and penalties for bad ones.** In simple words, the model learns by trial and error, gaining points for good moves and losing points for bad moves, until it discovers the best strategy.

For example, a game-playing AI like the one that mastered the board game Go learns by playing millions of games against itself. Winning gives a reward and losing gives a penalty, so over time it learns which moves lead to victory. A robot learning to walk works the same way, getting rewards for staying upright.

**Difference between the four types**

| Type | Data used | Goal | Example |
| --- | --- | --- | --- |
| Supervised | Labeled (input and answer) | Predict the answer | Spam detection, house price |
| Unsupervised | Unlabeled | Find hidden groups or structure | Customer segmentation |
| Semi-supervised | Few labeled, many unlabeled | Learn from limited labels | Photo classification |
| Reinforcement | Rewards and penalties | Learn the best actions | Game AI, robotics |
