# UNIT 2: Machine Learning Lifecycle

Building a machine learning solution is not just training a model. It is a full process that starts from understanding the real problem and ends with watching the model in production. These steps together are called the machine learning lifecycle. The lifecycle can be defined as follows.

**The machine learning lifecycle is the complete set of stages followed to build, deploy and maintain a machine learning solution, from problem definition to monitoring.**

In simple words, it is the full journey of an ML project from start to finish.

To make every stage concrete, we will follow one running example all the way through: a bank wants to predict which loan applicants are likely to default (not repay), so it can decide whom to approve.

---

## 1. Problem Definition

The first step is to clearly state the problem we are solving and what kind of ML task it is.

In simple words, before touching any data, we decide exactly what we want to predict and how we will measure success. A vague goal leads to a useless model.

For the bank, the problem is defined as: predict whether a loan applicant will default (yes or no), using their application details. This is a supervised classification problem, and success might be measured by how many real defaulters we catch without rejecting too many good applicants.

---

## 2. Business Understanding

Before modeling, we must understand the business need and the cost of mistakes, because the model must serve a real goal.

In simple words, we ask why the business wants this and what a wrong answer costs them.

For the bank, missing a real defaulter (approving someone who then does not repay) costs a lot of money, while wrongly rejecting a good applicant costs a lost customer. Understanding that a missed defaulter is more expensive tells us later to care more about recall (catching defaulters) than about plain accuracy.

---

## 3. Data Collection

Next we gather the data needed to learn from.

In simple words, we collect all the past examples and information that will help the model learn.

The bank collects past loan records: each applicant's age, income, loan amount, credit score, employment status, and crucially whether they defaulted or not. The default column is the answer (label) the model will learn to predict. Data can come from databases, files, or external sources, and more relevant data usually helps.

---

## 4. Data Cleaning

Raw data is almost always messy, so we fix it before using it.

**Data cleaning is the process of fixing or removing wrong, missing or duplicate data so that the dataset is reliable.**

In simple words, we tidy up the data so the model is not fed garbage.

In the bank data, some applicants have a missing income, some ages are clearly wrong (like 200), and a few records are duplicated. We fill or fix the missing values, correct or remove the impossible ages, and drop duplicates. The saying "garbage in, garbage out" means a model trained on dirty data gives dirty predictions, so this step is critical.

---

## 5. Exploratory Data Analysis (EDA)

Once the data is clean, we explore it with statistics and plots to understand it.

**EDA is the process of understanding the data using summary statistics and visualizations before modeling.**

In simple words, we get to know the data, its shape, its relationships and its surprises.

For the bank, EDA might reveal that defaulters tend to have lower credit scores and higher loan-to-income ratios, that the default rate is only 20 percent (so the classes are imbalanced), and that income is right-skewed. These findings guide every later choice, such as which features matter and how to handle the imbalance. (EDA is covered in full detail in the statistics notes.)

---

## 6. Feature Engineering

Now we prepare and improve the input columns (features) so the model can learn well.

**Feature engineering is the process of creating, transforming and selecting the input features that the model will learn from.**

In simple words, we shape the raw columns into the best possible inputs for the model.

For the bank, we might create a new feature called loan-to-income ratio (loan amount divided by income), which is more useful than either column alone. We also scale the numeric columns, convert categorical columns like employment status into numbers (encoding), and drop columns that carry no useful signal. Good feature engineering often matters more than the choice of model.

---

## 7. Model Building

With the features ready, we choose an algorithm and train the model.

**Model building is the process of selecting a machine learning algorithm and training it on the prepared data.**

In simple words, we pick a method and let it learn the patterns from the training data.

For the bank, we might try a few algorithms, such as logistic regression, a decision tree and a random forest, and train each on the historical applicants. Training means the algorithm studies the inputs and the known default outcomes and adjusts itself to predict default as accurately as it can.

---

## 8. Evaluation

After training, we check how good the model really is, using data it has not seen.

**Evaluation is the process of measuring the model's performance on unseen data using suitable metrics.**

In simple words, we test the model on new examples to see if it actually works, not just memorized.

For the bank, we test the model on a held-out set of applicants whose outcomes we know but the model did not train on. Because a missed defaulter is costly, we look closely at recall (how many real defaulters we caught) and at the confusion matrix, not just plain accuracy. Accuracy alone is misleading here, since a lazy model that approves everyone would still be 80 percent accurate while catching zero defaulters.

---

## 9. Deployment

A good model is useless sitting on a laptop, so we put it into real use.

**Deployment is the process of putting the trained model into production so it can make predictions on real, live data.**

In simple words, we connect the model to the real system so it starts giving predictions to users.

For the bank, the model is deployed behind the loan application system. When a new applicant applies, their details are sent to the model, which returns a default risk score that helps the officer decide. This is often done by wrapping the model in an API so other software can call it.

---

## 10. Monitoring

The job is not over after deployment, because the world keeps changing.

**Monitoring is the process of continuously checking a deployed model's performance and the incoming data over time.**

In simple words, we keep watching the model to catch the moment it starts going wrong.

For the bank, the economy might change, so the kind of people applying and their default behavior shifts away from the data the model was trained on. This is called drift. Monitoring detects when the model's accuracy is dropping or when the new data looks different from the training data, which signals that the model needs to be retrained on fresh data. Then the lifecycle loops back to earlier stages.

---

## Recap

The full machine learning lifecycle, start to finish, is: define the problem, understand the business, collect data, clean the data, explore it with EDA, engineer the features, build the model, evaluate it, deploy it, and monitor it. The most important idea is that it is a loop, not a straight line, because monitoring sends us back to retrain whenever the data or the world changes.
