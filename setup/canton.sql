/***************************************************************************************************

Defines a table to manage the cantons of Luxembourg. The table is used in the GIS section of the course.

2026 Copyright: Marc Linster
Last updated Oct 6, 2026

****************************************************************************************************/





CREATE TABLE IF NOT EXISTS public.canton
(
    gid integer NOT NULL,
    objectid double precision,
    region character varying(50) COLLATE pg_catalog."default",
    code character varying(50) COLLATE pg_catalog."default",
    name character varying(50) COLLATE pg_catalog."default",
    de_entity character varying(50) COLLATE pg_catalog."default",
    fr_entity character varying(50) COLLATE pg_catalog."default",
    en_entity character varying(50) COLLATE pg_catalog."default",
    fourcolor integer,
    geom geometry(MultiPolygon,4326),
    CONSTRAINT cantons_pkey PRIMARY KEY (gid)
);

-- Index: public.cantons_geom_idx
CREATE INDEX IF NOT EXISTS cantons_geom_idx
    ON public.canton USING gist
    (geom)
    TABLESPACE pg_default;