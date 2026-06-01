# 20. Date and Time

Working with dates and times is essential in data work - timestamps in logs, time-series data, expiration dates, etc. Python's `datetime` module handles most of what you'll need.

## 1. The `datetime` Module

Import it:

```python
from datetime import datetime, date, time, timedelta
```

Four main classes:

| Class | What it represents |
|---|---|
| `date` | A calendar date (year, month, day) |
| `time` | A clock time (hour, minute, second) |
| `datetime` | Both date and time together |
| `timedelta` | A duration (difference between two datetimes) |

## 2. Getting the Current Time

```python
from datetime import datetime, date

now = datetime.now()
print(now)              # 2026-05-29 14:32:18.123456

today = date.today()
print(today)             # 2026-05-29

# just the time
print(now.time())        # 14:32:18.123456
```

`datetime.now()` includes microseconds. Use `datetime.now().replace(microsecond=0)` to drop them.

## 3. Creating Specific Dates and Times

```python
from datetime import date, time, datetime

# date
d = date(2026, 5, 29)            # year, month, day
print(d)                          # 2026-05-29

# time
t = time(14, 30, 0)              # hour, minute, second
print(t)                          # 14:30:00

# datetime
dt = datetime(2026, 5, 29, 14, 30, 0)
print(dt)                         # 2026-05-29 14:30:00
```

## 4. Accessing Parts

```python
dt = datetime(2026, 5, 29, 14, 30, 0)

print(dt.year)           # 2026
print(dt.month)          # 5
print(dt.day)            # 29
print(dt.hour)           # 14
print(dt.minute)         # 30
print(dt.second)         # 0
print(dt.weekday())      # 4    (Monday=0, Sunday=6)
print(dt.isoweekday())   # 5    (Monday=1, Sunday=7)
```

## 5. Formatting Dates as Strings

Use `strftime` ("string format time") with format codes:

```python
dt = datetime(2026, 5, 29, 14, 30, 0)

print(dt.strftime("%Y-%m-%d"))                 # '2026-05-29'
print(dt.strftime("%d/%m/%Y"))                 # '29/05/2026'
print(dt.strftime("%B %d, %Y"))                # 'May 29, 2026'
print(dt.strftime("%A"))                       # 'Friday'
print(dt.strftime("%H:%M:%S"))                 # '14:30:00'
print(dt.strftime("%I:%M %p"))                 # '02:30 PM'
print(dt.strftime("%Y-%m-%d %H:%M"))           # '2026-05-29 14:30'
```

### Format codes

| Code | Meaning | Example |
|---|---|---|
| `%Y` | 4-digit year | 2026 |
| `%y` | 2-digit year | 26 |
| `%m` | Month as number | 05 |
| `%B` | Full month name | May |
| `%b` | Abbreviated month | May |
| `%d` | Day of month | 29 |
| `%A` | Full weekday | Friday |
| `%a` | Abbreviated weekday | Fri |
| `%H` | Hour (24-hour) | 14 |
| `%I` | Hour (12-hour) | 02 |
| `%M` | Minute | 30 |
| `%S` | Second | 00 |
| `%p` | AM/PM | PM |
| `%j` | Day of year | 149 |
| `%U` | Week of year | 21 |
| `%Z` | Timezone name | EST |

Use f-strings with format codes for compact code:

```python
dt = datetime.now()
print(f"{dt:%Y-%m-%d %H:%M}")              # works inside f-strings
```

## 6. Parsing Strings to Dates

`strptime` ("string parse time") is the opposite of strftime:

```python
text = "2026-05-29"
dt = datetime.strptime(text, "%Y-%m-%d")
print(dt)                            # 2026-05-29 00:00:00

text = "29/05/2026 14:30"
dt = datetime.strptime(text, "%d/%m/%Y %H:%M")
print(dt)                            # 2026-05-29 14:30:00
```

The format string must match the input exactly, or you get a `ValueError`.

### ISO format (recommended)

ISO 8601 format (YYYY-MM-DDTHH:MM:SS) is the standard and easiest to parse:

```python
text = "2026-05-29T14:30:00"
dt = datetime.fromisoformat(text)
print(dt)                            # 2026-05-29 14:30:00
```

## 7. Date Arithmetic with `timedelta`

`timedelta` represents a duration:

```python
from datetime import datetime, timedelta

now = datetime.now()

# add/subtract durations
tomorrow = now + timedelta(days=1)
last_week = now - timedelta(weeks=1)
in_2_hours = now + timedelta(hours=2)
later = now + timedelta(days=3, hours=12, minutes=30)
```

### `timedelta` parameters

```python
timedelta(days=N)
timedelta(seconds=N)
timedelta(minutes=N)
timedelta(hours=N)
timedelta(weeks=N)
timedelta(milliseconds=N)
timedelta(microseconds=N)

# can combine
timedelta(days=1, hours=2, minutes=30)
```

Note: no `months` or `years` parameter (because months have different lengths).

### Difference between two dates

Subtracting two datetimes gives a `timedelta`:

```python
start = datetime(2026, 1, 1)
end = datetime(2026, 5, 29)

diff = end - start
print(diff)                  # 148 days, 0:00:00
print(diff.days)             # 148
print(diff.total_seconds())  # 12787200.0
```

## 8. Common Patterns

### Days between two dates

```python
from datetime import date

d1 = date(2026, 1, 1)
d2 = date(2026, 5, 29)
days = (d2 - d1).days
print(days)              # 148
```

### Age calculation

```python
from datetime import date

def calculate_age(birth_date):
    today = date.today()
    age = today.year - birth_date.year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        age -= 1
    return age

age = calculate_age(date(2000, 7, 24))
print(age)
```

### Days remaining in the year

```python
from datetime import date

today = date.today()
end_of_year = date(today.year, 12, 31)
days_left = (end_of_year - today).days
print(days_left)
```

### Format date as a different style

```python
from datetime import datetime

# read in one format, write in another
input_date = "29/05/2026"
dt = datetime.strptime(input_date, "%d/%m/%Y")
output_date = dt.strftime("%B %d, %Y")
print(output_date)       # 'May 29, 2026'
```

### Generate a range of dates

```python
from datetime import date, timedelta

start = date(2026, 5, 25)
end = date(2026, 6, 1)

current = start
while current <= end:
    print(current)
    current += timedelta(days=1)
```

### Get first day of month, last day of month

```python
from datetime import date, timedelta

d = date(2026, 5, 15)

# first of month
first = d.replace(day=1)
print(first)             # 2026-05-01

# last of month (trick: first of next month minus 1 day)
if d.month == 12:
    next_month = date(d.year + 1, 1, 1)
else:
    next_month = date(d.year, d.month + 1, 1)
last = next_month - timedelta(days=1)
print(last)              # 2026-05-31
```

### Day of week

```python
from datetime import date

d = date(2026, 5, 29)

# weekday(): Monday=0, Sunday=6
print(d.weekday())       # 4

# isoweekday(): Monday=1, Sunday=7 (more conventional)
print(d.isoweekday())    # 5

# name
print(d.strftime("%A"))  # 'Friday'
```

### Is it a weekday or weekend?

```python
def is_weekend(d):
    return d.weekday() >= 5    # Sat=5, Sun=6

print(is_weekend(date(2026, 5, 29)))    # False (Friday)
print(is_weekend(date(2026, 5, 30)))    # True  (Saturday)
```

## 9. Working with Time Zones

Basic `datetime` objects are **naive** - they don't know what timezone they're in. For real-world apps, use **aware** datetimes.

Python 3.9+ has `zoneinfo` built in:

```python
from datetime import datetime
from zoneinfo import ZoneInfo

# aware datetime in NYC
nyc = datetime.now(tz=ZoneInfo("America/New_York"))
print(nyc)               # 2026-05-29 10:30:00-04:00

# convert to another timezone
tokyo = nyc.astimezone(ZoneInfo("Asia/Tokyo"))
print(tokyo)             # 2026-05-29 23:30:00+09:00

# UTC
utc = datetime.now(tz=ZoneInfo("UTC"))
print(utc)
```

For older Python (before 3.9), use the `pytz` library.

**Best practice:** store dates as UTC, convert to local time only for display.

## 10. The `time` Module (Different from `datetime`)

There's a separate `time` module for low-level time operations:

```python
import time

# current Unix timestamp (seconds since 1970)
ts = time.time()
print(ts)                # 1748520120.5

# pause execution
time.sleep(2)            # sleep for 2 seconds

# measure elapsed time
start = time.time()
# ... do work ...
elapsed = time.time() - start
print(f"Took {elapsed:.2f} seconds")
```

Don't confuse `time` (module, for timestamps and sleep) with `datetime.time` (class, for clock times).

## 11. Unix Timestamps

A Unix timestamp is seconds since 1970-01-01 UTC. Common in APIs and databases.

### Convert datetime to timestamp

```python
import time
from datetime import datetime

dt = datetime(2026, 5, 29, 14, 30)
ts = dt.timestamp()
print(ts)                # something like 1779972600.0
```

### Convert timestamp to datetime

```python
from datetime import datetime

ts = 1779972600
dt = datetime.fromtimestamp(ts)
print(dt)                # 2026-05-29 14:30:00
```

## 12. Quick Reference

```python
from datetime import datetime, date, time, timedelta

# get current
datetime.now()
date.today()

# create
datetime(2026, 5, 29, 14, 30, 0)
date(2026, 5, 29)

# format to string
dt.strftime("%Y-%m-%d %H:%M:%S")

# parse from string
datetime.strptime("2026-05-29", "%Y-%m-%d")
datetime.fromisoformat("2026-05-29T14:30:00")

# arithmetic
dt + timedelta(days=7)
dt - timedelta(hours=2)
(end - start).days

# parts
dt.year, dt.month, dt.day
dt.weekday(), dt.isoweekday()
dt.strftime("%A")        # weekday name
```

## Common Mistakes

### Mistake 1: comparing datetime and date

```python
from datetime import datetime, date

dt = datetime.now()
d = date.today()

# dt > d         # TypeError: cant compare these directly
```

Convert one to the other type before comparing:

```python
dt.date() > d              # date vs date - OK
dt > datetime.combine(d, datetime.min.time())   # datetime vs datetime
```

### Mistake 2: format codes mixed up

```python
# %M is minutes, %m is month! easy to confuse
dt.strftime("%Y-%M-%d")     # WRONG: minute in middle
dt.strftime("%Y-%m-%d")     # CORRECT
```

### Mistake 3: not handling timezone

```python
# naive datetime - timezone-unaware
dt = datetime(2026, 5, 29, 14, 30)
# converting to another zone without timezone info gives wrong answer
```

For real time-zone-aware apps, always use aware datetimes from `zoneinfo`.

### Mistake 4: assuming "month" arithmetic works simply

```python
from datetime import date, timedelta

# "one month from today" - timedelta doesn't do months
today = date.today()
# next_month = today + timedelta(months=1)   # TypeError: no months arg
```

Use the `dateutil` library for month arithmetic:

```python
from dateutil.relativedelta import relativedelta
next_month = today + relativedelta(months=1)
```

Or do it manually with year/month math.

## Summary

- `datetime` module has `date`, `time`, `datetime`, `timedelta`
- `datetime.now()` and `date.today()` for current
- `strftime` formats datetime to string, `strptime` parses string to datetime
- ISO format (`YYYY-MM-DD`) is the standard
- `timedelta(days=, hours=, minutes=)` for durations
- Subtract dates to get a `timedelta`
- Use `zoneinfo` (Python 3.9+) for timezone-aware datetimes
- `time` module is separate, for timestamps and `sleep()`

This completes Phase 3. Next: Phase 4 (data science libraries - NumPy, pandas, matplotlib, seaborn, scipy).
