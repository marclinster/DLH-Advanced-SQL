--
-- PostgreSQL database dump
--

\restrict nebvwynWXjpKQySQMbYmGjmwrqjhKpDfl3tuoqySGQra0Z2e2FfODT73yjBhDGi

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.3

-- Started on 2026-10-01 14:12:36 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4360 (class 0 OID 28563)
-- Dependencies: 226
-- Data for Name: campus_buildings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.campus_buildings VALUES (1, 'DLH Terre Rouge', '0101000020E6100000BB2148F17BC717404181F90D8AC04840') ON CONFLICT DO NOTHING;
INSERT INTO public.campus_buildings VALUES (2, 'Technoport Belval', '0101000020E61000009296D962E2CB17408C39D9E64AC04840') ON CONFLICT DO NOTHING;


--
-- TOC entry 4367 (class 0 OID 0)
-- Dependencies: 225
-- Name: campus_buildings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.campus_buildings_id_seq', 2, true);


-- Completed on 2026-10-01 14:12:36 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict nebvwynWXjpKQySQMbYmGjmwrqjhKpDfl3tuoqySGQra0Z2e2FfODT73yjBhDGi

