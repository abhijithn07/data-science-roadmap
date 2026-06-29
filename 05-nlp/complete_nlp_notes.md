# Complete NLP for Machine Learning (In One Shot)

---

## 1. Roadmap to Learn NLP

In standard machine learning we solve supervised problems (classification and regression) and unsupervised problems. A supervised model takes independent features `F1, F2, ... Fn` and learns to predict a dependent output feature. Those features are usually continuous or categorical, and categorical values can be converted with one hot encoding, target encoding, ordinal encoding, and so on.

The problem starts when an input feature is raw text. A model cannot read human language directly, and the language could change (English today, Chinese tomorrow), so the text has to become numbers first.

**Natural Language Processing (NLP) is the set of techniques used to convert text or sentences into meaningful vectors so a machine learning or deep learning model can process language and solve use cases on it.**

Plainly: NLP is the bridge that turns words into numbers that still carry meaning, so the usual ML machinery can run on them.

### Where NLP fits: AI vs ML vs DL

Think of three nested circles. **Artificial Intelligence** is the outer universe, the goal of building applications that do tasks on their own without human intervention. **Machine Learning** is a subset of AI that provides the statistical tools to analyze data, explore it, forecast, and make predictions. **Deep Learning** is a subset of machine learning that uses multi-layered neural networks to mimic how the human brain learns.

NLP is not a fourth circle. It sits across both ML and DL, because what defines NLP is the data type, text, not the algorithm. The reason it spans both is simple: a machine only understands binary (ones and zeros), so any text or voice we feed it has to be converted into vectors (a numerical format) first. Once text is vectorized, either an ML model or a DL model can learn the relationships between words and produce an output such as a spam label, a summary, a translation, or a chatbot reply.

### Prerequisites

Before NLP, the live session expects:

- **Python** (the working language).
- Some **statistics**.
- A few **machine learning algorithms**.
- **ANN** fundamentals, including optimizers and loss functions (needed once Word2Vec and deep learning start). CNN is not required.
- Later, **RNN, LSTM, GRU** for the deep-learning portion.

Motivating example, spam classification:

| email_subject | email_body | output |
|---|---|---|
| (text) | "you won a lottery of a billion dollars" | spam (1) |

The features here are entirely text, so the email has to be vectorized before any classifier can act on it. This is also what powers Alexa, Google Home, and "switch off the AC" style commands.

### The roadmap pyramid (bottom to top)

Build from the bottom up. Accuracy increases as you climb, and so does model size.

0. **Programming language**: Python.
1. **Text Preprocessing Part 1**: cleaning the input. Tokenization, stemming, lemmatization, stop words.
2. **Text Preprocessing Part 2**: converting cleaned text into vectors. Bag of Words, TF-IDF, unigrams, bigrams.
3. **Text Preprocessing Part 3**: better text-to-vector conversion. Word2Vec, Average Word2Vec (deep-learning based, often via the gensim library).
4. **Sequence models**: RNN, LSTM, GRU (deep learning for text classification, summarization, and more).
5. **Word embeddings (advanced)**: another text-to-vector approach that internally uses Word2Vec ideas, far more advanced, and which you can train yourself.
6. **Advanced deep learning**: bidirectional LSTM, encoders and decoders (used to build machine-translation systems), and attention models.
7. **Transformers and BERT**: the most advanced and most accurate, also the largest.

For NLP with classical machine learning you focus on the lower layers and use **NLTK**, **spaCy**, and **TextBlob**. For deep learning you move to **TensorFlow** (Google) or **PyTorch** (Facebook/Meta), and **Hugging Face** for pretrained transformer models. Whatever the layer, the goal never changes: clean the text, turn it into vectors, then solve the use case.

A practical caution from the session: do not jump straight to deep learning. If classical preprocessing plus an ML model already gives good accuracy on a simple problem, use that. Strong basics at each layer are what let you climb to the next one.

### Open challenge: sarcasm

A genuinely hard, still-unsolved problem is sarcasm. "You are brilliant" is positive, but "you are just brilliant, you don't know anything" is the opposite, and the surface words barely change. Machines still struggle to capture this, though work is progressing (for example open-source sarcasm-detection models, and voice-dubbing systems that can take English speech and re-voice it into other languages). The takeaway for note purposes: context and tone remain the frontier, not just word-to-vector conversion.

---

## 2. Practical Use Cases of NLP

Everyday products that are quietly running NLP:

- **Gmail**: spell correction, autocomplete, smart compose, and auto-generated reply suggestions.
- **LinkedIn**: automated quick-reply tags on messages.
- **Google Translate**: text translated across languages (English to Arabic, Hindi, etc.), plus "see translation" on multilingual posts.
- **Google search**: text-to-image and text-to-video retrieval by understanding the query text.
- **Hugging Face**: a hub of pretrained models for question answering, summarization, text classification, and translation, used by Google AI, Intel, Microsoft, Grammarly, and others.
- **Alexa and Google Assistant**: voice commands and calendar lookups ("do I have a doctor appointment tomorrow"), all driven by language understanding.

Common thread: every one of these takes text as input and performs a task on top of it.

---

## 3. Tokenization and Basic Terminologies

You will hear these four words constantly, so fix them first.

- **Corpus**: a paragraph, that is the whole body of text.
- **Documents**: the sentences inside the corpus.
- **Vocabulary**: the set (and count) of unique words in the corpus.
- **Words**: every word token in the corpus, repeats included.

**Tokenization is the process of breaking a paragraph or a sentence into smaller units called tokens. A paragraph can be tokenized into sentences, and a sentence (or paragraph) can be tokenized into words.**

Plainly: tokenization is the "cut it into pieces" step. The pieces can be sentences or words depending on which tokenizer you use. It is part of preprocessing because every word later needs its own vector.

Paragraph to sentences, then sentences to words:

```
Corpus (paragraph):
"My name is Krish and I have interest in teaching ML, NLP and DL. I am also a YouTuber."

Tokenize into sentences (documents), splitting on the full stop:
  S1: "My name is Krish and I have interest in teaching ML, NLP and DL"
  S2: "I am also a YouTuber"

Tokenize S1 into words:
  [My, name, is, Krish, and, I, have, interest, in, teaching, ML, NLP, and, DL]
```

So a token can be a sentence or a word: paragraph -> sentences is one tokenization, sentence -> words is another.

Worked vocabulary example:

```
Paragraph: "I like to drink apple juice. My friend likes mango juice."
Sentences (documents): 2 (split on the full stop)
Total words: 11
Unique words (vocabulary): I, like, to, drink, apple, juice, my, friend, likes, mango = 10
```

Note that `like` and `likes` count as two different words, while the repeated `juice` is counted once. If `likes` were `like`, the vocabulary would shrink to 9.

---

## 4. Tokenization Practicals (NLTK)

Install once with `pip install nltk`. NLTK is a leading platform for building Python programs that work with human language data. (Assignment from the video: compare NLTK and spaCy yourself.)

```python
corpus = """Hello welcome to Krish Naik's NLP tutorials.
Please do watch the entire course! To become expert in NLP."""
```

**`sent_tokenize`**: paragraph to sentences. Splits on sentence-ending characters like `.` and `!`.

```python
from nltk.tokenize import sent_tokenize
documents = sent_tokenize(corpus)
# -> ["Hello welcome to Krish Naik's NLP tutorials.",
#     'Please do watch the entire course!',
#     'To become expert in NLP.']
```

**`word_tokenize`**: paragraph or sentence to words. Punctuation like `,` `.` `!` becomes its own token, but `Naik's` stays as one token.

```python
from nltk.tokenize import word_tokenize
word_tokenize(corpus)   # each word and each punctuation mark is a separate token
```

**`wordpunct_tokenize`**: like `word_tokenize`, but it also splits punctuation off contractions. So `Naik's` becomes `Naik`, `'`, `s`.

```python
from nltk.tokenize import wordpunct_tokenize
wordpunct_tokenize(corpus)
```

**`TreebankWordTokenizer`**: similar to `word_tokenize`, with one difference. A full stop is attached to the previous word, except the final full stop of the text, which stays separate.

```python
from nltk.tokenize import TreebankWordTokenizer
tokenizer = TreebankWordTokenizer()
tokenizer.tokenize(corpus)
```

In practice, `word_tokenize` and `sent_tokenize` cover most needs.

---

## 5. Text Preprocessing: Stemming (NLTK)

When solving a review or spam classifier, words like `eating`, `eat`, `eaten` all carry the same core meaning. Keeping all of them inflates the feature count because every distinct word becomes a vector. Collapsing them to one root reduces that.

**Stemming is the process of reducing a word to its word stem by stripping affixes (prefixes or suffixes), where the stem may not be a real dictionary word.**

Plainly: stemming chops word endings using rules to reach a common root, fast but sometimes crude.

### Porter Stemmer

```python
from nltk.stem import PorterStemmer
stemming = PorterStemmer()
for w in ["eating","eats","eaten","writing","writes","programming",
          "programs","history","finally","finalized"]:
    print(w, "->", stemming.stem(w))
```

Good results: `eating -> eat`, `writes -> write`, `programs -> program`, `finally -> final`. Bad results that change meaning: `history -> histori`, `congratulations -> congratul`. This broken-word problem is the main disadvantage of stemming.

### Regexp Stemmer

**A stemmer that removes any prefix or suffix matching a regular expression you supply.**

```python
from nltk.stem import RegexpStemmer
reg_stemmer = RegexpStemmer('ing$|s$|e$|able$', min=4)
reg_stemmer.stem('eating')   # -> 'eat'   ($ anchors to the end)
reg_stemmer.stem('ingeating') # -> 'ingeat' (only the trailing 'ing' is removed)
```

The `$` anchors the pattern to the end of the word, so only trailing matches are stripped.

### Snowball Stemmer

**An improved stemming algorithm that generally produces better word forms than the Porter Stemmer.**

```python
from nltk.stem import SnowballStemmer
snowball = SnowballStemmer('english')
snowball.stem('fairly')      # -> 'fair'   (Porter gives 'fairli')
snowball.stem('sportingly')  # -> 'sport'  (Porter gives 'sportingli')
```

Snowball wins on words like `fairly` and `sportingly`, but it still mangles some words (`history`, `goes -> goe`). For chatbots and similar use cases, no stemmer is good enough, which is why we move to lemmatization.

### Stemming at a glance

- **Advantage**: very fast, since it only applies rules. Good for preprocessing huge datasets.
- **Disadvantage**: it can strip the meaning of a word and leave a non-word.
- **Use cases where the broken form is acceptable**: spam/ham classification, comment or review classification (good/bad, star ratings), toxic-comment classification.

---

## 6. Text Preprocessing: Lemmatization (NLTK)

Stemming returns a stem that can be a non-word. Lemmatization fixes that.

**Lemmatization reduces a word to its lemma, the valid dictionary root word, using the WordNet corpus so the output is always a real, meaningful word.**

Plainly: lemmatization looks the word up against a real dictionary instead of chopping it, so `goes -> go`, `history -> history`, `fairly -> fairly`, all valid.

```python
from nltk.stem import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()
lemmatizer.lemmatize('going')            # -> 'going' (default POS is noun 'n')
lemmatizer.lemmatize('going', pos='v')   # -> 'go'
```

The `pos` (part of speech) parameter matters a lot. POS tags used here:

- `n` noun (default)
- `v` verb
- `a` adjective
- `r` adverb

With `pos='v'`, words like `eating`, `eats`, `eaten` all return `eat`, and `history` stays `history`.

**Stemming vs lemmatization, which is slower?** Lemmatization, because it compares against the WordNet corpus through `morphy`. Use lemmatization where output quality matters, for example Q&A systems, chatbots, text summarization, and language translation. Use stemming where speed matters more than perfect forms, for example spam/ham or review classification.

---

## 7. Stop Words

Words like `the`, `is`, `a`, `he`, `she`, `of`, `to` appear everywhere and rarely help tasks like sentiment or spam detection.

**Stop words are very common words that carry little discriminative meaning and are usually removed during preprocessing to shrink the text and keep only informative words.**

Caution: words like `not` can flip sentiment, so review the list and consider building your own stop-word set rather than blindly removing all of them.

```python
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords
stopwords.words('english')   # also supports german, french, arabic, etc.
```

Typical pipeline, stop-word removal combined with stemming, on a paragraph (the APJ Abdul Kalam speech in the video):

```python
from nltk.stem import SnowballStemmer
stemmer = SnowballStemmer('english')
sentences = nltk.sent_tokenize(paragraph)

for i in range(len(sentences)):
    words = nltk.word_tokenize(sentences[i])
    words = [stemmer.stem(word.lower())
             for word in words
             if word not in set(stopwords.words('english'))]
    sentences[i] = ' '.join(words)
```

For each sentence: tokenize into words, drop any word that is a stop word, stem (or lemmatize) the rest, then join back into a sentence. Using a `set` for the stop words avoids repeated lookups. Lowercasing matters because `Boy` and `boy` would otherwise be treated as two different words. Swap `SnowballStemmer` for `WordNetLemmatizer().lemmatize(word.lower(), pos='v')` to get cleaner, valid words.

---

## 8. Parts of Speech (POS) Tagging

POS tagging is what makes lemmatization accurate, since the lemma of a word depends on whether it is a verb, noun, or adjective.

**POS tagging assigns each word a grammatical category (noun, verb, adjective, adverb, and so on) automatically.**

Some common tags: `CC` coordinating conjunction, `CD` cardinal digit, `DT` determiner, `IN` preposition, `JJ` adjective, `NN` noun singular, `NNP` proper noun singular, `NNPS` proper noun plural, `PRP` personal pronoun, `RB` adverb, `VBZ` verb third-person singular.

```python
nltk.download('averaged_perceptron_tagger')
sentence = "Taj Mahal is a beautiful Monument"
nltk.pos_tag(sentence.split())
# -> Taj NNP, Mahal NNP, is VBZ, a DT, beautiful JJ, Monument NN
```

Important gotcha: `pos_tag` expects a list of words. Passing a raw string makes it tag each character.

---

## 9. Named Entity Recognition (NER)

Beyond grammatical role, we often want to know what real-world thing a word refers to.

**Named Entity Recognition identifies and classifies entities in text into categories such as PERSON, GPE (geo-political entity / location), ORGANIZATION, DATE, TIME, and MONEY.**

Example sentence: "The Eiffel Tower was built from 1887 to 1889 by French engineer Gustave Eiffel, whose company specialized in building metal frameworks." NER can tag `Eiffel Tower` as an organization/place, `1887`/`1889` as dates, and `Gustave Eiffel` as a person.

```python
nltk.download('maxent_ne_chunker')
nltk.download('words')
words = nltk.word_tokenize(sentence)
tag_elements = nltk.pos_tag(words)
nltk.ne_chunk(tag_elements).draw()   # renders a labeled tree
```

POS tagging runs first, then `ne_chunk` groups tagged tokens into entities.

---

## 10. One Hot Encoding

This is the first text-to-vector method, and it is mostly used to expose the problems the later methods solve.

**One Hot Encoding represents each word as a vector of length V (the vocabulary size), with a 1 in the position of that word and 0 everywhere else.**

Example corpus:

```
D1: the food is good
D2: the food is bad
D3: pizza is amazing
Vocabulary (V = 7): the, food, is, good, bad, pizza, amazing
```

Each word becomes a 7-length vector, for instance `the = [1,0,0,0,0,0,0]`, `food = [0,1,0,0,0,0,0]`. A sentence becomes a stack of these word vectors:

```
D1 "the food is good" -> shape 4 x 7
[[1,0,0,0,0,0,0],   # the
 [0,1,0,0,0,0,0],   # food
 [0,0,1,0,0,0,0],   # is
 [0,0,0,1,0,0,0]]   # good
```

Doing the same for the other two documents shows the core problem. D2 shares its first three words with D1, only the last word changes to `bad`:

```
D2 "the food is bad" -> shape 4 x 7
[[1,0,0,0,0,0,0],   # the
 [0,1,0,0,0,0,0],   # food
 [0,0,1,0,0,0,0],   # is
 [0,0,0,0,1,0,0]]   # bad

D3 "pizza is amazing" -> shape 3 x 7
[[0,0,0,0,0,1,0],   # pizza
 [0,0,1,0,0,0,0],   # is
 [0,0,0,0,0,0,1]]   # amazing
```

D1 and D2 are 4 x 7 but D3 is 3 x 7. The row count changes with sentence length, which is exactly why one hot encoding cannot be fed straight into an ML model (covered under disadvantages).

### Advantages
- Easy to implement (`sklearn` `OneHotEncoder`, `pandas` `pd.get_dummies`).

### Disadvantages
- **Sparse matrix**: mostly zeros and ones, which tends to cause overfitting (great training accuracy, poor on new data).
- **No fixed-size input**: D1 is 4x7, D3 is 3x7. ML algorithms need fixed-size inputs, so this cannot be trained directly.
- **No semantic meaning captured**: `food`, `pizza`, `burger` end up equidistant, so the model cannot tell which words are related.
- **Out of vocabulary (OOV)**: a test word like `burger` that never appeared in training has no vector at all.
- Large real vocabularies (say 50k words) make the sparsity far worse.

---

## 11. Bag of Words (BoW)

BoW is the first method good enough to actually solve text classification, sentiment, and spam/ham.

**Bag of Words represents each sentence as a vector over the vocabulary, where each position holds the count (or presence) of that vocabulary word in the sentence, ignoring word order.**

Pipeline: lowercase everything, remove stop words, build the vocabulary, then sort vocabulary by frequency (descending).

```
Dataset (all positive, output 1):
"He is a good boy"   -> good boy
"She is a good girl" -> good girl
"Boy and girl are good" -> boy girl good

Vocabulary with frequency: good(3), boy(2), girl(2)
```

Each sentence becomes a vector over `[good, boy, girl]`:

```
S1 good boy       -> [1, 1, 0]
S2 good girl      -> [1, 0, 1]
S3 boy girl good  -> [1, 1, 1]
```

Unlike one hot encoding, the whole sentence collapses into one vector of fixed length (the vocabulary size).

**Binary BoW vs normal BoW**: in binary BoW each value is forced to 0 or 1 (present or not). In normal BoW the value is the actual count, so a word appearing twice gives a 2. For example, take the sentence `good girl girl good` (the word `good` appears twice, `girl` twice):

```
Vocabulary [good, boy, girl]
normal BoW:  good girl girl good -> [2, 0, 2]   # raw counts
binary BoW:  good girl girl good -> [1, 0, 1]   # presence forced to 1
```

When building this in code you can keep only the top-k most frequent words (top 10, top 20) instead of the entire vocabulary.

### Advantages
- Simple and intuitive.
- **Fixed-size input** for ML algorithms, because the vocabulary is fixed.

### Disadvantages
- **Sparse matrix / arrays** remain (a 50k vocabulary still produces huge sparse vectors), still leading to overfitting.
- **Word ordering is lost**, so the meaning tied to order is not captured.
- **OOV** still exists, new words get ignored.
- **Semantic meaning only weakly captured**. Classic failure: "the food is good" vs "the food is not good" differ in only one position, so cosine similarity rates them as nearly identical even though they are opposites.

---

## 12. TF-IDF (Term Frequency, Inverse Document Frequency)

TF-IDF improves on BoW by weighting words according to how informative they are.

**TF-IDF scores each word in a sentence by multiplying its term frequency by its inverse document frequency, raising the weight of words that are rare across documents and lowering the weight of words that appear in every document.**

Two components:

```
TF(word, sentence)  = (number of times word appears in sentence)
                      / (total number of words in sentence)

IDF(word) = log_e( (total number of sentences)
                   / (number of sentences containing the word) )

TF-IDF = TF * IDF
```

Worked example, same three preprocessed sentences (`S1 good boy`, `S2 good girl`, `S3 boy girl good`).

Term frequency:

| | good | boy | girl |
|---|---|---|---|
| S1 (2 words) | 1/2 | 1/2 | 0 |
| S2 (2 words) | 1/2 | 0 | 1/2 |
| S3 (3 words) | 1/3 | 1/3 | 1/3 |

Inverse document frequency (N = 3):

| word | sentences containing it | IDF = log_e(3/df) |
|---|---|---|
| good | 3 | log(3/3) = 0.0000 |
| boy | 2 (S1, S3) | log(3/2) = 0.4055 |
| girl | 2 (S2, S3) | log(3/2) = 0.4055 |

Final TF-IDF vectors (TF x IDF), verified in Python:

| | good | boy | girl |
|---|---|---|---|
| S1 | 0.0000 | 0.2027 | 0.0000 |
| S2 | 0.0000 | 0.0000 | 0.2027 |
| S3 | 0.0000 | 0.1352 | 0.1352 |

Notice `good` zeroes out everywhere because it appears in every sentence, so TF-IDF treats it as uninformative. `boy` carries S1, `girl` carries S2, and both share S3. That is word importance being captured per sentence.

### Advantages
- Simple and intuitive.
- Fixed-size input (vocabulary based).
- **Word importance is captured**: words present in all sentences get low weight, words specific to a sentence get high weight. This is the key advantage over BoW and a common interview point.

### Disadvantages
- **Sparsity** still exists (many zeros).
- **OOV** still exists, since features come from the training vocabulary.

Overall TF-IDF performs better than BoW.

---

## 13. Word Embeddings

This section reframes everything above and points toward Word2Vec.

**A word embedding is a representation of a word as a real-valued vector such that words closer together in the vector space are expected to be similar in meaning.**

Plainly: embeddings place words in a space where "happy" and "excited" sit near each other and "angry" sits far away, because the vectors encode meaning rather than just presence.

Two families of embedding techniques:

1. **Count or frequency based**: One Hot Encoding, Bag of Words, TF-IDF. (Everything covered so far.)
2. **Deep-learning trained models**: Word2Vec. Higher accuracy and solves the disadvantages of the count-based methods.

Word2Vec itself comes in two architectures:

- **CBOW** (Continuous Bag of Words)
- **Skip-gram**

So every method covered in these notes is technically a word embedding, but the deep-learning ones are the powerful members of the family.

---

## 14. Word2Vec

**Word2Vec is a deep-learning-based word embedding technique (published by Google in 2013) that uses a neural network to learn word associations from a large corpus, representing each word as a dense vector so that synonyms and related words land near each other.**

Plainly: Word2Vec learns each word's vector by training a small neural net on lots of text, and the resulting dense vectors capture real relationships between words.

### Feature representation intuition

Imagine each word described by a list of features (gender, royal, age, food, and so on). Real Word2Vec models use many such dimensions, for example Google's model uses 300, and the features are not human-readable, but the intuition holds:

| | gender | royal | age | food | ... (300 dims) |
|---|---|---|---|---|---|
| boy | -1.00 | 0.01 | 0.03 | 0.05 | ... |
| girl | +1.00 | 0.02 | 0.04 | 0.06 | ... |
| king | -0.92 | 0.95 | 0.75 | 0.02 | ... |
| queen | +0.93 | 0.96 | 0.68 | 0.01 | ... |
| apple | 0.01 | -0.02 | 0.20 | 0.91 | ... |
| mango | 0.02 | -0.01 | 0.23 | 0.92 | ... |

Because related words share similar feature values, vector arithmetic produces meaningful results. The famous one:

```
vector(King) - vector(man) + vector(woman) ~= vector(Queen)
```

Dense vectors also remove the sparsity problem of the count-based methods.

### Cosine similarity

To measure how close two word vectors are, use cosine similarity rather than raw counts.

**Cosine similarity is the cosine of the angle between two vectors, and the distance between them is `1 - cos(theta)`.**

```
angle 0   -> cos 0  = 1    -> distance 1 - 1     = 0      (identical / same word)
angle 45  -> cos 45 = 0.7071 -> distance 1 - 0.7071 = 0.2929 (similar)
angle 90  -> cos 90 = 0    -> distance 1 - 0     = 1      (unrelated / opposite)
```

Distance near 0 means very similar, distance near 1 means very different. This is also how recommendation works, for example "Avengers" and "Iron Man" land close because they share feature representations like action and comic.

---

## 15. CBOW (Continuous Bag of Words)

**CBOW is a Word2Vec architecture that predicts a center (target) word from its surrounding context words, training a fully connected neural network to learn the word vectors.**

### Building the training data

Pick an odd **window size** (an odd number keeps an equal number of context words on each side of the center word). Take the window-size words, treat the center word as the output, and the surrounding words as the input. Then slide the window by one and repeat.

```
Corpus: "Ineuron company is related to data science"
Window size = 5

Window 1: [Ineuron, company, is, related, to]
          input  = Ineuron, company, related, to   output = is
Window 2: [company, is, related, to, data]
          input  = company, is, to, data           output = related
Window 3: [is, related, to, data, science]
          input  = is, related, data, science      output = to
```

### The network

- Vocabulary here has 7 unique words, so every word enters as a 7-dimension one-hot vector.
- **Input layer**: the context words, each a 7-length one-hot vector.
- **Hidden layer**: size equals the window size (5 nodes here).
- **Output layer**: 7 nodes (vocabulary size), with the true center word as a 7-length one-hot target.

Training is ordinary neural-network training: every connection starts with random weights, forward propagation produces a predicted output `y_hat`, the loss between `y` (the true one-hot center word) and `y_hat` is computed, and backpropagation adjusts the weights until the loss is minimal. Weight matrices here are 7x5 going in and 5x7 coming out.

The crucial result: the hidden-layer size (the window size) becomes the dimension of each word's final vector. Window size 5 means every word is represented by a 5-dimensional vector. Google's window choice is why their model outputs 300 dimensions. Bigger window, generally better the model.

---

## 16. Skip-gram

**Skip-gram is a Word2Vec architecture that reverses CBOW: it predicts the surrounding context words from a single center word.**

Everything else stays the same as CBOW. Only the input and output are swapped.

```
Same corpus and window size = 5
CBOW:      input = context words   -> output = center word
Skip-gram: input = center word     -> output = context words
```

Network shape: input layer of 7 (one center word as a one-hot vector), hidden layer of window size (5), output layer producing the context words (each 7-dimensional). Soft-max is applied at the output, loss is computed against the true context, and forward/backward propagation runs until the loss is minimized.

### When to use which

- **Small dataset / corpus**: CBOW.
- **Large dataset / corpus**: Skip-gram. (Backed by research.)

### How to improve CBOW or Skip-gram

- **Increase the training data**: more data, better accuracy.
- **Increase the window size**: this directly increases the vector dimension, which generally improves performance.

Google's pretrained Word2Vec was trained on roughly 3 billion words from Google News and produces 300-dimension vectors for each word.

---

## 17. Average Word2Vec

Word2Vec gives one vector per word, but classification needs one vector per sentence. Averaging bridges that gap.

**Average Word2Vec converts a whole sentence into a single fixed-length vector by taking the element-wise average of the Word2Vec vectors of all the words in that sentence.**

Plainly: vectorize each word, then average those vectors down to one vector that stands in for the entire sentence.

```
Sentence: "the food is good"
Using a 300-dim pretrained model:
the  -> 300-dim vector
food -> 300-dim vector
is   -> 300-dim vector
good -> 300-dim vector

Average Word2Vec(sentence) = mean of the four vectors -> one 300-dim vector
```

That single 300-dimensional vector becomes the input row, paired with the sentence's output label, and the model trains on it. Because the word vectors already carry semantic information, averaging preserves much of it. This is the standard way to feed Word2Vec into a text classifier. The implementation uses the gensim library (covered next); there is also a separate library called GloVe that does similar embedding work, but gensim alone is enough to do everything here.

---

## 18. Word2Vec Practical Implementation (gensim)

Install with `pip install gensim`. The video uses Google's pretrained model (about 1.6 GB, so it is run in Google Colab).

```python
import gensim
from gensim.models import Word2Vec, KeyedVectors
import gensim.downloader as api

wv = api.load('word2vec-google-news-300')   # 300-dim vectors, 3 million words/phrases
# the Google News model was trained on roughly 100 billion words
```

Get a word vector and confirm its shape:

```python
vec_king = wv['king']
vec_king.shape       # -> (300,)
wv['cricket'].shape  # -> (300,)
```

Most similar words:

```python
wv.most_similar('cricket')
# -> cricketing (~0.83), cricketers (~0.81), Test_cricket (~0.80), ...

wv.most_similar('happy')
# -> glad, pleased, ecstatic, overjoyed, thrilled, satisfied, ...
```

Similarity between two words:

```python
wv.similarity('hockey', 'sports')   # ~0.53
```

The famous vector arithmetic:

```python
vec = wv['king'] - wv['man'] + wv['woman']
wv.most_similar([vec])
# top results include 'queen', confirming king - man + woman ~= queen
```

You can also train your own Word2Vec from scratch on a custom dataset with gensim, instead of using the pretrained Google model.

---

## Quick comparison table

| Technique | Output unit | Fixed size | Sparse | Semantic meaning | OOV handled |
|---|---|---|---|---|---|
| One Hot Encoding | per word | no | yes | no | no |
| Bag of Words | per sentence | yes | yes | weak | no |
| TF-IDF | per sentence | yes | yes | partial (word importance) | no |
| Word2Vec | per word (dense) | yes | no | yes | better |
| Average Word2Vec | per sentence (dense) | yes | no | yes | better |

---

## One-line recap of the whole flow

Clean the text (tokenize, remove stop words, stem or lemmatize), tag it if needed (POS, NER), convert it to vectors (one hot, BoW, TF-IDF, or Word2Vec), and for sentence-level tasks average the Word2Vec vectors, then train a model. Accuracy and model size both rise as you move from count-based methods up to Word2Vec, embeddings, and transformers.
