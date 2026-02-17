/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated Feb 17 2026
****************************************************************************************************/

-- dlh1.sql

/*

Section: Tables and Queries: Basics

*/

-- make sure you are connected to dlh1 database

SELECT current_database()

-- create a simple table

DROP TABLE IF EXISTS mycustomer;

CREATE TABLE mycustomer (
	id INTEGER,
	email TEXT,
	first_name TEXT,
	last_name TEXT,
	since DATE
);

CREATE TABLE mycustomer2 (
	id INTEGER,
	email TEXT,
	first_name TEXT,
	last_name TEXT,
	since DATE
);


/*

Section: Query Basics

*/


INSERT INTO mycustomer (id, email, first_name, last_name, since) 
	VALUES 
		(1,'marc@marclinster.com', 'Marc', 'Linster','2025-01-01');

INSERT INTO mycustomer (id, email, first_name, last_name, since) 
	VALUES 
		(2,'jmu@gmail.lu','Jeff', 'Mueller','2025-02-13'),
		(3,'bini@hotmail.lu', 'Jean','Bintner','2025-03-01');

SELECT first_name FROM mycustomer;

SELECT first_name, last_name FROM mycustomer;

SELECT * FROM mycustomer WHERE first_name LIKE 'Je%';

SELECT * FROM mycustomer WHERE first_name LIKE 'je%';

SELECT * FROM mycustomer WHERE first_name ILIKE 'je%';

SELECT * FROM mycustomer WHERE first_name LIKE '_e%';

INSERT INTO mycustomer (id, email, first_name, last_name, since) 
	VALUES 
		(4,'jimmy@gmail.lu','Jimmy', 'Bond','1.5.2025'),
		(5,'renee@hotmail.lu', 'Renee','Bintner','9.7.2025');


UPDATE mycustomer SET first_name = 'Mark' WHERE id = 1;
SELECT * FROM mycustomer;
DELETE FROM mycustomer WHERE id = 1;
SELECT * FROM mycustomer;
SELECT * FROM mycustomer ORDER BY last_name ASC;


/*

Section: Operators

*/

-- Let’s try it out - Numbers

SELECT * FROM mycustomer;
SELECT * FROM mycustomer WHERE id = 1;
SELECT * FROM mycustomer WHERE id = 1 OR id = 3;
SELECT * FROM mycustomer WHERE id IN (1,2);

SELECT email, last_name, first_name 
FROM mycustomer 
WHERE id IN (1,2);

SELECT email, last_name, first_name 
FROM mycustomer 
WHERE id IN (1,2)
ORDER BY last_name ASC;


-- Let’s try it out - Text/Character

SELECT * FROM mycustomer WHERE first_name LIKE 'Je%';

SELECT * FROM mycustomer WHERE first_name LIKE 'je%';

SELECT * FROM mycustomer WHERE first_name ILIKE 'je%';

SELECT * FROM mycustomer WHERE first_name LIKE '_e%';

SELECT * FROM mycustomer WHERE first_name LIKE '_e%' AND last_name = 'Bintner';

SELECT * FROM mycustomer WHERE since 
BETWEEN '2025-01-02' AND '2025-02-01';

-- Let’s try it out - Dates

SELECT last_name, first_name FROM mycustomer WHERE since = '2025-01-01';

SELECT last_name, first_name FROM mycustomer WHERE since > '2025-01-01';

SELECT last_name, first_name FROM mycustomer WHERE since >= '2025-01-01';

SELECT last_name, first_name, since 
	FROM mycustomer 
	WHERE since >= '7.9.2023'
	ORDER BY since DESC;

-- The select clause can also contain calculations and functions, not just column names
-- synonyms

SELECT last_name || ', ' || first_name AS customer 
FROM mycustomer;

SELECT 
	FORMAT ('%s %s has been a valued customer since %s', 
	first_name, 
	last_name, 
	since)
FROM mycustomer;


SELECT
	first_name || ' ' || last_name AS customer_name
FROM
	mycustomer
WHERE
	first_name LIKE 'Je%';

SELECT 	FORMAT ('%s. %s has been a valued customer since %s', 
			SUBSTRING (first_name, 1,1), last_name, since)
	FROM mycustomer;


SELECT FORMAT ('This is a string with a %s and a %s', 'first placeholder', 'second placeholder');

-- TO_CHAR – convert a timestamp or a numeric value to a string.

SELECT NOW();
SELECT current_date;
SELECT TO_CHAR (NOW(), 'DAY');
SELECT TO_CHAR (NOW(), 'MON');
SELECT TO_CHAR (CURRENT_DATE, 'Day Month, DD, YYYY');
SELECT TO_CHAR (12345.55, '99G999G999D99L');



-- Working with numbers in the SELECT clause
-- Simple arithmetic
SELECT 15 * 4;	
SELECT 15 / 4;
SELECT 15 / 4.0;
SELECT MOD (15, 4);
-- Casting
SELECT PI();
SELECT PI()::INTEGER;
SELECT PI()::NUMERIC;
-- Rounding
SELECT ROUND(PI()::NUMERIC);
SELECT ROUND(PI()::NUMERIC, 2);

-- Working with dates in the SELECT clause
-- Extracting date elements
SELECT last_name, since, EXTRACT (DAY FROM since) FROM mycustomer;
SELECT last_name, since, EXTRACT (YEAR FROM since) FROM mycustomer;
SELECT last_name, since, EXTRACT (DOW FROM since) FROM mycustomer;
-- Differences
SELECT last_name, since,  NOW()::date - since FROM mycustomer;
SELECT last_name, since, AGE( NOW(), since) FROM mycustomer;
SELECT last_name, since, 
	EXTRACT (YEAR FROM AGE(NOW(), since)) AS nbr_years 
	FROM mycustomer;

-- Extracting the day of the year

SELECT 'It is the ' || EXTRACT (DOY FROM current_date) || 'th day of the year';

SELECT 'It is the ' || EXTRACT (DOY FROM current_date) || 'th day of the year' as day_of_year;

-- Fancy stuff with FORMAT

SELECT FORMAT (
		'%s. %s is our oldest customer. ' 
		'He has been a valued customer for %s years, since %s', 
		SUBSTRING (first_name, 1,1), 
		last_name, 
		EXTRACT (YEAR FROM AGE( NOW(), since )),
		since)
	FROM mycustomer
	ORDER BY since ASC
	LIMIT 1;

-- Colaesce

SELECT COALESCE (NULL, 'Test') as first_non_zero;

-- Order By and LIMIT

SELECT * FROM mycustomer 
	WHERE first_name LIKE 'Je%'
	ORDER BY last_name ASC, first_name ASC;	

SELECT * FROM mycustomer 
	ORDER BY last_name ASC
	LIMIT 3;

SELECT * FROM mycustomer 
	ORDER BY last_name ASC
	OFFSET 2,
	LIMIT 3;

-- Try it out

SELECT FORMAT('%s, %s', last_name, first_name) AS customer_name, since AS customer_since
FROM mycustomer
ORDER BY last_name ASC, first_name ASC;	

/*

Section: Primary Keys, Constraints and Relationships

*/

CREATE TABLE mycustomer (
	id INTEGER,
	email TEXT,
	first_name TEXT,
	last_name TEXT,
	since DATE
);

-- add a primary key and a unique constraint

-- option 1: alter the table after creating it

ALTER TABLE mycustomer ADD CONSTRAINT mycustomer_pk PRIMARY KEY (id);

-- Option 2: drop and recreate the table with the primary key
DROP TABLE IF EXISTS mycustomer;
CREATE TABLE mycustomer (
	id INTEGER PRIMARY KEY,
	email TEXT,
	first_name TEXT,
	last_name TEXT,
	since DATE
);

INSERT INTO mycustomer (id, email, first_name, last_name, since) 
	VALUES 
		(1,'marc@marclinster.com', 'Marc', 'Linster','2025-01-01'),
		(2,'jmu@gmail.lu','Jeff', 'Mueller','2025-02-13'),
		(3,'bini@hotmail.lu', 'Jean','Bintner','2025-03-01');

-- create the myproduct table

CREATE TABLE myproduct (
	product_nbr VARCHAR(10),
	name TEXT,
	price numeric
);	


DROP TABLE IF EXISTS myproduct;

CREATE TABLE myproduct (
	nbr VARCHAR(10) PRIMARY KEY,
	name TEXT UNIQUE NOT NULL,
	price NUMERIC NOT NULL CHECK (price > 0) 
);

INSERT INTO myproduct (nbr, name, price) 
	VALUES 
		('ham_001','Hammer 200gr', 19.95),
		('ham_002', 'Hammer 1kg', 25.00),
		('chisel_004', 'Chisel stone', 39.95),
		('pli_019', 'Pliers red, adjustable', '13.50');

SELECT * FROM myproduct ORDER BY price ASC;

-- add table myorder to illustrate relations and foreign keys

DROP TABLE IF EXISTS myorder;

CREATE TABLE myorder (
	id INT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	date DATE,
	customer_id INTEGER NOT NULL,
	product_nbr VARCHAR(10) NOT NULL,
	qty INTEGER NOT NULL CHECK (qty > 0)
)

-- nonsense order

INSERT INTO myorder (date, customer_id, product_nbr, qty)
	VALUES (current_date, 25, 'big_thing', 11);

-- myorder with the correct foreign keys

DROP TABLE IF EXISTS myorder;

CREATE TABLE myorder (
	id INT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	date DATE,
	customer_id INTEGER REFERENCES mycustomer (id),
	product_nbr VARCHAR(10) REFERENCES myproduct (nbr),
	qty INTEGER NOT NULL CHECK (qty > 0)
);




-- retry the nonsense order

INSERT INTO myorder (date, customer_id, product_nbr, qty)
	VALUES (current_date, 25, 'big_thing', 11);

-- add four working orders

INSERT INTO myorder (date, customer_id, product_nbr, qty)
	VALUES 
		(current_date, 1, 'ham_001', 1),
		(current_date, 1, 'ham_002', 1),
		(current_date-1, 2, 'chisel_004', 2),
		('2025-03-01', 2, 'pli_019', 4);

SELECT * FROM myorder;

-- Tables revisited

CREATE TABLE test (
    nbr1 INTEGER CHECK (nbr1 > 0),
    nbr2 INTEGER CHECK (nbr2 > 0),
    CHECK (nbr1 < nbr2));

INSERT INTO test (nbr1, nbr2) VALUES (5, 10); -- valid
INSERT INTO test (nbr1, nbr2) VALUES (-5, 10); -- invalid



-- Queries with multiple tables

SELECT * FROM myorder o,
		myproduct p,
		mycustomer c
	WHERE 
		o.product_nbr = p.nbr
	AND 
o.customer_id = c.id;




-- Try it out

INSERT INTO mycustomer (id, email, first_name, last_name, since) 
	VALUES 
		(10,'pierre@pt.com', 'Pierre', 'Linster','1.4.2025'),
		(11,'jmu@gmail.lu','Jemp', 'Mueller','9.2.2025'),
		(12,'poli@hotmail.lu', 'Pol','Diederich','1.3.2025');

INSERT INTO myproduct (nbr, name, price)
   VALUES
       ('ham_003','Hammer Large 500gr', 19.95),
       ('ham_004', 'Hammer Extra Large 1000gr', 25.00),
       ('chisel_005', 'Chisel wood', 12.87),
       ('pli_020', 'Pliers black, fixed', 3.50);	


SELECT o.id AS order_id, 
		o.date AS order_date, 
		FORMAT('%s, %s', last_name, first_name) AS customer_name,
		p.name AS product_name,
		p.price AS unit_price,
		o.qty AS order_qty,
		o.qty * p.price AS extended_price
	FROM myorder o,
		myproduct p, mycustomer c 
	WHERE o.product_nbr = p.nbr
		AND o.customer_id = c.id
	ORDER BY order_date ASC;
	
/*

Section: Database Joins

*/


SELECT * FROM myorder
	JOIN mycustomer
	ON myorder.customer_id = mycustomer.id;

SELECT 
	o.id AS order_id, 
	o.date AS order_date, 
	o.qty AS order_quantity, 
	c.first_name || ' ' || c.last_name AS customer_name
FROM myorder o
	JOIN mycustomer c
	ON o.customer_id = c.id;

-- customers even if they didn't order anything
SELECT * FROM mycustomer c
	LEFT OUTER JOIN myorder o
	ON c.id = o.customer_id;

-- customers who never ordered anything
SELECT * FROM mycustomer c
	LEFT OUTER JOIN myorder o
	ON c.id = o.customer_id
	WHERE o.id IS NULL;

-- customers with order details
SELECT * FROM mycustomer c
	LEFT JOIN myorder o ON c.id = o.customer_id
	LEFT JOIN myproduct p ON o.product_nbr = p.nbr;	

-- Try it out
-- customers who never ordered anything
SELECT * FROM mycustomer c
	LEFT OUTER JOIN myorder o
	ON c.id = o.customer_id
	WHERE o.id IS NULL;

-- products that were never ordered

SELECT DISTINCT(p.*) FROM myproduct p
	LEFT JOIN myorder o ON o.product_nbr = p. nbr
	WHERE o.id IS NULL



/****************************************************************************************************
                                              End of File
****************************************************************************************************/