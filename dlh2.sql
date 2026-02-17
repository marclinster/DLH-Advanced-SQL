/****************************************************************************************************
Sample SQL files for the class 'Advanced SQL with Postgres'
2026 Copyright: Marc Linster
Last updated Feb 17 2026
****************************************************************************************************/


\c dlh2;

DROP TABLE IF EXISTS skill;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS employee_skill;


CREATE TABLE skill (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT
);

CREATE TABLE employee (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT
);

CREATE TABLE employee_skill (
    employee_id INTEGER REFERENCES employee(id),
    skill_id INTEGER REFERENCES skill(id)
);

INSERT INTO skill (id, name, description) VALUES
(1, 'SQL', 'Structured Query Language'),
(2, 'Python', 'Programming language'),
(3, 'Data Analysis', 'Analyzing data to extract insights');

INSERT INTO employee (id, first_name, last_name) VALUES
(1, 'Alice', 'Smith'),
(2, 'Bob', 'Johnson'),
(3, 'Charlie', 'Brown');

INSERT INTO employee_skill (employee_id, skill_id) VALUES
(1, 1), -- Alice has SQL
(1, 2), -- Alice has Python
(2, 1), -- Bob has SQL
(3, 3); -- Charlie has Data Analysis


CREATE TABLE test (
    nbr1 INTEGER CHECK (nbr1 > 0),
    nbr2 INTEGER CHECK (nbr2 > 0),
    CHECK (nbr1 < nbr2));

INSERT INTO test (nbr1, nbr2) VALUES (5, 10); -- valid
INSERT INTO test (nbr1, nbr2) VALUES (-5, 10); -- invalid    