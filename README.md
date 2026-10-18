# SQL Databases Learning and Practice

## 1. About the Project

This repository provides structured learning materials and practical SQL scripts for understanding relational databases, writing queries, manipulating data, and improving database performance.

It is designed for students, beginners, and database practitioners at the **Université Libre de Kigali (ULK)** and beyond who want to develop their SQL programming and database management skills through hands-on, runnable examples and graded exercises.

---

## 2. Learning Objectives

By completing the exercises in this repository, learners will be able to:

- Create and manage relational databases, schemas, and tables across modern RDBMSs.
- Enforce domain, entity, and referential integrity using primary keys, foreign keys, CHECK, and UNIQUE constraints.
- Perform CRUD operations: `INSERT`, `SELECT`, `UPDATE`, and `DELETE`.
- Filter, sort, and paginate records using Boolean predicates, pattern matching, and standard offset fetching.
- Apply built-in scalar functions for strings, numerics, dates, and conditional `CASE` logic.
- Aggregate and summarize data using `GROUP BY`, `HAVING`, and multidimensional `ROLLUP` / `GROUPING SETS`.
- Combine data across multiple tables using `INNER`, `LEFT`, `RIGHT`, `FULL OUTER`, `CROSS`, and `SELF JOIN` operations.
- Construct modular queries using subqueries, correlated queries, and Common Table Expressions (CTEs), including recursive queries for hierarchical data.
- Design standard virtual views, updatable views with `WITH CHECK OPTION`, and materialized caching views.
- Create B-Tree, composite, partial, and functional indexes and inspect query execution plans using `EXPLAIN`.
- Master all three major categories of **Window Functions**:
  - **Ranking Functions**: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()`, `NTILE()`.
  - **Aggregate Window Functions**: `AVG()`, `MAX()`, `MIN()`, `SUM()`, `COUNT()` with running sums and moving averages.
  - **Value Access Functions**: `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`, `NTH_VALUE()`.
- Control data integrity and concurrency using ACID transactions (`BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`).
- Apply set operations (`UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`), existence testing (`EXISTS`, `NOT EXISTS`), and query optimization techniques.
- Understand database-specific capabilities across PostgreSQL, MySQL, and Oracle Database.

---

## 3. Sample Database Architecture

All modules in this curriculum operate on a unified **University Academic Management System** (`ulk_university_db`):

```
+----------------+       +-------------------+       +--------------------+
|  departments   |<------+    instructors    |<------+      courses       |
+----------------+   1:N +-------------------+   1:N +--------------------+
        ^                          |                           ^        ^
        | 1:N                      +----+                      | 1:N    |
        |                               | (mentorship)         |        |
        |                               v                      |        |
+----------------+             +-------------------+           |        |
|    students    |             |    instructors    |           |        |
+----------------+             +-------------------+           |        |
        ^                                                      |        |
        | 1:N                                                  |        |
        +--------------------------+                           |        |
                                   |                           |        |
                                   v                           |        |
                        +--------------------+                 |        |
                        |    enrollments     |-----------------+        |
                        +--------------------+                          |
                                                                        |
                        +-----------------------+                       |
                        | course_prerequisites  |-----------------------+
                        +-----------------------+ (self-referencing prerequisites)
```

### Entities:
- **`departments`**: Academic units, campus buildings, and annual operating budgets.
- **`instructors`**: Faculty members, academic ranks, salaries, and hierarchical mentorship links.
- **`students`**: Student demographics, GPAs, and enrollment statuses.
- **`courses`**: Course catalog, credit weights, and departmental ownership.
- **`course_prerequisites`**: Associative table modeling course prerequisite chains.
- **`enrollments`**: Academic history, term registrations, numeric grades, and letter grades.

---

## 4. Quick Start: 1-Click Database Setup

Before running scripts in the individual topic modules, initialize the entire sample database, constraints, and seed records using the master setup script:

```bash
# PostgreSQL
psql -U postgres -d ulk_university_db -f sql/00_master_schema_and_data.sql

# MySQL
mysql -u root -p ulk_university_db < sql/00_master_schema_and_data.sql
```

You can also open [`sql/00_master_schema_and_data.sql`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/00_master_schema_and_data.sql) directly inside your database IDE (DBeaver, pgAdmin, MySQL Workbench, or VS Code) and execute it.

---

## 5. Repository Structure

The curriculum is structured into 15 modules under the [`sql/`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql) directory:

| Folder | Topics | Key Files |
|---|---|---|
| [`01-database-setup`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/01-database-setup) | Database creation and system catalog inspection | `01_create_database.sql`<br>`02_schema_overview.sql` |
| [`02-tables-and-constraints`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/02-tables-and-constraints) | Tables, data types, keys, constraints, ALTER TABLE | `01_create_tables.sql`<br>`02_primary_foreign_keys.sql`<br>`03_check_unique_constraints.sql`<br>`04_alter_tables.sql` |
| [`03-data-manipulation`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/03-data-manipulation) | CRUD: INSERT, SELECT, UPDATE, DELETE, TRUNCATE | `01_insert_records.sql`<br>`02_select_basics.sql`<br>`03_update_records.sql`<br>`04_delete_records.sql`<br>`05_truncate_tables.sql` |
| [`04-filtering-and-sorting`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/04-filtering-and-sorting) | WHERE, AND, OR, LIKE, BETWEEN, ORDER BY, FETCH | `01_where_and_or_not.sql`<br>`02_comparison_and_between.sql`<br>`03_in_and_like_pattern_matching.sql`<br>`04_null_handling.sql`<br>`05_order_by_and_pagination.sql` |
| [`05-sql-functions`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/05-sql-functions) | String, numeric, date, conversion, NULL functions, and CASE | `01_string_functions.sql`<br>`02_numeric_functions.sql`<br>`03_date_time_functions.sql`<br>`04_null_functions.sql`<br>`05_conditional_case_expressions.sql` |
| [`06-aggregate-functions`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/06-aggregate-functions) | COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING, ROLLUP | `01_basic_aggregates.sql`<br>`02_group_by.sql`<br>`03_having_clause.sql`<br>`04_grouping_sets_rollup.sql` |
| [`07-joins`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/07-joins) | INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN | `01_inner_join.sql`<br>`02_left_join.sql`<br>`03_right_and_full_outer_join.sql`<br>`04_cross_join.sql`<br>`05_self_join.sql` |
| [`08-subqueries-and-ctes`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/08-subqueries-and-ctes) | Subqueries, correlated queries, CTEs, recursive CTEs | `01_scalar_and_in_subqueries.sql`<br>`02_correlated_subqueries.sql`<br>`03_common_table_expressions.sql`<br>`04_recursive_ctes.sql` |
| [`09-views`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/09-views) | Creating, updating, and managing standard & materialized views | `01_creating_views.sql`<br>`02_modifying_and_updating_views.sql`<br>`03_materialized_views.sql` |
| [`10-indexing-and-performance`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/10-indexing-and-performance) | Indexes, composite indexes, functional indexes, EXPLAIN plans | `01_single_and_composite_indexes.sql`<br>`02_unique_and_partial_indexes.sql`<br>`03_explain_and_query_plans.sql` |
| [`11-window-functions`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/11-window-functions) | **Ranking, Aggregate, and Value Access Window Functions** | `01_ranking_functions.sql`<br>`02_aggregate_window_functions.sql`<br>`03_value_access_functions.sql`<br>`README.md` |
| [`12-transactions`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/12-transactions) | ACID principles, BEGIN, COMMIT, ROLLBACK, SAVEPOINT | `01_acid_principles.sql`<br>`02_commit_and_rollback.sql`<br>`03_savepoints.sql` |
| [`13-advanced-sql`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/13-advanced-sql) | Set operations, EXISTS / NOT EXISTS, SARGability & optimization | `01_set_operations.sql`<br>`02_exists_and_not_exists.sql`<br>`03_query_optimization_techniques.sql` |
| [`14-practice-exercises`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/14-practice-exercises) | Hands-on challenges with solutions | `01_beginner_exercises.sql`<br>`02_intermediate_exercises.sql`<br>`03_advanced_exercises.sql` |
| [`15-database-specific`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/15-database-specific) | PostgreSQL, MySQL, and Oracle dialect-specific extensions | `postgresql/01_postgres_features.sql`<br>`mysql/01_mysql_features.sql`<br>`oracle/01_oracle_features.sql` |

---

## 6. Detailed Window Functions Coverage

Module 11 provides in-depth instruction and runnable queries across all 3 standard window function families:

### 1. Ranking Functions
- **`ROW_NUMBER()`**: Assigns a unique sequential number to each row in the window without ties.
- **`RANK()`**: Assigns a rank to each row, leaving gaps for ties.
- **`DENSE_RANK()`**: Assigns a rank to each row without gaps for ties.
- **`PERCENT_RANK()`**: Computes the relative rank of a row as a percentage (0.0 to 1.0).
- **`NTILE(n)`**: Divides rows into `n` specified groups/buckets (quartiles, deciles).

### 2. Aggregate Functions
- **`AVG()`**: Calculates the average value in the window frame.
- **`MAX()`**: Finds the maximum value in the window frame.
- **`MIN()`**: Finds the minimum value in the window frame.
- **`SUM()`**: Calculates the cumulative running or partition total.
- **`COUNT()`**: Counts the number of rows or non-null values in the window.

### 3. Value Access Functions
- **`LAG()`**: Accesses a value from a previous row in the window.
- **`LEAD()`**: Accesses a value from a subsequent row in the window.
- **`FIRST_VALUE()`**: Returns the first value in the window frame.
- **`LAST_VALUE()`**: Returns the last value in the window frame *(with window frame boundary rules)*.
- **`NTH_VALUE()`**: Returns the value from the nth row in the window frame.

---

## 7. Technologies and Database Systems

This repository includes practical, cross-compatible standard ANSI SQL scripts, with dialect-specific notes and dedicated chapters for:

- **PostgreSQL** (v12+)
- **MySQL** (v8.0+)
- **Oracle Database** (12c / 19c / 21c / 23c)

Each script indicates the database system it supports in its header metadata.

---

## 8. How to Use This Repository

1. Clone or download the repository.
2. Install or connect to your database system (PostgreSQL, MySQL, Oracle, or SQLite).
3. Execute [`sql/00_master_schema_and_data.sql`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/00_master_schema_and_data.sql) to seed the sample tables and data.
4. Progress through the scripts in the recommended learning order.
5. Read the comments explaining query mechanics, execution phases, and performance considerations.
6. Complete the practice questions at the end of each script.
7. Attempt the comprehensive challenges in [`sql/14-practice-exercises/`](file:///e:/Academic%20Teaching%20&%20Course%20Materials/ULK/SQL%20DATABASE/sql-database-teaching-materials/sql/14-practice-exercises).

---

## 9. Recommended Learning Sequence

```
01-database-setup
       │
       ▼
02-tables-and-constraints
       │
       ▼
03-data-manipulation  ──▶  04-filtering-and-sorting  ──▶  05-sql-functions
                                                                 │
                                                                 ▼
08-subqueries-and-ctes  ◀──  07-joins  ◀──  06-aggregate-functions
       │
       ▼
09-views  ──▶  10-indexing-and-performance  ──▶  11-window-functions
                                                         │
                                                         ▼
15-database-specific  ◀──  14-practice-exercises  ◀──  13-advanced-sql  ◀──  12-transactions
```

---

## 10. SQL Script Documentation Standard

Every SQL file in this repository strictly adheres to this documentation format:

```sql
/*
Topic: SELECT Statement
Objective: Retrieve records from a database table.
Database: PostgreSQL / MySQL / Oracle
*/

-- 1. Concept Overview & Explanations

-- 2. SQL Examples with Comments
SELECT student_id, first_name, email
FROM students
WHERE student_id > 5;

-- 3. Practice Questions / Exercises
-- Exercise 1: ...
```

---

## 11. Important Notes & Best Practices

- Always understand a query and verify its execution plan before executing it on production datasets.
- Test `UPDATE` and `DELETE` predicates with a `SELECT` query first to avoid accidental bulk changes.
- Use explicit transactions (`START TRANSACTION` / `BEGIN`) with `COMMIT` and `ROLLBACK` for multi-step state mutations.
- Be aware of the Three-Valued Logic (3VL) of `NULL` in comparisons, `NOT IN`, and window functions.
- Never commit passwords, connection strings, or sensitive operational credentials to version control.

---

## 12. Contributions

Learners and faculty members can improve this repository by adding examples, exercises, explanations, and corrections while adhering to the established folder layout and script documentation header format.

---

## 13. License

This project is distributed under the [MIT License](LICENSE).# SQL-Developer
