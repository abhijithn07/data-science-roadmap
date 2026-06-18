# UNIT 1: Foundations of Statistics

## What is Statistics?

In our daily life we collect a lot of information, but raw numbers by themselves are very hard to use. To make sense of them and to take good decisions even when we are not fully sure, we need a proper method. That method is statistics. Statistics can be defined as follows.

**Statistics is the science of collecting, organizing, analyzing and interpreting data to take decisions under uncertainty.**

In simple words, statistics is the science of learning useful information from data.

Statistics is divided into two branches, and almost everything we study falls under one of them.

**1. Descriptive Statistics**

Descriptive statistics is used to summarize and describe the data that we already have, using values like averages and spread, and using charts. It never goes beyond the data in hand. In simple words, descriptive statistics tells us what the data looks like.

**2. Inferential Statistics**

Inferential statistics is used to study a small sample and then draw conclusions about a much larger population that we did not fully measure. In simple words, inferential statistics helps us guess about the whole using only a part.

**Example**

Suppose I measure the heights of 50 students in my college and report that their average height is 168 cm. This is descriptive statistics, because I am only describing the 50 students I actually measured. Now suppose I use those same 50 students to estimate that the average height of all 5000 students in the college is about 168 cm. This is inferential statistics, because now I am making a claim about 4950 students I never measured, using only my small sample. So descriptive statistics stays inside the data, and inferential statistics jumps from the sample to the whole population.

---

## Basic Terms

Before going further, some terms come again and again in statistics, so we should fix their meaning first.

**Population** is the entire group we want to study, for example all 5000 students in the college. **Sample** is the smaller subset we actually measure, for example the 50 students we surveyed. **Variable** is a characteristic that changes from one observation to another, such as height or gender. **Datum** is a single recorded value, and **Data** is the whole collection of values. **Experiment** is a process where we control or change something and record the outcome.

Two terms are the most important. **Parameter** is a number that describes the population (like the true average height of all 5000 students, written mu), and it is usually unknown. **Statistic** is a number computed from the sample (like the average height of the 50 students, written x-bar). In simple words, the parameter is the real value we want, and the statistic is our estimate of it.

---

## Population vs Sample

In real life we almost never get to measure an entire group, so we measure a small part and use it to understand the whole. The complete group is the population and the small part is the sample. They can be defined as follows.

**Population is the complete group of all items that we want to study, and Sample is a small subset of the population that we actually measure.**

In simple words, population is everyone, and sample is the few we actually check.

We use a sample because the population is usually too large to measure fully, because measuring everyone takes too much time and money, and because sometimes measuring destroys the item.

**Example**

Suppose the government wants to know the average monthly income of every household in a city of 20,00,000 households. Measuring all of them is impossible in any reasonable time. So they carefully select 5000 households at random and record their incomes. Here the 5000 households are the sample, and the 20,00,000 households are the population. If the average income of the 5000 comes out to 40,000 rupees, they use it to estimate that the whole city average is near 40,000. The important thing is that the 5000 must be chosen well, so that they form a small mirror of the whole city. If they survey only rich areas, the sample becomes wrong, no matter how many households they add.

This example also shows the two kinds of error in sampling.

**1. Sampling Error**

Sampling error is the small, random difference between the sample value and the true population value, caused only because we used a subset instead of everyone. In simple words, it is normal luck-based error, and it becomes smaller as the sample size becomes bigger.

**2. Sampling Bias**

Sampling bias is a fixed, one-sided error caused by choosing the sample in a wrong way (like surveying only rich areas). In simple words, it is a tilted sample, and a bigger sample does NOT fix it. We fix bias only by selecting the sample properly.

**Differences between Population and Sample**

| Population | Sample |
| --- | --- |
| Complete group | Small part of the group |
| Usually very large | Small and manageable |
| Value is called Parameter | Value is called Statistic |
| Hard or impossible to measure fully | Easy and fast to measure |

---

## Census vs Sample

When we want information about a population, we have two methods. We either measure every single member, or we measure only a part. These can be defined as follows.

**Census is the method of collecting data by measuring every member of the population, and Sample is the method of collecting data by measuring only a selected part of the population.**

In simple words, census means check everyone, and sample means check a few and guess the rest.

We use a census when the population is small, when measuring does not destroy the items, and when the population is not changing quickly. We use a sample when the population is very large or infinite, when measuring destroys the item (like testing the life of bulbs), and when the population keeps changing fast.

**Example**

The national population census tries to count every citizen, which is why it takes years of effort and huge cost, and is done only once in ten years. On the other hand, a TV rating agency cannot ask every viewer what they are watching tonight, so it places meters in a few thousand sampled homes and estimates the whole country from them. The first is a census, the second is a sample, and each one fits its situation.

**Note (important point)**

A census is not always more accurate. Suppose one person tries to measure the height of all 5000 students in a single rushed afternoon. They get tired, the tape slips, some students are absent so they guess, and many small mistakes pile up. But if they carefully measure only 100 students, taking time and double checking, the careful 100 can give a closer answer than the rushed 5000. The reason is that there are two ways to be wrong, one from looking at only a subset (only a sample has this) and one from sloppy measuring (which gets worse when we rush a huge job). A census removes the first error but often makes the second one much worse.

**Differences between Census and Sample**

| Census | Sample |
| --- | --- |
| Measures every member | Measures only a part |
| Slow and costly | Fast and cheap |
| No sampling error | Has sampling error |
| Not possible for huge groups | Possible for huge groups |

---

## Parameters vs Statistics

When we work with data we deal with two kinds of numbers, one for the population and one for the sample, and they are named differently so that we never confuse the true value with our estimate. They can be defined as follows.

**A Parameter is a value that describes the whole population, and a Statistic is a value that describes the sample.**

In simple words, the parameter is the real answer (usually unknown), and the statistic is the answer we calculate from our sample.

A parameter is a fixed value but it is usually unknown to us. A statistic is calculated from data and it changes if we take a different sample. We use the statistic to estimate the parameter. The convention is that parameters are written using Greek letters (mu for mean, sigma for standard deviation, p for proportion) and statistics using English letters (x-bar, s, p-hat).

**Example**

The true average age of all employees in a large company is a parameter, call it mu, and nobody knows its exact value, because no one has recorded every employee perfectly. If I pick 50 employees and find their average age is 31.4 years, then that 31.4 is a statistic (my x-bar), and it is my best estimate of mu. If a friend picks a different 50 employees, they might get 30.9. The parameter mu never changed, but the statistic changed because the sample changed.

**Differences between Parameter and Statistic**

| Parameter | Statistic |
| --- | --- |
| Describes the population | Describes the sample |
| Usually unknown | Calculated from data |
| Fixed value | Changes with each sample |
| Greek letters | English letters |

---

## Types of Data

Before doing any analysis, we must know what type of data we have, because the type of data decides which summary, which chart and which test we are allowed to use. Data can be defined as follows.

**Data is the collection of facts, values or observations that we collect for analysis.**

In simple words, data is the raw information we work with. Data is mainly divided into two types.

**1. Numerical (Quantitative) Data**

Numerical data are numbers on which we can do calculations like addition and average. In simple words, it is data we can measure or count. Examples are age, height, salary and number of children. Numerical data is again divided into two types.

- **a. Discrete Data:** data that can take only fixed, countable whole-number values, with gaps in between. In simple words, we count it. For example, the number of children in a family is discrete, because it can be 2 or 3 but never 2.5.
- **b. Continuous Data:** data that can take any value within a range, including decimals, because we measure it. In simple words, there are no gaps. For example, height is continuous, since a person can be 170 cm, 170.4 cm or 170.42 cm depending only on how precise the ruler is.

**2. Categorical (Qualitative) Data**

Categorical data are labels or categories, not real numbers for calculation. In simple words, it is data that describes a quality or a group. Examples are gender, city and blood group. Categorical data is again divided into two types.

- **a. Nominal Data:** categories with no natural order. In simple words, the labels are just names with no high or low. For example, eye color, blood type and city.
- **b. Ordinal Data:** categories with a meaningful order, but with unequal gaps. In simple words, we can put them in order but cannot say by how much. For example, a rating of poor, good, excellent, where excellent is better than good, but not "twice as good".

**Note**

We can find the mean of numerical data, but for nominal data only the mode makes sense. Also, in machine learning, categorical data must be converted into numbers (encoding) before training a model.

---

## Measurement Scales

Measurement scales are a finer way to describe how much meaning a number or label carries. There are four scales, going from the weakest to the strongest, and they are remembered as NOIR: Nominal, Ordinal, Interval, Ratio.

**Measurement scale is the rule that decides what operations and comparisons we can do on the data.**

In simple words, it tells us how powerful the data is.

**1. Nominal Scale**

Only names or labels, with no order. We can only check whether two values are equal or not equal. For example, gender, city and blood group.

**2. Ordinal Scale**

Labels with a clear order, but the gap between values is not fixed or meaningful. For example, ranks like first, second, third, where we know the order but not by how much they differ.

**3. Interval Scale**

Numbers with order and equal gaps between values, but with NO true zero, so ratios do not work. For example, temperature in Celsius: the gap from 10 to 20 equals the gap from 20 to 30, but 0 degrees does not mean "no temperature", so 20 degrees is not twice as hot as 10.

**4. Ratio Scale**

Numbers with order, equal gaps and a true zero that really means "none", so all calculations are allowed. This is the strongest scale. For example, height, weight and salary, where 0 salary really means no salary, and 40,000 is exactly twice 20,000.

**Decision rule:** first ask, is there an order? If no, it is nominal. If yes, are the gaps equal? If no, it is ordinal. If yes, is there a true zero? If no, it is interval, and if yes, it is ratio.

**Note**

Nominal and ordinal belong to categorical data, while interval and ratio belong to numerical data. The single difference between interval and ratio is the true zero, which ratio has and interval does not.
