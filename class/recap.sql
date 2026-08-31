

SELECT * FROM customer;

SELECT first_name AS given_name, last_name AS family_name, since AS customer_since
    FROM customer WHERE since > '2025-01-01';

SELECT first_name  given_name, last_name  family_name, since customer_since
    FROM customer WHERE since > '2025-01-01';    

SELECT last_name || ', ' || first_name AS full_name, since AS customer_since
    FROM customer WHERE since > '2025-01-01';    


SELECT FORMAT('%s. %s has been a valued customer since %s', SUBSTRING (first_name, 1,1), last_name, since)
    FROM customer
    LIMIT 10;

SELECT FORMAT('%s. %s has been a valued customer since %s (a %s)', 
    SUBSTRING (first_name, 1,1), 
    last_name,
    TO_CHAR (since, 'FMMonth DD YYYY'),
    TO_CHAR (since, 'FMDay')
    )
    FROM customer
    LIMIT 10;    


SELECT last_name, since, EXTRACT (DAY FROM since) FROM customer;
SELECT last_name, since, EXTRACT (YEAR FROM since) FROM customer;
SELECT last_name, since, EXTRACT (DOW FROM since) FROM customer;


SELECT last_name, since,  NOW()::date - since FROM customer;
SELECT last_name, since, AGE( NOW(), since) FROM customer;
SELECT last_name, since, 
EXTRACT (YEAR FROM AGE(NOW(), since)) AS nbr_years 
FROM customer;


SELECT 'It is the ' || EXTRACT (DOY FROM current_date) || 'th day of the year';

SELECT 'It is the ' || EXTRACT (DOY FROM current_date) || 'th day of the year' as day_of_year;

SELECT COALESCE (NULL, 'Test', 'Test 2') as first_non_zero;

SELECT FORMAT (
		'%s. %s is our oldest customer. ' 
		'He has been a valued customer for %s years, since %s', 
		SUBSTRING (first_name, 1,1), 
		last_name, 
		EXTRACT (YEAR FROM AGE( NOW(), since )),
		since)
	FROM customer
	ORDER BY since ASC
	LIMIT 1;

SELECT * FROM customer;
SELECT * FROM customer WHERE id = 1;
SELECT * FROM customer WHERE id = 1 OR id = 3;
SELECT * FROM customer WHERE id IN (1,2);
SELECT * FROM customer 
    WHERE id BETWEEN 1 AND 300
    AND first_name LIKE 'A%';

SELECT * FROM customer WHERE first_name = 'Alice';

SELECT * FROM customer WHERE first_name = 'alice';

SELECT * FROM customer WHERE first_name LIKE 'Al%';

SELECT * FROM customer WHERE first_name LIKE 'al%';

SELECT * FROM customer WHERE first_name ILIKE 'al%';

SELECT * FROM customer WHERE first_name LIKE '_lice%';


SELECT last_name, first_name FROM customer WHERE since = '2025-01-01';

SELECT last_name, first_name FROM customer WHERE since > '2025-01-01';

SELECT last_name, first_name FROM customer WHERE since >= '2025-01-01';

SELECT last_name, first_name, since 
	FROM customer 
	WHERE since >= '2023-07-09'
	ORDER BY since DESC;

SELECT * FROM customer 
	ORDER BY last_name ASC;

SELECT * FROM customer 
	WHERE first_name LIKE 'Al%'
	ORDER BY last_name ASC, first_name ASC;	

SELECT * FROM customer 
	ORDER BY last_name ASC
	LIMIT 3;

SELECT * FROM customer 
	ORDER BY last_name ASC
	OFFSET 2
	LIMIT 3;


SELECT * FROM product;

SELECT * FROM category;

-- problem 
INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('sandwich', 14, 'Ham and Cheese Sandwich', 0);

-- Fixed (prive >0 and category_id exists in category table)        
INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('sandwich', 14, 'Ham and Cheese Sandwich', 9.99);

/*

Views and materialized views

*/

--- View to show the number of customers per town and their average purchase amount in 2025
DROP VIEW IF EXISTS customer_summary_vw;


CREATE VIEW customer_summary_vw AS
SELECT c.id,
       c.first_name,
       c.last_name,
       a.localite,
       a.commune,
       p.product_nbr,
       p.name,
       p.price,
       pu.date,
       pu.quantity
FROM customer c
JOIN address a ON c.address_id = a.id
LEFT JOIN purchase pu ON c.id = pu.customer_id
LEFT JOIN product p ON pu.product_nbr = p.product_nbr
ORDER BY pu.date,
         c.last_name,
         c.first_name;

SELECT * FROM customer_summary_vw LIMIT 5;        


SELECT * FROM customer_summary_vw
        WHERE localite = 'Luxembourg'
        AND last_name = 'Adams'
        LIMIT 5; 

DROP VIEW IF EXISTS customer_list_vw;

CREATE VIEW customer_list_vw AS
SELECT FORMAT ('%s, %s.', last_name, SUBSTRING (first_name, 1,1)) AS customer_name,
    localite AS village,
    commune AS town,
    CURRENT_DATE - since AS customer_days
    FROM customer
    JOIN address ON customer.address_id = address.id;

DROP MATERIALIZED VIEW IF EXISTS customer_summary_mv;

CREATE MATERIALIZED VIEW customer_summary_mv AS
SELECT c.id,
       c.first_name,
       c.last_name,
       a.localite,
       a.commune,
       p.product_nbr,
       p.name,
       p.price,
       pu.date,
       pu.quantity
FROM customer c
JOIN address a ON c.address_id = a.id
LEFT JOIN purchase pu ON c.id = pu.customer_id
LEFT JOIN product p ON pu.product_nbr = p.product_nbr
ORDER BY pu.date,
         c.last_name,
         c.first_name;



DROP MATERIALIZED VIEW IF EXISTS customer_list_mw; 

CREATE MATERIALIZED VIEW customer_list_mw AS
SELECT FORMAT ('%s, %s.', last_name, SUBSTRING (first_name, 1,1)) AS customer_name,
    localite AS village,
    commune AS town,
    CURRENT_DATE - since AS customer_days
    FROM customer
    JOIN address ON customer.address_id = address.id;


-- insert two customers living in Bridel

-- find two random Belval addresses
SELECT * FROM address WHERE localite ILIKE 'Bridel' LIMIT 2;

INSERT INTO customer (first_name, last_name, since, address_id) 
    VALUES 
        ('Paul', 'Test', '2025-10-12', 841),
        ('Paulette', 'Test', '2025-01-01', 947);

DELETE FROM customer WHERE last_name Like 'Test%';

SELECT * FROM customer_list_mw WHERE customer_name LIKE 'Test%';

SELECT * FROM customer_list_vw WHERE customer_name LIKE 'Test%';

REFRESH MATERIALIZED VIEW customer_list_mw;


/*

Joins

*/



-- categories with products
SELECT * FROM category c
    JOIN product p ON p.category_id = c.id;

-- all categories    

SELECT * FROM category c
    LEFT JOIN product p ON p.category_id = c.id;    