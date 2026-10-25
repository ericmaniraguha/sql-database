# Module 11: Window Functions in SQL

Window functions (also called analytic functions) calculate a value for each row from a set of related rows, the **window**. Unlike `GROUP BY`, which collapses rows into one summary row per group, window functions **keep every row** and add the calculated value next to it.

---

## 🧭 The 3 Categories of Window Functions

### 1. Ranking Functions
Covered in [01_ranking_functions.sql](01_ranking_functions.sql):
- **`ROW_NUMBER()`**: a unique sequential number 1, 2, 3 … (ties broken arbitrarily).
- **`RANK()`**: equal values share a rank and leave gaps (1, 1, 1, 4).
- **`DENSE_RANK()`**: equal values share a rank with no gaps (1, 1, 1, 2).
- **`PERCENT_RANK()` / `CUME_DIST()`**: the relative position of a row, between `0` and `1`.
- **`NTILE(n)`**: splits the ordered rows into `n` nearly equal buckets (quartiles, deciles).

### 2. Aggregate Window Functions
Covered in [02_aggregate_window_functions.sql](02_aggregate_window_functions.sql):
- **`SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`** with `OVER (...)`: group totals next to every row, percentages of a total, running totals and moving averages.
- **Window frames**: `ROWS` vs `RANGE`, and why running totals should say `ROWS` explicitly.

### 3. Value Access Functions
Covered in [03_value_access_functions.sql](03_value_access_functions.sql):
- **`LAG(col, n, default)`** / **`LEAD(col, n, default)`**: the value from a previous / next row (month-on-month and term-on-term changes).
- **`FIRST_VALUE(col)`** / **`LAST_VALUE(col)`**: the first / last value of the frame (*mind the frame!*).
- **`NTH_VALUE(col, n)`**: the value from the n-th row of the frame (runner-up).

---

## ⚡ Window Syntax Anatomy

```sql
SELECT
    column_name,
    FUNCTION() OVER (
        PARTITION BY group_column              -- optional: restart for each group
        ORDER BY sort_column [ASC | DESC]      -- optional: order inside each group
        ROWS | RANGE BETWEEN start AND end     -- optional: which rows the frame covers
    ) AS window_value
FROM table_name;
```

Window functions are calculated **after** `WHERE`, `GROUP BY` and `HAVING`, so they cannot appear in `WHERE`. To filter on them (for example "top 2 per class"), compute them in a CTE or subquery first.

---

## ⚠️ Key Frame Caveat: `LAST_VALUE()`

When `OVER` contains `ORDER BY` but no frame clause, SQL uses:

```sql
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

The frame **ends at the current row**, so `LAST_VALUE()` returns the current row's value instead of the last value of the group. Widen the frame explicitly:

```sql
LAST_VALUE(final_percent) OVER (
    PARTITION BY offering_id
    ORDER BY final_percent DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```
