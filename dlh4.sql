/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated Feb 17 2026
****************************************************************************************************/

-- connect to dlh4 database

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
