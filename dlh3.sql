/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated February 17 2026
****************************************************************************************************/

-- dlh3.sql

/*

Section: Working with JSONB

*/

SELECT first_name, JSONB_PRETTY(phone_numbers) FROM customer LIMIT 5;

SELECT
	first_name,
	phone_numbers,
	phone_numbers ->> 'home' AS home_phone_number,
	phone_numbers ->> 'mobile' AS mobile_phone_number
FROM customer;

SELECT first_name, phone_numbers
FROM customer
WHERE phone_numbers ? 'mobile';

SELECT first_name, phone_numbers FROM customer
WHERE NOT(phone_numbers ? 'home');

UPDATE customer
	SET phone_numbers =
		jsonb_insert (phone_numbers, '{new}', '"123 456 789"')                                                                                                                                                       
        WHERE id = 1;

UPDATE customer 
		SET phone_numbers = 
			phone_numbers - 'new' 
		WHERE id = 1;

SELECT id, nbrs.*
FROM
	customer,
	JSON_TABLE (
		phone_numbers,
		'$' COLUMNS (
			mobile TEXT PATH '$.mobile',
			home TEXT PATH '$.home'
		)
	) nbrs
WHERE
	nbrs.mobile IS NOT NULL
LIMIT 5;

/*

-- Section: Views

*/

DROP VIEW IF EXISTS customer_purchase_view;

CREATE VIEW customer_purchase_view AS 
    SELECT 
        c.id AS customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.town,
        p.product_nbr,
        pr.name AS product_name,
        pr.category as product_category,
        p.quantity,
        p.id AS purchase_id,
        p.order_date,
        (p.quantity * pr.price) AS total_price
    FROM customer c
    JOIN purchase p ON c.id = p.customer_id
    JOIN product pr ON p.product_nbr = pr.product_nbr;


SELECT * FROM customer_purchase_view LIMIT 5;


/*

Section: Aggregates

*/

SELECT town, COUNT(id) FROM customer                                            
GROUP BY TOWN
ORDER BY town ASC;


SELECT town, COUNT(id) customer_count FROM customer
GROUP BY TOWN
ORDER BY town ASC;

SELECT town, COUNT(id) AS customer_count FROM customer
WHERE since >= '2024-01-01'  
    AND since < '2024-12-31'
GROUP BY TOWN
HAVING COUNT(id) > 1;

SELECT town, COUNT(id) AS customer_count FROM customer
WHERE since >= '2024-01-01'  
    AND since < '2024-12-31'
GROUP BY TOWN
HAVING COUNT(id) > 1
ORDER BY customer_count DESC; 

SELECT 
    town, 
    EXTRACT (YEAR FROM since) AS since_year,  
    COUNT(id) AS customer_count FROM customer
WHERE TOWN <> 'ESCH'    
GROUP BY town, since_year
HAVING COUNT(id) > 1
ORDER BY town ASC, since_year ASC; 


/* 

Section: Excercises 


*/

SELECT COUNT(*) FROM purchase
    JOIN product ON purchase.product_nbr = product.product_nbr
    WHERE product.category = 'food';

SELECT customer.id, customer.first_name, customer.last_name, SUM(purchase.quantity) AS total_qty
FROM customer
    JOIN purchase ON customer.id = purchase.customer_id
GROUP BY customer.id, customer.first_name, customer.last_name
ORDER BY total_qty DESC
LIMIT 10;

SELECT customer_name, sum(total_price) 
    FROM customer_purchase_view
    group by customer_name
    order by sum desc
    limit 10;

/*

Section Grouping Sets, Rollup, Cube

*/

SELECT product_category, product_name, sum(quantity) 
    FROM customer_purchase_view
    GROUP BY ROLLUP (product_category, product_name)
    ORDER BY product_category, product_name;


SELECT  COALESCE(product_category, 'Total') AS category, 
        COALESCE(product_name, 'Subtotal ' || product_category) AS name, 
        sum(quantity) AS quantity
    FROM customer_purchase_view
    GROUP BY ROLLUP (product_category, product_name)
    ORDER BY product_category, product_name ASC NULLS LAST;

SELECT FORMAT ('%s living in %s', customer_name, town) AS customer_town , product_category, product_name, sum(quantity) 
    FROM customer_purchase_view
    WHERE TOWN <> 'Esch'  
    GROUP BY ROLLUP (customer_town, product_category, product_name)
    ORDER BY customer_town, product_category, product_name;    

SELECT FORMAT ('%s living in %s', customer_name, town) AS customer_town , product_category, product_name, sum(quantity) 
    FROM customer_purchase_view
    WHERE TOWN <> 'Esch'  
    GROUP BY CUBE (customer_town, product_category, product_name)
    ORDER BY customer_town, product_category, product_name; 


/*

Stored procedures

*/

/* simple procedure to increase price of all products in a category by a fixed amount
this definition is just for training purposes. In real life you would just call the 
update statement directly without the procedure. 
The more complex examples below are more realistic use cases for stored procedures. */

CREATE OR REPLACE PROCEDURE increase_price (IN p_category TEXT, IN p_increase NUMERIC)
LANGUAGE SQL
AS $$
    UPDATE product
    SET price = price + p_increase
    WHERE category = p_category;
$$; 

SELECT * FROM product WHERE category = 'food';

CALL increase_price ('food', 1.00);

--- simple procedure to increase price of all products in a category by a fixed amount
CREATE OR REPLACE PROCEDURE increase_price2 (IN p_category TEXT, IN p_increase NUMERIC)
LANGUAGE PLPGSQL
AS $$
    DECLARE 
    v_product RECORD;
BEGIN
    FOR v_product IN SELECT * FROM product WHERE category = p_category
    LOOP
        UPDATE product
        SET price = price + p_increase
        WHERE product_nbr = v_product.product_nbr;    
        RAISE NOTICE 'Increased price of % by %', v_product.name, p_increase;
    END LOOP;
END; $$; 

SELECT * FROM product WHERE category = 'food';

CALL increase_price2 ('food', 1.00);

--- more complex procedure to increase price of all products by a percentage
CREATE OR REPLACE PROCEDURE increase_price_differentiated 
    (IN general_increase_percent NUMERIC, IN food_increase_percent NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
BEGIN
    FOR v_product IN SELECT * FROM product
    LOOP
        IF v_product.category = 'food' THEN
            UPDATE product
            SET price = price + (price * food_increase_percent / 100)
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by % percent', v_product.name, food_increase_percent;
        ELSE
            UPDATE product
            SET price = price + (price * general_increase_percent / 100)
            WHERE product_nbr = v_product.product_nbr;    
            RAISE NOTICE 'Increased price of % by % percent', v_product.name, general_increase_percent;        
        END IF;
    END LOOP;
END;    
$$; 

SELECT category, name, price FROM product
    ORDER BY category, name;

CALL increase_price_differentiated (5, 10);    

--- extend the procedure to have a special increase for snacks
CREATE OR REPLACE PROCEDURE increase_price_differentiated_2 
    (IN general_increase_percent NUMERIC, IN food_increase_percent NUMERIC, IN snack_increase_percent NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
BEGIN
    FOR v_product IN SELECT * FROM product
    LOOP
        IF v_product.category = 'food' THEN
            UPDATE product
            SET price = price + (price * food_increase_percent / 100)
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by % percent', v_product.name, food_increase_percent;    
        ELSIF v_product.category = 'snack' THEN
            UPDATE product
            SET price = price + (price * snack_increase_percent / 100)
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by % percent', v_product.name, snack_increase_percent;
        ELSE
            UPDATE product
            SET price = price + (price * general_increase_percent / 100)
            WHERE product_nbr = v_product.product_nbr;    
            RAISE NOTICE 'Increased price of % by % percent', v_product.name, general_increase_percent;        
        END IF;
    END LOOP;
END;    
$$; 

CALL increase_price_differentiated_2 (5, 10, 3);  

--- use the simple case statement to do the same
CREATE OR REPLACE PROCEDURE increase_price_differentiated_3 
    (IN general_increase_percent NUMERIC, IN food_increase_percent NUMERIC, IN snack_increase_percent NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
    v_increase_percent NUMERIC;
BEGIN
    FOR v_product IN SELECT * FROM product
    LOOP
        v_increase_percent := 
            CASE v_product.category
                WHEN 'food' THEN food_increase_percent
                WHEN 'snack' THEN snack_increase_percent
                ELSE general_increase_percent
            END;
        UPDATE product
        SET price = price + (price * v_increase_percent / 100)
        WHERE product_nbr = v_product.product_nbr;    
        RAISE NOTICE 'Increased price of % by % percent', v_product.name, v_increase_percent;        
    END LOOP;
END;    
$$;

CALL increase_price_differentiated_2 (5, 10, 3); 

--- functions

CREATE FUNCTION my_mult (p1 INT, p2 INT) RETURNS INT
AS
$$
	BEGIN
		RETURN p1 * p2;
	END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM my_mult (2, 3);

CREATE FUNCTION my_math (p1 INT, p2 INT, p_op text) RETURNS INT
AS
$$
	DECLARE v_result INT;
	BEGIN
		IF p_op = 'addition' THEN
			v_result = p1 + p2;
		ELSEIF p_op = 'multiplication' THEN
			v_result = p1 * p2;
		ELSE v_result = 0;
		END IF;
		RETURN v_result;
	END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM my_math(2,3, 'multiplication');
SELECT * FROM my_math(2,3, 'addition');
SELECT * FROM my_math(2,3, 'other');

/*

Section: CTEs and Recursion

*/

WITH esch_customers AS (
    SELECT id, first_name, last_name
    FROM customer
    WHERE town = 'Esch'
)
SELECT * FROM esch_customers;

-- define how much my Esch customers spent in total
WITH esch_customers AS (
    SELECT id, first_name, last_name
    FROM customer
    WHERE town = 'Esch'
),
customer_spend AS (
    SELECT 
        cpv.customer_id,
        SUM(cpv.total_price) AS total_spend
    FROM customer_purchase_view cpv
    GROUP BY cpv.customer_id
)
SELECT 
    ec.first_name, 
    ec.last_name, 
    cs.total_spend
FROM esch_customers ec
    JOIN customer_spend cs ON ec.id = cs.customer_id
ORDER BY cs.total_spend DESC;


WITH top_10_customers AS (
    SELECT customer_id, SUM(total_price) AS total_spent
    FROM customer_purchase_view
    GROUP BY customer_id
    ORDER BY total_spent DESC
    LIMIT 10
),
top_5_products AS (
    SELECT product_nbr, SUM(quantity) AS total_qty
    FROM customer_purchase_view
    GROUP BY product_nbr
    ORDER BY total_qty DESC
    LIMIT 5
)
-- what are the top 10 products bought by my overall top 10 customers
SELECT 
    pr.name AS product_name, 
    SUM(cpv.quantity) AS total_qty, 
    SUM(cpv.total_price) AS total_spent
FROM customer_purchase_view cpv
    JOIN top_10_customers tc ON cpv.customer_id = tc.customer_id
    JOIN top_5_products tp ON cpv.product_nbr = tp.product_nbr
    JOIN product pr ON cpv.product_nbr = pr.product_nbr
GROUP BY pr.name
ORDER BY total_spent DESC;

-- what did my overall top 10 customers buy in March 2025

WITH top10_customers AS (
    SELECT customer_id, SUM(total_price) AS total_spent
    FROM customer_purchase_view
    GROUP BY customer_id
    ORDER BY total_spent DESC
    LIMIT 10
)
SELECT 
    cpv.customer_name, 
    cpv.product_name, 
    SUM(cpv.quantity) AS total_qty, 
    SUM(cpv.total_price) AS total_spent
FROM customer_purchase_view cpv
    JOIN top10_customers tc ON cpv.customer_id = tc.customer_id
WHERE cpv.order_date >= '2025-06-01' AND cpv.order_date < '2025-07-01'
GROUP BY ROLLUP (cpv.customer_name, cpv.product_name)
ORDER BY cpv.customer_name, total_spent ASC;

-- try it out: How many food items did my customers in Esch and Dudelingen buy?

WITH esch_dud_customers AS (
    SELECT id, first_name, last_name
    FROM customer
    WHERE town IN ('Esch', 'Dudelingen')
)
SELECT 
    cpv.customer_name, 
    SUM(cpv.quantity) AS total_qty
FROM customer_purchase_view cpv
    JOIN esch_dud_customers edc ON cpv.customer_id = edc.id
WHERE cpv.product_category = 'food'
GROUP BY cpv.customer_name
ORDER BY cpv.customer_name ASC;


