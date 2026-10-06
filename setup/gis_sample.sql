/***************************************************************************************************

Creates a table for campus buildings and inserts sample data. It also creates a table for the boundary 
of Esch-sur-Alzette and inserts sample polygon data.

This table is used in the GIS section of the course.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/


CREATE TABLE IF NOT EXISTS campus_buildings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geog GEOGRAPHY(POINT, 4326)
);


INSERT INTO public.campus_buildings VALUES (1, 'DLH Terre Rouge', '0101000020E6100000BB2148F17BC717404181F90D8AC04840');
INSERT INTO public.campus_buildings VALUES (2, 'Technoport Belval', '0101000020E61000009296D962E2CB17408C39D9E64AC04840');
INSERT INTO public.campus_buildings VALUES (3, 'Kirchberg Campus', '0101000020E6100000879F3FE128A31840541CB14B38D04840');



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




