DROP TABLE IF EXISTS product CASCADE;

CREATE TABLE product (
    product_nbr TEXT PRIMARY KEY,
    category_id INTEGER REFERENCES category(id),
	name TEXT,
	price NUMERIC(10,2),
    CHECK (price > 0)
);	




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


SELECT * FROM product JOIN category ON product.category_id = category.id;

CREATE VIEW product_category_vw AS
SELECT p.product_nbr,
       category_id,
       p.name AS product_name,
       p.price AS product_price,
       c.name as category_name
FROM product AS p
JOIN category AS c ON c.id = p.category_id;