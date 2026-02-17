/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated Feb 17 2026
****************************************************************************************************/

-- connect to dlh3 database

-- functions to generate phone numbers for customers

CREATE OR REPLACE FUNCTION generate_random_phone_number (country_prefix TEXT) RETURNS TEXT
AS 
$$
    DECLARE 
        phone_number TEXT;
    BEGIN  
        phone_number := 
            FORMAT(
                '+%s (%s) %s-%s', 
                country_prefix,
                lpad (floor(random() * 1000)::text, 3, '1'), 
                lpad (floor(random() * 1000)::text, 3, '2'),
                lpad (floor(random() * 1000)::text, 3, '3')
                );
    RETURN phone_number;
    END;        
$$  LANGUAGE PLPGSQL;          

CREATE OR REPLACE FUNCTION generate_random_phone_numbers(geo TEXT DEFAULT 'US') RETURNS JSONB AS $$
-- random switch between landline (6 digits in groups of 2) and mobile (9 digits in groups of 3)
DECLARE
	country_prefix VARCHAR(4);
BEGIN
    IF geo = 'US' THEN country_prefix := '1'; ELSE country_prefix := '352'; END IF;
	IF RANDOM() > 0.5 THEN --- 50% of cases add a home line
		RETURN jsonb_build_object (
            'home', generate_random_phone_number(country_prefix), 
            'mobile', generate_random_phone_number(country_prefix)
            );
    ELSE    
        RETURN jsonb_build_object ('mobile', generate_random_phone_number(country_prefix));
    END IF; 
END;
$$ LANGUAGE plpgsql;



---
DROP TABLE IF EXISTS product CASCADE;

CREATE TABLE product (
    product_nbr TEXT PRIMARY KEY,
    category TEXT,
	name TEXT,
	price NUMERIC(10,2),
    CHECK (price > 0)
);	


INSERT INTO product (product_nbr, category, name, price) 
    VALUES 
        ('cheese_10', 'food', 'Cheese 10%', 2.99),
        ('cheese_30', 'food', 'Cheese 30%', 3.49),
        ('ham', 'food', 'Ham', 4.99),
        ('bread', 'food', 'Bread', 1.49),
        ('butter', 'food', 'Butter', 2.49),
        ('milk', 'food', 'Milk 1L', 1.09),
        ('cola_1L', 'drink', 'Cola 1L', 1.29),
        ('cola_2L', 'drink', 'Cola 2L', 1.99),
        ('water_1L', 'drink', 'Water 1L', 0.89),
        ('water_5L', 'drink', 'Water 5L', 3.49),
        ('chips', 'snack', 'Chips', 1.49),
        ('chocolate', 'snack', 'Chocolate', 0.99),
        ('cookie', 'snack', 'Cookie', 1.19),
        ('candy', 'snack', 'Candy', 0.79),
        ('gum', 'snack', 'Gum', 0.49),
        ('napkin', 'other', 'Napkin', 0.10),
        ('toiletpaper', 'other', 'Toilet Paper', 0.99),
        ('detergent', 'other', 'Detergent', 5.49),
        ('shampoo', 'other', 'Shampoo', 3.99),
        ('soap', 'other', 'Soap', 1.29);

DROP TABLE IF EXISTS customer CASCADE;

CREATE TABLE customer  (
    id INTEGER PRIMARY KEY,
    email TEXT,
    first_name TEXT,
    last_name TEXT,
    town TEXT,
    since DATE,
    phone_numbers JSONB
);    

INSERT INTO customer (id, email, first_name, last_name, town, since) VALUES
    (1, 'alice.lux@pt.lu', 'Alice', 'Becker', 'Differdange', '2022-03-14'),
    (2, 'luke.lux@pt.lu', 'Luke', 'Wagner', 'Differdange', '2021-06-28'),
    (3, 'nina.lux@pt.lu', 'Nina', 'Keller', 'Differdange', '2020-09-11'),
    (4, 'max.lux@pt.lu', 'Max', 'Fischer', 'Differdange', '2024-01-05'),
    (5, 'sophie.lux@pt.lu', 'Sophie', 'Schmit', 'Differdange', '2023-07-19'),
    (6, 'paul.lux@pt.lu', 'Paul', 'Stein', 'Differdange', '2022-12-27'),
    (7, 'emma.lux@pt.lu', 'Emma', 'Hoffmann', 'Differdange', '2020-04-30'),
    (8, 'lena.lux@pt.lu', 'Lena', 'Schneider', 'Differdange', '2021-11-16'),
    (9, 'tom.lux@pt.lu', 'Tom', 'Lang', 'Differdange', '2023-02-08'),
    (10, 'mia.lux@pt.lu', 'Mia', 'Frank', 'Differdange', '2022-08-22'),
    (11, 'marc.dupont@pt.lu', 'Marc', 'Dupont', 'Esch', '2021-07-10'),
    (12, 'claire.schmit@pt.lu', 'Claire', 'Schmit', 'Differdange', '2024-02-19'),
    (13, 'julien.muller@pt.lu', 'Julien', 'Muller', 'Esch', '2023-11-08'),
    (14, 'laura.weber@pt.lu', 'Laura', 'Weber', 'Differdange', '2022-05-15'),
    (15, 'pierre.klein@pt.lu', 'Pierre', 'Klein', 'Esch', '2020-07-22'),
    (16, 'sarah.fischer@pt.lu', 'Sarah', 'Fischer', 'Differdange', '2023-06-30'),
    (17, 'lucas.frank@pt.lu', 'Lucas', 'Frank', 'Esch', '2022-01-11'),
    (18, 'emma.stein@pt.lu', 'Emma', 'Stein', 'Differdange', '2021-09-25'),
    (19, 'leo.lang@pt.lu', 'Leo', 'Lang', 'Esch', '2020-03-14'),
    (20, 'nina.hoffmann@pt.lu', 'Nina', 'Hoffmann', 'Differdange', '2023-04-01'),
    (21, 'alex.schneider@pt.lu', 'Alex', 'Schneider', 'Esch', '2022-12-14'),
    (22, 'sophie.becker@pt.lu', 'Sophie', 'Becker', 'Differdange', '2020-08-18'),
    (23, 'tom.wagner@pt.lu', 'Tom', 'Wagner', 'Esch', '2023-02-05'),
    (24, 'lena.keller@pt.lu', 'Lena', 'Keller', 'Differdange', '2021-04-20'),
    (25, 'paul.schmit@pt.lu', 'Paul', 'Schmit', 'Esch', '2021-10-09'),
    (26, 'mia.dupont@pt.lu', 'Mia', 'Dupont', 'Differdange', '2022-06-23'),
    (27, 'max.fischer@pt.lu', 'Max', 'Fischer', 'Esch', '2020-11-17'),
    (28, 'eva.klein@pt.lu', 'Eva', 'Klein', 'Differdange', '2024-05-01'),
    (29, 'daniel.weber@pt.lu', 'Daniel', 'Weber', 'Esch', '2022-03-27'),
    (30, 'carla.muller@pt.lu', 'Carla', 'Muller', 'Differdange', '2023-07-13'),
    (31, 'ben.schneider@pt.lu', 'Ben', 'Schneider', 'Esch', '2021-06-21'),
    (32, 'first1.last1@pt.lu', 'First1', 'Last1', 'Differdange', '2020-09-30'),
    (33, 'first2.last2@pt.lu', 'First2', 'Last2', 'Esch', '2023-12-12'),
    (34, 'first3.last3@pt.lu', 'First3', 'Last3', 'Differdange', '2021-08-16'),
    (35, 'first4.last4@pt.lu', 'First4', 'Last4', 'Esch', '2022-10-02'),
    (36, 'first5.last5@pt.lu', 'First5', 'Last5', 'Differdange', '2023-05-28'),
    (37, 'first6.last6@pt.lu', 'First6', 'Last6', 'Esch', '2020-01-19'),
    (38, 'first7.last7@pt.lu', 'First7', 'Last7', 'Differdange', '2021-03-05'),
    (39, 'first8.last8@pt.lu', 'First8', 'Last8', 'Esch', '2024-04-10'),
    (40, 'first9.last9@pt.lu', 'First9', 'Last9', 'Differdange', '2022-07-30');    
    -- Add 30 new customers to the 'customer' table
INSERT INTO customer (id, email, first_name, last_name, town, since) VALUES
(41, 'julia.meyer@pt.lu', 'Julia', 'Meyer', 'Bridel', '2022-07-14'),
(42, 'felix.bauer@pt.lu', 'Felix', 'Bauer', 'Kopstal', '2021-03-29'),
(43, 'anna.schmit@pt.lu', 'Anna', 'Schmit', 'Koerich', '2020-11-06'),
(44, 'louis.dupont@pt.lu', 'Louis', 'Dupont', 'Bridel', '2023-02-18'),
(45, 'lucie.weber@pt.lu', 'Lucie', 'Weber', 'Kopstal', '2024-05-03'),
(46, 'simon.klein@pt.lu', 'Simon', 'Klein', 'Koerich', '2023-09-10'),
(47, 'marie.hoffmann@pt.lu', 'Marie', 'Hoffmann', 'Bridel', '2021-12-25'),
(48, 'paul.muller@pt.lu', 'Paul', 'Muller', 'Kopstal', '2022-04-02'),
(49, 'emma.schneider@pt.lu', 'Emma', 'Schneider', 'Koerich', '2020-08-19'),
(50, 'benjamin.lang@pt.lu', 'Benjamin', 'Lang', 'Bridel', '2024-03-13'),
(51, 'clara.fischer@pt.lu', 'Clara', 'Fischer', 'Kopstal', '2022-11-07'),
(52, 'maxime.frank@pt.lu', 'Maxime', 'Frank', 'Koerich', '2021-06-18'),
(53, 'lea.wagner@pt.lu', 'Lea', 'Wagner', 'Bridel', '2023-08-21'),
(54, 'ethan.becker@pt.lu', 'Ethan', 'Becker', 'Kopstal', '2020-05-30'),
(55, 'zoe.stein@pt.lu', 'Zoe', 'Stein', 'Koerich', '2022-02-14'),
(56, 'alexandre.muller@pt.lu', 'Alexandre', 'Muller', 'Bridel', '2023-06-09'),
(57, 'camille.schneider@pt.lu', 'Camille', 'Schneider', 'Kopstal', '2021-09-03'),
(58, 'nicolas.lang@pt.lu', 'Nicolas', 'Lang', 'Koerich', '2024-01-26'),
(59, 'julie.fischer@pt.lu', 'Julie', 'Fischer', 'Bridel', '2022-10-15'),
(60, 'victor.frank@pt.lu', 'Victor', 'Frank', 'Kopstal', '2020-12-08'),
(61, 'sarah.wagner@pt.lu', 'Sarah', 'Wagner', 'Koerich', '2023-04-27'),
(62, 'lucas.becker@pt.lu', 'Lucas', 'Becker', 'Bridel', '2021-05-17'),
(63, 'alice.stein@pt.lu', 'Alice', 'Stein', 'Kopstal', '2022-09-22'),
(64, 'julien.muller@pt.lu', 'Julien', 'Muller', 'Koerich', '2024-06-02'),
(65, 'nina.schneider@pt.lu', 'Nina', 'Schneider', 'Bridel', '2020-10-13'),
(66, 'tom.lang@pt.lu', 'Tom', 'Lang', 'Kopstal', '2023-12-04'),
(67, 'mia.fischer@pt.lu', 'Mia', 'Fischer', 'Koerich', '2021-08-28'),
(68, 'leo.frank@pt.lu', 'Leo', 'Frank', 'Bridel', '2022-01-19'),
(69, 'eva.wagner@pt.lu', 'Eva', 'Wagner', 'Kopstal', '2020-06-20'),
(70, 'sophie.becker@pt.lu', 'Sophie', 'Becker', 'Koerich', '2024-04-15'),
(71, 'marc.mamer@pt.lu', 'Marc', 'Mamer', 'Koerich', '2024-04-15');

DROP TABLE IF EXISTS purchase;

CREATE TABLE purchase (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    order_date DATE,
    customer_id INTEGER REFERENCES customer(id),
    product_nbr TEXT REFERENCES product(product_nbr),
    quantity INTEGER CHECK (quantity > 0)
);


INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-01-02', 11, 'bread', 2),
('2025-01-05', 13, 'cola_2L', 1),
('2025-01-07', 15, 'chips', 4),
('2025-01-13', 17, 'water_1L', 3),
('2025-01-18', 19, 'gum', 2),
('2025-01-20', 21, 'cola_1L', 1),
('2025-01-25', 23, 'milk', 5),
('2025-02-01', 25, 'cheese_10', 2),
('2025-02-08', 27, 'soap', 3),
('2025-02-13', 29, 'cookie', 4);

-- 40 orders from Esch customers
INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-01-02', 11, 'bread', 2),
('2025-01-05', 13, 'cola_2L', 1),
('2025-01-07', 15, 'chips', 4),
('2025-01-13', 17, 'water_1L', 3),
('2025-01-18', 19, 'gum', 2),
('2025-01-20', 21, 'cola_1L', 1),
('2025-01-25', 23, 'milk', 5),
('2025-02-01', 25, 'cheese_10', 2),
('2025-02-08', 27, 'soap', 3),
('2025-02-13', 29, 'cookie', 4),
('2025-02-15', 31, 'chocolate', 2),
('2025-02-19', 33, 'chips', 1),
('2025-02-25', 35, 'cola_1L', 3),
('2025-03-04', 37, 'bread', 2),
('2025-03-09', 39, 'cheese_30', 5),
('2025-03-12', 11, 'napkin', 1),
('2025-03-18', 13, 'cola_2L', 2),
('2025-03-22', 15, 'chocolate', 4),
('2025-03-28', 17, 'milk', 3),
('2025-04-01', 19, 'chips', 2),
('2025-04-08', 21, 'cheese_10', 1),
('2025-04-13', 23, 'cola_1L', 3),
('2025-04-18', 25, 'water_5L', 5),
('2025-04-28', 27, 'cookie', 2),
('2025-05-02', 29, 'ham', 1),
('2025-05-09', 31, 'detergent', 3),
('2025-05-15', 33, 'gum', 5),
('2025-05-22', 35, 'shampoo', 2),
('2025-05-27', 37, 'soap', 4),
('2025-06-03', 39, 'milk', 1),
('2025-06-11', 11, 'napkin', 2),
('2025-06-18', 13, 'cola_2L', 3),
('2025-06-23', 15, 'chips', 1),
('2025-07-02', 17, 'water_5L', 5),
('2025-07-09', 19, 'milk', 2),
('2025-07-17', 21, 'cola_1L', 4),
('2025-07-25', 23, 'cheese_30', 3),
('2025-08-02', 25, 'chips', 1),
('2025-08-09', 27, 'soap', 2),
('2025-08-15', 29, 'cheese_10', 5);

-- 160 orders from Kopstal, Koerich, Differdange (sample rows, randomize as needed)
INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-01-03', 1, 'gum', 2),
('2025-01-06', 2, 'napkin', 1),
('2025-01-09', 3, 'chips', 4),
('2025-01-14', 4, 'cola_1L', 3),
('2025-01-19', 5, 'bread', 2),
('2025-01-22', 6, 'cola_2L', 5),
('2025-01-27', 7, 'milk', 1),
('2025-02-03', 8, 'cheese_10', 2),
('2025-02-09', 9, 'water_5L', 3),
('2025-02-15', 10, 'chips', 4);


INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-01-03', 12, 'milk', 3),
('2025-01-05', 14, 'gum', 1),
('2025-01-07', 16, 'cola_2L', 5),
('2025-01-09', 18, 'chips', 2),
('2025-01-11', 20, 'cookie', 4),
('2025-01-13', 22, 'water_1L', 3),
('2025-01-15', 24, 'chocolate', 2),
('2025-01-17', 26, 'cola_1L', 1),
('2025-01-19', 28, 'bread', 5),
('2025-01-21', 30, 'candy', 2),
('2025-01-23', 32, 'cheese_30', 4),
('2025-01-25', 34, 'cheese_10', 1),
('2025-01-27', 36, 'water_5L', 3),
('2025-01-29', 38, 'cookie', 2),
('2025-01-31', 40, 'detergent', 1);

INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-02-02', 12, 'cheese_30', 2),
('2025-02-07', 14, 'cola_1L', 4),
('2025-02-12', 16, 'butter', 1),
('2025-02-17', 18, 'water_5L', 3),
('2025-02-22', 20, 'chips', 5),
('2025-02-27', 22, 'chocolate', 2),
('2025-03-03', 24, 'milk', 1),
('2025-03-08', 26, 'gum', 2),
('2025-03-13', 28, 'cookie', 4),
('2025-03-18', 30, 'candy', 3),
('2025-03-23', 32, 'cola_2L', 5),
('2025-03-28', 34, 'shampoo', 2),
('2025-04-02', 36, 'soap', 1),
('2025-04-07', 38, 'toiletpaper', 2),
('2025-04-12', 40, 'detergent', 4);

INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-06-01', 43, 'chips', 2),
('2025-06-02', 46, 'chocolate', 5),
('2025-06-03', 49, 'cookie', 3),
('2025-06-04', 52, 'candy', 1),
('2025-06-05', 55, 'gum', 4),
('2025-06-06', 58, 'chips', 1),
('2025-06-07', 61, 'chocolate', 2),
('2025-06-08', 64, 'cookie', 4),
('2025-06-09', 67, 'candy', 2),
('2025-06-10', 70, 'gum', 5),
('2025-06-11', 43, 'chips', 3),
('2025-06-12', 46, 'chocolate', 2),
('2025-06-13', 49, 'cookie', 1),
('2025-06-14', 52, 'candy', 5),
('2025-06-15', 55, 'gum', 2),
('2025-06-16', 58, 'chips', 4),
('2025-06-17', 61, 'chocolate', 1),
('2025-06-18', 64, 'cookie', 5),
('2025-06-19', 67, 'candy', 3),
('2025-06-20', 70, 'gum', 2),
('2025-06-21', 43, 'chips', 5),
('2025-06-22', 46, 'chocolate', 1),
('2025-06-23', 49, 'cookie', 2),
('2025-06-24', 52, 'candy', 4),
('2025-06-25', 55, 'gum', 3),
('2025-06-26', 58, 'chips', 2),
('2025-06-27', 61, 'chocolate', 3),
('2025-06-28', 64, 'cookie', 4),
('2025-06-29', 67, 'candy', 5),
('2025-06-30', 70, 'gum', 1),
('2025-06-05', 43, 'chips', 1),
('2025-06-06', 46, 'chocolate', 4),
('2025-06-07', 49, 'cookie', 2),
('2025-06-08', 52, 'candy', 3),
('2025-06-09', 55, 'gum', 5),
('2025-06-10', 58, 'chips', 2),
('2025-06-11', 61, 'chocolate', 5),
('2025-06-12', 64, 'cookie', 1),
('2025-06-13', 67, 'candy', 2),
('2025-06-14', 70, 'gum', 3),
('2025-06-15', 43, 'chips', 4),
('2025-06-16', 46, 'chocolate', 2),
('2025-06-17', 49, 'cookie', 5),
('2025-06-18', 52, 'candy', 1),
('2025-06-19', 55, 'gum', 4),
('2025-06-20', 58, 'chips', 3),
('2025-06-21', 61, 'chocolate', 2),
('2025-06-22', 64, 'cookie', 3),
('2025-06-23', 67, 'candy', 1);

INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-06-01', 43, 'cola_1L', 3),
('2025-06-02', 46, 'cola_2L', 2),
('2025-06-03', 49, 'water_1L', 5),
('2025-06-04', 52, 'water_5L', 1),
('2025-06-05', 55, 'cola_1L', 4),
('2025-06-06', 58, 'cola_2L', 2),
('2025-06-07', 61, 'water_1L', 3),
('2025-06-08', 64, 'water_5L', 1),
('2025-06-09', 67, 'cola_1L', 5),
('2025-06-10', 70, 'cola_2L', 2),
('2025-06-11', 43, 'water_1L', 2),
('2025-06-12', 46, 'water_5L', 3),
('2025-06-13', 49, 'cola_1L', 4),
('2025-06-14', 52, 'cola_2L', 1),
('2025-06-15', 55, 'water_1L', 5),
('2025-06-16', 58, 'water_5L', 2),
('2025-06-17', 61, 'cola_1L', 3),
('2025-06-18', 64, 'cola_2L', 4),
('2025-06-19', 67, 'water_1L', 1),
('2025-06-20', 70, 'water_5L', 5);

INSERT INTO purchase (order_date, customer_id, product_nbr, quantity) VALUES
('2025-06-01', 43, 'cheese_10', 2),
('2025-06-03', 46, 'bread', 1),
('2025-06-05', 49, 'milk', 3),
('2025-06-07', 52, 'butter', 2),
('2025-06-09', 55, 'ham', 1),
('2025-06-11', 58, 'cheese_30', 4),
('2025-06-13', 61, 'bread', 2),
('2025-06-15', 64, 'milk', 5),
('2025-06-17', 67, 'butter', 1),
('2025-06-19', 70, 'cheese_10', 3);


--- add the generated phone numbers to the customers
UPDATE customer SET phone_numbers = generate_random_phone_numbers('LU');

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