
/* Note 
* ST_Distance and ST_DWithin are not symmetric, so the order of the arguments matters.
* They need GEOGRAPHY points to get the distance in meters, otherwise it will be in degrees.

*/
select * from address
    WHERE 
        ST_DWithin(geom, 
        ST_GeogFromText('SRID=4326;POINT(6.2663952451367955 49.71453573620864 )'), 
        50);
      



WITH ref AS (
    SELECT geom
    FROM address
    WHERE rue = 'Rue de la Montagne'
      AND numero = '40'
      AND localite = 'Junglinster'
)
SELECT
    a.rue,
    a.numero,
    a.localite,
    a.geom,
    ST_Distance(a.geom::geography, ref.geom::geography) AS distance_m
FROM address a, ref
WHERE ST_DWithin(a.geom::geography, ref.geom::geography, 100)
ORDER BY distance_m;

SELECT ST_DISTANCE (a1.geom::geography, a2.geom::geography) as distance_m
FROM address as a1, address as a2
WHERE a1.rue = 'Rue de la Montagne'
  AND a1.numero = '40'
  AND a1.localite = 'Junglinster'
  AND a2.rue = 'Rue de la Montagne'
  AND a2.numero = '1'
  AND a2.localite = 'Junglinster';

SELECT
    a.rue,
    a.numero,
    a.localite,
    a.code_postal
FROM address a
JOIN canton c ON ST_Contains(c.geom, a.geom)
WHERE c.name = 'Grevenmacher'
ORDER BY a.localite, a.rue, a.numero;

SELECT * FROM address WHERE code_postal = '6136';

select id_caclr_bat, count(*) from address
group by id_caclr_bat
order by count desc;



TRUNCATE customer CASCADE;
CREATE OR REPLACE PROCEDURE insert_random_customers(num_customers INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    first_names TEXT[] := ARRAY['Alice', 'Bob', 'Charlie', 'David', 'Eva', 'Frank', 'Grace', 'Hannah', 'Ian', 'Julia', 
                        'Kevin', 'Laura', 'Mike', 'Nina', 'Oliver', 'Paula', 'Quinn', 'Rachel', 'Sam', 'Tina', 'Marc', 
                        'Sophie', 'Luke', 'Nina', 'Max', 'Emma', 'Lena', 'Tom', 'Mia', 'Marc', 'Claire', 'Julien', 'Laura', 'Pierre', 
                        'Sarah', 'Lucas', 'Emma', 'Leo', 'Nina', 'Alex', 'Sophie', 'Tom', 'Lena', 'Paul', 'Pia'];
    last_names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Garcia', 'Rodriguez', 
                        'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson',
                        'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 
                        'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Mueller', 'Hill', 'Adams', 
                        'Baker', 'Nelson', 'Carter', 'Mitchell', 'Perez', 'Roberts', 'Turner', 'Bintner', 'Ewen', 'Linster', 'Thull', 'Lagrange',
                        'Becker', 'Wagner', 'Keller', 'Fischer', 'Schmit', 'Stein', 'Hoffmann', 'Schneider', 'Lang', 'Frank', 'Weber', 'Muller', 'Klein'];
    random_first_name TEXT;
    random_last_name TEXT;
BEGIN
    FOR i IN 1..num_customers LOOP
        random_first_name := first_names[1 + floor(random() * array_length(first_names, 1))];
        random_last_name := last_names[1 + floor(random() * array_length(last_names, 1))];
        INSERT INTO customer (first_name, last_name, address_id, since, phone_numbers, email_addresses, social_media)
        VALUES (random_first_name, random_last_name, NULL, CURRENT_DATE - (random() * 365)::INT, NULL, 
                jsonb_build_array(jsonb_build_object('email', random_first_name || '.' || random_last_name || '@example.com')), NULL);
    END LOOP;
END;
$$;

CALL insert_random_customers(5000);

-- assign random addresses to customers
CREATE OR REPLACE PROCEDURE assign_random_addresses_to_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_id INT;
    v_address_id INT;
BEGIN
    FOR v_customer_id IN SELECT id FROM customer LOOP
        SELECT id INTO v_address_id FROM address ORDER BY random() LIMIT 1;
        UPDATE customer SET address_id = v_address_id WHERE id = v_customer_id;
    END LOOP;
END;
$$;

CALL assign_random_addresses_to_customers();

-- assign random phone numbers to customers in the Luxembourg format (+352) 69X XXX XXX
-- vary between the label "mobile", "home", "work"
-- assign random social media handles to customers, with the platform being one of "Twitter", "Facebook", "Instagram", "LinkedIn"
CREATE OR REPLACE PROCEDURE assign_random_phone_numbers_and_social_media_to_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_id INT;
    phone_number TEXT;
    phone_label TEXT;
    phone_json JSONB;
    social_media_json JSONB;
    social_media_platform TEXT;
BEGIN
    FOR v_customer_id IN SELECT id FROM customer LOOP
        -- Assign random phone number
        phone_number := '(+352) ' || (floor(random() * 900) + 100)::INT || ' ' || (floor(random() * 900) + 100)::INT || ' ' || (floor(random() * 900) + 100) :: INT;   
        phone_label := CASE WHEN random() < 0.33 THEN 'mobile' WHEN random() < 0.66 THEN 'home' ELSE 'work' END;
        phone_json := jsonb_build_object(phone_label, phone_number);
        -- Assign 30% of the customers a second, different phone number with a different label
        IF random() < 0.3 THEN
            phone_number := '(+352) ' || (floor(random() * 900) + 100)::INT || ' ' || (floor(random() * 900) + 100)::INT || ' ' || (floor(random() * 900) + 100) :: INT;
            phone_label := CASE WHEN random() < 0.33 THEN 'mobile' WHEN random() < 0.66 THEN 'home' ELSE 'work' END;
            phone_json := phone_json || jsonb_build_object(phone_label, phone_number);
        END IF;
        social_media_platform := CASE WHEN random() < 0.25 THEN 'Twitter' WHEN random() < 0.5 THEN 'Facebook' WHEN random() < 0.75 THEN 'Instagram' ELSE 'LinkedIn' END;
        -- Update customer with phone number and social media
        UPDATE customer 
        SET phone_numbers = phone_json,
            social_media = jsonb_build_object(social_media_platform, lower(social_media_platform) || '_' || v_customer_id)
        WHERE id = v_customer_id;
    END LOOP;
END;
$$;

Call assign_random_phone_numbers_and_social_media_to_customers();

-- assign random email addresses to customers, with the domain being one of "example.com", "test.com", "demo.com"
-- 30% of the customers should have a second email address with a different domain
CREATE OR REPLACE PROCEDURE assign_random_email_addresses_to_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    customer_id INT;
    v_first_name TEXT;
    v_last_name TEXT;
    email_domain TEXT;
    email_json JSONB;
BEGIN
    FOR customer_id IN SELECT id FROM customer LOOP
        SELECT first_name, last_name INTO v_first_name, v_last_name FROM customer WHERE id = customer_id;
        email_domain := CASE WHEN random() < 0.33 THEN 'example.com' WHEN random() < 0.66 THEN 'test.com' ELSE 'demo.com' END;
        email_json := jsonb_build_object('email', v_first_name || '.' || v_last_name || customer_id || '@' || email_domain);
        -- Assign 30% of the customers a second email address with a different domain
        IF random() < 0.3 THEN
            email_domain := CASE WHEN random() < 0.33 THEN 'google.com' WHEN random() < 0.66 THEN 'pt.com' ELSE 'microsoft.com' END;
            email_json := email_json || jsonb_build_object('work_email', v_last_name || '.' || v_first_name || '@' || email_domain);
        END IF;
        UPDATE customer 
        SET email_addresses = email_json
        WHERE id = customer_id;
    END LOOP;
END;
$$;

call assign_random_email_addresses_to_customers();



select * from customer;

SELECT c.first_name, c.last_name, a.geom FROM customer c
    JOIN address a ON c.address = a.id
    WHERE a.localite = 'Junglinster'
    ORDER BY c.last_name, c.first_name;

SELECT c.first_name, c.last_name, a.geom, sum(p.quantity * pr.price) AS total FROM customer c
    JOIN address a ON c.address = a.id
    JOIN purchase p ON c.id = p.customer_id
    JOIN product pr ON p.product_nbr = pr.product_nbr
    WHERE a.localite = 'Differdange'
    GROUP BY c.id, c.first_name, c.last_name, a.geom
    ORDER BY c.last_name, c.first_name;  

SELECT c.first_name, c.last_name, a.geom FROM customer c
    JOIN address a ON c.address = a.id;


-- draw a 10 km circle around the address of the customer with id = 1 and find all customers within that circle
WITH ref AS (
    SELECT a.geom
    FROM customer c
    JOIN address a ON c.address = a.id
    WHERE c.id = 1
)
SELECT c.first_name, c.last_name, a.geom
FROM customer c
JOIN address a ON c.address = a.id, ref
WHERE ST_DWithin(a.geom::geography, ref.geom::geography, 10000)
ORDER BY c.last_name, c.first_name;    


WITH ref_geom AS 
	(SELECT a.geom 
		FROM store s 
		JOIN address a 
		ON a.id = s.address_id WHERE s.id = 1)
SELECT c.first_name, c.last_name, a.geom
	FROM customer c
	JOIN address a ON a.id = c.address_id
    CROSS JOIN ref_geom
	WHERE ST_DWithin (ref_geom.geom::geography, a.geom::geography, 5000);

-- identify where two cantons share a border
SELECT
    c1.name AS canton_1,
    c2.name AS canton_2,
    ST_Intersection(c1.geom, c2.geom) AS shared_border
FROM canton c1
JOIN canton c2 ON c1.gid < c2.gid
WHERE ST_Touches(c1.geom, c2.geom)
AND c1.name = 'Capellen';

-- draw a 10 km circle around the address of each store
WITH store_geom AS (
    SELECT s.id AS store_id, a.geom AS store_geom
    FROM store s
    JOIN address a ON s.address_id = a.id
)
SELECT s.store_id, ST_Buffer(s.store_geom::geography, 10000)::geometry AS buffer_geom
FROM store_geom s;

-- Try to show the circle around the store with id = 1 and find all customers within that circle
WITH store_geom AS 
	(SELECT a.geom 
		FROM store s 
		JOIN address a 
		ON a.id = s.address_id WHERE s.id = 1)
SELECT c.first_name, c.last_name, a.geom, ST_Buffer(store_geom.geom::geography, 10000)::geometry AS buffer_geom
	FROM customer c
	JOIN address a ON a.id = c.address_id
    CROSS JOIN store_geom
	WHERE ST_DWithin (store_geom.geom::geography, a.geom::geography, 5000);

-- customers within 10km of at least two distinct stores
SELECT
    c.id,
    c.first_name,
    c.last_name,
    ca.commune,
    COUNT(DISTINCT s.id) AS nearby_store_count,
    string_agg(DISTINCT s.name, ', ' ORDER BY s.name) AS nearby_store_names
FROM customer c
JOIN address ca ON ca.id = c.address_id
JOIN store s ON TRUE
JOIN address sa ON sa.id = s.address_id
WHERE ST_DWithin(ca.geom::geography, sa.geom::geography, 10000)
GROUP BY c.id, c.first_name, c.last_name, ca.commune
HAVING COUNT(DISTINCT s.id) >= 2
ORDER BY c.last_name, c.first_name;


SELECT * FROM address where commune iLike 'Esch%';

--- reorganizing the address table to have a primary key and to use the id as foreign key in the customer table

CREATE TABLE IF NOT EXISTS public.address2
(
   	id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	rue text COLLATE pg_catalog."default",
    numero text COLLATE pg_catalog."default",
    localite text COLLATE pg_catalog."default",
    code_postal text COLLATE pg_catalog."default",
    lat_wgs84 double precision,
    lon_wgs84 double precision,
    commune text COLLATE pg_catalog."default",
    geom geometry(Point,4326) GENERATED ALWAYS AS (st_setsrid(st_makepoint(lon_wgs84, lat_wgs84), 4326)) STORED
);

INSERT INTO address2 (id, rue, numero, localite, code_postal, lat_wgs84, lon_wgs84, commune)
SELECT id, rue, numero, localite, code_postal, lat_wgs84, lon_wgs84, commune
FROM address;

SELECT * FROM address2;

SELECT * FROM store JOIN address2 ON store.address_id = address2.id;

DROP TABLE address CASCADE;

ALTER TABLE address2 RENAME TO address;