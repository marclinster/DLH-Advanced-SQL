/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated Oct 3 2026
****************************************************************************************************/



-- sample data for a simple recursive CTE

DROP TABLE IF EXISTS public.employee;

CREATE TABLE public.employee (
    id integer NOT NULL,
    name text,
    manager_id integer,
    salary numeric
);

INSERT INTO public.employee (id, name, manager_id, salary) VALUES
(1, 'Marc', 15, 67500),
(2, 'Susi', 15, 68300),
(3, 'Jake', 15, 66450),
(4, 'Karin', 2, 62450),
(5, 'Bill', 2, 63000),
(6, 'John', 4, 49000),
(7, 'Frank', 4, 51000),
(8, 'Siggi', 4, 53000),
(9, 'Theo', 4, 52600),
(10, 'Barbara', 9, 46750),
(15, 'Bill', NULL, 75000);

