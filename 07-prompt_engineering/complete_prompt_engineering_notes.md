# Complete Prompt Engineering Notes

---

## 1. What is Prompt Engineering

An LLM does one thing at its core: it predicts the next token. The model takes a sequence of text, predicts the most likely next token based on its training, appends that token, and repeats. A prompt is just the starting text you give it to steer that chain of predictions.

**Prompt engineering is the process of designing high-quality prompts that guide an LLM to produce accurate, useful outputs.**

In plain terms: you are setting up the model so that the next-token predictions land on the answer you actually want. It is iterative. You tinker with wording, length, structure, and examples, then test and refine.

Key points to remember:
- You do not need to be a data scientist to write a prompt, but writing an *effective* one takes work.
- Many things affect a prompt's quality: the model, its training data, the configuration settings, your word choice, tone, structure, and the context you provide.
- A weak prompt gives ambiguous or wrong answers. The fix is usually clearer text, not a bigger model.
- Prompts are model-specific. The same prompt may need tuning for Gemini vs GPT vs Claude vs an open model like Gemma or LLaMA.

---

## 2. LLM Output Configuration

Before prompting technique, you set the model's configuration. These knobs control how the predicted token probabilities get turned into actual output.

### Output length (max tokens)

**Output length is a cap on the number of tokens the model is allowed to generate in a response.**

Plainly: it is a hard stop, not a style instruction. Setting a low max-token value does not make the model write more concisely. It just makes the model stop mid-thought once it hits the limit. If you genuinely want short output, you have to ask for it in the prompt itself.

Why it matters: more tokens means more computation, which means higher cost, more energy, and slower responses. It is especially important for techniques like ReAct, where the model tends to keep emitting useless tokens after the answer you wanted.

### Sampling controls

The model does not pick a single next token outright. It assigns a probability to every token in its vocabulary, then samples from those probabilities. Temperature, top-K, and top-P control how that sampling happens.

#### Temperature

**Temperature controls the degree of randomness in token selection.**

Low temperature means more deterministic and focused output. High temperature means more diverse, creative, or unexpected output.

- **Temperature 0** is greedy decoding: the single highest-probability token is always chosen. Deterministic (with the caveat that exact ties may break randomly).
- **As temperature rises**, output gets more random. At very high values, all tokens become roughly equally likely.

A useful mental model: temperature is like the softmax temperature (T) in ML. Low T sharpens the distribution toward one preferred token with high certainty. High T flattens it, so a wider range of tokens becomes acceptable.

#### Top-K and top-P

Both restrict which tokens are even eligible before sampling.

**Top-K sampling keeps only the K most probable tokens, then samples from those.**

Higher K means more variety and creativity. Lower K means more factual and restrictive output. A top-K of 1 is identical to greedy decoding (only the single best token survives).

**Top-P sampling (nucleus sampling) keeps the smallest set of top tokens whose cumulative probability does not exceed P, then samples from those.**

P ranges from 0 (greedy decoding, only the most probable token) to 1 (the entire vocabulary is eligible).

The best way to pick between top-K and top-P is to experiment with both, separately and together, and see which gives the results you want.

### Putting it all together

When temperature, top-K, and top-P are all active, the usual order of operations is:

```
1. Tokens must pass BOTH the top-K and top-P criteria to be candidates.
2. Temperature is then applied to sample one token from those candidates.
```

Extreme settings cancel each other out:

```
temperature = 0      -> top-K and top-P become irrelevant (most probable token wins)
temperature very high (10s) -> temperature becomes irrelevant (random sample from K/P survivors)
top-K = 1            -> temperature and top-P become irrelevant (one token passes)
top-P = 0 (tiny)     -> only the most probable token passes, temperature and top-K irrelevant
top-P = 1            -> no tokens filtered out by P
```

**Recommended starting points** (from the whitepaper):

| Goal | Temperature | Top-P | Top-K |
|---|---|---|---|
| Coherent, mildly creative | 0.2 | 0.95 | 30 |
| Especially creative | 0.9 | 0.99 | 40 |
| Less creative / more factual | 0.1 | 0.9 | 20 |
| Single correct answer (e.g. math) | 0 | n/a | n/a |

Note: more freedom (higher temperature, top-K, top-P, output length) can make the model drift into less relevant text.

---

## 3. Prompting Techniques

LLMs follow instructions, but the clearer the prompt, the better the next-token prediction. The techniques below take advantage of how LLMs are trained and structured.

A useful habit from the whitepaper: document prompts in a structured table (Name, Goal, Model, Temperature, Token Limit, Top-K, Top-P, Prompt, Output). This is covered in Best Practices, but the examples below use that framing.

### 3.1 Zero-shot prompting

**A zero-shot prompt gives only a task description and the input, with no examples.**

The name means "no examples" (zero of them). It is the simplest prompt: a question, an instruction, or some text to continue.

Worked example (movie review classification):

```
Goal: classify a movie review as POSITIVE, NEUTRAL, or NEGATIVE
Temperature: 0.1   Token Limit: 5

Prompt:
Classify movie reviews as POSITIVE, NEUTRAL or NEGATIVE.
Review: "Her" is a disturbing study revealing the direction humanity is
headed if AI is allowed to keep evolving, unchecked. I wish there were
more movies like this masterpiece.
Sentiment:

Output: POSITIVE
```

Note the difficulty here: "disturbing" and "masterpiece" appear in the same sentence, so the model has to weigh conflicting signals. Low temperature is correct because no creativity is needed.

### 3.2 One-shot and few-shot prompting

When zero-shot is not enough, give the model examples to imitate.

**A one-shot prompt provides a single example. A few-shot prompt provides multiple examples that demonstrate a pattern to follow.**

Plainly: examples are a reference target. They are especially useful for steering the model toward a specific output structure or format.

How many examples? As a rule of thumb, use at least 3 to 5 for few-shot. Use more for complex tasks, fewer if you hit input-length limits. (Best Practices later suggests starting with 6.)

Worked example (parse a pizza order to JSON, few-shot):

```
Goal: parse a customer's pizza order into valid JSON
Temperature: 0.1   Token Limit: 250

Prompt:
Parse a customer's pizza order into valid JSON:

EXAMPLE:
I want a small pizza with cheese, tomato sauce, and pepperoni.
JSON Response:
{
  "size": "small",
  "type": "normal",
  "ingredients": [["cheese", "tomato sauce", "pepperoni"]]
}

EXAMPLE:
Can I get a large pizza with tomato sauce, basil and mozzarella.
{
  "size": "large",
  "type": "normal",
  "ingredients": [["tomato sauce", "basil", "mozzarella"]]
}

Now, I would like a large pizza, with the first half cheese and mozzarella.
And the other tomato sauce, ham and pineapple.
JSON Response:

Output:
{
  "size": "large",
  "type": "half-half",
  "ingredients": [["cheese", "mozzarella"], ["tomato sauce", "ham", "pineapple"]]
}
```

Tips for choosing examples:
- Make them relevant to the task, diverse, high quality, and well written. One small mistake in an example can confuse the model.
- If you want robustness, include edge cases (unusual inputs the model should still handle, like the half-and-half pizza above).

### 3.3 System, contextual, and role prompting

These three guide the model in different ways. They overlap (a single prompt can do all three), but each has a distinct primary purpose.

**System prompting sets the overall context and purpose: the big-picture task the model is doing.** It defines the model's fundamental job, like "classify reviews" or "translate this." The name means "providing an additional task to the system."

**Contextual prompting supplies specific background details relevant to the current task.** It is highly specific and dynamic, changing per request, and helps the model tailor its response to the immediate situation.

**Role prompting assigns the model a character or identity to adopt.** It frames the output's style and voice, adding personality and focused expertise.

Quick contrast:

| Type | Primary purpose |
|---|---|
| System | Defines fundamental capability and overarching purpose |
| Contextual | Provides immediate, task-specific info (dynamic) |
| Role | Frames output style, voice, and personality |

#### System prompting example (return only a label)

```
Temperature: 1   Token Limit: 5   Top-K: 40   Top-P: 0.8

Prompt:
Classify movie reviews as positive, neutral or negative. Only return
the label in uppercase.
Review: "Her" is a disturbing study ... It's so disturbing I couldn't watch it.
Sentiment:

Output: NEGATIVE
```

Even with temperature raised to 1, the clear instruction ("only return the label in uppercase") kept the output clean. System prompts are also useful for forcing structure (e.g. valid JSON), which limits hallucinations, and for safety (add a line like "You should be respectful in your answer.").

#### Role prompting example (travel guide)

```
Prompt:
I want you to act as a travel guide. I will write to you about my location
and you will suggest 3 places to visit near me. ...
My suggestion: "I am in Amsterdam and I want to visit only museums."
Travel Suggestions:

Output:
1. Rijksmuseum ...
2. Van Gogh Museum ...
3. Stedelijk Museum Amsterdam ...
```

Adding a style turns the same role humorous or inspirational. Useful styles to pick from: Confrontational, Descriptive, Direct, Formal, Humorous, Influential, Informal, Inspirational, Persuasive.

#### Contextual prompting example (blog topics)

```
Prompt:
Context: You are writing for a blog about retro 80's arcade video games.
Suggest 3 topics to write an article about with a few lines of description.

Output:
1. The Evolution of Arcade Cabinet Design ...
2. Blast From The Past: Iconic Arcade Games of The 80's ...
3. The Rise and Retro Revival of Pixel Art ...
```

The single line of context ("retro 80's arcade games") tightly scopes the suggestions.

### 3.4 Step-back prompting

**Step-back prompting first asks the LLM a general question related to the task, then feeds that answer back as context into the prompt for the specific task.**

Plainly: zoom out before you zoom in. Asking the broad question first activates relevant background knowledge and reasoning, so the final answer is more accurate and less generic. It also helps reduce bias by anchoring on general principles instead of jumping straight to specifics.

Worked example (video game level storyline):

```
Traditional prompt:
"Write a one paragraph storyline for a new level of a first-person shooter."
-> Output is creative but random and generic.

Step 1 (step back, general):
"Based on popular first-person shooter games, what are 5 fictional key settings
that contribute to a challenging and engaging level storyline?"
-> Output: Abandoned Military Base, Cyberpunk City, Alien Spaceship,
   Zombie-Infested Town, Underwater Research Facility.

Step 2 (feed one theme back as context):
"Context: [the 5 themes above]. Take one of the themes and write a one
paragraph storyline ..."
-> Output: a focused, vivid storyline built on the Underwater Research
   Facility theme.
```

The two-step version produces a noticeably more grounded result than the direct prompt.

### 3.5 Chain of Thought (CoT)

**Chain of Thought prompting asks the LLM to generate intermediate reasoning steps before giving the final answer.**

Plainly: make the model "show its work." Walking through steps leads to more accurate answers, especially on reasoning and math.

Why use it:
- Low effort, high impact, works with off-the-shelf models (no fine-tuning).
- Interpretable: you can see the reasoning and spot where it went wrong.
- More robust across different model versions.

Costs: more reasoning means more output tokens, so higher cost and slower responses.

Worked example (the age problem). Without CoT:

```
Prompt: When I was 3 years old, my partner was 3 times my age.
        Now I am 20. How old is my partner?
Output: 63 years old        <- WRONG
```

With CoT (just add "Let's think step by step"):

```
Reasoning:
- When I was 3, partner was 3 * 3 = 9.
- I went from 3 to 20, an increase of 17 years.
- Partner also aged 17 years: 9 + 17 = 26.
Output: 26 years old        <- CORRECT
```

CoT also combines with one-shot or few-shot. Give a solved Q&A example first, then the real question, and the model copies the reasoning pattern.

Good use cases: code generation (break the request into steps mapped to lines), synthetic data creation, and generally any task you could solve by "talking it through." If you can explain the steps yourself, try CoT.

### 3.6 Self-consistency

**Self-consistency runs the same CoT prompt multiple times at high temperature to generate diverse reasoning paths, then takes the majority answer.**

Plainly: vote. Plain CoT uses one greedy path, which can be wrong. Self-consistency samples several reasoning paths and picks the most common final answer, improving accuracy and coherence. It gives a pseudo-probability of an answer being correct, but it is expensive (many calls).

Steps:

```
1. Send the same prompt multiple times (high temperature -> varied reasoning).
2. Extract the final answer from each response.
3. Choose the most common answer (majority vote).
```

Worked example (classify an email as IMPORTANT or NOT IMPORTANT). The email is from "Harry the Hacker," friendly in tone, reporting a JavaScript bug in a contact form, but written with sarcasm that can trick the model. Running the prompt three times produced:

```
Attempt 1 -> IMPORTANT   (focuses on the security risk of the bug)
Attempt 2 -> NOT IMPORTANT (focuses on casual tone, no action requested)
Attempt 3 -> IMPORTANT   (security risk, unknown sender credibility)

Majority vote -> IMPORTANT
```

The majority answer is more reliable than any single run.

### 3.7 Tree of Thoughts (ToT)

**Tree of Thoughts generalizes CoT by letting the model explore multiple reasoning paths at once, branching like a tree instead of following one linear chain.**

Plainly: CoT is a single line of reasoning, ToT is a tree of them. Each node is a "thought" (a coherent intermediate step), and the model can branch out from different nodes to explore alternatives. This makes it well suited to complex problems that need exploration and backtracking.

```
CoT:  Input -> thought -> thought -> ... -> Output   (one path)
ToT:  Input -> branches into many thoughts, explores several paths -> Output
```

### 3.8 ReAct (Reason and Act)

**ReAct combines natural-language reasoning with actions (using external tools like search or a code interpreter) in a thought-action loop.**

Plainly: the model thinks, then acts (calls a tool), observes the result, updates its reasoning, and repeats until it solves the problem. This mimics how humans reason out loud and take actions to gather information. It is a first step toward agents.

Loop:

```
reason -> generate a plan -> act (call tool) -> observe result
       -> update reasoning -> new plan -> ... until solved
```

Worked example ("How many kids do the band members of Metallica have?"). Using LangChain + a search tool, ReAct chains five searches:

```
Thought: Metallica has 4 members.
Action: Search -> James Hetfield  -> 3 children   (running total 3)
Action: Search -> Lars Ulrich     -> 3 children   (running total 6)
Action: Search -> Kirk Hammett    -> 2 children   (running total 8)
Action: Search -> Robert Trujillo -> 2 children   (running total 10)
Final Answer: 10
```

Each observation feeds the next thought. In practice, ReAct requires resending prior prompts/responses (and trimming extra generated content) plus good example instructions.

### 3.9 Automatic Prompt Engineering (APE)

**APE uses an LLM to generate prompt variants, scores them, and keeps the best, automating the prompt-writing process itself.**

Plainly: write a prompt that writes prompts. You prompt the model to produce many phrasings, evaluate them, possibly tweak the good ones, and repeat.

Worked example (training a t-shirt webshop chatbot to recognize order phrasings):

```
1. Prompt the model: "We have a band merchandise t-shirt webshop ...
   Generate 10 variants with the same meaning for 'One Metallica t-shirt size S'."
   -> Output: 10 rephrasings ("I'd like to purchase a Metallica t-shirt in
      size small.", "Can I order a small-sized Metallica t-shirt?", etc.)

2. Score each candidate with a metric like BLEU or ROUGE.

3. Select the highest-scoring candidate as your final prompt. Optionally tweak
   and re-evaluate.
```

---

## 4. Code Prompting

LLMs handle code as just another text task: writing, explaining, translating, and debugging. Always read and test generated code first, since the model cannot truly reason and may repeat training data.

### 4.1 Writing code

Worked example (Bash script to rename files):

```
Goal: write Bash that prompts for a folder name, then prepends "draft_"
      to every file in it.
Temperature: 0.1   Token Limit: 1024

Output (abridged):
#!/bin/bash
echo "Enter the folder name: "
read folder_name
if [ ! -d "$folder_name" ]; then
  echo "Folder does not exist."
  exit 1
fi
files=( "$folder_name"/* )
for file in "${files[@]}"; do
  new_file_name="draft_$(basename "$file")"
  mv "$file" "$new_file_name"
done
echo "Files renamed successfully."
```

The output is even self-documented, but you still test it on a small folder before trusting it.

### 4.2 Explaining code

Paste the code and ask the model to explain it. The model walks through each block (user input, folder existence check, file listing, the rename loop, the success message). Useful when reading a teammate's unfamiliar code.

### 4.3 Translating code

Ask the model to translate from one language to another. Worked example (Bash to Python):

```
Prompt: Translate the below Bash code to a Python snippet. [paste Bash]

Output (abridged):
import os, shutil
folder_name = input("Enter the folder name: ")
if not os.path.isdir(folder_name):
    print("Folder does not exist."); exit(1)
files = os.listdir(folder_name)
for file in files:
    new_file_name = f"draft_{file}"
    shutil.move(os.path.join(folder_name, file),
                os.path.join(folder_name, new_file_name))
print("Files renamed successfully.")
```

Note: when prompting for Python in Vertex AI Language Studio, click the "Markdown" button, otherwise you lose the indentation that Python needs.

### 4.4 Debugging and reviewing code

Paste the broken code plus the error traceback and ask the model to debug and improve it. In the whitepaper example, a script calls a nonexistent `toUpperCase(prefix)` and throws `NameError`. The model:

```
- Identifies the bug: toUpperCase is not defined.
- Fixes it: use prefix.upper() instead.
- Then goes further and suggests improvements not even asked for:
  1. Preserve the original file extension.
  2. Handle spaces in folder names.
  3. Prefer f-strings over '+' concatenation.
  4. Wrap shutil.move in try/except for error handling.
```

So debugging prompts can both fix the immediate error and surface other latent bugs.

### 4.5 Multimodal prompting (brief)

**Multimodal prompting uses multiple input formats (text, images, audio, code, etc.) together to guide the model, rather than text alone.**

It is a separate concern from code prompting. Prompting for code still uses an ordinary text LLM. Multimodal depends on the model actually supporting those input types.

---

## 5. Best Practices

The single biggest lever is examples, but the rest compound.

### Provide examples
The most important best practice. One-shot or few-shot examples act as a teaching tool, giving the model a target to imitate and improving accuracy, style, and tone.

### Design with simplicity
Keep prompts concise, clear, and easy to read. If the prompt confuses you, it will confuse the model. Avoid complex language and unnecessary detail.

```
BEFORE: I am visiting New York right now, and I'd like to hear more about
        great locations. I am with two 3 year old kids. Where should we go?
AFTER:  Act as a travel guide for tourists. Describe great places to visit
        in New York Manhattan with a 3 year old.
```

Use action verbs: Act, Analyze, Categorize, Classify, Compare, Create, Describe, Define, Evaluate, Extract, Find, Generate, Identify, List, Measure, Organize, Parse, Pick, Predict, Provide, Rank, Recommend, Return, Retrieve, Rewrite, Select, Show, Sort, Summarize, Translate, Write.

### Be specific about the output
Vague prompts give generic output. Specify what you want.

```
DO:     Generate a 3 paragraph blog post about the top 5 video game consoles.
        Informative, engaging, conversational style.
DO NOT: Generate a blog post about video game consoles.
```

### Use instructions over constraints

**An instruction tells the model what to do. A constraint tells the model what not to do.**

Research suggests positive instructions usually beat heavy constraints. Instructions communicate the desired outcome directly, while constraints leave the model guessing about what is allowed and can clash with each other. Use constraints when needed for safety, strict formatting, or to prevent harmful output.

```
DO:     Generate a 1 paragraph blog post about the top 5 video game consoles.
        Only discuss the console, the company, the year, and total sales.
DO NOT: Generate a 1 paragraph blog post ... Do not list video game names.
```

Start by prioritizing instructions, add constraints only when necessary.

### Control the max token length
Either set a max-token limit in the config, or request a length in the prompt, e.g. "Explain quantum physics in a tweet length message."

### Use variables in prompts
Store reused values in variables so prompts stay dynamic and DRY. Useful when integrating prompts into an application.

```
VARIABLES: {city} = "Amsterdam"
PROMPT:    You are a travel guide. Tell me a fact about the city: {city}
```

### Experiment with input formats and writing styles
The same goal phrased as a question, a statement, or an instruction yields different outputs. Example for the Sega Dreamcast:

```
Question:    What was the Sega Dreamcast and why was it revolutionary?
Statement:   The Sega Dreamcast was a sixth-generation console released in 1999. It...
Instruction: Write a single paragraph describing the Dreamcast and why it was revolutionary.
```

### For few-shot classification, mix up the classes
Shuffle the order of response classes in your examples. If they are ordered, the model may overfit to the order instead of learning each class's features. Mixing improves generalization. Start with about 6 examples and tune from there.

### Adapt to model updates
Track architecture changes and new capabilities. Try newer model versions and adjust prompts to use new features.

### Experiment with output formats
For non-creative tasks (extracting, selecting, parsing, ordering, ranking, categorizing), ask for structured output like JSON or XML. JSON forces a structure, returns sorted data, and limits hallucinations.

### Experiment together with other prompt engineers
Have several people independently attempt a prompt following these practices. You will see real variance in performance, which surfaces better prompts.

### CoT-specific best practices
- Put the final answer *after* the reasoning, because generating the reasoning changes the tokens available when the model predicts the answer.
- With CoT and self-consistency, make sure you can extract the final answer separately from the reasoning.
- Set temperature to 0 for CoT, since reasoning toward a single correct answer is greedy-decoding territory.

### Document every attempt
Keep a full record of prompts so you can learn over time. Output can differ across models, sampling settings, and even identical prompts (tie-breaking randomness). A recommended template (e.g. in a Google Sheet):

| Field | Content |
|---|---|
| Name | name and version of the prompt |
| Goal | one-sentence goal of this attempt |
| Model | name and version of the model |
| Temperature / Token Limit | values |
| Top-K / Top-P | values |
| Prompt | the full prompt |
| Output | the output(s) |

Also track iteration number, a result status (OK / NOT OK / SOMETIMES OK), and feedback. For RAG systems, also log the query, chunk settings, and chunk output. Once a prompt is solid, store it in your codebase in a separate file from code, and rely on automated tests and evaluation to check how well it generalizes.

Prompt engineering is iterative: craft, test, analyze, document, refine, repeat. When you change the model or config, revisit and re-test your old prompts.

---

## 6. Quick Recap

| Technique | One-line idea |
|---|---|
| Zero-shot | Task description only, no examples |
| One-shot / few-shot | Give 1 or several examples to imitate |
| System | Set the overall task and purpose |
| Contextual | Supply task-specific background |
| Role | Assign a character / voice |
| Step-back | Ask a general question first, feed the answer back |
| Chain of Thought | Generate reasoning steps before the answer |
| Self-consistency | Many CoT runs, take the majority vote |
| Tree of Thoughts | Explore many reasoning paths as a tree |
| ReAct | Reason and act in a tool-using loop |
| APE | Use an LLM to generate and score prompts |

Configuration cheat sheet:
- Deterministic / factual: temperature low or 0, low top-K, low top-P.
- Creative: temperature high, higher top-K and top-P.
- Single correct answer (math, classification, CoT): temperature 0.
- Output length caps tokens, it does not enforce brevity. Ask for short output explicitly.
