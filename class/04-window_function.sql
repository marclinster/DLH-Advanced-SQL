
/***************************************************************************************************

Database setup script for the DLH Advanced SQL course. This file provides
an overview of window functions in SQL.

The examples use the database dlh_adv_sql, which is created by the setup.sql script.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


-- make sure that this view exists, if not create it
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


-- Putting the price of a product in comparision with the average price of the category

SELECT c.name category, p.name product, p.price price
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;

SELECT c.name category, p.name product, p.price price,
    ROUND(AVG(p.price) OVER (PARTITION BY c.name),2) AS avg_category
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;

SELECT c.name category, p.name product, p.price price AS p_price,
    ROUND(AVG(p.price) OVER (PARTITION BY c.name),2) AS c_avg,
    ROUND(MIN(p.price) OVER (PARTITION BY c.name),2) AS c_min,
    ROUND(MAX(p.price) OVER (PARTITION BY c.name),2) AS c_max
    FROM product p
    JOIN category c ON p.category_id = c.id
    ORDER BY c.name, p.name;  

-- Rank the products by price within their category
SELECT c.name category, p.name product, p.price price AS p_price,
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