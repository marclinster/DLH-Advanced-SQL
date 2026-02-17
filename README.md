# Advanced SQL with Postgres — Course slides and sample SQL

These slides and example SQL files are for the class "Advanced SQL with Postgres" taught in October 2025 and February 2026
at the Digital Learning Hub Luxembourg (https://www.dlh.lu).

Repository contents

- `DLH - Advanced SQL - March 2026.pdf` — Slides for the course.
- `setup.sql` — Database setup script to create the sample schema and data used in the exercises.
- `dlh1.sql`, `dlh2.sql`, `dlh3.sql`, `dlh3_data_set.sql`, `dlh4.sql`,`dlh4_data_set.sql`, `dlh5.sql` — Example queries and exercise files referenced by the slides.

Quick start

1. The content was tested on PostgreSQL 17 and 18
2. Ensure you have PostgreSQL installed and running.
2. From a shell (connected as a superuser or a role with sufficient privileges) run the setup script against the `postgres` database:

```sh
# connect as the postgres superuser and run the setup script
psql -d postgres -U postgres -f setup.sql
```

Notes

- The slides are intended for an intermediate-to-advanced audience familiar with basic SQL concepts and PostgreSQL.
- If you run into permission issues when running `setup.sql`, either connect as the database superuser or run the necessary `CREATE` statements with an elevated role.


```

License

See the `LICENSE` file in this repository for license details.

If you want any edits to the slides or additional walkthrough files, open an issue or send a pull request.