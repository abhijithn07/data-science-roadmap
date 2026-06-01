# 17. OOP Basics

**OOP** (Object-Oriented Programming) is a way of organizing code around **objects** that bundle together data (attributes) and the operations on that data (methods).

You've already been using objects:
- A string `"hello"` is an object with methods like `.upper()`, `.split()`.
- A list `[1, 2, 3]` is an object with methods like `.append()`, `.sort()`.
- A dict `{"a": 1}` is an object with methods like `.keys()`, `.items()`.

In this note you'll learn to create your own object types using **classes**.

## 1. Why OOP?

Suppose you're modeling a customer:

```python
# without classes - lots of separate variables
customer_name = "Aaron"
customer_age = 25
customer_email = "aaron@example.com"

def greet_customer(name, age):
    return f"Hello {name}, age {age}"
```

This works but gets messy with many customers and many operations. With classes:

```python
class Customer:
    def __init__(self, name, age, email):
        self.name = name
        self.age = age
        self.email = email
    
    def greet(self):
        return f"Hello {self.name}, age {self.age}"

c = Customer("Aaron", 25, "aaron@example.com")
print(c.greet())            # "Hello Aaron, age 25"
```

Now `Customer` is a reusable blueprint. Each customer is one object with its own data and shared methods.

## 2. Class vs Instance

- A **class** is a blueprint, like `Customer`.
- An **instance** is one specific object built from the blueprint, like `c = Customer("Aaron", 25, ...)`.

You can have many instances of one class:

```python
c1 = Customer("Aaron", 25, "a@x.com")
c2 = Customer("Bea",   30, "b@x.com")
c3 = Customer("Carlos", 35, "c@x.com")
```

Each has its own `name`, `age`, `email`.

## 3. Anatomy of a Class

```python
class Customer:
    """A customer of the store."""             # docstring (optional)
    
    def __init__(self, name, age, email):      # constructor
        self.name = name                        # attributes
        self.age = age
        self.email = email
    
    def greet(self):                            # method
        return f"Hello {self.name}"
    
    def is_adult(self):                         # another method
        return self.age >= 18
```

### `__init__` - the constructor

`__init__` is a special method that runs when a new instance is created. Use it to set up the initial state.

```python
c = Customer("Aaron", 25, "aaron@x.com")
# Python calls Customer.__init__(c, "Aaron", 25, "aaron@x.com")
```

### `self` - the current instance

`self` is the first parameter of every method. It refers to the instance the method is being called on.

```python
def greet(self):
    return f"Hello {self.name}"

c.greet()              # self is c
# inside greet, self.name is c.name
```

You **must** include `self` as the first parameter of every method. You don't pass it explicitly when calling - Python does that for you.

### Attributes - the data

`self.name = name` creates an attribute on the instance. Access with `instance.attribute`:

```python
c = Customer("Aaron", 25, "a@x.com")
print(c.name)          # 'Aaron'
print(c.age)           # 25

c.age = 26             # can also be modified
```

### Methods - the operations

Methods are functions defined inside the class. They always take `self` as the first parameter:

```python
def is_adult(self):
    return self.age >= 18

c = Customer("Aaron", 25, "a@x.com")
print(c.is_adult())    # True
```

## 4. A Complete Example

```python
class BankAccount:
    """Simple bank account with deposits and withdrawals."""
    
    def __init__(self, owner, balance=0):
        self.owner = owner
        self.balance = balance
    
    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Amount must be positive")
        self.balance += amount
        return self.balance
    
    def withdraw(self, amount):
        if amount > self.balance:
            raise ValueError("Insufficient funds")
        self.balance -= amount
        return self.balance
    
    def __str__(self):
        return f"BankAccount(owner={self.owner}, balance=${self.balance})"


# usage
acc = BankAccount("Aaron", 100)
print(acc)                 # BankAccount(owner=Aaron, balance=$100)

acc.deposit(50)
print(acc.balance)         # 150

acc.withdraw(30)
print(acc.balance)         # 120

try:
    acc.withdraw(1000)
except ValueError as e:
    print(e)               # Insufficient funds
```

## 5. Special Methods (Dunder Methods)

Methods with double underscores (`__method__`) are special - Python calls them automatically in certain situations.

### `__init__` - already covered (constructor)

### `__str__` - string representation for humans

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __str__(self):
        return f"({self.x}, {self.y})"

p = Point(3, 4)
print(p)               # (3, 4)
print(str(p))          # (3, 4)
```

Without `__str__`, `print(p)` would show something ugly like `<__main__.Point object at 0x7f...>`.

### `__repr__` - string representation for developers

```python
def __repr__(self):
    return f"Point(x={self.x}, y={self.y})"
```

Used by the REPL and in lists:

```python
points = [Point(1, 2), Point(3, 4)]
print(points)          # [Point(x=1, y=2), Point(x=3, y=4)]
```

Best practice: define `__repr__`. Define `__str__` only if you want different output for users.

### `__eq__` - compare equality

```python
def __eq__(self, other):
    return self.x == other.x and self.y == other.y

p1 = Point(1, 2)
p2 = Point(1, 2)
print(p1 == p2)        # True (without __eq__, this would be False)
```

### `__len__` - support for `len()`

```python
class Bag:
    def __init__(self):
        self.items = []
    
    def add(self, item):
        self.items.append(item)
    
    def __len__(self):
        return len(self.items)

b = Bag()
b.add("apple")
b.add("banana")
print(len(b))          # 2
```

There are many more (`__add__`, `__contains__`, `__iter__`, etc.), but these are the most common to start with.

## 6. Class Attributes vs Instance Attributes

**Instance attributes** are unique to each object (set in `__init__` with `self`):

```python
class Customer:
    def __init__(self, name):
        self.name = name        # instance attribute
```

**Class attributes** are shared by all instances:

```python
class Customer:
    company = "Acme Corp"        # class attribute, shared
    
    def __init__(self, name):
        self.name = name          # instance attribute, unique

c1 = Customer("Aaron")
c2 = Customer("Bea")

print(c1.company)            # 'Acme Corp'
print(c2.company)            # 'Acme Corp'

# changing on instance creates an instance attribute on that one only
c1.company = "Different"
print(c1.company)            # 'Different'
print(c2.company)            # 'Acme Corp'    (still class attribute)
```

Class attributes are useful for constants and shared data.

## 7. Inheritance

A class can **inherit** from another class, getting all its attributes and methods, plus adding its own.

```python
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        print(f"{self.name} makes a sound")


class Dog(Animal):           # Dog inherits from Animal
    def speak(self):          # override the parent's method
        print(f"{self.name} says Woof!")


class Cat(Animal):
    def speak(self):
        print(f"{self.name} says Meow!")


d = Dog("Rex")
c = Cat("Whiskers")

d.speak()              # Rex says Woof!
c.speak()              # Whiskers says Meow!
```

`Dog` and `Cat` both got the `__init__` from `Animal` automatically. They each defined their own `speak()` to override the inherited one.

### Calling the parent class - `super()`

If you want to extend (not replace) a parent method:

```python
class Animal:
    def __init__(self, name):
        self.name = name


class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)    # call Animal's __init__
        self.breed = breed         # add new attribute


d = Dog("Rex", "Labrador")
print(d.name)          # 'Rex'
print(d.breed)         # 'Labrador'
```

`super()` refers to the parent class. Use it when you need both the parent's work AND your own additions.

### Checking types

```python
print(isinstance(d, Dog))         # True
print(isinstance(d, Animal))      # True (Dog IS an Animal)
print(isinstance(d, Cat))         # False
```

## 8. Encapsulation - Private Attributes (by Convention)

Python doesn't enforce truly private attributes. Instead, there's a convention:

```python
class Account:
    def __init__(self, balance):
        self._balance = balance      # one underscore: "private, please don't touch"
        self.__pin = 1234             # two underscores: name-mangled, harder to access
    
    def get_balance(self):
        return self._balance


a = Account(100)
print(a.get_balance())     # 100
print(a._balance)           # 100   (still accessible, just please don't)
# print(a.__pin)            # AttributeError due to name mangling
print(a._Account__pin)      # 1234  (the mangled name)
```

Convention:
- `name` - public
- `_name` - "internal, don't access from outside" (just a hint)
- `__name` - name-mangled to discourage subclass collision

Don't overuse `__`. Most of the time `_` is enough.

## 9. Properties - controlled attribute access

Sometimes you want an "attribute" that actually runs code on get/set:

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius
    
    @property
    def area(self):
        return 3.14159 * self._radius ** 2
    
    @property
    def radius(self):
        return self._radius
    
    @radius.setter
    def radius(self, value):
        if value <= 0:
            raise ValueError("Radius must be positive")
        self._radius = value


c = Circle(5)
print(c.radius)        # 5    (calls the getter, no parens)
print(c.area)          # 78.5 (computed on access)

c.radius = 10          # calls the setter, which validates
print(c.area)          # 314

# c.radius = -1        # ValueError
```

Properties let you keep simple attribute syntax while adding logic.

## 10. Common Patterns

### Counter with reset

```python
class Counter:
    def __init__(self, start=0):
        self.count = start
    
    def increment(self):
        self.count += 1
    
    def reset(self):
        self.count = 0
    
    def __str__(self):
        return f"Counter({self.count})"


c = Counter()
c.increment()
c.increment()
print(c)               # Counter(2)
c.reset()
print(c)               # Counter(0)
```

### Simple data class (records)

```python
class Person:
    def __init__(self, name, age, city):
        self.name = name
        self.age = age
        self.city = city
    
    def __repr__(self):
        return f"Person({self.name!r}, {self.age}, {self.city!r})"


people = [
    Person("Aaron", 25, "Tampa"),
    Person("Bea",   30, "Miami"),
]

for p in people:
    print(p)
```

For lots of simple data classes, Python 3.7+ has `dataclass` decorator:

```python
from dataclasses import dataclass

@dataclass
class Person:
    name: str
    age: int
    city: str

# auto-generates __init__, __repr__, __eq__
```

### Hierarchical model

```python
class Shape:
    def area(self):
        raise NotImplementedError

class Rectangle(Shape):
    def __init__(self, w, h):
        self.w = w
        self.h = h
    
    def area(self):
        return self.w * self.h

class Circle(Shape):
    def __init__(self, r):
        self.r = r
    
    def area(self):
        return 3.14159 * self.r ** 2

shapes = [Rectangle(3, 4), Circle(5)]
for s in shapes:
    print(s.area())
# 12
# 78.5...
```

## Common Mistakes

### Mistake 1: forgetting `self`

```python
class Customer:
    def __init__(self, name):
        name = name        # WRONG: doesn't save to instance
    
    def __init__(self, name):
        self.name = name    # CORRECT
```

### Mistake 2: forgetting `self` in method definitions

```python
class Customer:
    def greet():            # WRONG: missing self
        print("hi")

c = Customer()
c.greet()                   # TypeError: takes 0 args but 1 given (the implicit self)
```

### Mistake 3: mutable default in __init__

Same gotcha as functions:

```python
class Bag:
    def __init__(self, items=[]):    # SHARED across instances!
        self.items = items

b1 = Bag()
b1.items.append("apple")
b2 = Bag()
print(b2.items)                       # ['apple']   surprise!
```

Use `None` and check:
```python
def __init__(self, items=None):
    self.items = items if items is not None else []
```

### Mistake 4: not using super() in subclass __init__

```python
class Animal:
    def __init__(self, name):
        self.name = name

class Dog(Animal):
    def __init__(self, name, breed):
        self.breed = breed       # forgot to call super!

d = Dog("Rex", "Lab")
print(d.name)        # AttributeError: no name
```

Always call `super().__init__(...)` to run the parent's init:

```python
class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)
        self.breed = breed
```

## Summary

- `class Name:` defines a class (blueprint)
- `instance = Name(...)` creates an instance
- `__init__` is the constructor
- `self` is the current instance, always first parameter of methods
- Attributes hold data, methods do things
- `__str__`, `__repr__`, `__eq__` are special methods Python calls automatically
- `class Child(Parent):` is inheritance
- `super().method()` calls the parent's version
- `_name` is "private by convention", `__name` is name-mangled
- `@property` makes an "attribute" computed by code

Next: [Iterators and Generators](./18-iterators-and-generators.md) - the foundation of how Python handles sequences.
