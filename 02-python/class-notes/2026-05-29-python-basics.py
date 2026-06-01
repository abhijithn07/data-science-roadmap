# 29/05/2026, PYTHON BASICS
# setup, data types, casting, operators, input, branching


# 1. WHAT IS PYTHON / WHY USE IT
#
# general purpose programming language. used everywhere :
# scripting, data analysis, ML, web backends, automation.
# readable syntax, huge library ecosystem, easy to learn.
#
# difference from SQL :
#   SQL is meant for databases ONLY (querying / manipulating stored data).
#   Python is a full programming language : variables, control flow,
#   functions, classes, file IO, networking, anything.


# 2. ENVIRONMENT SETUP
#
# Anaconda        : package manager + python + many libraries bundled
# Jupyter Notebook: interactive python in the browser, cell by cell
# VS Code         : code editor for writing python scripts (.py files)
#
# we will use python for general programming, including patterns
# (the classic star/number printing exercises).


# 3. HELLO WORLD

print("Hello World")
print(123)


# 4. FUNDAMENTAL DATA TYPES
#
# integers : whole numbers, positive or negative
# floats   : numbers with a decimal point
# strings  : text, in quotes
# complex  : numbers with a real and imaginary part (a + bj)
# bool     : True or False

a = 9        # int
b = 3.14     # float
c = "hello"  # str
d = 3 + 4j   # complex
e = True     # bool


# 5. VARIABLES
#
# in python you do NOT declare a type. just assign a value with =
# and python figures out the type automatically.
# a variable can be reassigned to a different value (and even a different type).

a = 9
a = 10           # a is now 10. the old value 9 is no longer reachable.
b = 3
print(a + b)     # 13

# what happens to the old value (9) when we reassign a?
# python's garbage collector cleans it up since nothing points to it anymore.

# a variable can also switch types entirely
a = 9
a = "hello"      # totally legal, a is now a string


# 6. TYPE CASTING
#
# converting a value from one type to another. two flavors :
#   implicit : python does it automatically when safe
#   explicit : you do it manually with int() / float() / str() / bool()

# implicit example : int + float automatically promotes to float
a = 9
b = 3.5
print(a + b)          # 12.5
print(type(a + b))    # <class 'float'>

# explicit example : convert string to int
x = "10"
y = int(x)
print(y + 5)          # 15

# float to int drops the decimal (does not round)
print(int(3.9))       # 3
print(int(-3.9))      # -3

# int to string for concatenation
print(str(123) + " is a number")


# 7. DUCK TYPING
#
# "if it walks like a duck and quacks like a duck, treat it as a duck."
# python does not care what type an object IS, only what it can DO.
# if it has the methods/operations you need, it works.


# 8. DYNAMIC TYPING
#
# the type of a variable is determined at runtime, not declared upfront.
# the same variable can hold different types over time (see section 5).
# contrast with statically typed languages (C, Java) where you declare
# the type and it stays fixed.


# 9. type() FUNCTION
#
# tells you the current type of a value or variable

print(type(9))         # <class 'int'>
print(type(3.14))      # <class 'float'>
print(type("hello"))   # <class 'str'>
print(type(True))      # <class 'bool'>
print(type(3 + 4j))    # <class 'complex'>


# 10. ARITHMETIC OPERATORS

a = 10
b = 3

print(a + b)    # 13   addition
print(a - b)    # 7    subtraction
print(a * b)    # 30   multiplication
print(a / b)    # 3.33 division - always returns float
print(a // b)   # 3    floor division - drops the decimal
print(a % b)    # 1    modulo - remainder after division
print(a ** b)   # 1000 exponent - a to the power of b


# 11. COMPARISON OPERATORS
#
# return True or False

a = 10
b = 3

print(a == b)   # False  equal to
print(a != b)   # True   not equal to
print(a >  b)   # True   greater than
print(a <  b)   # False  less than
print(a >= b)   # True   greater than or equal
print(a <= b)   # False  less than or equal


# 12. LOGICAL OPERATORS
#
# combine boolean values

x = True
y = False

print(x and y)  # False  both must be True
print(x or  y)  # True   at least one must be True
print(not x)    # False  flips the value


# 13. ASSIGNMENT OPERATORS
#
# shortcuts that modify a variable in place

a = 5
a += 3   # same as a = a + 3, now a is 8
a -= 2   # same as a = a - 2, now a is 6
a *= 4   # same as a = a * 4, now a is 24
a /= 2   # same as a = a / 2, now a is 12.0
a //= 5  # same as a = a // 5
a %= 3   # same as a = a % 3
a **= 2  # same as a = a ** 2


# 14. INPUT FROM USER
#
# input() reads a line from the user. it ALWAYS returns a string,
# even if the user types a number.

name = input("Enter your name : ")
print("Hello", name)

# to read a number, wrap input() with int() or float()
age = int(input("Enter your age : "))
print(age + 1, "next year")

# wrong way - this would crash on the + operation because age would be a string
# age = input("Enter your age : ")
# print(age + 1)        # TypeError: can only concatenate str (not "int") to str


# 15. STRING FORMATTING
#
# three ways to insert variables into a string.

name = "Aaron"
age  = 25

# (a) f-string  : preferred, python 3.6+
print(f"My name is {name} and I am {age} years old")

# (b) .format() : older but still common
print("My name is {} and I am {} years old".format(name, age))

# (c) % formatting : oldest style, c-like
print("My name is %s and I am %d years old" % (name, age))


# 16. BOOLEAN EVALUATION
#
# in python, certain values are treated as "falsy" :
#   0, 0.0, "" (empty string), [] (empty list), {} (empty dict),
#   None, False
# everything else is "truthy".
#
# this matters because if-statements check truthiness, not just True/False.

if 0:        print("yes")  # nothing prints, 0 is falsy
if "":       print("yes")  # nothing prints, empty string is falsy
if "hello":  print("yes")  # prints, non-empty string is truthy
if 5:        print("yes")  # prints, non-zero number is truthy
if []:       print("yes")  # nothing, empty list is falsy
if [0]:      print("yes")  # prints, the list itself is non-empty


# 17. BRANCHING - if / elif / else
#
# indentation is required in python (4 spaces by convention).
# the block inside if / elif / else is decided by indentation, not braces.

age = 18

if age < 13:
    print("child")
elif age < 18:
    print("teen")
elif age < 60:
    print("adult")
else:
    print("senior")


# 18. NESTED IF
#
# an if statement inside another if statement.
# indentation must increase for each nested level.

age = 20
has_id = True

if age >= 18:
    if has_id:
        print("can enter the venue")
    else:
        print("need ID")
else:
    print("too young")
