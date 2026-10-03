/*

Initial recap of the SQL concepts covered in the intro course
Copyright Marc Linster, 2026

*/



/*

Computations in the SELECT clause

*/ 

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


SELECT localite FROM address ORDER BY localite ASC;

SELECT DISTINCT localite FROM address ORDER BY localite ASC;

SELECT DISTINCT commune, localite FROM address ORDER BY commune, localite ASC;

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

    /* Operators in the WHERE clause */ 

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


/* ORDER BY and LIMIT */

SELECT * FROM customer 
	ORDER BY last_name ASC
	LIMIT 3;

SELECT * FROM customer 
	ORDER BY last_name ASC
	OFFSET 2
	LIMIT 3;


SELECT * FROM product;

SELECT * FROM category;

/*

Create a query that
    Selects customers from the customer table
    Puts the name in the format ‘last name, first name’, e.g., Linster, Marc
    Adds a columns entitled 'customer_since'
    Sorts descending by last name, ascending by first name
    Skips the first 20 customers
    Shows 10 customers


*/

SELECT FORMAT ('%s, %s', last_name, first_name) AS customer_name,
    since AS customer_since
    FROM customer
    ORDER BY last_name DESC, first_name ASC
    OFFSET 20
    LIMIT 10;


-- problem 1
INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('sandwich', 14, 'Ham and Cheese Sandwich', 0);

-- Fixed (prive >0 and category_id exists in category table)        
INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('sandwich', 28, 'Ham and Cheese Sandwich', 9.99);

-- Change the constraint to allow products with a price of 0, but not negative prices
ALTER TABLE product
    DROP CONSTRAINT product_price_check;

ALTER TABLE product
    ADD CONSTRAINT product_price_check CHECK (price >= 0);    

-- problem 2
-- add a new category called tools to satisfy the foreign key constraint for the product 'hammer'

INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('hammer', 20, 'Hammer - 250gr', 19.99);       

INSERT INTO category (id, name) VALUES (20, 'Tools');        

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
WHERE pu.date >= '2025-01-01' AND pu.date < '2026-01-01'
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
SELECT c.id as customer_id,
       c.first_name,
       c.last_name,
       c.since,
       a.localite,
       a.commune,
       p.product_nbr,
       p.name product_name,
       p.price,
       cat.id category_id,
       cat.name category_name,
       pu.date,
       pu.quantity
FROM customer c
JOIN address a ON c.address_id = a.id
LEFT JOIN purchase pu ON c.id = pu.customer_id
LEFT JOIN product p ON pu.product_nbr = p.product_nbr
LEFT JOIN category cat ON p.category_id = cat.id
ORDER BY pu.date,
         c.last_name,
         c.first_name;


-- new materialized view to explain the difference between a view and a materialized view

DROP MATERIALIZED VIEW IF EXISTS customer_list_mw; 

CREATE MATERIALIZED VIEW customer_list_mw AS
SELECT FORMAT ('%s, %s.', last_name, SUBSTRING (first_name, 1,1)) AS customer_name,
    localite AS village,
    commune AS town,
    CURRENT_DATE - since AS customer_days
    FROM customer
    JOIN address ON customer.address_id = address.id;

-- insert two customers living in Bridel

-- find two random Bridel addresses
SELECT * FROM address WHERE localite ILIKE 'Bridel' LIMIT 2;

INSERT INTO customer (first_name, last_name, since, address_id) 
    VALUES 
        ('Paul', 'Test', '2025-10-12', 841),
        ('Paulette', 'Test', '2025-01-01', 947);

SELECT * FROM customer_list_mw WHERE customer_name LIKE 'Test%';

SELECT * FROM customer_list_vw WHERE customer_name LIKE 'Test%';

DELETE FROM customer WHERE last_name Like 'Test%';

REFRESH MATERIALIZED VIEW customer_list_mw;



CREATE MATERIALIZED VIEW communes_localites_mv AS
    SELECT DISTINCT commune, localite FROM address 
    ORDER BY commune, localite ASC;



/*

Joins

*/



-- categories with products
SELECT * FROM category c
    JOIN product p ON p.category_id = c.id;

-- all categories    

SELECT * FROM category c
    LEFT JOIN product p ON p.category_id = c.id;    

-- categories with no products

SELECT * FROM category c
    LEFT JOIN product p ON p.category_id = c.id
    WHERE p.product_nbr IS NULL;

-- Find villages (localite) without any sales

SELECT cl.* FROM communes_localites_mv cl
    LEFT JOIN customer_summary_mv cs ON cl.localite = cs.localite
    WHERE cs.localite IS NULL
    ORDER BY cl.commune, cl.localite ASC;

-- Products without any purchases

SELECT pr.* FROM product pr
    LEFT JOIN purchase pu ON pr.product_nbr = pu.product_nbr
    WHERE pu.product_nbr IS NULL;


/*

Aggregates

*/
   


SELECT localite, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    GROUP BY localite
    ORDER BY localite ASC;


SELECT localite, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    WHERE since >= '2026-01-01'
    GROUP BY localite
    HAVING COUNT(DISTINCT customer_id) > 1
    ORDER BY localite ASC;

SELECT localite, EXTRACT(YEAR FROM since) AS nbr_years, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    GROUP BY localite, nbr_years
    HAVING COUNT(DISTINCT customer_id) > 1
    ORDER BY nbr_customers DESC;    

SELECT localite, EXTRACT(YEAR FROM since) AS nbr_years, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    WHERE commune = 'Junglinster'
    GROUP BY localite, nbr_years
    HAVING COUNT(DISTINCT customer_id) > 1
    ORDER BY nbr_customers DESC;        

-- excercise: How many food items did we sell in 2025?

SELECT COUNT(*) AS nbr_food_items_sold FROM customer_summary_mv
    WHERE category_name = 'Food'
    AND date >= '2025-01-01' AND date < '2026-01-01';

-- How many food items did we sell in 2025 per commune, localite, and product?

SELECT commune, localite, product_name, COUNT(*) AS nbr_food_items_sold FROM customer_summary_mv
    WHERE category_name = 'Food'
    AND date >= '2025-01-01' AND date < '2026-01-01'
    GROUP BY commune, localite, product_name
    ORDER BY commune, localite, product_name;

-- How many food items did we sell in the commune of Junglinster, by localite, product, year and month?

SELECT commune, localite, product_name, EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, COUNT(*) AS nbr_food_items_sold 
    FROM customer_summary_mv
    WHERE category_name = 'Food'
    AND commune = 'Junglinster'
    GROUP BY commune, localite, product_name, year, month
    ORDER BY commune, localite, product_name, year, month;


-- How many food items did we sell for how much by year and month in the commune of Junglinster, by localite, product?

SELECT EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, 
    localite, product_name, 
    SUM (quantity)AS nbr_food_items_sold, 
    SUM (price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE category_name = 'Food'
    AND commune = 'Junglinster'
    GROUP BY year, month,  localite, product_name
    ORDER BY year, month,  localite, product_name ASC;

-- use ROLLUP to count the number of customers per commune, and localite, and the total number of customers
SELECT commune, localite, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    WHERE commune  IN ('Junglinster','Bech')
    GROUP BY ROLLUP(commune, localite)
    ORDER BY commune, localite ASC;

-- use ROLLUP to get totals by year and month
SELECT EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, 
    localite, product_name, 
    SUM (quantity)AS nbr_food_items_sold, 
    SUM (price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE category_name = 'Food'
    AND commune = 'Junglinster'
    GROUP BY ROLLUP(year, month,  localite, product_name)
    ORDER BY year, month,  localite, product_name ASC;

-- Compare CUBE and ROLLUP

SELECT commune, localite, category_name, sum(price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE commune  IN ('Junglinster','Bech')
    GROUP BY ROLLUP(commune, localite, category_name)
    ORDER BY commune, localite, category_name ASC;

SELECT commune, localite, category_name, sum(price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE commune  IN ('Junglinster','Bech')
    GROUP BY CUBE (commune, localite, category_name)
    ORDER BY commune, localite, category_name ASC;    

-- excercise    
-- 1) Report showing total sales price per commune and category for sales in 2026
SELECT commune,category_name, sum(price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE date >= '2026-01-01' AND date < '2027-01-01'
    GROUP BY commune, category_name
    ORDER BY commune, category_name ASC;

-- 2) with subtotals per commune and category, and a grand total for all communes and categories
SELECT commune,category_name, sum(price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE date >= '2026-01-01' AND date < '2027-01-01'
    GROUP BY ROLLUP(commune, category_name)
    ORDER BY commune, category_name ASC; 

-- 3) with subtotals per commune and category, and a grand total for all communes and categories, but also with subtotals per category across all communes
SELECT commune,category_name, sum(price * quantity) AS total_sales
    FROM customer_summary_mv
    WHERE date >= '2026-01-01' AND date < '2027-01-01'
    GROUP BY CUBE(commune, category_name)
    ORDER BY commune, category_name ASC;    





/* CTE */

WITH customer_counts AS (
    SELECT localite, COUNT(DISTINCT customer_id) AS nbr_customers
    FROM customer_summary_mv
    GROUP BY localite
)
SELECT * FROM customer_counts
    WHERE nbr_customers > 1
    ORDER BY nbr_customers DESC;


-- What did my top 10 customers buy in 2025? 
-- Show the total quantity purchased per product per customer.
WITH top_10_customers AS (
    SELECT customer_id, COUNT(*) AS nbr_purchases
    FROM customer_summary_mv
    GROUP BY customer_id
    ORDER BY nbr_purchases DESC
    LIMIT 10
)
SELECT customer_id, first_name, last_name, product_name, SUM(quantity) AS total_quantity FROM customer_summary_mv
    JOIN top_10_customers USING (customer_id)
    WHERE date >= '2025-01-01' AND date < '2026-01-01'
    GROUP BY customer_id, first_name, last_name, product_name
    ORDER BY customer_id, product_name;

-- What did my top 10 customers buy from the top 10 products in 2025? 
-- Show the total quantity purchased per product per customer.
WITH top_10_customers AS (
    SELECT customer_id, COUNT(*) AS nbr_purchases
    FROM customer_summary_mv
    GROUP BY customer_id
    ORDER BY nbr_purchases DESC
    LIMIT 10
),
top_10_products AS (
    SELECT product_nbr, COUNT(*) AS nbr_sales
    FROM customer_summary_mv
    GROUP BY product_nbr
    ORDER BY nbr_sales DESC
    LIMIT 10
)
SELECT customer_id, first_name, last_name, product_name, SUM(quantity) AS total_quantity FROM customer_summary_mv
    JOIN top_10_customers USING (customer_id)
    JOIN top_10_products USING (product_nbr)
    WHERE date >= '2025-01-01' AND date < '2026-01-01'
    GROUP BY customer_id, first_name, last_name, product_name
    ORDER BY customer_id, product_name;


-- Create a CTE to find how many of the TOP 10 food items did my customers in Esch and Duedange buy in 2025?
WITH top_10_products AS (
    SELECT product_nbr, COUNT(*) AS nbr_sales
    FROM customer_summary_mv
    GROUP BY product_nbr
    ORDER BY nbr_sales DESC
    LIMIT 10
)
SELECT commune, product_name, SUM(quantity) AS total_quantity FROM customer_summary_mv
    JOIN top_10_products USING (product_nbr)
    WHERE date >= '2025-01-01' AND date < '2026-01-01'
    AND commune IN ('Esch-sur-Alzette', 'Dudelange')
    GROUP BY commune, product_name
    ORDER BY commune, product_name;

/*

    JSON(B)

*/

-- use this in psql to pretty print the JSONB columns
SELECT id, first_name, last_name, address_id, since, 
    jsonb_pretty(phone_numbers) AS phone_numbers, 
    jsonb_pretty(email_addresses) AS email_addresses,
    jsonb_pretty(social_media) AS social_media
    FROM customer 
    WHERE id =2;




-- access the private mobile number for the 5th customer
-- explain the JSONB path '{private,mobile}' and the difference between #> and #>> operators

SELECT 
    -- gets the column
    phone_numbers, 
    -- gets the subdocument with the key 'private'
    phone_numbers #> '{private}' AS private_phone_numbers,
    -- gets the subdocument with the key 'private, mobile'
    phone_numbers #> '{private,mobile}' AS private_mobile_number_jsonb, 
    -- gets the value with the key 'private, mobile'
    phone_numbers #>> '{private,mobile}' AS private_mobile_number_text 
    FROM customer  
    WHERE id = 2;


-- return the value as string using the #>> operator
SELECT 
    phone_numbers #>> '{private,mobile}' AS private_mobile_number,
    phone_numbers #>> '{work,mobile}' AS work_mobile_number_text
    FROM customer  
    WHERE id < 5;

-- explain the use of -> and ->> operators to access JSONB values
SELECT 
    phone_numbers -> 'private'-> 'mobile' AS private_mobile_number,
    phone_numbers ->> 'work' AS work_mobile_number_text
    FROM customer  
    WHERE id < 5;  

-- add a new phone number to the first customer, in the group work with label car2
-- use jsonb_set to add a new key-value pair to the work object

UPDATE customer
SET phone_numbers = JSONB_SET(phone_numbers, '{work,car 2}', '"(+352) 111 222 334"')
WHERE id = 1
RETURNING jsonb_pretty(phone_numbers) AS phone_numbers;

-- remove the phone number for the "car 2" label for the first customer
UPDATE customer
SET phone_numbers = phone_numbers - '{work,car 2}'
WHERE id = 1;

-- find all customers that have a private mobile phone number

SELECT id, first_name, last_name, phone_numbers #>> '{private,mobile}' AS private_mobile_number
    FROM CUSTOMER 
    WHERE phone_numbers #>> '{private,mobile}' IS NOT NULL
    ORDER BY phone_numbers #>> '{private,mobile}' ASC;

-- find all customers living in Junglinster, that have a Twitter handle
SELECT * FROM customer c
    JOIN address a ON c.address_id = a.id
    WHERE a.commune = 'Junglinster'
    AND c.social_media #>> '{Twitter}' IS NOT NULL;


-- set the phone number for the "home" label for the first customer to "(+352) 987 654 321"
-- without using jsonb_set
UPDATE customer
SET phone_numbers = jsonb_build_object('home', '(+352) 987 654 321')
WHERE id = 2;

SELECT jsonb_pretty(phone_numbers) AS phone_numbers
    FROM customer
    WHERE id = 2;

-- add a new phone number to the first customer, with label "work" and number "(+352) 123 456 789"
UPDATE customer
SET phone_numbers = phone_numbers || jsonb_build_object('work', '(+352) 123 456 789')
WHERE id = 1;

-- change the phone number for the "home" label for the first customer to "(+352) 987 654 321"
-- if it doesn't exist, add it
UPDATE customer
SET phone_numbers = jsonb_set(phone_numbers, '{home}', '"(+352) 987 654 321"')
WHERE id = 1;

-- now change the phone number for the "home" label for the first customer to "(+352) 111 222 333"
UPDATE customer
SET phone_numbers = jsonb_set(phone_numbers, '{home}', '"(+352) 111 222 333"')
WHERE id = 1
RETURNING jsonb_pretty(phone_numbers) AS phone_numbers;

-- delete the phone number for the "home" label for the first customer
UPDATE customer
SET phone_numbers = phone_numbers - 'home'
WHERE id = 1
RETURNING jsonb_pretty(phone_numbers) AS phone_numbers;

-- add a JSONB nested object for social media for the first customer, 
-- with sets for work accounts and personal accounts, each with a Twitter and LinkedIn account

UPDATE customer
SET social_media = jsonb_build_object(
    'work', jsonb_build_object(
        'Twitter', 'work_twitter_1',
        'LinkedIn', 'work_linkedin_1'
    ),
    'personal', jsonb_build_object(
        'Twitter', 'personal_twitter_1',
        'LinkedIn', 'personal_linkedin_1'
    )
)
WHERE id = 1;

-- update the personal Twitter account for the first customer to "personal_twitter_2"
-- navigate to the personal Twitter account using the path '{personal,Twitter}'.
UPDATE customer
SET social_media = jsonb_set(social_media, '{personal,Twitter}', '"personal_twitter_2"')
WHERE id = 1
RETURNING jsonb_pretty(social_media) AS social_media;

/* WINDOW FUNCTIONS */

/*

Compare product prices to the avg of their category
Percentage of total sales by commune descending

*/


-- Putting the price of a product in comparision with the average price of the category

SELECT c.name, p.name, p.price
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;

SELECT c.name, p.name, p.price,
    ROUND(AVG(p.price) OVER (PARTITION BY c.name),2) AS avg_category
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;

SELECT c.name, p.name, p.price AS p_price,
    ROUND(AVG(p.price) OVER (PARTITION BY c.name),2) AS c_avg,
    ROUND(MIN(p.price) OVER (PARTITION BY c.name),2) AS c_min,
    ROUND(MAX(p.price) OVER (PARTITION BY c.name),2) AS c_max
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;  

-- Rank the products by price within their category
SELECT c.name, p.name, p.price p_price,
    ROUND(AVG(p.price) OVER (PARTITION BY c.name),2) AS c_avg,
    ROUND(MIN(p.price) OVER (PARTITION BY c.name),2) AS c_min,
    ROUND(MAX(p.price) OVER (PARTITION BY c.name),2) AS c_max,
    RANK() OVER (PARTITION BY c.name ORDER BY p.price ASC) AS pp_rank
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, pp_rank ASC;

-- Order communes by sales in descending order
SELECT commune, SUM(price * quantity) AS total_sales
    FROM customer_summary_mv
    GROUP BY commune
    ORDER BY total_sales DESC;

-- Rank the total sales by commune in descending order
SELECT commune, SUM(price * quantity) AS total_sales,
    RANK() OVER (ORDER BY SUM(price * quantity) DESC) AS sales_rank
    FROM customer_summary_mv
    GROUP BY commune
    ORDER BY total_sales DESC;

-- Rank the total sales by commune in descending order and show the percentage of total sales by commune
SELECT commune, SUM(price * quantity) AS total_sales,
    RANK() OVER (ORDER BY SUM(price * quantity) DESC) AS sales_rank,
    ROUND(SUM(price * quantity) * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS pct_total_sales
    FROM customer_summary_mv
    GROUP BY commune
    ORDER BY total_sales DESC;    

SELECT commune, SUM(price * quantity) AS total_sales
    FROM customer_summary_mv
    GROUP BY commune
    ORDER BY total_sales DESC;        

-- Add a running total of sales by commune in descending order and show the percentage of total sales by commune
SELECT commune,
       SUM(price * quantity) AS total_sales,
       RANK() OVER (
                    ORDER BY SUM(price * quantity) DESC) AS sales_rank,
       ROUND(SUM(price * quantity) * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS pct_total_sales,
       SUM(SUM(price * quantity)) OVER w AS running_total,
       ROUND(SUM(SUM(price * quantity)) OVER w * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS running_pct
FROM customer_summary_mv
GROUP BY commune WINDOW w AS (
                              ORDER BY SUM(price * quantity) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY total_sales DESC;

-- excercise: Create a report that ranks the localities within Junglinster and Bech by 2026 sales, and shows the percentile ranking for each localite
SELECT localite,
       SUM(price * quantity) AS total_sales,
       RANK() OVER (
                    ORDER BY SUM(price * quantity) DESC) AS sales_rank,
       ROUND(SUM(price * quantity) * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS pct_total_sales,
       SUM(SUM(price * quantity)) OVER w AS running_total,
       ROUND(SUM(SUM(price * quantity)) OVER w * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS running_pct
FROM customer_summary_mv
WHERE commune IN ('Junglinster', 'Bech')
AND date >= '2026-01-01' AND date < '2027-01-01'
GROUP BY localite WINDOW w AS (
                              ORDER BY SUM(price * quantity) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY total_sales DESC;

-- Rank the individual customers within the commune of Junglinster by their total 2026 sales
SELECT customer_id,
       first_name,
       last_name,
       SUM(price * quantity) AS total_sales,
       RANK() OVER (
                    ORDER BY SUM(price * quantity) DESC) AS sales_rank
FROM customer_summary_mv
WHERE commune = 'Junglinster'
AND date >= '2026-01-01' AND date < '2027-01-01'
GROUP BY customer_id, first_name, last_name
ORDER BY total_sales DESC;

-- add a percentile ranking for each customer within the commune of Junglinster by their total 2026 sales
SELECT customer_id,
       first_name,
       last_name,
       SUM(price * quantity) AS total_sales,
       RANK() OVER (
                    ORDER BY SUM(price * quantity) DESC) AS sales_rank,
       ROUND(SUM(price * quantity) * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS pct_total_sales,
       SUM(SUM(price * quantity)) OVER w AS running_total,
       ROUND(SUM(SUM(price * quantity)) OVER w * 100.0 / SUM(SUM(price * quantity)) OVER (), 2) AS running_pct
FROM customer_summary_mv
WHERE commune = 'Junglinster'
AND date >= '2026-01-01' AND date < '2027-01-01'
GROUP BY customer_id, first_name, last_name WINDOW w AS (
                              ORDER BY SUM(price * quantity) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY total_sales DESC;