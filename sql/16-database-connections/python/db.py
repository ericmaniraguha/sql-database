"""
================================================================================
Shared connection settings for the Python lessons in module 16.

The five connection values (host, port, database, user, password) are read
from environment variables. The easiest way to set them is a .env file next
to this script: copy .env.example to .env and type your own password in it.
.env is listed in .gitignore, so your password never reaches GitHub.
================================================================================
"""
import os
from pathlib import Path
from urllib.parse import quote_plus

import psycopg

try:                                    # python-dotenv reads the .env file
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).with_name(".env"))
except ImportError:                     # without it, set the variables yourself
    pass

SETTINGS = {
    "host":     os.getenv("PGHOST", "localhost"),
    "port":     int(os.getenv("PGPORT", "5432")),
    "dbname":   os.getenv("PGDATABASE", "ulk_university_db"),
    "user":     os.getenv("PGUSER", "ulk_admin"),
    "password": os.getenv("PGPASSWORD"),      # None: PostgreSQL tries ~/.pgpass
}


def get_connection(**options) -> psycopg.Connection:
    """Open a new connection. Use it in a `with` block so it is always closed."""
    params = {key: value for key, value in SETTINGS.items() if value is not None}
    return psycopg.connect(
        **params,
        application_name="ulk-sql-course",   # shows up in pg_stat_activity
        connect_timeout=5,                    # seconds before giving up
        **options,
    )


def sqlalchemy_url() -> str:
    """The same settings as a SQLAlchemy URL (used with pandas in script 04)."""
    s = SETTINGS
    password = f":{quote_plus(s['password'])}" if s["password"] else ""
    return f"postgresql+psycopg://{quote_plus(s['user'])}{password}@{s['host']}:{s['port']}/{s['dbname']}"


def describe() -> str:
    """Where we are connecting, without the password: user@host:port/database."""
    s = SETTINGS
    return f"{s['user']}@{s['host']}:{s['port']}/{s['dbname']}"


def connection_help(error: Exception) -> str:
    """Turn the most common connection errors into a hint for the student."""
    message = str(error)
    if "password authentication failed" in message:
        return "Wrong user or password. Check PGUSER and PGPASSWORD in your .env file."
    if "no password supplied" in message:
        return "No password given. Copy .env.example to .env and fill in PGPASSWORD."
    if "does not exist" in message and "database" in message:
        return "Check PGDATABASE, or create the database first (module 01)."
    if "Connection refused" in message or "could not connect" in message or "timeout" in message:
        return "Is the PostgreSQL service running? Check PGHOST and PGPORT."
    return "See the troubleshooting table in this module's README.md."


def print_table(rows, headers) -> None:
    """Print query results as a small aligned text table."""
    rows = [list(row.values()) if isinstance(row, dict) else list(row) for row in rows]
    text = [["" if value is None else str(value) for value in row] for row in rows]
    widths = [max([len(header)] + [len(row[i]) for row in text]) for i, header in enumerate(headers)]
    print("  ".join(header.ljust(width) for header, width in zip(headers, widths)))
    print("  ".join("-" * width for width in widths))
    for row in text:
        print("  ".join(value.ljust(width) for value, width in zip(row, widths)))
    print(f"({len(rows)} row{'' if len(rows) == 1 else 's'})\n")


def show(cursor) -> None:
    """Print every remaining row of the cursor's last query, with column names."""
    print_table(cursor.fetchall(), [column.name for column in cursor.description])


def run(main) -> None:
    """Run a lesson's main() and explain the usual setup problems in plain words."""
    try:
        main()
    except psycopg.OperationalError as error:
        print(f"Could not connect as {describe()}\n\n{error}\nHint: {connection_help(error)}")
        raise SystemExit(1)
    except psycopg.errors.InsufficientPrivilege as error:
        print(f"Connected as {describe()}, but: {error}\n"
              f"Hint: this user has not been given access to the tables yet. As postgres,\n"
              f"connected to {SETTINGS['dbname']}, run PHASE 2 of\n"
              f"sql/01-database-setup/02_create_user_and_permissions.sql.")
        raise SystemExit(1)
    except psycopg.errors.UndefinedTable as error:
        print(f"Connected as {describe()}, but: {error}\n"
              f"Hint: load the sample database with sql/00_master_schema_and_data.sql\n"
              f"(or, for the three views only, run sql/09-views/01_creating_views.sql).")
        raise SystemExit(1)
