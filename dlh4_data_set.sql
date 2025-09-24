/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2025 Copyright: Marc Linster
Last updated Sep 23 2025
****************************************************************************************************/

-- connect to dlh4 database

-- sample data for a simple recirsive CTE

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

-- Hierarchy

WITH RECURSIVE employee_hierachy (id, name, manager_id)
AS (
	SELECT id, name, manager_id 
FROM employee 
WHERE manager_id IS NULL
	UNION ALL
	SELECT e.id, e.name, e.manager_id 
FROM employee e
		INNER JOIN employee_hierachy eh 
				ON e.manager_id = eh.id
		)
SELECT * FROM employee_hierachy;

-- Hierarchy with Level Count
WITH RECURSIVE employee_hierachy AS (
	SELECT id, name, manager_id, 1 AS level -- initiate level count
FROM employee WHERE manager_id IS NULL -- define starting point
	UNION ALL
	SELECT e.id, e.name, e.manager_id, 
eh.level +1 -- add to the level count
FROM employee e
		INNER JOIN employee_hierachy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierachy;



-- Hierarchy with Manager Name and Reporting Line
WITH RECURSIVE employee_hierachy AS (
	SELECT id, name, manager_id, NULL AS manager_name, 
1 AS level, 
'Top' as reporting_line
		FROM employee 
		WHERE manager_id IS NULL
	UNION ALL
	SELECT e.id, e.name, eh.id, eh.name AS manager_name, eh.level +1, 
FORMAT('%s/%s', eh.reporting_line, eh.name) –
FROM employee e
		INNER JOIN employee_hierachy eh ON e.manager_id = eh.id
)
SELECT 
	employee_hierachy.manager_id,
	employee_hierachy.manager_name,
	employee_hierachy.level as reporting_level,
	employee_hierachy.id as employee_id,
	employee_hierachy.name as employee_name,
	employee_hierachy.reporting_line
	FROM employee_hierachy
	ORDER BY reporting_level, manager_name ASC;
