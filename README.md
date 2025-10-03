# Advanced SQL with Postgres — Course slides and sample SQL

These slides and example SQL files are for the class "Advanced SQL with Postgres" taught in October 2025 at the Digital Learning Hub Luxembourg (https://www.dlh.lu).

Repository contents

- `DLH - Advanced SQL - Oct 2025.pdf` — Slides for the course.
- `setup.sql` — Database setup script to create the sample schema and data used in the exercises.
- `dlh1.sql`, `dlh3.sql`, `dlh3_data_set.sql`, `dlh4_data_set.sql`, `dlh5.sql` — Example queries and exercise files referenced by the slides.

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

Note about examples

These examples assume you have run `setup.sql` and the sample data has been created. Actual output may vary depending on which statements from the scripts you executed.

Example output (illustrative)

Simple query — list customer first names (example output):

```
 first_name
-----------
 Jeff
 Jean
 Jimmy
 Renee
 Pierre
 Jemp
 Pol
```

Join example — order details with extended price (example output):

```
 order_id | order_date  |  customer_name  |      product_name       | unit_price | order_qty | extended_price
----------+-------------+-----------------+-------------------------+------------+-----------+----------------
        1 | 2025-09-23  | Mueller, Jeff   | Hammer 200gr            |      19.95 |         1 |          19.95
        2 | 2025-09-23  | Mueller, Jeff   | Hammer 1kg              |      25.00 |         1 |          25.00
        3 | 2025-09-22  | Bintner, Jean   | Chisel stone            |      39.95 |         2 |          79.90
        4 | 2025-03-01  | Bintner, Jean   | Pliers red, adjustable  |      13.50 |         4 |          54.00
```

These outputs are illustrative — the exact rows, ids and dates depend on which setup steps were executed and the order of operations when you ran `setup.sql`.

Examples

Below are two short example commands taken from `dlh1.sql` you can run after the setup script has created the sample data.

Simple query — list customer first names:

```sql
-- List all customer first names
SELECT first_name FROM mycustomer;
```

Join example — order details with extended price:

```sql
-- Order details with calculated extended price
SELECT
  o.id AS order_id,
  o.date AS order_date,
  FORMAT('%s, %s', last_name, first_name) AS customer_name,
  p.name AS product_name,
  p.price AS unit_price,
  o.qty AS order_qty,
  o.qty * p.price AS extended_price
FROM myorder o
JOIN myproduct p ON o.product_nbr = p.nbr
JOIN mycustomer c ON o.customer_id = c.id
ORDER BY order_date ASC;
```

License

See the `LICENSE` file in this repository for license details.

If you want any edits to the slides or additional walkthrough files, open an issue or send a pull request.