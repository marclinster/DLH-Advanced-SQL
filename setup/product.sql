/***************************************************************************************************

Creates the table product and loads sample data into it. 

The sproc reset_product_prices() is also created to reset the prices of the products to their original values.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


DROP TABLE IF EXISTS product CASCADE;

CREATE TABLE product (
    product_nbr TEXT PRIMARY KEY,
    category_id INTEGER REFERENCES category(id),
	name TEXT,
	price NUMERIC(10,2)
);	

ALTER TABLE product ADD CONSTRAINT product_price_check CHECK (price > 0);


INSERT INTO product (product_nbr, category_id, name, price) 
    VALUES 
        ('cheese_30', 5, 'Cheese 30%', 3.49),
        ('bread', 6, 'Bread', 1.49),
        ('butter', 6, 'Butter', 2.49),
        ('milk', 6, 'Milk 1L', 1.09),
        ('cola_1L', 7, 'Cola 1L', 1.29),
        ('water_1L', 7, 'Water 1L', 0.89),
        ('chips', 8, 'Chips', 1.49),
        ('cookie', 8, 'Cookie', 1.19),
        ('candy', 8, 'Candy', 0.79),
        ('detergent', 9, 'Detergent', 5.49),
        ('shampoo', 9, 'Shampoo', 3.99),
        ('soap', 9, 'Soap', 1.29);        


CREATE VIEW product_category_vw AS
SELECT p.product_nbr,
       category_id,
       p.name AS product_name,
       p.price AS product_price,
       c.name as category_name
FROM product AS p
JOIN category AS c ON c.id = p.category_id;

CREATE OR REPLACE PROCEDURE reset_product_prices ()
LANGUAGE SQL
AS $$
    UPDATE product AS p
    SET price = v.price
    FROM (VALUES
        ('cheese_30', 3.49),
        ('bread', 1.49),
        ('butter', 2.49),
        ('milk', 1.09),
        ('cola_1L', 1.29),
        ('water_1L', 0.89),
        ('chips', 1.49),
        ('cookie', 1.19),
        ('candy', 0.79),
        ('detergent', 5.49),
        ('shampoo', 3.99),
        ('soap', 1.29)
    ) AS v(product_nbr, price)
    WHERE p.product_nbr = v.product_nbr;
$$;

CALL reset_product_prices ();