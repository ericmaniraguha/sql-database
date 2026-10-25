# Module 16: Database Connections and Python

So far you have typed SQL into pgAdmin. Real applications (a student portal, a finance system, a data report) send SQL from **program code**. This module explains how any program connects to PostgreSQL, then shows how to do it from **Python**: run queries, pass values safely, use transactions, and build reports with pandas.

| File | What you learn |
|---|---|
| [`01_connection_info.sql`](01_connection_info.sql) | Inspect your own connection: database, user, server, other sessions, limits, privileges |
| [`python/db.py`](python/db.py) | Shared connection settings, read from a `.env` file (used by every script) |
| [`python/01_connect_and_query.py`](python/01_connect_and_query.py) | Connect with **psycopg**, run `SELECT`, read rows as tuples and dictionaries |
| [`python/02_parameterized_queries.py`](python/02_parameterized_queries.py) | Pass values with `%s`, see a real **SQL injection**, build dynamic SQL safely |
| [`python/03_transactions_and_errors.py`](python/03_transactions_and_errors.py) | `COMMIT` / `ROLLBACK` from Python, catch constraint errors by type, savepoints |
| [`python/04_reports_with_pandas.py`](python/04_reports_with_pandas.py) | Load results into **pandas**, pivot them, export a CSV report |

---

## 1. What Is a Connection?

```
  your program            network             PostgreSQL server
 ┌──────────────┐   host + port (5432)   ┌──────────────────────────┐
 │ pgAdmin      │ ─────────────────────▶ │ checks user + password   │
 │ psql         │                        │ opens ONE database:      │
 │ Python       │ ◀───────────────────── │   ulk_university_db      │
 └──────────────┘     rows / errors      └──────────────────────────┘
```

A connection is a **session**: it logs in as one user, works in one database, and has its own transaction. Every connection needs the same five values:

| Value | Our course setting | Meaning |
|---|---|---|
| host | `localhost` | the computer the server runs on (`localhost` = this computer) |
| port | `5432` | PostgreSQL's default port |
| database | `ulk_university_db` | created in module 01 |
| user | `ulk_admin` | the course login from module 01 (`postgres` is the administrator) |
| password | your own | set when the user was created |

### Connection strings

The same five values can be written as one string:

```text
URI:        postgresql://ulk_admin:PASSWORD@localhost:5432/ulk_university_db
Key/value:  host=localhost port=5432 dbname=ulk_university_db user=ulk_admin password=PASSWORD
SQLAlchemy: postgresql+psycopg://ulk_admin:PASSWORD@localhost:5432/ulk_university_db
```

In a URI, special characters in the password must be encoded (`@` becomes `%40`). `db.py` does this for you.

---

## 2. Connecting with Tools

| Tool | How |
|---|---|
| **psql** (terminal) | `psql -h localhost -p 5432 -U ulk_admin -d ulk_university_db` |
| **pgAdmin** | *Register → Server*. On the **Connection** tab enter host, port, maintenance database, username, and password. |
| **DBeaver / VS Code** | *New connection → PostgreSQL*, then the same five values |

Once connected, run [`01_connection_info.sql`](01_connection_info.sql) to see exactly who and where you are.

---

## 3. Before You Start: Give `ulk_admin` Access

The Python scripts log in as `ulk_admin`, which can only read tables it has been **granted**. As `postgres`, **connected to `ulk_university_db`**, make sure that:

1. The sample database is loaded, **views included**: run [`../00_master_schema_and_data.sql`](../00_master_schema_and_data.sql). If you built it with the module 02/03 files, also run [`../09-views/01_creating_views.sql`](../09-views/01_creating_views.sql).
2. **PHASE 2** of [`../01-database-setup/02_create_user_and_permissions.sql`](../01-database-setup/02_create_user_and_permissions.sql) has been run *in this database*. It grants access to the existing tables and sets default privileges, so tables recreated later by `postgres` are covered too.

Check it (as `postgres`):

```sql
SELECT has_table_privilege('ulk_admin', 'students', 'SELECT');   -- must be true
```

---

## 4. Connecting from Python

### Setup (once)

From the repository folder, in a terminal:

```bash
cd sql/16-database-connections/python

python -m venv .venv                 # a private folder for this project's libraries
.venv\Scripts\activate               # Windows
# source .venv/bin/activate          # macOS / Linux

pip install -r requirements.txt      # psycopg, SQLAlchemy, pandas, python-dotenv

copy .env.example .env               # Windows   (macOS / Linux: cp .env.example .env)
```

Open `.env` and replace `change-me` with the password of `ulk_admin`. Then run the scripts in order:

```bash
python 01_connect_and_query.py
python 02_parameterized_queries.py 2023CS014
python 03_transactions_and_errors.py
python 04_reports_with_pandas.py
```

The scripts need Python 3.10 or newer. Script 03 rolls back every change it makes, so your sample data stays the same. Script 04 writes its report to `python/output/`.

### The libraries

| Library | Role |
|---|---|
| [psycopg 3](https://www.psycopg.org/psycopg3/docs/) | The PostgreSQL **driver**: it opens connections and sends SQL |
| [SQLAlchemy](https://docs.sqlalchemy.org/) | An **engine** that manages connections; pandas uses it |
| [pandas](https://pandas.pydata.org/docs/) | Tables of data in Python: pivot, group, export to CSV / Excel |
| [python-dotenv](https://pypi.org/project/python-dotenv/) | Loads the settings in `.env` into the program |

### The pattern every script follows

```python
from db import get_connection

with get_connection() as conn:                     # open; always closed at the end
    rows = conn.execute(
        "SELECT first_name, last_name FROM students WHERE program_id = %s",
        (1,),                                      # values go here, never into the SQL text
    ).fetchall()
# leaving the block: COMMIT if no error, ROLLBACK if there was one
```

---

## 5. Rules for Safe Database Code

1. **Never write a password in code.** Keep it in `.env` (already in `.gitignore`) or in environment variables.
2. **Never build SQL from user input** with f-strings or `+`. Pass values as parameters (`%s`, `%(name)s`, or `:name` in SQLAlchemy). Script 02 shows an attack leaking every student's record.
3. **Use the smallest set of rights.** Applications log in as `ulk_admin`, not `postgres`; a reporting tool only needs a read-only role.
4. **Always close connections.** Use `with` blocks; a server only accepts a limited number of connections (`SHOW max_connections`).
5. **Keep transactions short, and commit on purpose.** psycopg starts a transaction automatically, and nothing is saved until it commits.

---

## 6. Troubleshooting

| You see | Usual cause | Fix |
|---|---|---|
| `connection refused` / `connection timeout expired` | PostgreSQL is not running, or wrong host / port | Start the PostgreSQL service (Windows: *Services → postgresql-x64-15*); check `PGHOST`, `PGPORT` |
| `password authentication failed for user "ulk_admin"` | Wrong password or user name | Fix `.env`; reset it as postgres: `ALTER ROLE ulk_admin PASSWORD '...';` |
| `database "ulk_university_db" does not exist` | Database not created, or a typo | Run `01-database-setup/01_create_database.sql`; check `PGDATABASE` |
| `permission denied for table students` | `ulk_admin` was never granted access in this database | Section 3 above: run PHASE 2 of `02_create_user_and_permissions.sql` |
| `relation "student_gpa" does not exist` | The views were not created | Run `00_master_schema_and_data.sql` or `09-views/01_creating_views.sql` |
| `ModuleNotFoundError: No module named 'psycopg'` | Libraries not installed, or the virtual environment is not active | Activate `.venv`, then `pip install -r requirements.txt` |
| `FATAL: sorry, too many clients already` | Programs leaving connections open | Use `with` blocks; close idle sessions (`01_connection_info.sql`, section 3) |

Note: on a personal laptop PostgreSQL is often set to `trust` local connections, which means **any** password (or none) is accepted. On a shared server it asks for a real password. `01_connection_info.sql`, section 6, shows how to see which rule applies.

---

## 7. Practice Exercises

1. Write a script that asks for a registration number with `input()` and prints that student's transcript from `final_grades`, using a `%s` parameter.
2. Write a script that saves every student who owes money (`student_balances`) to `output/debtors.csv`, sorted by the amount owed.
3. Write a function `record_payment(conn, invoice_id, amount, method)` that inserts a payment inside `conn.transaction()` and refuses it (rolls back) if the balance would go below zero.
4. Create a read-only role `ulk_reader`, put it in `.env`, and run script 03. Which error class does psycopg raise, and in which section?
