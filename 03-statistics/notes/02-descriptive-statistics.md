# UNIT 2: Descriptive Statistics

Descriptive statistics is used to summarize a dataset using a few numbers. These numbers describe three things: the centre of the data (mean, median, mode), the spread of the data (range, variance, standard deviation, IQR), and the shape of the data (skewness, kurtosis). We study each of them below.

---

## Mean

The mean is the most familiar measure of the centre. Because it uses every single value, it reacts to every change in the data. The mean can be defined as follows.

**Mean is the sum of all values divided by the number of values.**

In simple words, the mean is the average.

Formula: mean = (sum of all values) / (number of values). The population mean is written mu and the sample mean is written x-bar.

**Example**

Take the exam scores 55, 60, 64, 66, 70. The mean is (55 + 60 + 64 + 66 + 70) / 5 = 315 / 5 = 63. So the typical score is around 63. But the mean has one weakness: it is sensitive to outliers. If that last score had been 195 instead of 70, the mean would jump to (55 + 60 + 64 + 66 + 195) / 5 = 88, even though four of the five students still scored in the sixties. One unusual value has pulled the average up to a number that describes nobody. This is exactly why we sometimes prefer the median.

---

## Median

The median is the value in the middle of the sorted data, so it splits the data into two equal halves. It can be defined as follows.

**Median is the middle value when the data is arranged in order.**

In simple words, it is the value that divides the data into two equal halves.

To find it, first arrange the values in increasing order. If the count is odd, the median is the middle value. If the count is even, the median is the average of the two middle values.

**Example**

Take 3, 5, 7, 9, 11. The middle value is 7, so the median is 7. Now take an even set, 3, 5, 7, 9. There is no single middle, so we average the two middle values, (5 + 7) / 2 = 6, and the median is 6. The big advantage of the median is that it is not affected by outliers. For the scores 55, 60, 64, 66, 70 the median is 64, and even if the 70 becomes a wild 195, the sorted data is 55, 60, 64, 66, 195 and the median is still 64. The mean was wrecked by that outlier, but the median barely moved, because it only cares about the position of the middle value, not its size. This is why income, which has a few very rich people, is reported using the median.

---

## Mode

The mode is the most common value in the data. It is the only measure of centre that also works for categorical data. The mode can be defined as follows.

**Mode is the value that appears most often in the data.**

In simple words, it is the most repeated value.

**Example**

In the data 2, 4, 4, 4, 6, 9 the value 4 appears three times, more than any other, so the mode is 4. For categorical data like the colors red, blue, blue, green, blue, the mode is blue, since it occurs most. A dataset can have no mode (all values appear once), one mode, or several modes if more than one value ties for the top.

---

## Range

The range is the simplest measure of spread, but it uses only the two most extreme values. It can be defined as follows.

**Range is the difference between the maximum and the minimum value.**

In simple words, it is the gap between the highest and the lowest value.

Formula: range = maximum value - minimum value.

**Example**

For 4, 8, 15, 16, 23 the range is 23 - 4 = 19. The weakness shows the moment there is an outlier. If one more value of 200 is added, the range becomes 200 - 4 = 196, even though almost all the data still sits between 4 and 23. So the range is quick to compute but easily fooled by a single extreme value.

---

## Variance

Variance measures how far the values are spread out from the mean, on average. It can be defined as follows.

**Variance is the average of the squared differences between each value and the mean.**

In simple words, it measures how much the data is scattered around the mean. We square the differences so that values below and above the mean do not cancel out.

Formula (sample): variance = sum of (x - mean) squared, divided by (n - 1). For a sample we divide by n - 1 (the correct degrees of freedom), and for a full population we divide by N.

**Example**

Take 2, 4, 6 with mean 4. The distances from the mean are -2, 0 and +2. Squaring them gives 4, 0 and 4, and their average is (4 + 0 + 4) / 3 = 2.67, so the variance is about 2.67. The one inconvenience of variance is that it is in squared units (like squared rupees), which has no real-world meaning, and this is exactly why we usually take its square root and use the standard deviation instead.

---

## Standard Deviation

The standard deviation brings the spread back into the original units, which makes it easy to read. It can be defined as follows.

**Standard deviation is the square root of the variance.**

In simple words, it is the typical distance of the values from the mean, in the original units. The population standard deviation is sigma and the sample one is s.

**Example**

From the variance example above, the variance was 2.67, so the standard deviation is the square root of 2.67, which is about 1.63. If those numbers were in centimetres, we would say the values sit on average about 1.63 cm away from the mean. A small standard deviation means the data is tightly packed around the mean, and a large one means it is widely spread. Because it is in the original units and uses every value, standard deviation is the most used measure of spread.

---

## Percentiles

A percentile tells us the position of a value inside the whole dataset. It can be defined as follows.

**A percentile is the value below which a given percentage of the data falls.**

In simple words, the kth percentile is the value that is greater than k percent of the data.

**Example**

If your exam score is at the 90th percentile, it means you scored higher than 90 percent of the students, and only 10 percent did better than you. Percentiles are how exam ranks, growth charts for children, and income brackets are described. One percentile you already know is the 50th percentile, which is just the median.

---

## Quartiles

Quartiles are special percentiles that cut the sorted data into four equal parts. They can be defined as follows.

**Quartiles are the three values (Q1, Q2, Q3) that split the ordered data into four equal parts.**

In simple words, they cut the data at 25 percent, 50 percent and 75 percent.

- Q1 (first quartile) is the 25th percentile, with one quarter of the data below it.
- Q2 (second quartile) is the 50th percentile, which is the median.
- Q3 (third quartile) is the 75th percentile, with three quarters of the data below it.

**Example**

If we line up everyone's exam scores from lowest to highest, Q1 is the score that the bottom 25 percent fall under, Q2 is the middle score, and Q3 is the score that 75 percent fall under. Together with the minimum and maximum, these form the five-number summary that pandas describe() prints.

---

## Interquartile Range (IQR)

The IQR measures the spread of only the middle 50 percent of the data, so it ignores the extremes. It can be defined as follows.

**IQR is the difference between the third quartile and the first quartile.**

In simple words, it is the spread of the middle 50 percent of the data.

Formula: IQR = Q3 - Q1.

**Example and use (outlier detection)**

A common rule says a value is an outlier if it is below Q1 - 1.5 x IQR, or above Q3 + 1.5 x IQR. For example, if Q1 is 60 and Q3 is 80, then the IQR is 20, and 1.5 x IQR is 30. So any value below 60 - 30 = 30, or above 80 + 30 = 110, is flagged as an outlier. This is the rule that draws the whiskers and dots on a box plot. Because the IQR throws away the bottom and top quarters, it is not affected by outliers, unlike the range.

---

## Skewness

Skewness describes the shape of the data, telling us whether it is balanced or tilted to one side. It can be defined as follows.

**Skewness is a measure of the asymmetry of the data distribution.**

In simple words, it tells us which side has a longer tail.

- **Symmetric (zero skew):** both sides mirror each other, like the normal bell curve, and the mean, median and mode are all equal.
- **Skewed right (positive):** a long tail on the right, where a few large values pull the mean above the median.
- **Skewed left (negative):** a long tail on the left, where a few small values pull the mean below the median.

**Example**

Income is the classic right-skew case: most people earn a modest amount, but a small number of very high earners stretch the right tail, so the mean income is higher than the median income. Exam scores can be left-skewed when most students do well and only a few score very low. The direction of skew is also why we use the median to fill missing values in a skewed column, since the median is not dragged around by that long tail.

---

## Kurtosis

Kurtosis also describes the shape, but it looks at the tails, meaning how often extreme values appear. It can be defined as follows.

**Kurtosis is a measure of how heavy or light the tails of a distribution are.**

In simple words, it tells us how often extreme values (outliers) appear.

- **Mesokurtic:** normal-sized tails, like the bell curve itself.
- **Leptokurtic:** heavy tails and a sharp peak, so extreme values happen more often than normal.
- **Platykurtic:** light, thin tails and a flat peak, so extreme values are rarer than normal.

**Example**

In finance, the returns of a risky stock are often leptokurtic, which means very large gains or losses (the extremes) happen more often than a normal distribution would predict. So high kurtosis is a warning that the data produces more surprises at the extremes than the normal bell curve suggests.
