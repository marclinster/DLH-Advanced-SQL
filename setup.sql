/*****************************************************************************************************

Database setup script for the DLH Advanced SQL course. This script will 
* create new databases called dlh_adv_sql, rec_cte, gis_sample, and acid_test.
* add the postgis and plpython3u extensions, and load the necessary tables and data for the course.

This couse requires PostgreSQL 18 or higher, with the PostGIS extension installed. 
The course will use the databases dlh_adv_sql, rec_cte, gis_sample, and acid_test.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/



\set ON_ERROR_STOP true

\c postgres

-- create the database dlh_adv_sql and enable PostGIS extension

DROP DATABASE IF EXISTS dlh_adv_sql WITH (FORCE);
CREATE DATABASE dlh_adv_sql;

COMMENT ON DATABASE dlh_adv_sql IS 'Database for the DLH Advanced SQL course. Created by Marc Linster, 2026';

\c dlh_adv_sql;

CREATE EXTENSION IF NOT EXISTS postgis;

\echo 'Database dlh_adv_sql created and PostGIS extension enabled'

\echo 'Setting up tables and populating them with some random data'
-- set up address table 
\i setup/address.sql
\i setup/address-data.sql

\echo 'Setting up cantons and populating them with data'
-- set up canton table
\i setup/canton.sql
\i setup/canton-data.sql

\echo 'Setting up customer table and populating it with some random data'
\i setup/customer.sql

\echo 'Setting up product categories and populating them with some random data'
\i setup/category.sql

\echo 'Setting up products and populating them with some random data'
\i setup/product.sql

\echo 'Setting up purchase table and populating it with some random data'
\i setup/purchase.sql

\echo 'Setting up store table and populating it with some random data'
\i setup/store.sql


\c postgres

-- create the database rec_cte
DROP DATABASE IF EXISTS rec_cte WITH (FORCE);
CREATE DATABASE rec_cte;

\c rec_cte;

\i setup/rec_cte_dataset.sql


DROP DATABASE IF EXISTS gis_sample WITH (FORCE);
CREATE DATABASE gis_sample;

\c gis_sample

CREATE EXTENSION IF NOT EXISTS postgis;

\i setup/gis_sample.sql

-- add data about cantons
\i setup/canton.sql
\i setup/canton-data.sql

\c postgres;
DROP DATABASE IF EXISTS acid_test WITH (FORCE);
CREATE DATABASE acid_test;

\c dlh_adv_sql;

