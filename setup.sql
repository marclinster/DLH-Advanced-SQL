/*

Database setup script for the DLH Advanced SQL course. This script will create a new database called dlh_adv_sql, 
enable the PostGIS extension, and set up the necessary tables and populate them with data.
Copyright Marc Linster, 2026

*/



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
DROP DATABASE IF EXISTS rec_cte;
CREATE DATABASE rec_cte;

\c rec_cte;

\i setup/rec_cte_dataset.sql

/*
DROP DATABASE IF EXISTS gis_sample;
CREATE DATABASE gis_sample;

DROP DATABASE IF EXISTS rec_cte;
CREATE DATABASE rec_cte;
*/

