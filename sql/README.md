# SQL Teaching & Practice Modules Roadmap

Welcome to the **ULK SQL Databases Learning & Practice** curriculum. This directory contains 15 sequentially organized learning modules covering relational database concepts from foundational queries to advanced query engineering.

---

## 🚀 Quick Start: 1-Click Database Setup

Before running queries in any module, initialize the full ULK University database schema and sample dataset:

```bash
# PostgreSQL
psql -U postgres -d ulk_university_db -f sql/00_master_schema_and_data.sql

# MySQL
mysql -u root -p ulk_university_db < sql/00_master_schema_and_data.sql
```

This single script sets up:
- **`departments`**: Academic faculties, budgets, and campus buildings
- **`instructors`**: Faculty members, academic ranks, salaries, and mentorship links
- **`students`**: Student demographics, GPAs, and enrollment status
- **`courses`**: Course catalog, credits, and department allocations
- **`course_prerequisites`**: Course dependencies (hierarchical self-joins)
- **`enrollments`**: Student course registrations, numeric grades, and letter grades

---

## 📂 Curriculum Structure

| Module | Title | Primary Topics | Key Scripts |
|---|---|---|---|
| **01** | `01-database-setup` | Database Creation & System Catalogs | `01_create_database.sql`, `02_schema_overview.sql` |
| **02** | `02-tables-and-constraints` | DDL, Data Types, Primary/Foreign Keys, Constraints | `01_create_tables.sql`, `02_primary_foreign_keys.sql`, `03_check_unique_constraints.sql`, `04_alter_tables.sql` |
| **03** | `03-data-manipulation` | CRUD Operations & DML | `01_insert_records.sql`, `02_select_basics.sql`, `03_update_records.sql`, `04_delete_records.sql`, `05_truncate_tables.sql` |
| **04** | `04-filtering-and-sorting` | Predicates, Ranges, Patterns & Pagination | `01_where_and_or_not.sql`, `02_comparison_and_between.sql`, `03_in_and_like_pattern_matching.sql`, `04_null_handling.sql`, `05_order_by_and_pagination.sql` |
| **05** | `05-sql-functions` | Scalar String, Math, Date & CASE Expressions | `01_string_functions.sql`, `02_numeric_functions.sql`, `03_date_time_functions.sql`, `04_null_functions.sql`, `05_conditional_case_expressions.sql` |
| **06** | `06-aggregate-functions` | Aggregates, GROUP BY, HAVING, ROLLUP | `01_basic_aggregates.sql`, `02_group_by.sql`, `03_having_clause.sql`, `04_grouping_sets_rollup.sql` |
| **07** | `07-joins` | INNER, LEFT, RIGHT, FULL, CROSS & SELF JOINs | `01_inner_join.sql`, `02_left_join.sql`, `03_right_and_full_outer_join.sql`, `04_cross_join.sql`, `05_self_join.sql` |
| **08** | `08-subqueries-and-ctes` | Subqueries, Correlated Queries & CTEs | `01_scalar_and_in_subqueries.sql`, `02_correlated_subqueries.sql`, `03_common_table_expressions.sql`, `04_recursive_ctes.sql` |
| **09** | `09-views` | Virtual Tables, Updatable Views & Materialized Views | `01_creating_views.sql`, `02_modifying_and_updating_views.sql`, `03_materialized_views.sql` |
| **10** | `10-indexing-and-performance` | B-Trees, Composite Indexes & EXPLAIN Plans | `01_single_and_composite_indexes.sql`, `02_unique_and_partial_indexes.sql`, `03_explain_and_query_plans.sql` |
| **11** | `11-window-functions` | Analytical Ranks, Partitions, Value Access & Running Aggregates | `01_ranking_functions.sql`, `02_aggregate_window_functions.sql`, `03_value_access_functions.sql` |
| **12** | `12-transactions` | ACID Properties, COMMIT, ROLLBACK & SAVEPOINTS | `01_acid_principles.sql`, `02_commit_and_rollback.sql`, `03_savepoints.sql` |
| **13** | `13-advanced-sql` | Set Operations, EXISTS Semi-Joins & Query Tuning | `01_set_operations.sql`, `02_exists_and_not_exists.sql`, `03_query_optimization_techniques.sql` |
| **14** | `14-practice-exercises` | Graded Hands-on Problem Sets with Solutions | `01_beginner_exercises.sql`, `02_intermediate_exercises.sql`, `03_advanced_exercises.sql` |
| **15** | `15-database-specific` | Dialect Deep Dives | `postgresql/01_postgres_features.sql`, `mysql/01_mysql_features.sql`, `oracle/01_oracle_features.sql` |

---

## 🎯 Script Standards

Every `.sql` script strictly follows the documentation header standard:

```sql
/*
Topic: <Topic Name>
Objective: <Learning Objective>
Database: PostgreSQL / MySQL / Oracle
*/
```

Each script contains:
1. **Conceptual explanations** breaking down relational theory and mechanics.
2. **Runnable, tested SQL queries** on the shared ULK University schema.
3. **Important notes and caveats** (NULL traps, operator precedence, indexing trade-offs).
4. **End-of-script Practice Questions** for classroom assignments and self-study.
