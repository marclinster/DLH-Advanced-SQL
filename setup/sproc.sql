

/* 

stored procedures

Connect to database dlh_adv_sql

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
    FROM category
    WHERE product.category_id = category.id
    AND category.name = p_category;
$$; 


SELECT * FROM product JOIN category ON product.category_id = category.id WHERE category.name = 'Food';

CALL increase_price ('Food', 1.00);

--- simple procedure to increase price of all products in a category by a fixed amount
CREATE OR REPLACE PROCEDURE increase_price2 (IN p_category TEXT, IN p_increase NUMERIC) 
LANGUAGE PLPGSQL AS 
$$
    DECLARE
        v_product RECORD;
    BEGIN
        FOR v_product 
            IN SELECT product_nbr, product_name, category_name FROM product_category_vw
                WHERE category_name = p_category
        LOOP
            UPDATE product
            SET price = price + p_increase
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by %', v_product.product_name, p_increase;
        END LOOP;
    END; 
$$;

CALL increase_price2 ('Food', 1.00);

--- more complex procedure to increase price of all products and food differently
DROP PROCEDURE IF EXISTS increase_price_differentiated;

CREATE OR REPLACE PROCEDURE increase_price_differentiated 
    (IN general_increase NUMERIC, IN food_increase NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
BEGIN
    FOR v_product IN 
        SELECT product_nbr, product_name, category_name FROM product_category_vw
    LOOP
        IF v_product.category_name = 'Food' THEN
            UPDATE product
            SET price = price + food_increase
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by %', v_product.product_name, food_increase;
        ELSE
            UPDATE product
            SET price = price + general_increase
            WHERE product_nbr = v_product.product_nbr;    
            RAISE NOTICE 'Increased price of % by % ', v_product.product_name, general_increase;        
        END IF;
    END LOOP;
END;    
$$; 


CALL increase_price_differentiated (5, 10);    

--- extend the procedure to have a special increase for snacks
DROP PROCEDURE IF EXISTS increase_price_differentiated_2;

CREATE OR REPLACE PROCEDURE increase_price_differentiated_2 
    (IN general_increase NUMERIC, IN food_increase NUMERIC, IN snack_increase NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
BEGIN
    FOR v_product IN 
        SELECT product_nbr, product_name, category_name FROM product_category_vw
    LOOP
        IF v_product.category_name = 'Food' THEN
            UPDATE product
            SET price = price + food_increase
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by % ', v_product.product_name, food_increase;    
        ELSIF v_product.category_name = 'Snack' THEN
            UPDATE product
            SET price = price + snack_increase
            WHERE product_nbr = v_product.product_nbr;
            RAISE NOTICE 'Increased price of % by %', v_product.product_name, snack_increase;
        ELSE
            UPDATE product
            SET price = price + general_increase
            WHERE product_nbr = v_product.product_nbr;    
            RAISE NOTICE 'Increased price of % by % ', v_product.product_name, general_increase;        
        END IF;
    END LOOP;
END;    
$$; 

CALL increase_price_differentiated_2 (5, 10, 3);  

--- use the simple case statement to do the same

DROP PROCEDURE IF EXISTS increase_price_differentiated_3;


CREATE OR REPLACE PROCEDURE increase_price_differentiated_3 
    (IN p_general_increase NUMERIC, IN p_food_increase NUMERIC, IN p_snack_increase NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
    v_increase NUMERIC;
BEGIN
    FOR v_product IN 
        SELECT product_nbr, product_name, category_name FROM product_category_vw
    LOOP
            CASE v_product.category_name
                WHEN 'Food' THEN v_increase := p_food_increase;
                WHEN 'Snack' THEN v_increase := p_snack_increase;
                ELSE v_increase := p_general_increase;
            END CASE;
        UPDATE product
        SET price = price + v_increase
        WHERE product_nbr = v_product.product_nbr;
        RAISE NOTICE 'Increased price of % by % ', v_product.product_name, v_increase;        
    END LOOP;
END;      
$$;

CALL increase_price_differentiated_3 (5.0, 10.0, 3.0); 

/* functions in PL/SQL */

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


-- use the case statement to do the same
CREATE FUNCTION my_math2 (p1 INT, p2 INT, p_op text) RETURNS INT
AS
$$
    DECLARE v_result INT;   
    BEGIN
        CASE p_op
            WHEN 'addition' THEN v_result = p1 + p2;
            WHEN 'multiplication' THEN v_result = p1 * p2;
            ELSE v_result = 0;
        END CASE;
        RETURN v_result;
    END;
$$ LANGUAGE PLPGSQL;


/* understanding what a query returns and how to use it in a procedure */
DROP PROCEDURE IF EXISTS increase_price_differentiated_4 ;

CREATE OR REPLACE PROCEDURE increase_price_differentiated_4 
    (IN p_category_name TEXT, IN p_increase NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
    v_old_price NUMERIC;
    v_new_price NUMERIC;
BEGIN
FOR v_product IN 
        SELECT product_nbr, product_name, category_name FROM product_category_vw
        WHERE category_name = p_category_name
    LOOP
        UPDATE product 
            SET price = price + p_increase
            WHERE product_nbr = v_product.product_nbr
            RETURNING OLD.price, NEW.price INTO v_old_price, v_new_price;
            RAISE NOTICE 'Increased price for %s from %s to %s because it is a member of %s category',
            v_product.product_name, v_old_price, v_new_price, v_product.category_name;
    END LOOP;
END;
$$;

CALL increase_price_differentiated_4 ('Food', 0.1);

/* error message when the constraint is violated */

-- no error handling
-- all changes fail if one of them fails

CREATE OR REPLACE PROCEDURE decrease_price_differentiated_1
    (IN p_category_name TEXT, IN p_price_decrease NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
    v_old_price NUMERIC;
    v_new_price NUMERIC;
BEGIN
FOR v_product IN
        SELECT product_nbr, product_name, category_name FROM product_category_vw
        WHERE category_name = p_category_name
    LOOP
        UPDATE product
            SET price = price - p_price_decrease
            WHERE product_nbr = v_product.product_nbr
            RETURNING OLD.price, NEW.price INTO v_old_price, v_new_price;
            RAISE NOTICE 'Decreased price for % from % to % because it is a member of % category',
            v_product.product_name, v_old_price, v_new_price, v_product.category_name;
    END LOOP;
END;
$$;

CALL decrease_price_differentiated_1 ('Food', 15);


-- this handles the error and changes all prices that are > 0 (aligned with check constraint)

CREATE OR REPLACE PROCEDURE decrease_price_differentiated_2
    (IN p_category_name TEXT, IN p_price_decrease NUMERIC)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_product RECORD;
    v_old_price NUMERIC;
    v_new_price NUMERIC;
	v_constraint text;
BEGIN
FOR v_product IN
        SELECT product_nbr, product_name, category_name, product_price FROM product_category_vw
        WHERE category_name = p_category_name
    LOOP
        BEGIN
            UPDATE product
                SET price = price - p_price_decrease
                WHERE product_nbr = v_product.product_nbr
                RETURNING OLD.price, NEW.price INTO v_old_price, v_new_price;
                RAISE NOTICE 'Decreased price for % from % to % because it is a member of % category',
                v_product.product_name, v_old_price, v_new_price, v_product.category_name;
        EXCEPTION
            WHEN check_violation THEN
                GET STACKED DIAGNOSTICS
		            v_constraint = constraint_name;
	            RAISE NOTICE 'Price adjustment for % violated check constraint: %', 
                    v_product.product_name,
                    v_constraint;
                RAISE NOTICE 'Price remains unchanged at %', v_product.product_price;
            WHEN OTHERS THEN
                RAISE NOTICE 'unknown error';
        END;
    END LOOP;
END;
$$;

CALL decrease_price_differentiated_2 ('Snack', 12);
