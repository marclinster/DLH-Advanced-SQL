

CREATE TABLE IF NOT EXISTS campus_buildings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geog GEOGRAPHY(POINT, 4326)
);

INSERT INTO campus_buildings (name, geog)
VALUES ('DLH Terre Rouge', 
            ST_GeographyFromText('POINT(5.944808740642141 49.504213091686786)')),
       ('Technoport Belval', 
            ST_GeographyFromText('POINT(5.949105782061126 49.50228582007102)'));


CREATE TABLE IF NOT EXISTS esch_boundary_geog (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    geog GEOGRAPHY(Polygon, 4326)
);


-- SRID 4326 is assumed for the polygon, so we can use ST_GeographyFromText to create the geography from WKT
INSERT INTO esch_boundary_geog (name, geog)
VALUES (
    'Esch-sur-Alzette Boundary',
    ST_GeographyFromText(
        'POLYGON((
            5.9682 49.5124, 
            6.0041 49.5215, 
            6.0128 49.4839, 
            5.9645 49.4791, 
            5.9682 49.5124
        ))'
    )
);




