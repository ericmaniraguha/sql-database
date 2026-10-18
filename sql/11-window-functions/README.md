# Module 11: Window Functions in SQL

Window functions (also known as analytic functions) perform calculations across a set of table rows that are related to the current row. Unlike `GROUP BY`, which collapses rows into a single summary record, window functions **retain the individual identity of each row** while calculating aggregates, ranks, and relative values.

---

## 🧭 The 3 Core Categories of Window Functions

### 1. Ranking Functions
Assigned in [01_ranking_functions.sql](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/11-window-functions/01_ranking_functions.sql):
- **`ROW_NUMBER()`**: Assigns a unique sequential integer starting from 1 to each row within a partition.
- **`RANK()`**: Assigns a rank based on ordering, leaving gaps in rank numbers when ties occur (e.g., 1, 2, 2, 4).
- **`DENSE_RANK()`**: Assigns a rank based on ordering without gaps when ties occur (e.g., 1, 2, 2, 3).
- **`PERCENT_RANK()`**: Computes the relative rank of a row as a percentage between `0.0` and `1.0`.
- **`NTILE(n)`**: Divides rows into `n` approximately equal buckets or quantiles (e.g., quartiles, deciles).

### 2. Aggregate Window Functions
Detailed in [02_aggregate_window_functions.sql](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/11-window-functions/02_aggregate_window_functions.sql):
- **`AVG()`**: Calculates the average value in the window frame or partition.
- **`MAX()`**: Finds the maximum value in the window frame or partition.
- **`MIN()`**: Finds the minimum value in the window frame or partition.
- **`SUM()`**: Calculates the running or total sum of values in the window.
- **`COUNT()`**: Counts the number of rows or non-null values in the window.

### 3. Value Access Functions
Covered in [03_value_access_functions.sql](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/11-window-functions/03_value_access_functions.sql):
- **`LAG(col, offset, default)`**: Accesses a value from a preceding row in the window.
- **`LEAD(col, offset, default)`**: Accesses a value from a subsequent row in the window.
- **`FIRST_VALUE(col)`**: Returns the first value in the current window frame.
- **`LAST_VALUE(col)`**: Returns the last value in the window frame *(remember frame specification!)*.
- **`NTH_VALUE(col, n)`**: Returns the value from the nth row in the window frame.

---

## ⚡ Window Syntax Anatomy

```sql
SELECT 
    column_name,
    FUNCTION() OVER (
        PARTITION BY partition_column       -- Optional: Subdivides dataset into groups
        ORDER BY sort_column [ASC|DESC]      -- Optional: Orders rows inside each group
        ROWS|RANGE BETWEEN frame_start AND frame_end  -- Optional: Defines exact window frame
    ) AS window_metric
FROM table_name;
```

---

## ⚠️ Key Window Frame Caveat: `LAST_VALUE()`
When an `ORDER BY` clause is present without an explicit frame clause, SQL defaults to:
```sql
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```
Because this default frame terminates at the **`CURRENT ROW`**, calling `LAST_VALUE()` will simply return the current row's value! To capture the actual final value of the whole partition, expand the frame explicitly:
```sql
LAST_VALUE(col) OVER (
    PARTITION BY dept_id 
    ORDER BY score DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```
