/***************************************************************************************************

Database setup script for the DLH Advanced SQL course. This file provides
an overview of PostGIS

The examples use the database gis_sample, which is created by the setup.sql script.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


SELECT * FROM campus_buildings;

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

-- what is the distance between the campus_buildings?
SELECT a.name AS building_a,
       b.name AS building_b,
       ROUND(ST_Distance(a.geog, b.geog)) AS distance_meters
FROM campus_buildings a, campus_buildings b
WHERE a.name = 'DLH Terre Rouge';


-- what is the boundary of the town of Esch?
SELECT name,geog
FROM esch_boundary_geog;

-- what is the boundary of the canton Esch-sur-Alzette?
SELECT * FROM canton
	WHERE name = 'Esch-sur-Alzette';

-- are the campus_buildings within the Esch-sur-Alzette boundary?
    SELECT cb.name AS building_name,
        be.name AS boundary_name,
        ST_CoveredBy(cb.geog, be.geog) AS is_within_boundary
    FROM campus_buildings cb, esch_boundary_geog be
    WHERE be.name = 'Esch-sur-Alzette Boundary';

-- are the campus_buildings within the boundary of the canton of Esch-sur-Alzette?
SELECT cb.name AS building_name,
       c.name AS canton_name,
       cb.geog AS building_geog
FROM campus_buildings AS cb
JOIN canton AS c ON c.name = 'Esch-sur-Alzette'
WHERE ST_CoveredBy(cb.geog::geometry, c.geom);