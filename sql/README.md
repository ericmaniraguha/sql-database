# SQL Teaching & Practice Modules Roadmap

Welcome to the **ULK SQL Databases Learning & Practice** curriculum. This folder contains 16 modules, from creating a database to advanced queries, transactions, and connecting from Python. Every module uses the same sample database, `ulk_university_db`.

For the full picture of the database (tables, design rules, sample data), see the [main README](../README.md).

---

## 🚀 Quick Start

The scripts are written for **PostgreSQL 12+** (tested with PostgreSQL 15 and pgAdmin 4).

1. Create the database once: run [`01-database-setup/01_create_database.sql`](01-database-setup/01_create_database.sql) while connected to the `postgres` database.
2. Load the tables, views, and sample data:

   ```bash
   psql -U postgres -d ulk_university_db -f sql/00_master_schema_and_data.sql
   ```

   or, in pgAdmin, open [`00_master_schema_and_data.sql`](00_master_schema_and_data.sql) in a Query Tool on `ulk_university_db` and press **F5**.
3. Using the `ulk_admin` login (pgAdmin with that user, or the Python scripts in module 16)? Run **PHASE 2** of [`01-database-setup/02_create_user_and_permissions.sql`](01-database-setup/02_create_user_and_permissions.sql) while connected to `ulk_university_db`.

Run the master script again at any time to reset the sample data.

### What the master script builds

| Area | Tables |
|---|---|
| Academic structure | `faculties`, `departments`, `programs`, `academic_terms` |
| People | `lecturers`, `department_heads`, `students` |
| Teaching | `courses`, `course_prerequisites`, `course_offerings`, `enrollments` |
| Grades | `grade_scale`, `assessments`, `assessment_scores` |
| Finance | `fee_structures`, `invoices`, `invoice_items`, `payments`, `scholarships`, `student_scholarships`, `salary_payments` |
| Views | `final_grades`, `student_gpa`, `student_balances` |

---

## 📂 Curriculum Structure

| Module | Folder | Topics | Scripts |
|---|---|---|---|
| **01** | [`01-database-setup`](01-database-setup) | Creating the database, users and permissions, the system catalog | `01_create_database.sql`, `02_create_user_and_permissions.sql`, `03_schema_overview.sql` |
| **02** | [`02-tables-and-constraints`](02-tables-and-constraints) | Data types, primary and foreign keys, constraints, `ALTER TABLE` | `00_drop_tables_if_needed.sql`, `01_create_tables.sql`, `02_primary_foreign_keys.sql`, `03_check_unique_constraints.sql`, `04_alter_tables.sql` |
| **03** | [`03-data-manipulation`](03-data-manipulation) | `INSERT`, `SELECT`, `UPDATE`, `DELETE`, `TRUNCATE` | `01_insert_records.sql`, `02_select_basics.sql`, `03_update_records.sql`, `04_delete_records.sql`, `05_truncate_tables.sql` |
| **04** | [`04-filtering-and-sorting`](04-filtering-and-sorting) | All SQL operators at a glance; `WHERE`, ranges, `IN`, `LIKE`, `NULL`, sorting, pagination | `00_sql_operators_reference.sql`, `01_where_and_or_not.sql`, `02_comparison_and_between.sql`, `03_in_and_like_pattern_matching.sql`, `04_null_handling.sql`, `05_order_by_and_pagination.sql` |
| **05** | [`05-sql-functions`](05-sql-functions) | String, numeric, date, and `NULL` functions; `CASE` | `01_string_functions.sql`, `02_numeric_functions.sql`, `03_date_time_functions.sql`, `04_null_functions.sql`, `05_conditional_case_expressions.sql` |
| **06** | [`06-aggregate-functions`](06-aggregate-functions) | Aggregates, `GROUP BY`, `HAVING`, `ROLLUP`, `CUBE`, `GROUPING SETS` | `01_basic_aggregates.sql`, `02_group_by.sql`, `03_having_clause.sql`, `04_grouping_sets_rollup.sql` |
| **07** | [`07-joins`](07-joins) | `INNER`, `LEFT`, `RIGHT`, `FULL`, `CROSS`, and self joins | `01_inner_join.sql`, `02_left_join.sql`, `03_right_and_full_outer_join.sql`, `04_cross_join.sql`, `05_self_join.sql` |
| **08** | [`08-subqueries-and-ctes`](08-subqueries-and-ctes) | Subqueries, correlated subqueries, CTEs, recursive CTEs | `01_scalar_and_in_subqueries.sql`, `02_correlated_subqueries.sql`, `03_common_table_expressions.sql`, `04_recursive_ctes.sql` |
| **09** | [`09-views`](09-views) | Views, updatable views, materialized views | `01_creating_views.sql`, `02_modifying_and_updating_views.sql`, `03_materialized_views.sql` |
| **10** | [`10-indexing-and-performance`](10-indexing-and-performance) | Indexes and `EXPLAIN` plans | `01_single_and_composite_indexes.sql`, `02_unique_and_partial_indexes.sql`, `03_explain_and_query_plans.sql` |
| **11** | [`11-window-functions`](11-window-functions) | Ranking, aggregate, and value-access window functions | `01_ranking_functions.sql`, `02_aggregate_window_functions.sql`, `03_value_access_functions.sql` |
| **12** | [`12-transactions`](12-transactions) | ACID, isolation levels, `COMMIT`, `ROLLBACK`, `SAVEPOINT` | `01_acid_principles.sql`, `02_commit_and_rollback.sql`, `03_savepoints.sql` |
| **13** | [`13-advanced-sql`](13-advanced-sql) | Set operations, `EXISTS`, query optimization | `01_set_operations.sql`, `02_exists_and_not_exists.sql`, `03_query_optimization_techniques.sql` |
| **14** | [`14-practice-exercises`](14-practice-exercises) | Graded problem sets with solutions | `01_beginner_exercises.sql`, `02_intermediate_exercises.sql`, `03_advanced_exercises.sql` |
| **15** | [`15-database-specific`](15-database-specific) | PostgreSQL, MySQL, and Oracle features | `postgresql/01_postgres_features.sql`, `mysql/01_mysql_features.sql`, `oracle/01_oracle_features.sql` |
| **16** | [`16-database-connections`](16-database-connections) | Connection settings; Python with psycopg, SQL injection, transactions, pandas | `01_connection_info.sql`, `python/01_connect_and_query.py`, `python/02_parameterized_queries.py`, `python/03_transactions_and_errors.py`, `python/04_reports_with_pandas.py` |

---

## 🎯 Script Standards

Every `.sql` script starts with the same header:

```sql
/*
================================================================================
Topic: <Topic Name>
Objective: <What the student will be able to do>
Database: PostgreSQL (pgAdmin)
          MySQL / Oracle: <differences, if any>
================================================================================
*/
```

The Python scripts in module 16 use the same header as a docstring, plus a `Run:` line.

Each script contains:

1. A **Concept Overview** explaining the idea and its syntax.
2. **Numbered sections** of runnable examples on the shared database, with the expected result in a comment (e.g. `-- 4 rows`).
3. Statements that are **meant to fail**, commented out with the error you should see.
4. **Practice Exercises** at the end.

Every lesson must run from top to bottom without errors on a freshly loaded database, both one query at a time and as a whole file (pgAdmin **F5**). It must leave the sample data unchanged: changes are demonstrated inside `BEGIN; … ROLLBACK;`.
