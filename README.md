# DLH Advanced SQL

This repository contains material for a PostgreSQL and PostGIS-focused advanced SQL course, with hands-on examples for data modeling, recursion, window functions, GIS analysis, and database setup.

## What is in this repo?

- `setup.sql` builds the course databases and loads the sample data.
- `setup/` contains the schema and seed data for the main training database.
- `class/` contains SQL exercises and examples by topic.
- `cnt_adv_sql/` contains Docker-based setup assets.
- `raw_data/` contains source files used for the data import examples.
- `bup/` contains backup files and historical snapshots.

## Course topics

The examples cover:

- SQL recap and fundamentals
- Recursive CTEs
- JSONB usage
- Window functions
- PostGIS and geospatial queries
- Dataset setup and practical SQL exercises

## Databases created by setup.sql

Running the setup script creates these databases:

- `dlh_adv_sql`
- `rec_cte`
- `gis_sample`
- `acid_test`

The script also enables PostgreSQL extensions such as PostGIS.

## Prerequisites

- PostgreSQL 18 or newer
- PostGIS extension installed
- `psql` available on your system

## Quick start

From the repository root, run:

```bash
psql -h localhost -U postgres -d postgres -f setup.sql
```

If your database user differs, adapt the connection parameters accordingly.

## Repository layout

```text
.
├── LICENSE
├── README.md
├── setup.sql
├── setup/
│   ├── address.sql
│   ├── address-data.sql
│   ├── canton.sql
│   ├── canton-data.sql
│   ├── customer.sql
│   ├── product.sql
│   ├── purchase.sql
│   ├── store.sql
│   ├── rec_cte_dataset.sql
│   ├── gis_sample.sql
│   └── ...
├── class/
│   ├── 01-recap.sql
│   ├── 02-rec_cte.sql
│   ├── 03-JSONB.sql
│   ├── 04-window_function.sql
│   └── 05-gis.sql
├── raw_data/
├── bup/
├── cnt_adv_sql/
└── ...
```

## License

This project is licensed under the Creative Commons Attribution 4.0 International License. See [LICENSE](LICENSE) for details.

