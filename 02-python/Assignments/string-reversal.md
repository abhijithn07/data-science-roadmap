# Assignment 1, reversing a string

## 1. Using Slicing

```python
text = "PROGRAM"
reversed_text = text[::-1]

print(reversed_text)
```

Output:

```
MARGORP
```

## 2. Using reversed() Function

```python
text = "PROGRAM"
reversed_text = ''.join(reversed(text))

print(reversed_text)
```

Output:

```
MARGORP
```

## 3. Using a Loop

```python
text = "PROGRAM"
reversed_text = ""

for char in text:
    reversed_text = char + reversed_text

print(reversed_text)
```

Output:

```
MARGORP
```

## 4. Using Recursion

```python
def reverse_string(text):
    if len(text) == 0:
        return text
    return reverse_string(text[1:]) + text[0]

print(reverse_string("PROGRAM"))
```

Output:

```
MARGORP
```

## 5. Using List and reverse()

```python
text = "PROGRAM"
chars = list(text)
chars.reverse()
reversed_text = ''.join(chars)

print(reversed_text)
```

Output:

```
MARGORP
```

## 6. Using a While Loop

```python
text = "PROGRAM"
i = len(text) - 1
reversed_text = ""

while i >= 0:
    reversed_text += text[i]
    i -= 1

print(reversed_text)
```

Output:

```
MARGORP
```

## 7. Using List Comprehension

```python
text = "PROGRAM"

reversed_text = ''.join([text[i] for i in range(len(text)-1, -1, -1)])

print(reversed_text)
```

Output:

```
MARGORP
```

## 8. Reverse Words Instead of Characters

```python
text = "Learning is fun"

reversed_words = " ".join(text.split()[::-1])

print(reversed_words)
```

Output:

```
fun is Learning
```

## 9. Reverse Each Word in a String

```python
text = "Learning is fun"

result = " ".join(word[::-1] for word in text.split())

print(result)
```

Output:

```
gninraeL si nuf
```

## 10. Using Negative Indexing

```python
text = "PROGRAM"
reversed_text = ""

for i in range(1, len(text) + 1):
    reversed_text += text[-i]

print(reversed_text)
```

Output:

```
MARGORP
```
