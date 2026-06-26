# CSV → SQL Server Loader

A small, reusable **data-engineering utility** that loads a CSV file into a
Microsoft SQL Server table. It auto-detects the file's text encoding, reads the
data with pandas, then inserts every row into the database with live progress
tracking — the kind of repeatable ingestion step that sits at the start of most
analytics and reporting pipelines.

> **Tools:** Python (pandas, NumPy, pyodbc) · Microsoft SQL Server (T-SQL) · Jupyter
> **Skills:** ETL · data ingestion · encoding handling · parameterised SQL · database connectivity

**Dataset:** a small, **synthetic** `sample_customers.csv` (200 rows of `name, age`)
is bundled so the project runs out of the box. It is fictional — generated purely
to demonstrate the loader end-to-end. The tool itself works with **any** CSV (see
[Adapting it to your own CSV](#adapting-it-to-your-own-csv)).

---

## Table of Contents
- [What It Does](#what-it-does)
- [Repository Structure](#repository-structure)
- [How It Works](#how-it-works)
- [How to Reproduce](#how-to-reproduce)
- [Adapting It to Your Own CSV](#adapting-it-to-your-own-csv)
- [Notes & Caveats](#notes--caveats)

---

## What It Does

Getting raw CSV files into a database reliably is a deceptively fiddly job — files
arrive in different encodings, and a naive `read_csv` throws on the first odd
character. This loader handles that gracefully and gets the data into SQL Server:

- **Encoding auto-detection** — tries `utf-8`, `latin1`, `iso-8859-1`, `cp1252`
  and `windows-1252` in turn, so files exported from Excel or legacy systems load
  without manual fiddling.
- **Quick data check** — prints the row/column count and a preview before writing
  anything, so you can confirm the load looks right.
- **Parameterised inserts** — rows are inserted with `?` placeholders (pyodbc),
  not string-built SQL, which avoids SQL-injection and quoting issues.
- **Progress tracking** — prints progress every 100 rows so large files don't look
  frozen, and commits the transaction at the end.
- **Windows authentication** — connects with a trusted connection by default (no
  passwords in the notebook).

---

## Repository Structure

```
CSV-to-SQL-Loader/
├── notebooks/
│   └── CSV Data Insert.ipynb     # the loader, step by step
├── data/
│   └── sample_customers.csv      # synthetic demo data (name, age)
├── sql/
│   └── 00_create_table.sql       # creates the database + destination table
├── .env.example                  # reference for the connection settings
├── requirements.txt              # Python dependencies
├── .gitignore
├── LICENSE
└── README.md
```

---

## How It Works

The notebook runs top to bottom in five short stages:

1. **Import libraries** — pandas, NumPy, pyodbc.
2. **Load the CSV** — `read_raw_data()` loops through a list of encodings and
   returns the first one that reads cleanly as a DataFrame.
3. **Check the data** — `df.shape` and `df.head()` confirm what was loaded.
4. **Connect to SQL Server** — a pyodbc connection using the ODBC Driver 17 and
   Windows authentication.
5. **Insert the rows** — iterate the DataFrame, run a parameterised `INSERT` per
   row, print progress every 100 rows, then `commit()` and close the connection.

---

## How to Reproduce

**Prerequisites**
- Python 3.9+
- Microsoft SQL Server (Express edition is fine) + [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
- SQL Server Management Studio (SSMS), or any way to run a `.sql` script

**Steps**

1. **Clone the repo and install dependencies**
   ```bash
   git clone https://github.com/ObbieKalenga/CSV-to-SQL-Loader.git
   cd CSV-to-SQL-Loader
   pip install -r requirements.txt
   ```

2. **Create the database and table** — run [`sql/00_create_table.sql`](sql/00_create_table.sql)
   in SSMS. It creates the `CSV_Loader_Demo` database and a `dbo.customer_age`
   table matching the sample CSV.

3. **Update the connection** — open [`notebooks/CSV Data Insert.ipynb`](notebooks/CSV%20Data%20Insert.ipynb)
   and, in the *Connect to SQL Server* cell, set `Server=` to your own SQL Server
   instance name (and `Database=` if you changed it). See [`.env.example`](.env.example)
   for the settings involved.

4. **Run all cells.** The notebook loads `data/sample_customers.csv` and inserts
   the 200 rows. You should see:
   ```
   Inserting rows 100/200...
   Inserting rows 200/200...
   Done! Obbie you have Inserted 200 rows.
   ```

5. **Confirm in SQL Server**
   ```sql
   SELECT COUNT(*) FROM dbo.customer_age;   -- 200
   SELECT TOP (10) * FROM dbo.customer_age;
   ```

---

## Adapting It to Your Own CSV

The loader is meant to be reused. To point it at a different file:

1. Drop your CSV in `data/` and update the `file_path` in the notebook.
2. Create a destination table whose columns match your CSV (edit
   [`sql/00_create_table.sql`](sql/00_create_table.sql)).
3. In the *Insert rows* cell, update the table name, the column list, the
   `VALUES (?, ?)` placeholders, and the `row.<column>` values so they match your
   columns.

That's it — the encoding detection, progress tracking and connection logic stay
the same.

---

## Notes & Caveats

- **The bundled data is synthetic** and for skills-demonstration only.
- The loader inserts **row by row**, which is simple and easy to follow but not
  the fastest path for very large files. For millions of rows, a bulk approach
  (`BULK INSERT`, `bcp`, or `fast_executemany`) would be the next step.
- The connection uses **Windows (trusted) authentication**. For SQL
  authentication, swap `Trusted_Connection=yes;` for `UID=...;PWD=...;` and keep
  those credentials in a git-ignored `.env` rather than in the notebook.
- No real server names or credentials are committed to this repo.

---

**Author:** Obbie Kalenga · [github.com/ObbieKalenga](https://github.com/ObbieKalenga)
