/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2025 Copyright: Marc Linster
Last updated Sep 23 2025
****************************************************************************************************/

/*
This script creates the databases used in the Advanced SQL with Postgres course.
Run this script from psql as a superuser (e.g. postgres user).
It will drop existing databases if they exist, so be careful if you have any data in them

*/

\c postgres

-- dlh1 is an empty database that is used for Day 1 exercises
DROP DATABASE IF EXISTS dlh1 WITH (FORCE);
CREATE DATABASE dlh1;

--- DLH2 is an empty database for exercises
DROP DATABASE IF EXISTS dlh2 WITH (FORCE);
CREATE DATABASE dlh2;

-- DLH3 
DROP DATABASE IF EXISTS dlh3 WITH (FORCE);
CREATE DATABASE dlh3;
-- don't forget to load in dlh3_data_set.sql

-- DLH4
DROP DATABASE IF EXISTS dlh4 WITH (FORCE);
CREATE DATABASE dlh4;
-- don't forget to load in dlh4_data_set.sql

-- DLH5
DROP DATABASE IF EXISTS dlh5 WITH (FORCE);
CREATE DATABASE dlh5;

\c dlh3

\i dlh3_data_set.sql

\c dlh4
\i dlh4_data_set.sql