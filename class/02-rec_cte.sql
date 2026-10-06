/***************************************************************************************************

Database setup script for the DLH Advanced SQL course. This file provides
an overview of the recursive CTEs and their usage in SQL.

The examples use the database rec_cte, which is created by the setup.sql script.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


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
	SELECT id, name, manager_id, NULL AS manager_name, 1 AS level, 'Top' as reporting_line
		FROM employee 
		WHERE manager_id IS NULL
	UNION ALL
	SELECT e.id, e.name, eh.id, eh.name AS manager_name, eh.level +1, 
		FORMAT('%s/%s', eh.reporting_line, eh.name) AS reporting_line
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



-- Another Hierarchy: Product Categories (category tree)

DROP TABLE IF EXISTS product_category;
CREATE TABLE product_category (
	id        INT PRIMARY KEY,
	name      TEXT NOT NULL,
	parent_id INT REFERENCES product_category(id)
);

INSERT INTO product_category (id, name, parent_id) VALUES
	(1, 'Electronics', NULL),
	(2, 'Computers',   1),
	(3, 'Laptops',     2),
	(4, 'Desktops',    2),
	(5, 'Phones',      1),
	(6, 'Smartphones', 5),
	(7, 'Accessories', 1),
	(8, 'Chargers',    7),
	(9, 'Gaming Laptops', 3);


