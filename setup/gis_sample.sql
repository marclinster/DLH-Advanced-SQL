DROP DATABASE IF EXISTS gis_sample WITH (FORCE);
CREATE DATABASE gis_sample;

\c gis_sample

CREATE EXTENSION IF NOT EXISTS postgis;


CREATE TABLE campus_buildings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geog GEOGRAPHY(POINT, 4326)
);

INSERT INTO campus_buildings (name, geog)
VALUES ('DLH Terre Rouge', 
            ST_GeographyFromText('POINT(5.944808740642141 49.504213091686786)')),
       ('Technoport Belval', 
            ST_GeographyFromText('POINT(5.949105782061126 49.50228582007102)'));


-- LineString connecting the two campus_buildings points
SELECT ST_MakeLine(a.geog::geometry, b.geog::geometry) AS building_line
    FROM campus_buildings a, campus_buildings b
    WHERE a.name = 'DLH Terre Rouge'
    AND b.name = 'Technoport Belval';
  

-- same query, returned as WKT for easy reading
SELECT ST_AsText(
        ST_MakeLine(a.geog::geometry, b.geog::geometry)
       ) AS building_line_wkt
    FROM campus_buildings a, campus_buildings b
    WHERE a.name = 'DLH Terre Rouge'
    AND b.name = 'Technoport Belval';


CREATE TABLE IF NOT EXISTS esch_boundary_geog (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    geog GEOGRAPHY(Polygon, 4326)
);

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

SELECT name,geog
FROM esch_boundary_geog;

-- are the two campus_buildings within the Esch-sur-Alzette boundary?
SELECT a.name AS building_name,
       b.name AS boundary_name,
       ST_CoveredBy(a.geog, b.geog) AS is_within_boundary
FROM campus_buildings a, esch_boundary_geog b
WHERE b.name = 'Esch-sur-Alzette Boundary';

-- what is the distance between the two campus_buildings?
SELECT a.name AS building_a,
       b.name AS building_b,
       ROUND(ST_Distance(a.geog, b.geog)) AS distance_meters
FROM campus_buildings a, campus_buildings b
WHERE a.name = 'DLH Terre Rouge'
AND b.name = 'Technoport Belval';