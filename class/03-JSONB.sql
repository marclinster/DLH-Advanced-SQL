/*

    JSON(B)

*/

-- use this in psql to pretty print the JSONB columns
-- use psql
SELECT id, first_name, last_name, address_id, since, 
    jsonb_pretty(phone_numbers) AS phone_numbers, 
    jsonb_pretty(email_addresses) AS email_addresses,
    jsonb_pretty(social_media) AS social_media
    FROM customer 
    WHERE id =2;

-- access the private mobile number for the 5th customer
-- explain the JSONB path '{private,mobile}' and the difference between #> and #>> operators

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
    LIMIT 10;

-- using the JSONB path to see if a key exists

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
    WHERE JSONB_PATH_EXISTS(phone_numbers, '$.private.mobile')
    LIMIT 1;   



SELECT 
    -- gets the column
    phone_numbers, 
    -- gets the subdocument with the key 'private'
    JSONB_PATH_QUERY(phone_numbers, '$.private') AS private_phone_numbers,
    -- gets the subdocument with the key 'private, mobile'
    JSONB_PATH_QUERY(phone_numbers, '$.private.mobile') AS private_mobile_number_jsonb,
    -- gets the value of the key 'private, mobile'
    JSONB_PATH_QUERY(phone_numbers, '$.private.mobile')::text AS private_mobile_number_text
    FROM customer   
    WHERE JSONB_PATH_EXISTS(phone_numbers, '$.private.mobile')
    LIMIT 1;


-- JSONB_BUILD_OBJECT

SELECT jsonb_pretty(
     JSONB_BUILD_OBJECT(
        'work', 
            JSONB_BUILD_OBJECT(
            'mobile', '(+352) 123 456 789', 
            'car', '(+352) 987 654 321'), 
        'private', JSONB_BUILD_OBJECT(
            'home', '(+352) 345 678 901', 
            'mobile', '(+352) 456 789 012'))
            );

-- JSONB as columns in a table

SELECT 
    phone_numbers #>> '{private,mobile}' AS private_mobile_number,
    phone_numbers #>> '{work,mobile}' AS work_mobile_number_text
    FROM customer  
    WHERE id < 5;


-- add a new phone number to the first customer, in the group work with label car2
-- use jsonb_set to add a new key-value pair to the work object

UPDATE customer
SET phone_numbers = JSONB_SET(phone_numbers, '{work,car 2}', '"(+352) 111 222 334"')
WHERE id = 1 RETURNING JSONB_PRETTY(phone_numbers) AS phone_numbers;

-- remove the phone number for the "car 2" label for the first customer

UPDATE customer
SET phone_numbers = phone_numbers - '{work,car 2}'
WHERE id = 1;

-- find all customers that have a private mobile phone number

SELECT id, first_name, last_name, phone_numbers #>> '{private,mobile}' AS private_mobile_number
    FROM CUSTOMER 
    WHERE phone_numbers #>> '{private,mobile}' IS NOT NULL
    ORDER BY phone_numbers #>> '{private,mobile}' ASC;

-- find all customers living in Junglinster, that have a work Twitter handle
SELECT * FROM customer c
    JOIN address a ON c.address_id = a.id
    WHERE a.commune = 'Junglinster'
    AND c.social_media #>> '{work, Twitter}' IS NOT NULL;


-- Set the work car phone number for the first customer to "(+352) 123 123 123" using jsonb_set
SELECT JSONB_PRETTY(phone_numbers) AS phone_numbers
    FROM customer
    WHERE id = 1;

UPDATE customer
SET phone_numbers = JSONB_SET(phone_numbers, '{work,car}', '"(+352) 123 123 123"')
WHERE id = 1
RETURNING JSONB_PRETTY(phone_numbers) AS phone_numbers;

-- change the work car phone number for the first customer to "(+352) 987 987 987" using jsonb_set
UPDATE customer
SET phone_numbers = JSONB_SET(phone_numbers, '{work,car}', '"(+352) 987 987 987"')
WHERE id = 1
RETURNING JSONB_PRETTY(phone_numbers) AS phone_numbers;

SELECT JSONB_PRETTY(phone_numbers) AS phone_numbers
    FROM customer
    WHERE id = 1;


-- delete the phone number for the "work,car" label for the first customer
UPDATE customer
SET phone_numbers = phone_numbers #- '{work,car}'
WHERE id = 1
RETURNING JSONB_PRETTY(phone_numbers) AS phone_numbers;

-- add a JSONB nested object for social media for the first customer
-- with a Twitter handle and a LinkedIn profile

UPDATE customer
SET social_media = JSONB_BUILD_OBJECT(
    'work', JSONB_BUILD_OBJECT(
        'Twitter', first_name|| '.'|| last_name|| '@twitter',
        'LinkedIn', 'www.linkedin.address_id.com/' || first_name || '.' || last_name
    )
)
WHERE id = 1;
