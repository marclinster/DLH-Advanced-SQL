/***************************************************************************************************

Creates a table for stores and inserts sample data. 

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


DROP TABLE IF EXISTS store;

CREATE TABLE store (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT,
    address_id INTEGER REFERENCES address(id)
);

INSERT INTO store (name, address_id) VALUES
    ('Junglinster', 54419),
    ('Differdange', 55011),
    ('Esch', 55012),
    ('Luxembourg', 55013),
    ('Remich', 55014);


SELECT name, geom FROM store
    JOIN address ON store.address_id = address.id;

   