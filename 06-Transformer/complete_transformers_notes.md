# Complete Transformers Notes

---

## 1. Why Transformers

Before Transformers, sequence-to-sequence tasks (like English to French translation) were solved with RNN, LSTM, GRU, then encoder-decoder, then encoder-decoder with attention. Each fixed some problems but left others. Transformers solve the two big remaining ones.

**A Transformer is a deep learning model that uses a self-attention mechanism to process sequences in parallel, built as an encoder-decoder architecture.**

Plainly: it replaces the recurrent (LSTM/RNN) cells with self-attention, so the whole sentence is processed at once instead of word by word.

### Problem 1: encoder-decoder is not scalable

In the old encoder-decoder, words were fed in one per time step (t=1, t=2, ...). The encoder LSTM compressed the whole sentence into a single **context vector**, which was passed to the decoder.

```
Old encoder-decoder:
X1 -> X2 -> X3  (one per time step, sequential)
       LSTM
        |
   context vector  -> decoder LSTM -> output
```

Two issues followed:
- The single context vector could not represent long sentences. As sentence length grew, the BLEU score dropped.
- Because words go in one per time step, training cannot be parallelized, so it does not scale to huge datasets.

Attention (Bahdanau-style) fixed the context bottleneck by giving the decoder an additional context per word (alignment scores plus attention weights), but it still used bidirectional LSTM/RNN, so it was still sequential and still not scalable.

**Transformers never use LSTM or RNN in the encoder or decoder. They use a self-attention module, so all words are sent in parallel.** This is what makes training scalable on huge datasets and is why Transformers power state-of-the-art models (BERT, GPT) and multimodal systems (text plus image, like DALL-E).

### Problem 2: contextual embeddings

A plain embedding layer (like Word2Vec) gives every word a **fixed** vector regardless of the sentence.

**A contextual embedding is a word vector that changes based on the other words in the sentence.**

Plainly: in "my name is Krish and I play cricket", the vector for "cricket" should be influenced by "play" and "I", not be a fixed lookup. Self-attention produces these context-aware vectors, which is the second reason Transformers are so accurate.

---

## 2. Architecture Overview

A Transformer is an encoder-decoder stack. Critically, there is not one encoder and one decoder, there are several stacked.

```
Input (English) -> [Encoder stack] -> [Decoder stack] -> Output (French)

The paper uses 6 encoders and 6 decoders.
Information flows bottom to top through the encoders, and the
final encoder output feeds every decoder.
```

What is inside each block:

| Block | Layers inside |
|---|---|
| One encoder | self-attention -> feed forward neural network |
| One decoder | masked self-attention -> encoder-decoder attention -> feed forward neural network |

So the encoder has two sub-layers, the decoder has three (the extra one is the encoder-decoder attention). Each word enters the encoder as a vector (from an embedding layer), self-attention turns it into a contextual vector (Z1, Z2, Z3), the feed forward network processes it, and the result passes up to the next encoder.

---

## 3. Self-Attention (Scaled Dot-Product Attention)

This is the core of the Transformer.

**Self-attention (scaled dot-product attention) is the mechanism that lets the model weigh the importance of every other token in the sequence when building each token's vector, turning fixed embeddings into contextual embeddings.**

Plainly: for each word, self-attention asks "how much should every other word influence my vector?" and rebuilds the vector accordingly.

It runs in a fixed series of steps. We will use the running example sentence `the cat sat` with an embedding dimension of 4.

### Step 1: token embeddings

Convert each word to a fixed vector. For this worked example:

```
the = [1, 0, 1, 0]
cat = [0, 1, 0, 1]
sat = [1, 1, 1, 1]
```

### Step 2: linear transformation to get Q, K, V

For every token we create three vectors by multiplying its embedding with three learned weight matrices.

**Query (Q) represents the token we are currently computing attention for. Key (K) represents every token to compare against. Value (V) holds the actual information that gets aggregated into the output.**

In plain terms:
- The **query** is "what am I looking for?"
- The **keys** are "what does each token offer?" Comparing query to keys (a dot product) tells the model how much attention to give each token.
- The **values** are the content that gets mixed together, weighted by that attention.

```
Q = embedding . W_Q
K = embedding . W_K
V = embedding . W_V
```

The weight matrices `W_Q`, `W_K`, `W_V` start random and are **learned through backpropagation**. For this worked example we initialize all three as the identity matrix, so Q = K = V = the embeddings themselves.

### Step 3: compute attention scores

**The attention score is the dot product of a token's query vector with every key vector, measuring how much focus to give each token relative to the current one.**

```
score(the) = [ q_the.k_the, q_the.k_cat, q_the.k_sat ] = [2, 0, 2]
score(cat) = [ q_cat.k_the, q_cat.k_cat, q_cat.k_sat ] = [0, 2, 2]
score(sat) = [ q_sat.k_the, q_sat.k_cat, q_sat.k_sat ] = [2, 2, 4]
```

(Verified in Python.) Notice `cat` and `sat` score 2 with each other, so the model already sees a dependency.

### Step 4: scaling

**Scaling divides the attention scores by the square root of the key-vector dimension, sqrt(d_k), before the softmax.**

Here d_k = 4, so sqrt(d_k) = 2.

```
the: [2,0,2] / 2 = [1, 0, 1]
cat: [0,2,2] / 2 = [0, 1, 1]
sat: [2,2,4] / 2 = [1, 1, 2]
```

Why this matters has its own section below (Step 4 deep dive). In short, large dot products make softmax saturate and gradients vanish during training, so scaling keeps them in a stable range.

### Step 5: softmax to get attention weights

Apply softmax to the scaled scores. These are the attention weights (verified in Python):

```
the -> [0.4223, 0.1554, 0.4223]
cat -> [0.1554, 0.4223, 0.4223]
sat -> [0.2119, 0.2119, 0.5762]
```

Each row sums to 1 and says how much of each value vector to mix in.

### Step 6: weighted sum of values

Multiply the attention weights by the value vectors and sum. This produces the contextual vector for each word (verified in Python):

```
output(the) = 0.4223*V_the + 0.1554*V_cat + 0.4223*V_sat = [0.8446, 0.5777, 0.8446, 0.5777]
output(cat) = [0.5777, 0.8446, 0.5777, 0.8446]
output(sat) = [0.7881, 0.7881, 0.7881, 0.7881]
```

So `the` went in as the fixed embedding `[1,0,1,0]` and came out as the contextual vector `[0.8446, 0.5777, 0.8446, 0.5777]`, now shaped by the other words. That is the whole point of self-attention.

(Note: the video's hand calculation of this last step had an arithmetic slip; the Python-verified values above are correct given the inputs.)

---

## 4. Why Scaling (Step 4 deep dive)

This is worth its own treatment because it explains the sqrt(d_k) in the formula.

**Scaling prevents the dot products from growing too large, which keeps gradients stable during training.**

Without scaling, two problems appear as d_k grows:
- **Gradient exploding**: large dot products produce large gradients in backpropagation, making training unstable.
- **Softmax saturation**: almost all the attention weight goes to a single token and the rest get near-zero, so during backpropagation those weights barely update. This is the **vanishing gradient problem**.

### Worked demonstration

Take two raw scores 6 and 4 (for example from `K . K1^T = 6` and `K . K2^T = 4`, where K=[2,3,4,1], K1=[1,0,1,0], K2=[0,1,0,1]).

```
Without scaling:  softmax([6, 4]) = [0.8808, 0.1192]   (huge gap from a small score difference)
With scaling /2:  softmax([3, 2]) = [0.7311, 0.2689]   (more balanced)
```

(Both verified in Python.) The unscaled version dumps 88 percent of the weight on one token; the scaled version is balanced, so the second token keeps some influence and the gradients stay healthy.

### Why sqrt(d_k) specifically

As the dimension grows, the variance of the dot product grows with it. Dividing by sqrt(d_k) keeps that variance roughly constant no matter the dimension, which is exactly the stabilizing effect we want. The takeaway: scaling stabilizes training and prevents softmax saturation, producing more balanced attention weights.

---

## 5. Multi-Head Attention

One self-attention pass gives one "view" of the dependencies. Multi-head attention runs several in parallel.

**Multi-head attention runs multiple self-attention heads in parallel, each with its own learned W_Q, W_K, W_V, then concatenates their outputs and projects them with one more weight matrix.**

Plainly: each head can focus on a different relationship. One head might capture that `sat` depends on `cat`, another might capture a different dependency like `it` referring to `animal` in a longer sentence.

```
Head 0: own W_Q0,W_K0,W_V0 -> Z0
Head 1: own W_Q1,W_K1,W_V1 -> Z1
...
Head 7: own W_Q7,W_K7,W_V7 -> Z7   (the paper uses 8 heads)

Concatenate [Z0, Z1, ..., Z7], then multiply by W_O -> final Z
```

The feed forward network expects a single matrix per word, so the heads must be concatenated and projected back down with `W_O` before being passed on. The benefit: multi-head attention "expands the model's ability to focus on different positions" and gives multiple representation subspaces, so the model captures more relationships at once.

---

## 6. Positional Encoding

Because all words go in parallel, the model loses word order. Positional encoding puts the order back.

**Positional encoding adds a vector to each word embedding that encodes the word's position in the sequence, so the parallel self-attention layer knows the order.**

Plainly: "lion kills tiger" and "tiger kills lion" contain the same words. Without order information, self-attention would return the same vectors for both. Positional encoding fixes that.

Why not just append the index (1, 2, 3, ...)? Because for a long document with hundreds of thousands of words, those position numbers are unbounded and huge, which breaks training during backpropagation. We need a bounded scheme.

### Sinusoidal positional encoding

The paper uses sine and cosine functions of different frequencies, so all values stay between -1 and 1:

```
PE(pos, 2i)   = sin( pos / 10000^(2i / d_model) )
PE(pos, 2i+1) = cos( pos / 10000^(2i / d_model) )

pos     = position of the word in the sentence
i       = index into the dimension pairs
d_model = embedding dimension
```

Even dimensions use sine, odd dimensions use cosine. The reason for mixing both: if we used only sine, two different positions could land on the same value and we would lose the ordering. Pairing sine with cosine guarantees each position gets a unique encoding.

### Worked example (the cat sat, d_model = 4)

Verified in Python:

```
pos 0 (the) -> [0.0,    1.0,    0.0,  1.0   ]
pos 1 (cat) -> [0.8415, 0.5403, 0.01, 1.0   ]
pos 2 (sat) -> [0.9093, -0.4161, 0.02, 0.9998]
```

This positional vector is **added** to the word's embedding before it enters self-attention. In the paper, d_model is 512, so each positional vector is 512-dimensional.

There is also **learned positional encoding** (a position matrix trained via backpropagation), but the paper uses the sinusoidal version.

---

## 7. Layer Normalization

After multi-head attention, the architecture does "add and normalize." Two ideas are bundled here: residual connections and layer normalization.

### Normalization in general

**Normalization rescales values so they have mean 0 and standard deviation 1, using the z-score formula (value minus mean, divided by standard deviation).**

This is the same idea as standard scaling on tabular features (house size, number of rooms) before feeding a neural network. Benefits: more stable training, faster convergence, and protection from vanishing or exploding gradients, because all values stay centered near zero.

The problem: after the weight multiplications inside the network, the distribution of the intermediate outputs (Z1, Z2, ...) drifts away from the nice normalized input distribution. So we re-normalize the intermediate outputs too.

### Batch vs layer normalization

```
Batch normalization: normalize each FEATURE column across the batch.
Layer normalization:  normalize each ROW (each token's own vector) on its own.
```

**Transformers use layer normalization** (each token's vector is normalized independently), not batch normalization. In NLP, padding produces many zero vectors. With batch norm those zeros distort the whole column's mean and standard deviation. With layer norm, a zero vector normalizes to zeros (mean 0, std 0) and does not pollute the real tokens.

### Residual connections (skip connections)

**A residual (skip) connection passes a layer's input directly to a later layer, skipping the sub-layer in between.**

In the encoder, the input embedding plus positional encoding is added to the output of multi-head attention before normalization. Why this helps (from the paper):
- It creates a short path for gradients to flow directly through the network, so gradients stay large enough to fight the **vanishing gradient problem** across the 6 stacked layers.
- It improves gradient flow, giving faster convergence and smoother training.
- It enables training of much deeper networks, letting the model learn more complex functions.

### Scale and shift (gamma and beta)

Sometimes you do not want to force a normalized distribution. Two learnable parameters control this.

**Gamma (scale) and beta (shift) are learned parameters applied after normalization: y = gamma * normalized + beta.**

If the original distribution is actually useful, training can learn gamma and beta to undo or adjust the normalization. With gamma = 1 and beta = 0 (the paper's initialization), the output equals the normalized vector unchanged.

### Worked example (cat = [2, 4, 6, 8])

Verified in Python, with gamma = [1,1,1,1], beta = [0,0,0,0], epsilon = 1e-5:

```
mean     = (2+4+6+8)/4 = 5
variance = ((2-5)^2 + (4-5)^2 + (6-5)^2 + (8-5)^2)/4 = 20/4 = 5
denom    = sqrt(variance + epsilon) = sqrt(5.00001) = 2.2361   (epsilon avoids divide by zero)

normalized = (x - mean) / denom = [-1.3416, -0.4472, 0.4472, 1.3416]
y = gamma*normalized + beta     = [-1.3416, -0.4472, 0.4472, 1.3416]   (unchanged, since gamma=1 beta=0)
```

---

## 8. Encoder Architecture

Putting the encoder together with the paper's actual parameters.

```
Input sequence
  -> text embedding (512 dims per word) + positional encoding (512 dims)
  -> multi-head attention (8 heads; Q, K, V are 64 dims each)
  -> add and normalize (residual + layer norm)
  -> feed forward neural network (hidden layer ~512 nodes)
  -> add and normalize
  -> pass up to the next encoder (6 encoders total)
```

Key parameters from the paper:

| Parameter | Value |
|---|---|
| Embedding dimension (d_model) | 512 |
| Q / K / V dimension | 64 each |
| Number of attention heads | 8 |
| Encoders stacked | 6 |

Note that inside attention, the scaling divides by sqrt(64) = 8.

### Why so many encoders
Sequence-to-sequence tasks like translation are very complex (dialects, long dependencies). One encoder cannot reach good accuracy, so the paper stacks 6. You can change this number for your own models.

### Why residuals (recap)
They create short gradient paths, fix vanishing gradients across the deep stack, speed convergence, and enable deep training.

### Why a feed forward neural network
- **Adds non-linearity**: self-attention is largely linear mixing; the FFN (with activation functions) lets the model capture non-linear, complex patterns.
- **Processes each token independently**: self-attention captures relationships between tokens; the FFN then transforms each token's representation on its own, letting the model learn richer features from each contextual vector.
- **Adds depth and parameters**: more depth means more learning capacity, which helps the model generalize to unseen data.

---

## 9. Decoder

The decoder generates the output sequence one token at a time, using the encoder output plus the tokens already generated. It has three sub-layers.

```
One decoder:
  masked multi-head self-attention
  -> add and normalize
  -> encoder-decoder attention (multi-head)
  -> add and normalize
  -> feed forward neural network
  -> add and normalize
```

The one new idea versus the encoder is **masking**.

### Masked multi-head self-attention

**Masking controls which tokens each position is allowed to attend to, so padding tokens are ignored and future tokens are hidden during generation.**

There are two masks, combined together.

**Padding mask**: handles variable-length sequences. Sentences in a batch are padded with zeros to equal length. Without masking, those zero-padded positions would influence the attention mechanism and bias predictions. The padding mask marks real tokens with 1 and padding with 0 so the padding is ignored.

**Look-ahead mask**: maintains the autoregressive property. When predicting a token, the decoder may only attend to previous positions and itself, never future positions. This is essential for generation: you should not see the future word while predicting the current one.

```
Look-ahead mask (4x4):   each row can only see itself and earlier positions
[1 0 0 0]
[1 1 0 0]
[1 1 1 0]
[1 1 1 1]
```

### Combining the masks and applying them

The padding mask is extended to 2D and multiplied element-wise with the look-ahead mask to get a combined mask. Then, wherever the combined mask is 0, the corresponding attention score has **minus infinity** added to it (not replaced, added).

Why minus infinity: the next step is softmax, and softmax of minus infinity is 0. So those positions (padding or future tokens) contribute exactly zero attention weight, removing their influence cleanly.

```
masked score -> softmax -> the minus-infinity entries become 0
```

After masking and softmax, the rest is the same as encoder self-attention: weighted sum of value vectors.

### Encoder-decoder attention (multi-head attention)

**In encoder-decoder attention, the Key and Value vectors come from the encoder output, while the Query comes from the decoder's masked self-attention layer.**

Plainly: the decoder uses its current query to look into the encoded input sentence (keys and values), which lets it focus on the right input words when producing each output word. This is how the decoder connects what it has generated so far to the source sentence.

```
K, V  <- from the encoder output (the encoded source sentence)
Q     <- from the decoder's masked self-attention
```

### Training vs inference

- **Training**: the real target output (shifted right, with a start token and padding) is fed into the decoder all at once, and masking enforces that each position only sees earlier positions. The model predicts y_hat and the loss is computed against the true y.
- **Inference**: generation is autoregressive, one token per time step. A start token goes in first, the decoder predicts the first word, that word is fed back in as the previous output to predict the next word, and so on until the sequence ends.

```
t=1: [start]            -> predict word1
t=2: [start, word1]     -> predict word2
t=3: [start, word1, w2] -> predict word3
...
```

---

## 10. Linear and Softmax (Output Layer)

The decoder outputs vectors. The final layer turns a vector into an actual word.

**The linear layer is a fully connected network that projects the decoder's output vector into a logits vector with one cell per vocabulary word. Softmax then turns those logits into probabilities, and the highest-probability word is the output.**

```
decoder output vector
  -> linear layer (fully connected) -> logits vector of size = vocabulary
     (e.g. 10,000 words -> 10,000 logits, one score per unique word)
  -> softmax -> probabilities summing to 1
  -> pick the highest probability -> output word for this time step
```

### Training recap

Each target word is represented (for example with one-hot encoding) over the vocabulary. Suppose vocabulary = [am, I, thanks, to, student, EOS]. To translate "Mercy" to "thanks", the target one-hot puts 1.0 at the `thanks` index. An untrained model outputs near-random probabilities, so we compute the loss between predicted and target distributions and backpropagate to update all the weights (including W_Q, W_K, W_V and the linear layer). Over epochs, the output probability at the correct word climbs toward 1.0.

---

## 11. Quick Recap

| Component | One-line idea |
|---|---|
| Why Transformers | Parallel processing (scalable) + contextual embeddings, no LSTM/RNN |
| Self-attention | Q.K^T scores -> scale -> softmax -> weighted sum of V = contextual vector |
| Scaling (sqrt d_k) | Stops large dot products that cause softmax saturation and vanishing gradients |
| Multi-head attention | Several attention heads in parallel, concatenate, project with W_O |
| Positional encoding | Sine/cosine vectors added to embeddings to encode word order |
| Layer normalization | Normalize each token's vector; residuals add short gradient paths |
| Scale and shift | Learnable gamma, beta let the model adjust the normalization |
| Encoder | self-attention -> add and norm -> FFN -> add and norm (6 stacked) |
| Decoder | masked self-attention -> encoder-decoder attention -> FFN (6 stacked) |
| Masking | Padding mask ignores padding; look-ahead mask hides future tokens |
| Encoder-decoder attention | K, V from encoder; Q from decoder |
| Linear + softmax | Project to vocabulary-size logits, softmax, pick the top word |

Paper parameters: d_model = 512, Q/K/V = 64, heads = 8, encoders = decoders = 6, scale divisor = sqrt(64) = 8.
