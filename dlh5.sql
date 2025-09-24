/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2025 Copyright: Marc Linster
Last updated Sep 23 2025
****************************************************************************************************/
-- dlh5.sql

-- make sure you are connected to dlh5 database
SELECT current_database()

CREATE TABLE account (id INT, amount NUMERIC);

INSERT INTO account VALUES (1, 100);
INSERT INTO account VALUES (2, 0);

-- Session 1 (left)

SELECT * FROM account 
	ORDER BY id ASC;

BEGIN;

UPDATE account 
		SET amount = amount - 50 
WHERE id = 1;

SELECT * FROM account 
		ORDER BY id ASC;

UPDATE account 
		SET amount = amount + 50 
	WHERE id = 2;

COMMIT;            

-- Session 2 (right)

SELECT * FROM account 
		ORDER BY id ASC;

      