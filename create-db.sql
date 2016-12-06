--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE geodesy;
ALTER ROLE geodesy WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5a49d6d1baa2f719f28e308e8a3c249fd';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;




--
-- PostgreSQL database cluster dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE geodesydb;
--
-- Name: geodesydb; Type: DATABASE; Schema: -; Owner: geodesy
--

CREATE DATABASE geodesydb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE geodesydb OWNER TO geodesy;

\connect geodesydb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: geodesy; Type: SCHEMA; Schema: -; Owner: geodesy
--

CREATE SCHEMA geodesy;


ALTER SCHEMA geodesy OWNER TO geodesy;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = geodesy, pg_catalog;

--
-- Name: add_records_to_site_in_network(); Type: FUNCTION; Schema: geodesy; Owner: geodesy
--

CREATE FUNCTION add_records_to_site_in_network() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare
rsc record;
v_id cors_site_in_network.id%type;


BEGIN 
  RAISE NOTICE 'Start to update site_in_network and relation...';

  for rsc IN select b.id as "site_id", a.network_1, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_1 = c.name
union
select b.id as "site_id", a.network_2, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_2 = c.name
union
select b.id as "site_id", a.network_3, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_3 = c.name
union
select b.id as "site_id", a.network_4, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_4 = c.name
order by 1 LOOP


      v_id  := nextVal('seq_surrogate_keys');
      insert into cors_site_in_network (id, cors_site_id, cors_site_network_id) values (v_id, rsc.site_id, rsc.network_id);       

  
END LOOP;
--commit;
RAISE NOTICE 'Done update site_in_network and relation.';

RETURN null;
END;
             $$;


ALTER FUNCTION geodesy.add_records_to_site_in_network() OWNER TO geodesy;

--
-- Name: add_records_to_site_network(); Type: FUNCTION; Schema: geodesy; Owner: geodesy
--

CREATE FUNCTION add_records_to_site_network() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare
rsc record;
v_id cors_site_network.id%type;


BEGIN 
  RAISE NOTICE 'Start to update site_network and relation...';

  for rsc IN select distinct network_1 as "name" from temp_site_network where network_1 is not null
union
select distinct network_2 as "name" from temp_site_network where network_2 is not null
union
select distinct network_3 as "name" from temp_site_network where network_3 is not null
union
select distinct network_4 as "name" from temp_site_network where network_4 is not null
order by 1 LOOP

v_id := nextVal('seq_surrogate_keys');

insert into cors_site_network (id, name) values (v_id, rsc.name);
  
END LOOP;
--commit;
RAISE NOTICE 'Done update site_network and relation.';
   RETURN null;

END;
             $$;


ALTER FUNCTION geodesy.add_records_to_site_network() OWNER TO geodesy;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: clock_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE clock_configuration (
    id integer NOT NULL,
    input_frequency text
);


ALTER TABLE clock_configuration OWNER TO geodesy;

--
-- Name: cors_site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE cors_site (
    bedrock_condition text,
    bedrock_type text,
    domes_number text,
    four_character_id character varying(4) NOT NULL,
    geologic_characteristic text,
    id integer NOT NULL,
    monument_id integer,
    nine_character_id character varying(9) DEFAULT '_geodesy_'::character varying NOT NULL,
    site_status character varying(20) DEFAULT 'PRIVATE'::character varying NOT NULL
);


ALTER TABLE cors_site OWNER TO geodesy;

--
-- Name: cors_site_in_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE cors_site_in_network (
    id integer NOT NULL,
    cors_site_id integer NOT NULL,
    cors_site_network_id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone
);


ALTER TABLE cors_site_in_network OWNER TO geodesy;

--
-- Name: TABLE cors_site_in_network; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE cors_site_in_network IS 'table between cors_site and cors_site_network to break a many-to-many relationship and also store time_in and out information.';


--
-- Name: COLUMN cors_site_in_network.cors_site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN cors_site_in_network.cors_site_id IS 'a foreign key linked to cors_site primary key (id)';


--
-- Name: COLUMN cors_site_in_network.cors_site_network_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN cors_site_in_network.cors_site_network_id IS 'a foreign key linked to cors_site_network primary key (id)';


--
-- Name: cors_site_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE cors_site_network (
    id integer NOT NULL,
    name text,
    description text
);


ALTER TABLE cors_site_network OWNER TO geodesy;

--
-- Name: databasechangelog; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE databasechangelog OWNER TO geodesy;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE databasechangeloglock OWNER TO geodesy;

--
-- Name: domain_event; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE domain_event (
    event_name text NOT NULL,
    id integer NOT NULL,
    error text,
    retries integer,
    subscriber text NOT NULL,
    time_handled timestamp without time zone,
    time_published timestamp without time zone,
    time_raised timestamp without time zone NOT NULL
);


ALTER TABLE domain_event OWNER TO geodesy;

--
-- Name: equipment; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE equipment (
    equipment_type text NOT NULL,
    id integer NOT NULL,
    manufacturer text,
    serial_number text,
    type text,
    version integer
);


ALTER TABLE equipment OWNER TO geodesy;

--
-- Name: equipment_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE equipment_configuration (
    equipment_configuration_id integer NOT NULL,
    equipment_id integer NOT NULL,
    configuration_time timestamp without time zone
);


ALTER TABLE equipment_configuration OWNER TO geodesy;

--
-- Name: equipment_in_use; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE equipment_in_use (
    id integer NOT NULL,
    equipment_configuration_id integer NOT NULL,
    equipment_id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    setup_id integer
);


ALTER TABLE equipment_in_use OWNER TO geodesy;

--
-- Name: gnss_antenna_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE gnss_antenna_configuration (
    id integer NOT NULL,
    alignment_from_true_north text,
    antenna_cable_length text,
    antenna_cable_type text,
    antenna_reference_point text,
    marker_arp_east_eccentricity double precision,
    marker_arp_north_eccentricity double precision,
    marker_arp_up_eccentricity double precision,
    notes text,
    radome_serial_number text,
    radome_type text
);


ALTER TABLE gnss_antenna_configuration OWNER TO geodesy;

--
-- Name: gnss_receiver_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE gnss_receiver_configuration (
    id integer NOT NULL,
    elevation_cutoff_setting text,
    firmware_version text,
    notes text,
    satellite_system text,
    temperature_stabilization text
);


ALTER TABLE gnss_receiver_configuration OWNER TO geodesy;

--
-- Name: humidity_sensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE humidity_sensor (
    aspiration text,
    id integer NOT NULL
);


ALTER TABLE humidity_sensor OWNER TO geodesy;

--
-- Name: humidity_sensor_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE humidity_sensor_configuration (
    id integer NOT NULL,
    height_diff_to_antenna text,
    notes text
);


ALTER TABLE humidity_sensor_configuration OWNER TO geodesy;

--
-- Name: invalid_site_log_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE invalid_site_log_received (
    site_log_text text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE invalid_site_log_received OWNER TO geodesy;

--
-- Name: monument; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE monument (
    id integer NOT NULL,
    description text,
    foundation text,
    height text,
    marker_description text
);


ALTER TABLE monument OWNER TO geodesy;

--
-- Name: node; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE node (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    invalidated boolean NOT NULL,
    setup_id integer,
    site_id integer NOT NULL,
    version integer
);


ALTER TABLE node OWNER TO geodesy;

--
-- Name: position; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE "position" (
    id integer NOT NULL,
    as_at timestamp without time zone,
    datum_epsg_code integer,
    epoch timestamp without time zone,
    four_character_id character varying(255),
    node_id integer,
    position_source_id integer,
    x double precision,
    y double precision
);


ALTER TABLE "position" OWNER TO geodesy;

--
-- Name: responsible_party; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE responsible_party (
    id integer NOT NULL,
    iso_19115 text
);


ALTER TABLE responsible_party OWNER TO geodesy;

--
-- Name: seq_event; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_event
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_event OWNER TO geodesy;

--
-- Name: seq_sitelogantenna; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogantenna
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogantenna OWNER TO geodesy;

--
-- Name: seq_sitelogcollocationinfo; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogcollocationinfo
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogcollocationinfo OWNER TO geodesy;

--
-- Name: seq_sitelogfrequencystandard; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogfrequencystandard
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogfrequencystandard OWNER TO geodesy;

--
-- Name: seq_siteloghumiditysensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_siteloghumiditysensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_siteloghumiditysensor OWNER TO geodesy;

--
-- Name: seq_siteloglocalepisodicevent; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_siteloglocalepisodicevent
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_siteloglocalepisodicevent OWNER TO geodesy;

--
-- Name: seq_siteloglocaltie; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_siteloglocaltie
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_siteloglocaltie OWNER TO geodesy;

--
-- Name: seq_sitelogmultipathsource; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogmultipathsource
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogmultipathsource OWNER TO geodesy;

--
-- Name: seq_sitelogotherinstrument; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogotherinstrument
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogotherinstrument OWNER TO geodesy;

--
-- Name: seq_sitelogpressuresensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogpressuresensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogpressuresensor OWNER TO geodesy;

--
-- Name: seq_sitelogradiointerference; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogradiointerference
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogradiointerference OWNER TO geodesy;

--
-- Name: seq_sitelogreceiver; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogreceiver
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogreceiver OWNER TO geodesy;

--
-- Name: seq_sitelogsignalobstruction; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogsignalobstruction
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogsignalobstruction OWNER TO geodesy;

--
-- Name: seq_sitelogsite; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogsite
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogsite OWNER TO geodesy;

--
-- Name: seq_sitelogtemperaturesensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogtemperaturesensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogtemperaturesensor OWNER TO geodesy;

--
-- Name: seq_sitelogwatervaporsensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_sitelogwatervaporsensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_sitelogwatervaporsensor OWNER TO geodesy;

--
-- Name: seq_surrogate_keys; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE seq_surrogate_keys
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_surrogate_keys OWNER TO geodesy;

--
-- Name: setup; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE setup (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    invalidated boolean NOT NULL,
    name text NOT NULL,
    site_id integer
);


ALTER TABLE setup OWNER TO geodesy;

--
-- Name: site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE site (
    id integer NOT NULL,
    date_installed timestamp without time zone,
    description text,
    name text,
    version integer,
    shape public.geometry(Point,4326)
);


ALTER TABLE site OWNER TO geodesy;

--
-- Name: site_log_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE site_log_received (
    four_char_id text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE site_log_received OWNER TO geodesy;

--
-- Name: site_updated; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE site_updated (
    four_character_id character varying(255) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE site_updated OWNER TO geodesy;

--
-- Name: sitelog_collocationinformation; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_collocationinformation (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    instrument_type text,
    notes text,
    status text,
    site_id integer
);


ALTER TABLE sitelog_collocationinformation OWNER TO geodesy;

--
-- Name: sitelog_frequencystandard; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_frequencystandard (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    input_frequency text,
    notes text,
    type text,
    site_id integer
);


ALTER TABLE sitelog_frequencystandard OWNER TO geodesy;

--
-- Name: sitelog_gnssantenna; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_gnssantenna (
    id integer NOT NULL,
    alignment_from_true_north text,
    antenna_cable_length text,
    antenna_cable_type text,
    antenna_radome_type text,
    antenna_reference_point text,
    date_installed timestamp without time zone,
    date_removed timestamp without time zone,
    marker_arp_east_ecc double precision,
    marker_arp_north_ecc double precision,
    marker_arp_up_ecc double precision,
    notes text,
    radome_serial_number text,
    serial_number text,
    antenna_type text,
    site_id integer
);


ALTER TABLE sitelog_gnssantenna OWNER TO geodesy;

--
-- Name: sitelog_gnssreceiver; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_gnssreceiver (
    id integer NOT NULL,
    date_installed timestamp without time zone,
    date_removed timestamp without time zone,
    elevation_cutoff_setting text,
    firmware_version text,
    notes text,
    satellite_system text,
    serial_number text,
    temperature_stabilization text,
    receiver_type text,
    site_id integer
);


ALTER TABLE sitelog_gnssreceiver OWNER TO geodesy;

--
-- Name: sitelog_humiditysensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_humiditysensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accuracy_percent_rel_humidity text,
    aspiration text,
    data_sampling_interval text,
    notes text,
    site_id integer
);


ALTER TABLE sitelog_humiditysensor OWNER TO geodesy;

--
-- Name: sitelog_localepisodicevent; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_localepisodicevent (
    id integer NOT NULL,
    event text,
    site_id integer,
    effective_from timestamp(6) without time zone,
    effective_to timestamp(6) without time zone
);


ALTER TABLE sitelog_localepisodicevent OWNER TO geodesy;

--
-- Name: sitelog_mutlipathsource; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_mutlipathsource (
    id integer NOT NULL,
    site_id integer
);


ALTER TABLE sitelog_mutlipathsource OWNER TO geodesy;

--
-- Name: sitelog_otherinstrumentation; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_otherinstrumentation (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    instrumentation text,
    site_id integer
);


ALTER TABLE sitelog_otherinstrumentation OWNER TO geodesy;

--
-- Name: sitelog_pressuresensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_pressuresensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accuracy_hpa text,
    data_sampling_interval text,
    notes text,
    site_id integer
);


ALTER TABLE sitelog_pressuresensor OWNER TO geodesy;

--
-- Name: sitelog_radiointerference; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_radiointerference (
    id integer NOT NULL,
    observed_degradation text,
    site_id integer
);


ALTER TABLE sitelog_radiointerference OWNER TO geodesy;

--
-- Name: sitelog_responsible_party; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_responsible_party (
    id integer NOT NULL,
    site_id integer,
    responsible_party text NOT NULL,
    responsible_role_id integer NOT NULL
);


ALTER TABLE sitelog_responsible_party OWNER TO geodesy;

--
-- Name: TABLE sitelog_responsible_party; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE sitelog_responsible_party IS 'The table contains information of responsible party that associated with a sitelog site. Currently the responsible party information is stored as xml text, but in the future it should be coverted into columns in the table, such as name, organisation, address etc to facilitate serach.';


--
-- Name: COLUMN sitelog_responsible_party.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party.id IS 'unique identifier of the record, primary key';


--
-- Name: COLUMN sitelog_responsible_party.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party.site_id IS 'foreign key to pk of sitelog_site table';


--
-- Name: COLUMN sitelog_responsible_party.responsible_party; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party.responsible_party IS 'information about the responsible party that associated with the responsible role. currently in xml text';


--
-- Name: COLUMN sitelog_responsible_party.responsible_role_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party.responsible_role_id IS 'a responsible role that associated with the responsible party record, foreign key to pk of sitelog_responsible_party_role';


--
-- Name: sitelog_responsible_party_role; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_responsible_party_role (
    id integer NOT NULL,
    responsible_role_name text NOT NULL,
    responsible_role_xmltag text
);


ALTER TABLE sitelog_responsible_party_role OWNER TO geodesy;

--
-- Name: TABLE sitelog_responsible_party_role; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE sitelog_responsible_party_role IS 'The table contains information about all roles within the responsible party.';


--
-- Name: COLUMN sitelog_responsible_party_role.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party_role.id IS 'unique identifier of the record, primary key.';


--
-- Name: COLUMN sitelog_responsible_party_role.responsible_role_name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party_role.responsible_role_name IS 'the name of a responsible role in responsible party defined by OGC/gml schemas.';


--
-- Name: COLUMN sitelog_responsible_party_role.responsible_role_xmltag; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN sitelog_responsible_party_role.responsible_role_xmltag IS 'the tag name used by responsible role in responsible party defined by OGC/gml schemas.';


--
-- Name: sitelog_signalobstraction; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_signalobstraction (
    id integer NOT NULL,
    site_id integer
);


ALTER TABLE sitelog_signalobstraction OWNER TO geodesy;

--
-- Name: sitelog_site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_site (
    id integer NOT NULL,
    entrydate timestamp without time zone,
    form_date_prepared timestamp without time zone,
    form_prepared_by text,
    form_report_type text,
    mi_antenna_graphics text,
    mi_hard_copy_on_file text,
    mi_horizontal_mask text,
    mi_text_graphics_from_antenna text,
    mi_monument_description text,
    mi_notes text,
    mi_primary_data_center text,
    mi_secondary_data_center text,
    mi_site_diagram text,
    mi_site_map text,
    mi_site_pictires text,
    mi_url_for_more_information text,
    bedrock_condition text,
    bedrock_type text,
    cdp_number text,
    date_installed timestamp without time zone,
    distance_activity text,
    fault_zones_nearby text,
    foundation_depth text,
    four_character_id character varying(4),
    fracture_spacing text,
    geologic_characteristic text,
    height_of_monument text,
    iers_domes_number text,
    marker_description text,
    monument_description text,
    monument_foundation text,
    monument_inscription text,
    notes text,
    site_name text,
    elevation_grs80 text,
    itrf_x double precision,
    itrf_y double precision,
    itrf_z double precision,
    city text,
    country text,
    location_notes text,
    state text,
    tectonic_plate text,
    site_contact_id integer,
    site_metadata_custodian_id integer,
    site_log_text text NOT NULL,
    mi_doi text,
    nine_character_id character varying(9)
);


ALTER TABLE sitelog_site OWNER TO geodesy;

--
-- Name: sitelog_surveyedlocaltie; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_surveyedlocaltie (
    id integer NOT NULL,
    date_measured timestamp without time zone,
    dx double precision,
    dy double precision,
    dz double precision,
    local_site_tie_accuracy text,
    notes text,
    survey_method text,
    tied_marker_cdp_number text,
    tied_marker_domes_number text,
    tied_marker_name text,
    tied_marker_usage text,
    site_id integer
);


ALTER TABLE sitelog_surveyedlocaltie OWNER TO geodesy;

--
-- Name: sitelog_temperaturesensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_temperaturesensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accurace_degree_celcius text,
    aspiration text,
    data_sampling_interval text,
    notes text,
    site_id integer
);


ALTER TABLE sitelog_temperaturesensor OWNER TO geodesy;

--
-- Name: sitelog_watervaporsensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE sitelog_watervaporsensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    distance_to_antenna double precision,
    notes text,
    site_id integer
);


ALTER TABLE sitelog_watervaporsensor OWNER TO geodesy;

--
-- Name: v_cors_site; Type: VIEW; Schema: geodesy; Owner: geodesy
--

CREATE VIEW v_cors_site AS
 SELECT s.id,
    s.date_installed,
    s.description,
    s.name,
    s.version,
    s.shape,
    cs.bedrock_condition,
    cs.bedrock_type,
    cs.domes_number,
    cs.four_character_id,
    cs.geologic_characteristic,
    cs.monument_id
   FROM site s,
    cors_site cs
  WHERE (s.id = cs.id);


ALTER TABLE v_cors_site OWNER TO geodesy;

--
-- Name: VIEW v_cors_site; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON VIEW v_cors_site IS 'View that combines cors_site and site tables';


--
-- Name: weekly_solution; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE weekly_solution (
    id integer NOT NULL,
    as_at timestamp without time zone,
    epoch timestamp without time zone,
    sinex_file_name text
);


ALTER TABLE weekly_solution OWNER TO geodesy;

--
-- Name: weekly_solution_available; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE weekly_solution_available (
    weekly_solution_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE weekly_solution_available OWNER TO geodesy;

--
-- Data for Name: clock_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY clock_configuration (id, input_frequency) FROM stdin;
\.


--
-- Data for Name: cors_site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY cors_site (bedrock_condition, bedrock_type, domes_number, four_character_id, geologic_characteristic, id, monument_id, nine_character_id, site_status) FROM stdin;
\.


--
-- Data for Name: cors_site_in_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY cors_site_in_network (id, cors_site_id, cors_site_network_id, effective_from, effective_to) FROM stdin;
\.


--
-- Data for Name: cors_site_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY cors_site_network (id, name, description) FROM stdin;
1	APREF	\N
51	ARGN	\N
101	AUSCOPE	\N
151	CAMPAIGN	\N
201	CORSNET-NSW	\N
251	GEONET	\N
301	GPSNET	\N
351	IGS	\N
401	POSITIONZ	\N
451	RTKNETWEST	\N
501	SPRGN	\N
551	SUNPOZ	\N
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1464742487660-1	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.70937	1	EXECUTED	7:2a4dd6b2a7fb54bad8e62d1e94c47c28	createSequence sequenceName=seq_event		\N	3.5.3	\N	\N	0982757420
1464742487660-2	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.723751	2	EXECUTED	7:b0ea6bcffbbea9bf625b0f499912e255	createSequence sequenceName=seq_sitelogantenna		\N	3.5.3	\N	\N	0982757420
1464742487660-3	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.729887	3	EXECUTED	7:72f5bd12ed54d1fbe2d3eba5fe5aec87	createSequence sequenceName=seq_sitelogcollocationinfo		\N	3.5.3	\N	\N	0982757420
1464742487660-4	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.737824	4	EXECUTED	7:396ff91a03798752c5fd4d59b50d1a28	createSequence sequenceName=seq_sitelogfrequencystandard		\N	3.5.3	\N	\N	0982757420
1464742487660-5	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.745045	5	EXECUTED	7:1b34ad155c8978443fe109fef291ec02	createSequence sequenceName=seq_siteloghumiditysensor		\N	3.5.3	\N	\N	0982757420
1464742487660-6	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.756272	6	EXECUTED	7:dd4e906c1b7e92c7bbd9394e09bf7e87	createSequence sequenceName=seq_siteloglocalepisodicevent		\N	3.5.3	\N	\N	0982757420
1464742487660-7	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.768363	7	EXECUTED	7:5c7b0c0a24b56208b06655b28ae9d442	createSequence sequenceName=seq_siteloglocaltie		\N	3.5.3	\N	\N	0982757420
1464742487660-8	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.778721	8	EXECUTED	7:152e9ca6dfa32f7a02fe928fbf9cd4ae	createSequence sequenceName=seq_sitelogmultipathsource		\N	3.5.3	\N	\N	0982757420
1464742487660-9	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.784788	9	EXECUTED	7:9cca0c65fafb6e6d0f34e8e759cf5c7d	createSequence sequenceName=seq_sitelogotherinstrument		\N	3.5.3	\N	\N	0982757420
1464742487660-10	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.791141	10	EXECUTED	7:3b5e26e4921f6ab7ec2540c6f3051a5b	createSequence sequenceName=seq_sitelogpressuresensor		\N	3.5.3	\N	\N	0982757420
1464742487660-11	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.795821	11	EXECUTED	7:b874fe45a2549bb588479b6749e905a4	createSequence sequenceName=seq_sitelogradiointerference		\N	3.5.3	\N	\N	0982757420
1464742487660-12	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.800931	12	EXECUTED	7:20997afc8e96bf3c3b08b108dd09317c	createSequence sequenceName=seq_sitelogreceiver		\N	3.5.3	\N	\N	0982757420
1464742487660-13	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.806003	13	EXECUTED	7:b2b2016e465b3731ed41e5d7d43c42d8	createSequence sequenceName=seq_sitelogsignalobstruction		\N	3.5.3	\N	\N	0982757420
1464742487660-14	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.811103	14	EXECUTED	7:387448feb47c7742e918e9e035274297	createSequence sequenceName=seq_sitelogsite		\N	3.5.3	\N	\N	0982757420
1464742487660-15	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.818731	15	EXECUTED	7:7148aca958f1b2545bf88b06e22bfb92	createSequence sequenceName=seq_sitelogtemperaturesensor		\N	3.5.3	\N	\N	0982757420
1464742487660-16	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.824179	16	EXECUTED	7:6feb5a726a22905249d8550baf9ff0e6	createSequence sequenceName=seq_sitelogwatervaporsensor		\N	3.5.3	\N	\N	0982757420
1464742487660-17	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.829319	17	EXECUTED	7:8ffe0ddda63385420d097e3a2509724c	createSequence sequenceName=seq_surrogate_keys		\N	3.5.3	\N	\N	0982757420
1464742487660-18	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.834996	18	EXECUTED	7:ebc6c0045986823adcb06ad59bbdcfc8	createTable tableName=clock_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-19	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.843708	19	EXECUTED	7:0eeee521a1a7a70d4c912060720b56dd	createTable tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1464742487660-20	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.852262	20	EXECUTED	7:2e7fbbcaf355b21e9868f4ea569e8e77	createTable tableName=domain_event		\N	3.5.3	\N	\N	0982757420
1464742487660-21	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.861209	21	EXECUTED	7:e5b30d93e010a715aa7ccb7316b8d5f0	createTable tableName=equipment		\N	3.5.3	\N	\N	0982757420
1464742487660-22	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.86799	22	EXECUTED	7:35e7847eec3c275f511ef3d9ffb4e74d	createTable tableName=equipment_in_use		\N	3.5.3	\N	\N	0982757420
1464742487660-23	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.879069	23	EXECUTED	7:d3a55d70973289fffbd1ed2d5b68100f	createTable tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-24	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.891376	24	EXECUTED	7:f7e3538378a7125e288f60b5a7e03d42	createTable tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-25	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.903695	25	EXECUTED	7:1b2feb62573bdb2a53ca2d5d4fdf8a28	createTable tableName=humidity_sensor		\N	3.5.3	\N	\N	0982757420
1464742487660-26	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.914253	26	EXECUTED	7:3bd269014eafc98c54651829e994c552	createTable tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-27	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.924632	27	EXECUTED	7:7db50529fd12f857883d5311e5ac59b5	createTable tableName=invalid_site_log_received		\N	3.5.3	\N	\N	0982757420
1464742487660-28	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.934025	28	EXECUTED	7:6b4df0c48a48f4897636fc7414fb2f5c	createTable tableName=monument		\N	3.5.3	\N	\N	0982757420
1464742487660-29	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.945325	29	EXECUTED	7:241ffba958accea8c6641e57ddacce5e	createTable tableName=node		\N	3.5.3	\N	\N	0982757420
1464742487660-30	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.951649	30	EXECUTED	7:6100a1d72706417e4b10fe38333ced2e	createTable tableName=position		\N	3.5.3	\N	\N	0982757420
1464742487660-31	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.960376	31	EXECUTED	7:2773d96b3417ce619959cff54e0c7af3	createTable tableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1464742487660-32	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.966469	32	EXECUTED	7:e765d26e935353cd831b96766a60a011	createTable tableName=setup		\N	3.5.3	\N	\N	0982757420
1464742487660-33	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.975227	33	EXECUTED	7:185fd1d5119a097cefbc22cffbeca270	createTable tableName=site		\N	3.5.3	\N	\N	0982757420
1464742487660-34	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.981175	34	EXECUTED	7:1e3cb4e53f6becb91b0020088246079f	createTable tableName=site_log_received		\N	3.5.3	\N	\N	0982757420
1464742487660-35	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.98727	35	EXECUTED	7:ae8efc9850d88ea55ea24f948e06c72a	createTable tableName=site_updated		\N	3.5.3	\N	\N	0982757420
1464742487660-36	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:57.996295	36	EXECUTED	7:75dea22fc34bf0fe2b62a39bba18d4e7	createTable tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	0982757420
1464742487660-37	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.007051	37	EXECUTED	7:cce7ac7f2704d46a07346e749cd7f1f0	createTable tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	0982757420
1464742487660-38	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.016242	38	EXECUTED	7:ef60fc43b388af31cf04721229fa0d37	createTable tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1464742487660-39	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.025408	39	EXECUTED	7:7da264dfb246573e3cf6d9fea9d61b46	createTable tableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	0982757420
1464742487660-40	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.035133	40	EXECUTED	7:b1e37f1a8b2175ef20dba51cfdfc41ae	createTable tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1464742487660-41	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.043503	41	EXECUTED	7:dec2ffe3029d4f1fd8c9e8e84f7bf09b	createTable tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1464742487660-42	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.049063	42	EXECUTED	7:c3f691297907948621ed890b8172a1a0	createTable tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	0982757420
1464742487660-43	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.057821	43	EXECUTED	7:5c73df66532d44045d966ff2a4072e66	createTable tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	0982757420
1464742487660-44	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.06699	44	EXECUTED	7:f79450124910cebd6df61a13a59b4214	createTable tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1464742487660-45	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.072255	45	EXECUTED	7:e4e44b113681ec1b880277187dc138f1	createTable tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	0982757420
1464742487660-46	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.077409	46	EXECUTED	7:a4f55bf1c827c526294865643e29a16a	createTable tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	0982757420
1464742487660-47	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.088875	47	EXECUTED	7:ce3e61a73134ad24ff13f628654b04a7	createTable tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-48	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.098269	48	EXECUTED	7:a5e7fda6e4448d93f514f837317af628	createTable tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1464742487660-49	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.107896	49	EXECUTED	7:5dbaef061683670db540c47dfecb85ef	createTable tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1464742487660-50	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.118725	50	EXECUTED	7:e3870722fb48e6ed9f64218e288847ba	createTable tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1464742487660-51	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.124634	51	EXECUTED	7:d932f717541f4569c55caa44bda8df3e	createTable tableName=weekly_solution		\N	3.5.3	\N	\N	0982757420
1464742487660-52	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.130272	52	EXECUTED	7:845a006d5a17f43f207d8daec6f26a5b	createTable tableName=weekly_solution_available		\N	3.5.3	\N	\N	0982757420
1464742487660-54	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.14451	53	EXECUTED	7:385d20c42154aa7fb3a07e4798c8da46	addPrimaryKey constraintName=clock_configuration_pkey, tableName=clock_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-55	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.15177	54	EXECUTED	7:9933ed5009080f6ade54d9ed66acf18a	addPrimaryKey constraintName=cors_site_pkey, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1464742487660-56	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.158704	55	EXECUTED	7:baf9f75edfd130ad7c84e601325e65de	addPrimaryKey constraintName=domain_event_pkey, tableName=domain_event		\N	3.5.3	\N	\N	0982757420
1464742487660-57	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.165693	56	EXECUTED	7:b48cbb1555008354d21c51d32e93cd22	addPrimaryKey constraintName=equipment_in_use_pkey, tableName=equipment_in_use		\N	3.5.3	\N	\N	0982757420
1464742487660-58	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.173245	57	EXECUTED	7:4b6b911c4909d6693c5ccb34a0e8d179	addPrimaryKey constraintName=equipment_pkey, tableName=equipment		\N	3.5.3	\N	\N	0982757420
1464742487660-59	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.179905	58	EXECUTED	7:e2c36bbb3512978f81b7f1a9f9c25643	addPrimaryKey constraintName=gnss_antenna_configuration_pkey, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-60	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.186757	59	EXECUTED	7:4f50a082bee6d19d8c262c3f91017a72	addPrimaryKey constraintName=gnss_receiver_configuration_pkey, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-61	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.193716	60	EXECUTED	7:e65bfac7c40f6c8906f831bb9d8ee0a0	addPrimaryKey constraintName=humidity_sensor_configuration_pkey, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1464742487660-62	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.200496	61	EXECUTED	7:6bde33c68827285599c8232b9d649ace	addPrimaryKey constraintName=humidity_sensor_pkey, tableName=humidity_sensor		\N	3.5.3	\N	\N	0982757420
1464742487660-63	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.206996	62	EXECUTED	7:45af95d7d39bc2badee2d843989b8ce3	addPrimaryKey constraintName=invalid_site_log_received_pkey, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	0982757420
1464742487660-64	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.21338	63	EXECUTED	7:4d6f113562d6a69ca42e48e04c21ff51	addPrimaryKey constraintName=monument_pkey, tableName=monument		\N	3.5.3	\N	\N	0982757420
1464742487660-65	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.220381	64	EXECUTED	7:02696cfeda038626b787993af761b8c1	addPrimaryKey constraintName=node_pkey, tableName=node		\N	3.5.3	\N	\N	0982757420
1464742487660-66	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.226827	65	EXECUTED	7:0380327c68cd5a6a54addc8cd5e72b18	addPrimaryKey constraintName=position_pkey, tableName=position		\N	3.5.3	\N	\N	0982757420
1464742487660-67	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.233706	66	EXECUTED	7:05891fa768f34399f0ad6dc4523c8cf2	addPrimaryKey constraintName=responsible_party_pkey, tableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1464742487660-68	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.24187	67	EXECUTED	7:88f6fd670cd11c32911657cf0386e98a	addPrimaryKey constraintName=setup_pkey, tableName=setup		\N	3.5.3	\N	\N	0982757420
1473286366418-5	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.826352	147	EXECUTED	7:f5dbb2468d80488a0e7763ce6f136dc5	modifyDataType columnName=alignment_from_true_north, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1464742487660-69	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.249618	68	EXECUTED	7:21d03fc6d3063bd735ac9952ef671efb	addPrimaryKey constraintName=site_log_received_pkey, tableName=site_log_received		\N	3.5.3	\N	\N	0982757420
1464742487660-70	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.257402	69	EXECUTED	7:880ee6601ce7db71c6d440a0eca68541	addPrimaryKey constraintName=site_pkey, tableName=site		\N	3.5.3	\N	\N	0982757420
1464742487660-71	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.265093	70	EXECUTED	7:35f83f0a8a482cd4c7ad23fcaa80766c	addPrimaryKey constraintName=site_updated_pkey, tableName=site_updated		\N	3.5.3	\N	\N	0982757420
1464742487660-72	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.272228	71	EXECUTED	7:8d4e7b39207bd8d087107c4e1470bc22	addPrimaryKey constraintName=sitelog_collocationinformation_pkey, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	0982757420
1464742487660-73	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.279495	72	EXECUTED	7:f24d3e2093d4a5e10d54aaafcec6c43f	addPrimaryKey constraintName=sitelog_frequencystandard_pkey, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	0982757420
1464742487660-74	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.286554	73	EXECUTED	7:3ab4648373f63660cfdb49a36e258637	addPrimaryKey constraintName=sitelog_gnssantenna_pkey, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1464742487660-75	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.293465	74	EXECUTED	7:f791db1c7e3d0d15e3c81205bd760925	addPrimaryKey constraintName=sitelog_gnssgreceiver_pkey, tableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	0982757420
1464742487660-76	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.300828	75	EXECUTED	7:711c53bc8ebb42fd1382fd892dbbdac6	addPrimaryKey constraintName=sitelog_humiditysensor_pkey, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1464742487660-77	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.307348	76	EXECUTED	7:ff57c0435506639047c5a20061cbb63c	addPrimaryKey constraintName=sitelog_localepisodicevent_pkey, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1464742487660-78	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.314025	77	EXECUTED	7:849f26cfb8aeff96c4187609d232000a	addPrimaryKey constraintName=sitelog_mutlipathsource_pkey, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	0982757420
1464742487660-79	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.320446	78	EXECUTED	7:13c3c5309eb148066b77a1fb76ef5a55	addPrimaryKey constraintName=sitelog_otherinstrumentation_pkey, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	0982757420
1464742487660-80	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.328922	79	EXECUTED	7:f7828a7a676aa372445bc4b142f60620	addPrimaryKey constraintName=sitelog_pressuresensor_pkey, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1464742487660-81	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.34116	80	EXECUTED	7:b09783a7d2dc15e32022b299550aeea9	addPrimaryKey constraintName=sitelog_radiointerference_pkey, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	0982757420
1464742487660-82	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.347683	81	EXECUTED	7:360ff3ff2c790c6e79a0b1a7d4d6af2d	addPrimaryKey constraintName=sitelog_signalobstraction_pkey, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	0982757420
1464742487660-83	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.35537	82	EXECUTED	7:a567e35511d5977b4286c33c0200ca18	addPrimaryKey constraintName=sitelog_site_pkey, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-84	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.362872	83	EXECUTED	7:9775d5687a4ea2f42125b71d02babc3a	addPrimaryKey constraintName=sitelog_surveyedlocaltie_pkey, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1464742487660-85	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.370856	84	EXECUTED	7:514045c1ed51a0fcbae9ea6bb64b8a98	addPrimaryKey constraintName=sitelog_temperaturesensor_pkey, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1464742487660-86	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.379616	85	EXECUTED	7:f5e9d2ce7f2371a6fafd3a8965db899a	addPrimaryKey constraintName=sitelog_watervaporsensor_pkey, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1464742487660-87	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.386673	86	EXECUTED	7:5d6b9866e9f065305aa4f99a98e408f8	addPrimaryKey constraintName=weekly_solution_available_pkey, tableName=weekly_solution_available		\N	3.5.3	\N	\N	0982757420
1464742487660-88	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.392996	87	EXECUTED	7:d7e157e23a4d12c1d54c7e0de1cafd3f	addPrimaryKey constraintName=weekly_solution_pkey, tableName=weekly_solution		\N	3.5.3	\N	\N	0982757420
1464742487660-89	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.403166	88	EXECUTED	7:da0d597c13fded412ee2280e69cad2d7	addUniqueConstraint constraintName=uk_fg9w6m54cvx6bhnjag7t1i4a8, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1464742487660-90	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.410873	89	EXECUTED	7:49d9c59be21df83b333c1f58b7293eb1	addForeignKeyConstraint baseTableName=sitelog_signalobstraction, constraintName=fk1cs9mfi9h443h8b8fwp2g8o2j, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-91	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.417061	90	EXECUTED	7:bd677c3de84909dd2c4055977da2f913	addForeignKeyConstraint baseTableName=cors_site, constraintName=fk25mip9h81ast4isagcbn5nnsk, referencedTableName=monument		\N	3.5.3	\N	\N	0982757420
1464742487660-92	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.425979	91	EXECUTED	7:b4569a06600eed01370a634a78fb0985	addForeignKeyConstraint baseTableName=sitelog_gnssantenna, constraintName=fk2kaqvog12n3c227vv9wmka8sk, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-93	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.432047	92	EXECUTED	7:90b7a42deddb7f76537d250e6d04c319	addForeignKeyConstraint baseTableName=humidity_sensor, constraintName=fk3v3u8pev0722n8fjgvx596fsg, referencedTableName=equipment		\N	3.5.3	\N	\N	0982757420
1464742487660-94	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.437836	93	EXECUTED	7:7293a0e9ca4e5145d365f17c06a7d900	addForeignKeyConstraint baseTableName=site_updated, constraintName=fk4k5lbyl5p83qh9dikhri2m5v3, referencedTableName=domain_event		\N	3.5.3	\N	\N	0982757420
1464742487660-95	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.443396	94	EXECUTED	7:71fcced1d396fcc21860ac19b1250d59	addForeignKeyConstraint baseTableName=site_log_received, constraintName=fk66u1s5twhejx5r71kce1xbndo, referencedTableName=domain_event		\N	3.5.3	\N	\N	0982757420
1464742487660-96	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.449041	95	EXECUTED	7:4ce70e5ddaf0b478d894808fd059e34a	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk6j824swpk9wrunv18oltj7r4h, referencedTableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1464742487660-97	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.45464	96	EXECUTED	7:f87ca48a3c5f4d3b2587fd408baf9778	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk6l38ggororukg4q0921somuq2, referencedTableName=setup		\N	3.5.3	\N	\N	0982757420
1464742487660-98	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.460841	97	EXECUTED	7:0dc1da316946fbd00f11b02510a19dab	addForeignKeyConstraint baseTableName=sitelog_collocationinformation, constraintName=fk7dvx9fjqujrwswcq5ai8yrbgd, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-99	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.466121	98	EXECUTED	7:237c33fc64f28c7caa662f3e9108a10d	addForeignKeyConstraint baseTableName=sitelog_gnssgreceiver, constraintName=fk9pk6uvtcik5nbfnxqbj57sl7a, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-100	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.471993	99	EXECUTED	7:cb9185929be191f9d853d9fe0498fc38	addForeignKeyConstraint baseTableName=sitelog_pressuresensor, constraintName=fkac6h7fcxwqdb02wmd9ioa9qxy, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-101	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.477598	100	EXECUTED	7:866ce473d93a8cc157011461959de876	addForeignKeyConstraint baseTableName=sitelog_frequencystandard, constraintName=fkdbdv2fxny6htdef63toxeouo4, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-102	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.486948	101	EXECUTED	7:4b3538a963763c3641cf17058617f6d2	addForeignKeyConstraint baseTableName=sitelog_otherinstrumentation, constraintName=fkeuy2r6xamax3cuji4c48scctu, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-103	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.492129	102	EXECUTED	7:920fac2bc1b9ed95e71512c3200c85f6	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fkfhimbva6rwtmx2jwvtimp1iau, referencedTableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1464742487660-104	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.497621	103	EXECUTED	7:3b74b3d985555f8dc54dd3c92393ae35	addForeignKeyConstraint baseTableName=sitelog_watervaporsensor, constraintName=fkgu7ol5xrkfrdcx68jg7y3yfnx, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-105	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.504329	104	EXECUTED	7:a162adf81baf0fc078c72291d4072de3	addForeignKeyConstraint baseTableName=cors_site, constraintName=fkhsotbco85rmtycrk2fydldkv5, referencedTableName=site		\N	3.5.3	\N	\N	0982757420
1464742487660-106	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.513332	105	EXECUTED	7:059049cc8953de8cf3580c31dde417e0	addForeignKeyConstraint baseTableName=sitelog_radiointerference, constraintName=fkketnpsi74n9jy8h4ivigf0rm5, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-107	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.519633	106	EXECUTED	7:6f210c37e32c7284c2564b7e52c75a8b	addForeignKeyConstraint baseTableName=sitelog_mutlipathsource, constraintName=fkkria59xm558w92kh5lqpd1f3x, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-108	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.526138	107	EXECUTED	7:268d5db86999c6b7657f570c615cccee	addForeignKeyConstraint baseTableName=sitelog_humiditysensor, constraintName=fkmlt0smj74de6jldjl24s27vj8, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-109	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.531866	108	EXECUTED	7:7eb3f4736e810a5e3c3d0f0e41f35895	addForeignKeyConstraint baseTableName=sitelog_localepisodicevent, constraintName=fkmx1d8uddptk7ey2qqemjblaqh, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-110	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.53773	109	EXECUTED	7:1bdfce992e3c77a27ef9016d532460e9	addForeignKeyConstraint baseTableName=sitelog_temperaturesensor, constraintName=fkqi6nwchgfbv76i7lbyommqfb5, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-111	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.543965	110	EXECUTED	7:188e95c9d80a127147b946687ffacf40	addForeignKeyConstraint baseTableName=sitelog_surveyedlocaltie, constraintName=fksve549v5ist4ri18uvf8sxjn3, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1464742487660-112	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.551945	111	EXECUTED	7:8dc1eb19a98a3c0389e9cef54d4a9997	addForeignKeyConstraint baseTableName=invalid_site_log_received, constraintName=fkt0wcgi5uifpvl1m5vbxtbql2d, referencedTableName=domain_event		\N	3.5.3	\N	\N	0982757420
1464742487660-113	simon (generated)	db/geodesy-db-schema-baseline.xml	2016-12-06 00:05:58.558341	112	EXECUTED	7:ec69a902fb46a78acc713b7eb1320150	addForeignKeyConstraint baseTableName=weekly_solution_available, constraintName=fktiaeyjhtj7j08vvfdab8ft66y, referencedTableName=domain_event		\N	3.5.3	\N	\N	0982757420
1465197179687-1	lazar (generated)	db/rename-site-name-column.xml	2016-12-06 00:05:58.56309	113	EXECUTED	7:30176eccb1c353c08f0d1e5d0ffbd669	renameColumn newColumnName=name, oldColumnName=site_name, tableName=site		\N	3.5.3	\N	\N	0982757420
1465281587609-1	lazar (generated)	db/add-site-log-text-column.xml	2016-12-06 00:05:58.569878	114	EXECUTED	7:d34ec880ecf16b3af5cb0e496eb26980	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -1	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2016-12-06 00:05:58.577439	115	EXECUTED	7:38cd051bf0abe331df1d1fa32aded0b3	renameTable newTableName=sitelog_gnssreceiver, oldTableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	0982757420
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -2	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2016-12-06 00:05:58.583388	116	EXECUTED	7:010e839a366777cbbf0e3ad0aac260b1	dropPrimaryKey constraintName=sitelog_gnssgreceiver_pkey, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -3	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2016-12-06 00:05:58.591511	117	EXECUTED	7:86c2d2f53c81f86d6dcd5b0b5d9e1b45	addPrimaryKey constraintName=sitelog_gnssreceiver_pkey, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1465522320786-1	brookes (generated)	db/geodesy-add-sitelog_site_midoi.xml	2016-12-06 00:05:58.597154	118	EXECUTED	7:9f3e8d11cc1299d3efe75138289ac4dc	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1466471561618-1	heya (custom)	db/remove-event-date-and-add-effective-dates.xml	2016-12-06 00:05:58.603756	119	EXECUTED	7:b9b466b606ada9a3a70139f15f43002d	dropColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1466471561618-2	heya (generated)	db/remove-event-date-and-add-effective-dates.xml	2016-12-06 00:05:58.609585	120	EXECUTED	7:7a39e7c9631382d4edb1e68d415ba11c	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1466471561618-3	heya (generated)	db/remove-event-date-and-add-effective-dates.xml	2016-12-06 00:05:58.614106	121	EXECUTED	7:e88f63953bec09ee4459c46ae343bc99	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1467790767-1	lbodor (custom)	db/add-equipment-configuration-fks.xml	2016-12-06 00:05:58.638524	122	EXECUTED	7:b22597da8e3bb04b9a3456d0d22a51b9	addForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_equipmentconfiguration_equipment, referencedTableName=equipment; addForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_equipmentconf...		\N	3.5.3	\N	\N	0982757420
rename equipment foreign keys	simon	db/geodesy-rename-equipment-fks.xml	2016-12-06 00:05:58.649192	123	EXECUTED	7:4e4b798984f4881008f917b73f2ca367	sql		\N	3.5.3	\N	\N	0982757420
drop generically named foreign keys	simon	db/geodesy-drop-generically-named-fks.xml	2016-12-06 00:05:58.675228	124	EXECUTED	7:f6098a0c34313a9cba3281ee6316e065	sql		\N	3.5.3	\N	\N	0982757420
1469510134849-1	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.68172	125	EXECUTED	7:98c25aebe6e16dd4cc1e9cb8f972c61e	addForeignKeyConstraint baseTableName=cors_site, constraintName=fk_cors_site_monument, referencedTableName=monument		\N	3.5.3	\N	\N	0982757420
1469510134849-2	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.687652	126	EXECUTED	7:e552f823e6c3b4ea4315a7abd7067cc6	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_responsible_party_contact, referencedTableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1469510134849-3	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.694267	127	EXECUTED	7:abfb804a456a4bd7318633e88af58cc3	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_responsible_party_custodian, referencedTableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1469510134849-4	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.700829	128	EXECUTED	7:bd2ce4e0a3e2e2151e160702255a6a79	addForeignKeyConstraint baseTableName=sitelog_collocationinformation, constraintName=fk_sitelog_site_sitelog_collocationinformation, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-5	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.71481	129	EXECUTED	7:cab35a37da7dfa174127efc560946a93	addForeignKeyConstraint baseTableName=sitelog_gnssantenna, constraintName=fk_sitelog_site_sitelog_gnss_antenna, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-6	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.724494	130	EXECUTED	7:835c1bfbd6583bf1a7d1947a99e04f5d	addForeignKeyConstraint baseTableName=sitelog_gnssreceiver, constraintName=fk_sitelog_site_sitelog_gnss_receiver, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-7	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.73044	131	EXECUTED	7:ae5e9385ccc2ae732be2085389c5378f	addForeignKeyConstraint baseTableName=sitelog_humiditysensor, constraintName=fk_sitelog_site_sitelog_humiditysensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-8	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.736677	132	EXECUTED	7:6ec8ee8c41b1d62149d7591a6934e97c	addForeignKeyConstraint baseTableName=sitelog_localepisodicevent, constraintName=fk_sitelog_site_sitelog_localepisodicevent, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-9	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.743264	133	EXECUTED	7:81766d9f8b3d9e4d1719ee710e97db31	addForeignKeyConstraint baseTableName=sitelog_mutlipathsource, constraintName=fk_sitelog_site_sitelog_mutlipathsource, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-10	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.749894	134	EXECUTED	7:518dce5da95ac8b16296ca161a4d4faa	addForeignKeyConstraint baseTableName=sitelog_otherinstrumentation, constraintName=fk_sitelog_site_sitelog_otherinstrumentation, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-11	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.755943	135	EXECUTED	7:6a79935ca90ba52c6f4b99e9784d946d	addForeignKeyConstraint baseTableName=sitelog_pressuresensor, constraintName=fk_sitelog_site_sitelog_pressuresensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-12	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.762	136	EXECUTED	7:e8f5f21fdeee8f8a549ce9cbf2015ed8	addForeignKeyConstraint baseTableName=sitelog_radiointerference, constraintName=fk_sitelog_site_sitelog_radiointerference, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-13	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.767676	137	EXECUTED	7:7631467723b12d7b4c7b6c75646e88cb	addForeignKeyConstraint baseTableName=sitelog_signalobstraction, constraintName=fk_sitelog_site_sitelog_signalobstraction, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-14	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.773979	138	EXECUTED	7:85099192f85d2cd087b54df8b9eabaa0	addForeignKeyConstraint baseTableName=sitelog_surveyedlocaltie, constraintName=fk_sitelog_site_sitelog_surveyedlocaltie, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-15	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.781019	139	EXECUTED	7:6af060e5cfce7dba23108d2dd19e2dc5	addForeignKeyConstraint baseTableName=sitelog_temperaturesensor, constraintName=fk_sitelog_site_sitelog_temperaturesensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-16	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.78781	140	EXECUTED	7:df9c8a495661d89da59c8a20af412db5	addForeignKeyConstraint baseTableName=sitelog_watervaporsensor, constraintName=fk_sitelog_site_sitelog_watervaporsensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1469510134849-17	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2016-12-06 00:05:58.793643	141	EXECUTED	7:37a6c2fe9d084fcd0233e1cd928a0610	addForeignKeyConstraint baseTableName=sitelog_frequencystandard, constraintName=fk_sitelog_site_sitelogfrequencystandard, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1472444888001-1	ted (generated)	db/add-site-log-nine-character-id-column.xml	2016-12-06 00:05:58.80235	142	EXECUTED	7:01cab3f46d7bdf69e55306889f2a9b9b	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-1	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.807351	143	EXECUTED	7:92e7ca1c1cad84b10b9174280d2433ba	modifyDataType columnName=accurace_degree_celcius, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-2	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.811606	144	EXECUTED	7:f8c7a552888d14eb6fcc5a042818f022	modifyDataType columnName=accuracy_hpa, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-3	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.817013	145	EXECUTED	7:23e42b3b1894b40ef6756787631d64c4	modifyDataType columnName=accuracy_percent_rel_humidity, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-4	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.822724	146	EXECUTED	7:9109609cf7a72198f098342df8e7f2fc	modifyDataType columnName=alignment_from_true_north, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-6	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.829575	148	EXECUTED	7:0ee8e4a912123120e72a00a7918387ac	modifyDataType columnName=antenna_cable_length, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-7	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.834701	149	EXECUTED	7:f76ff4ceebf0dd2d9ff56940b69aa9b0	modifyDataType columnName=antenna_cable_length, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-8	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.841125	150	EXECUTED	7:e04689cf3399422d3779bb4199802652	modifyDataType columnName=antenna_cable_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-9	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.844661	151	EXECUTED	7:29cd1aa58e698edbfe4cc658a7471cce	modifyDataType columnName=antenna_cable_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-10	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.848356	152	EXECUTED	7:f48db6f23384e1ad29f2238610abf626	modifyDataType columnName=antenna_radome_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-11	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.85221	153	EXECUTED	7:8829fe584a9c1d95d26a162e0638b7f6	modifyDataType columnName=antenna_reference_point, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-12	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.856499	154	EXECUTED	7:722d7e94f2ab7cb54abd6d1d4a6ee3fd	modifyDataType columnName=antenna_reference_point, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-13	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.860347	155	EXECUTED	7:bd55296b1a46cedd2a93c07a747d17df	modifyDataType columnName=antenna_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-14	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.868445	156	EXECUTED	7:3fe0af6fc724100b7a6aa07dcb3e5442	modifyDataType columnName=aspiration, tableName=humidity_sensor		\N	3.5.3	\N	\N	0982757420
1473286366418-15	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.873876	157	EXECUTED	7:b24005f9d425c38b065ae57d2a67f63c	modifyDataType columnName=aspiration, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-16	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.878797	158	EXECUTED	7:0f4b908e5f69d55e44cedf771efea850	modifyDataType columnName=aspiration, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-17	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.883723	159	EXECUTED	7:23621128b058da0233bf85508ad39967	modifyDataType columnName=bedrock_condition, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1473286366418-18	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.889041	160	EXECUTED	7:4ce4ce0d8a4b812bfabd4410f66404e6	modifyDataType columnName=bedrock_condition, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-19	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.894014	161	EXECUTED	7:99ae714f1659a3c3dff2e07bc88abd37	modifyDataType columnName=bedrock_type, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1473286366418-20	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.898812	162	EXECUTED	7:e2e8b81b57dc77e2e20aadb38292ff14	modifyDataType columnName=bedrock_type, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-21	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.903743	163	EXECUTED	7:ff7e5151aa2a8c8a476f7c86e295149f	modifyDataType columnName=cdp_number, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-22	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.908725	164	EXECUTED	7:53b69025d0f11dbb46d491c5caece569	modifyDataType columnName=city, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-23	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.913513	165	EXECUTED	7:d9af7f31f2d94048b16718165e8a839f	modifyDataType columnName=country, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-24	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.918198	166	EXECUTED	7:dc1ec015f2cfa4fe3a949a2f41415f91	modifyDataType columnName=data_sampling_interval, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-25	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.922625	167	EXECUTED	7:070b9d5fb1a398778788ac6b400f166b	modifyDataType columnName=data_sampling_interval, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-26	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.927339	168	EXECUTED	7:298e337b32c10e77b0d3a85001b01f31	modifyDataType columnName=data_sampling_interval, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-27	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.932146	169	EXECUTED	7:e8f63fd58497d85bb3ecd7b625f84e39	modifyDataType columnName=description, tableName=monument		\N	3.5.3	\N	\N	0982757420
1473286366418-28	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.936941	170	EXECUTED	7:e1497cb4d6bfa2d0b035c197e02079a0	modifyDataType columnName=description, tableName=site		\N	3.5.3	\N	\N	0982757420
1473286366418-29	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.941356	171	EXECUTED	7:216acc7b35909bee195c81a80a48bc49	modifyDataType columnName=distance_activity, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-30	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.945814	172	EXECUTED	7:7a73fc3416f424291f030ae0b4fac557	modifyDataType columnName=domes_number, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1473286366418-31	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.95037	173	EXECUTED	7:d5248dc95c2e33beaa4339746cd4f335	modifyDataType columnName=elevation_cutoff_setting, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-32	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.954608	174	EXECUTED	7:6b0d7d9db71db8c0dd4a652c44de4372	modifyDataType columnName=elevation_cutoff_setting, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-33	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.959317	175	EXECUTED	7:cbb7ab89935ad9a15e4e5966fec8aaaf	modifyDataType columnName=elevation_grs80, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-34	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.964359	176	EXECUTED	7:0cc29f1a4fba14e5c2371155d30e6283	modifyDataType columnName=equipment_type, tableName=equipment		\N	3.5.3	\N	\N	0982757420
1473286366418-35	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.96866	177	EXECUTED	7:68c34141044533a8dd2948d89c564400	modifyDataType columnName=error, tableName=domain_event		\N	3.5.3	\N	\N	0982757420
1473286366418-36	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.973268	178	EXECUTED	7:3617291f868f28905a25f8f18fdb2287	modifyDataType columnName=event, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	0982757420
1473286366418-37	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.977741	179	EXECUTED	7:d1edaf0db57f584e9696a6d128cdf6e6	modifyDataType columnName=event_name, tableName=domain_event		\N	3.5.3	\N	\N	0982757420
1473286366418-38	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.983855	180	EXECUTED	7:366366d0edd58673d5babb138d1b3d9e	modifyDataType columnName=fault_zones_nearby, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-39	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.988344	181	EXECUTED	7:0ee4b04c9a6465c12860d67d6716cc53	modifyDataType columnName=firmware_version, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-40	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.992856	182	EXECUTED	7:0b695a192930dd286ac3037b50ec88fa	modifyDataType columnName=firmware_version, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-41	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:58.99731	183	EXECUTED	7:9062e36e16308aee0a23aae9ffce202d	modifyDataType columnName=form_prepared_by, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-42	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.001956	184	EXECUTED	7:017becf0fdaaa71f17def0cfecc2d212	modifyDataType columnName=form_report_type, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-43	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.006652	185	EXECUTED	7:66a43f5e52c293f3989516b15ef7a83e	modifyDataType columnName=foundation, tableName=monument		\N	3.5.3	\N	\N	0982757420
1473286366418-44	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.011291	186	EXECUTED	7:76b5328ed3dd88766c11da6f63a7a659	modifyDataType columnName=foundation_depth, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-45	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.018973	187	EXECUTED	7:a6607551df3ac02de5897c3e876ef0e3	modifyDataType columnName=four_char_id, tableName=site_log_received		\N	3.5.3	\N	\N	0982757420
1473286366418-46	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.02407	188	EXECUTED	7:ccb26a0d59502a8d6d198701c4f4b7cb	modifyDataType columnName=fracture_spacing, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-47	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.028374	189	EXECUTED	7:3e517c92d51ee71ba530e2c2766fc9de	modifyDataType columnName=geologic_characteristic, tableName=cors_site		\N	3.5.3	\N	\N	0982757420
1473286366418-48	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.033534	190	EXECUTED	7:8e4e1078c3702c80fb1043d260d655db	modifyDataType columnName=geologic_characteristic, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-49	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.037335	191	EXECUTED	7:29e54ff57c679cc897d9d0ca9e99ab03	modifyDataType columnName=height, tableName=monument		\N	3.5.3	\N	\N	0982757420
1473286366418-50	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.04144	192	EXECUTED	7:8037ba98f5693f8fdc79d91c6f4cb865	modifyDataType columnName=height_diff_to_antenna, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-51	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.045849	193	EXECUTED	7:6e791b3cd7871e217050f02bf31a7218	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-52	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.04917	194	EXECUTED	7:21a5638407967bf6a9eb24da170bd968	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-53	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.052591	195	EXECUTED	7:895acdee719ba5b57d475c41956e5452	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-54	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.055892	196	EXECUTED	7:ddd820a90cf1028efb07ebf47ed3a1ef	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1473286366418-55	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.059284	197	EXECUTED	7:7cc433fc6ff054d793b0417b517c1eb4	modifyDataType columnName=height_of_monument, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-56	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.062613	198	EXECUTED	7:9f120764a7202cbe5152b67c1570644e	modifyDataType columnName=iers_domes_number, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-57	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.067974	199	EXECUTED	7:d35cb2617214ca1d791800e7c55783d5	modifyDataType columnName=input_frequency, tableName=clock_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-58	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.071578	200	EXECUTED	7:1fc617c598b542b6a5b67f924dc06208	modifyDataType columnName=input_frequency, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	0982757420
1473286366418-59	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.075539	201	EXECUTED	7:334c6d75a267553c4532e205393cdebd	modifyDataType columnName=instrument_type, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	0982757420
1473286366418-60	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.079542	202	EXECUTED	7:7763ed17364f1fa3b9ba3990a31a95ba	modifyDataType columnName=instrumentation, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	0982757420
1473286366418-61	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.083589	203	EXECUTED	7:55e23eece2b5e5736b8e758c3ff1481a	modifyDataType columnName=iso_19115, tableName=responsible_party		\N	3.5.3	\N	\N	0982757420
1473286366418-62	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.087471	204	EXECUTED	7:6e1011722804bae6171e863da9bfe609	modifyDataType columnName=local_site_tie_accuracy, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-63	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.091613	205	EXECUTED	7:a8975aef55b466014c9508f514917925	modifyDataType columnName=location_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-64	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.095684	206	EXECUTED	7:e802aea1ba8fe3c8d4f10dc8daa7e294	modifyDataType columnName=manufacturer, tableName=equipment		\N	3.5.3	\N	\N	0982757420
1473286366418-65	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.099676	207	EXECUTED	7:3372f798afb6d96a0f40e41587f87089	modifyDataType columnName=manufacturer, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-66	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.103562	208	EXECUTED	7:7e4c8bf7e183672b355685e0cf9b3a6c	modifyDataType columnName=manufacturer, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-67	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.107624	209	EXECUTED	7:b7f24d991355a06e9fa8ee7804c9319a	modifyDataType columnName=manufacturer, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-68	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.11151	210	EXECUTED	7:cff446e9690dd0e8051ef2f96a1c0be0	modifyDataType columnName=manufacturer, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1473286366418-69	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.115351	211	EXECUTED	7:12c917be0918e11d8d813fcb199d54ea	modifyDataType columnName=marker_description, tableName=monument		\N	3.5.3	\N	\N	0982757420
1473286366418-70	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.11925	212	EXECUTED	7:096b417860141f21b2064148a3a9fac9	modifyDataType columnName=marker_description, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-71	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.123122	213	EXECUTED	7:d22d0fa30faeec447454137ca0af651e	modifyDataType columnName=mi_antenna_graphics, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-72	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.127014	214	EXECUTED	7:3655eb55154264abe582266519c32ea9	modifyDataType columnName=mi_doi, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-73	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.130991	215	EXECUTED	7:f095ddec827b6b94b25351aa0187907a	modifyDataType columnName=mi_hard_copy_on_file, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-74	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.135008	216	EXECUTED	7:da41585880c2eb3812b532cd62a26a18	modifyDataType columnName=mi_horizontal_mask, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-75	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.138861	217	EXECUTED	7:1ce2f22e9e5c5502c87fa954cfe51036	modifyDataType columnName=mi_monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-76	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.142795	218	EXECUTED	7:7729c50b2c47e1b4bf7af3723740c559	modifyDataType columnName=mi_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-77	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.146987	219	EXECUTED	7:ab4b566fe292bcd4b99f83107e27fc4e	modifyDataType columnName=mi_primary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-78	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.151082	220	EXECUTED	7:3db03922bd8dafa3c3bf841870f681bf	modifyDataType columnName=mi_secondary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-79	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.155028	221	EXECUTED	7:55572fc1ce09796d559822a1ab16d6c0	modifyDataType columnName=mi_site_diagram, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-80	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.159023	222	EXECUTED	7:8e9795b80058bfb76e46f708705e5e0a	modifyDataType columnName=mi_site_map, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-81	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.163185	223	EXECUTED	7:ccb89e0c4b803e16cf34d2da369095f5	modifyDataType columnName=mi_site_pictires, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-82	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.167509	224	EXECUTED	7:4194be60af747139aae14111f4aa1f39	modifyDataType columnName=mi_text_graphics_from_antenna, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-83	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.171542	225	EXECUTED	7:89b6d58bdf95df7432fea8239057d934	modifyDataType columnName=mi_url_for_more_information, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-84	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.175544	226	EXECUTED	7:019db638e2576d29eb13affd82ead7e2	modifyDataType columnName=monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-85	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.179687	227	EXECUTED	7:3d7824c6c297f595b40f92ef75021bc9	modifyDataType columnName=monument_foundation, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-86	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.183914	228	EXECUTED	7:e35c2e4f12a4d5d0c1885c203e1e298c	modifyDataType columnName=monument_inscription, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-87	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.190664	229	EXECUTED	7:c5b8c87dcfb47453948653c8c9eaeb8c	modifyDataType columnName=name, tableName=setup		\N	3.5.3	\N	\N	0982757420
1473286366418-88	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.19473	230	EXECUTED	7:af89c081a1467ae46f72e673e72688d4	modifyDataType columnName=name, tableName=site		\N	3.5.3	\N	\N	0982757420
1473286366418-89	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.198642	231	EXECUTED	7:b67245dec0ebdcb71cbae939fc82d30d	modifyDataType columnName=notes, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-90	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.202605	232	EXECUTED	7:90cab3c99f1e121c11c00259692cfdb6	modifyDataType columnName=notes, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-91	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.206927	233	EXECUTED	7:4195bb205ccd1eca27835b6a7cc9db50	modifyDataType columnName=notes, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-92	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.210936	234	EXECUTED	7:ce55160fd597f291ff0201ba3e172a55	modifyDataType columnName=notes, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	0982757420
1473286366418-93	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.215083	235	EXECUTED	7:cf0f6e6d91d175181580accdc13057d7	modifyDataType columnName=notes, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	0982757420
1473286366418-94	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.219019	236	EXECUTED	7:67c4108c0b3c3bb9291502b21f4c7888	modifyDataType columnName=notes, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-95	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.222957	237	EXECUTED	7:c5066ef89dcc9af66cef2a2a4de09320	modifyDataType columnName=notes, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-96	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.22704	238	EXECUTED	7:7b9a74b0c3fff234ab3dde3c58db115e	modifyDataType columnName=notes, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-97	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.231114	239	EXECUTED	7:315aee88eaaed0279baf1ad6892e9b59	modifyDataType columnName=notes, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-98	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.234636	240	EXECUTED	7:3606dada87e6935eb8050014b1031678	modifyDataType columnName=notes, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-99	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.237951	241	EXECUTED	7:312ce26aeb9d49ce7537221a17b0fe33	modifyDataType columnName=notes, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-100	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.24227	242	EXECUTED	7:21039fe683b8e98764e3f4da62fdba5e	modifyDataType columnName=notes, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-101	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.24609	243	EXECUTED	7:d01ff68675329c55d7fc3141bddd135b	modifyDataType columnName=notes, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1473286366418-102	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.252916	244	EXECUTED	7:12a07dcbbf2638d0a187bd22a06ca87a	modifyDataType columnName=observed_degradation, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	0982757420
1473286366418-103	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.256695	245	EXECUTED	7:92eb2759078652b366180895e607c360	modifyDataType columnName=radome_serial_number, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-104	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.260007	246	EXECUTED	7:5910fdaabacaa896b61f732e68bdd2be	modifyDataType columnName=radome_serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-105	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.264222	247	EXECUTED	7:a5a2973a91f54b3dba12c6d6eef45c4c	modifyDataType columnName=radome_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-106	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.268458	248	EXECUTED	7:893957b059ec2f9429660932f49e431a	modifyDataType columnName=receiver_type, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-107	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.272589	249	EXECUTED	7:c56310dbd8b5bad3689fc52e45a24a5f	modifyDataType columnName=satellite_system, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-108	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.276714	250	EXECUTED	7:5cf90c470db95c609a29f599658e155b	modifyDataType columnName=satellite_system, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-109	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.280876	251	EXECUTED	7:542ff5084fe6ac56df07b94590841f88	modifyDataType columnName=serial_number, tableName=equipment		\N	3.5.3	\N	\N	0982757420
1473286366418-110	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.285081	252	EXECUTED	7:6ac8a8ac1595b43bf2ec47e1253af51e	modifyDataType columnName=serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	0982757420
1473286366418-111	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.289364	253	EXECUTED	7:73d01d74b43146823be52d6ee160e14b	modifyDataType columnName=serial_number, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-112	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.293407	254	EXECUTED	7:55df725e9829b7edcd2abf1e3a76ad4e	modifyDataType columnName=serial_number, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-113	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.297596	255	EXECUTED	7:5abaa3966d94f27f702c58c7c8d6a100	modifyDataType columnName=serial_number, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-114	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.301751	256	EXECUTED	7:21be4a8dd9d19a4ffbb3b2fedaa32898	modifyDataType columnName=serial_number, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-115	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.306142	257	EXECUTED	7:0aa47cc9a70a7c0f590ed53797ec5a4c	modifyDataType columnName=serial_number, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1473286366418-116	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.313508	258	EXECUTED	7:4ed51303a22da91d839f2573856ebd61	modifyDataType columnName=sinex_file_name, tableName=weekly_solution		\N	3.5.3	\N	\N	0982757420
1473286366418-117	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.318063	259	EXECUTED	7:379ad151180be24488c773a5b869526b	modifyDataType columnName=site_log_text, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	0982757420
1473286366418-118	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.322413	260	EXECUTED	7:9c0d84f42aad093c88731106461d01ed	modifyDataType columnName=site_log_text, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-119	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.326869	261	EXECUTED	7:204256a2569caaedd9b5e8e670453fcd	modifyDataType columnName=site_name, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-120	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.331381	262	EXECUTED	7:d51770cff75d5adaa5cb7af36f1cb9a4	modifyDataType columnName=state, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-121	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.335847	263	EXECUTED	7:9bd75b36ebf4a304fac92156bd81adf6	modifyDataType columnName=status, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	0982757420
1473286366418-122	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.340249	264	EXECUTED	7:d46164f310eaeb26888edd313b6a92b5	modifyDataType columnName=subscriber, tableName=domain_event		\N	3.5.3	\N	\N	0982757420
1473286366418-123	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.344536	265	EXECUTED	7:79ee84d20c5841bddfb3ce5e6ab3de98	modifyDataType columnName=survey_method, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-124	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.348899	266	EXECUTED	7:b84a1bb8242840b3433996dbcdda0926	modifyDataType columnName=tectonic_plate, tableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1473286366418-125	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.353226	267	EXECUTED	7:5cdeffb3022d8291c76cfca0082d733a	modifyDataType columnName=temperature_stabilization, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1473286366418-126	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.357498	268	EXECUTED	7:e84ae239c25ddfc72e44fedd2077cddb	modifyDataType columnName=temperature_stabilization, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	0982757420
1473286366418-127	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.362187	269	EXECUTED	7:483d2c2397da2fff882b5712b2bfe98c	modifyDataType columnName=tied_marker_cdp_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-128	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.373998	270	EXECUTED	7:da6fe2c8a3585f972aae5f3a6d7ece7a	modifyDataType columnName=tied_marker_domes_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-129	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.379741	271	EXECUTED	7:ee62d453d2623d7c6892aa72978ce8d3	modifyDataType columnName=tied_marker_name, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-130	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.386172	272	EXECUTED	7:1624669cac317d1a526c37904743d22b	modifyDataType columnName=tied_marker_usage, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	0982757420
1473286366418-131	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.390476	273	EXECUTED	7:15ca6ad873b575b1bad013a2c88f9ff7	modifyDataType columnName=type, tableName=equipment		\N	3.5.3	\N	\N	0982757420
1473286366418-132	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.395212	274	EXECUTED	7:5a5e5579045004fdd3a9e49d605699d2	modifyDataType columnName=type, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	0982757420
1473286366418-133	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.399957	275	EXECUTED	7:9b5b3e6603d5c247b017404c39620be9	modifyDataType columnName=type, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	0982757420
1473286366418-134	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.404542	276	EXECUTED	7:ae2bc29d5a2238cbe2612c1b3c14e328	modifyDataType columnName=type, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	0982757420
1473286366418-135	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.409188	277	EXECUTED	7:026fcde64700a65734370102a46086e4	modifyDataType columnName=type, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	0982757420
1473286366418-136	lbodor (generated)	db/use-text-data-type.xml	2016-12-06 00:05:59.41389	278	EXECUTED	7:3f1d51b9ade48b4b58ccb828a0a6e671	modifyDataType columnName=type, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	0982757420
1473637019131-1	hong (generated)	db/add_missing_fk.xml	2016-12-06 00:05:59.421663	279	EXECUTED	7:ef9a9ccf38c87d85475c7b7ae8f7d416	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk_equipment_in_use_equipmentid, referencedTableName=equipment		\N	3.5.3	\N	\N	0982757420
1473637019131-2	hong (generated)	db/add_missing_fk.xml	2016-12-06 00:05:59.427607	280	EXECUTED	7:8ab18b53c9fe136bd7cb495cbc1584d5	addForeignKeyConstraint baseTableName=setup, constraintName=fk_setup_siteid, referencedTableName=site		\N	3.5.3	\N	\N	0982757420
1473998705916-1	asedgmen (generated)	db/prepare-view-for-site-wfs.xml	2016-12-06 00:05:59.484699	281	EXECUTED	7:2a66b32757b8c3dd877d3a6bd370af7e	addColumn tableName=site		\N	3.5.3	\N	\N	0982757420
1473998705916-2	asedgmen (generated)	db/prepare-view-for-site-wfs.xml	2016-12-06 00:05:59.493063	282	EXECUTED	7:a4d3132975624d5752d9d521f2279881	createView viewName=v_cors_site		\N	3.5.3	\N	\N	0982757420
1474431967	asedgment	db/add-comment-to-cors-site-view.sql	2016-12-06 00:05:59.497277	283	EXECUTED	7:e7173f7586756a383e80a078693ee637	sql		\N	3.5.3	\N	\N	0982757420
1474419465891-1	hong (generated)	db/create_equipment_configuration_table.xml	2016-12-06 00:05:59.502348	284	EXECUTED	7:6c7ab0aad5834ee4471e38f52cf801b8	createTable tableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474419465891-2	hong (generated)	db/create_equipment_configuration_table.xml	2016-12-06 00:05:59.510122	285	EXECUTED	7:0f2259effae1616adb83dd6c602ada58	addPrimaryKey constraintName=equjipment_configuration_pkey, tableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474424364	HongJin	db/add_records_to_equipment_configuration.sql	2016-12-06 00:05:59.523578	286	EXECUTED	7:27c581adb9942c587999c863c3fcd7d2	sql		\N	3.5.3	\N	\N	0982757420
1474431280707-1	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.528741	287	EXECUTED	7:89d348ea863b0c5583073e357c00e8b5	addForeignKeyConstraint baseTableName=clock_configuration, constraintName=fk_clock_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474431280707-2	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.534059	288	EXECUTED	7:faaea3e30aeb67869ed51c570974327f	addForeignKeyConstraint baseTableName=equipment_configuration, constraintName=fk_equipment_configuration_equipment_id, referencedTableName=equipment		\N	3.5.3	\N	\N	0982757420
1474431280707-3	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.539086	289	EXECUTED	7:44d9184533a0d986254d61f014043b4d	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk_equipment_in_use_equipment_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474431280707-4	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.544193	290	EXECUTED	7:86fa637e9ef717bd9b068587f44c2d8d	addForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_gnss_antenna_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474431280707-5	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.549769	291	EXECUTED	7:90f9b05c0dc59e82c4fcc00843d45ec3	addForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_gnss_receiver_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474431280707-6	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.555665	292	EXECUTED	7:db3e198044b01a9224ded75b9ceba35f	addForeignKeyConstraint baseTableName=humidity_sensor_configuration, constraintName=fk_humidity_sensor_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	0982757420
1474431280707-7	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.562766	293	EXECUTED	7:2619a097fd843d65f10b4bfd7c3e900f	dropForeignKeyConstraint baseTableName=clock_configuration, constraintName=fk_clock_configuration_equipment		\N	3.5.3	\N	\N	0982757420
1474431280707-8	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.567982	294	EXECUTED	7:575f24993c1f38adf20b713755da4212	dropForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_gnss_antenna_configuration_equipment		\N	3.5.3	\N	\N	0982757420
1474431280707-9	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.571814	295	EXECUTED	7:bc76711ccaffad526b7f01cbb29fe575	dropForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_gnss_receiver_configuration_equipment		\N	3.5.3	\N	\N	0982757420
1474431280707-10	hong (generated)	db/redo_fk_link.xml	2016-12-06 00:05:59.576024	296	EXECUTED	7:00c3a739e50e105ad72e5262b37a2158	dropForeignKeyConstraint baseTableName=humidity_sensor_configuration, constraintName=fk_humidity_sensor_configuration_equipment		\N	3.5.3	\N	\N	0982757420
1474524159272-1	hong (generated)	db/drop_configuration_time_columns.xml	2016-12-06 00:05:59.580925	297	EXECUTED	7:f0c7a58af1d6ab11182b6f1baec70586	dropColumn columnName=configuration_time, tableName=clock_configuration		\N	3.5.3	\N	\N	0982757420
1474524159272-2	hong (generated)	db/drop_configuration_time_columns.xml	2016-12-06 00:05:59.585504	298	EXECUTED	7:f4f839a2b6c4429f31dfb2912e48d342	dropColumn columnName=configuration_time, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1474524159272-3	hong (generated)	db/drop_configuration_time_columns.xml	2016-12-06 00:05:59.590331	299	EXECUTED	7:1ff98d87494bce1acb6adcd58ce2c5e9	dropColumn columnName=configuration_time, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1474524159272-4	hong (generated)	db/drop_configuration_time_columns.xml	2016-12-06 00:05:59.594676	300	EXECUTED	7:e31504f32f8b8fed9b7e5e314f84e97a	dropColumn columnName=configuration_time, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1474595198431-1	hong (generated)	db/drop_equipment_id.xml	2016-12-06 00:05:59.59871	301	EXECUTED	7:be194533910984b77021d443f6081923	dropColumn columnName=equipment_id, tableName=clock_configuration		\N	3.5.3	\N	\N	0982757420
1474595198431-2	hong (generated)	db/drop_equipment_id.xml	2016-12-06 00:05:59.603068	302	EXECUTED	7:768b1692673544f655772cc28346af75	dropColumn columnName=equipment_id, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	0982757420
1474595198431-3	hong (generated)	db/drop_equipment_id.xml	2016-12-06 00:05:59.607497	303	EXECUTED	7:355583a97dc88106dd82a0341a0c1db6	dropColumn columnName=equipment_id, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	0982757420
1474595198431-4	hong (generated)	db/drop_equipment_id.xml	2016-12-06 00:05:59.611865	304	EXECUTED	7:75198f98d6b607c0a59b3322b17ae179	dropColumn columnName=equipment_id, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	0982757420
1475206562	HongJin	db/rename_all_constraints.sql	2016-12-06 00:05:59.653029	305	EXECUTED	7:abc7b96e0e506b08b33ee5ef61ce705e	sql		\N	3.5.3	\N	\N	0982757420
1475639382613-1	hong (generated)	db/create-temp-tab-for-9-digit-character.xml	2016-12-06 00:05:59.658285	306	EXECUTED	7:5abc7e428171f6251290b715646b50c4	createTable tableName=temp_9_character_data		\N	3.5.3	\N	\N	0982757420
1476162775	HongJin	db/add-9-character-id-to-cors-site.sql	2016-12-06 00:06:00.11131	307	EXECUTED	7:1663481dd8fa405a27807dcc1a92aff2	sql		\N	3.5.3	\N	\N	0982757420
1476314353412-1	hong (generated)	db/create-temp-tab-for-site-status-updating.xml	2016-12-06 00:06:00.116614	308	EXECUTED	7:f38e17eb271fd4c8574dc52b93ac2456	createTable tableName=temp_site_network		\N	3.5.3	\N	\N	0982757420
1476314353412-2	hong (generated)	db/create-temp-tab-for-site-status-updating.xml	2016-12-06 00:06:00.123715	309	EXECUTED	7:d9994e4b7721086960209351b27606e9	addPrimaryKey constraintName=temp_site_network_pkey, tableName=temp_site_network		\N	3.5.3	\N	\N	0982757420
1476314284	HongJin	db/update-site-status.sql	2016-12-06 00:06:00.772096	310	EXECUTED	7:f570c5f2d0243479ef6c2d9ab641ddf6	sql		\N	3.5.3	\N	\N	0982757420
1476851963015-1	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.781047	311	EXECUTED	7:34234d20f60ad8f78cd263e42cda449e	createTable tableName=cors_site_network		\N	3.5.3	\N	\N	0982757420
1476851963015-2	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.787361	312	EXECUTED	7:cd24dd7e48638b9d3ff8572a02b1c614	createTable tableName=cors_site_network_relation		\N	3.5.3	\N	\N	0982757420
1476851963015-3	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.794171	313	EXECUTED	7:10968f4a0390fa75c5cde342ac550e4a	addPrimaryKey constraintName=pk_cors_site_network_relation_id, tableName=cors_site_network_relation		\N	3.5.3	\N	\N	0982757420
1476851963015-4	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.801079	314	EXECUTED	7:7bcee42f0c1850f4281786d1b689c8ec	addPrimaryKey constraintName=pk_cors_site_networkid, tableName=cors_site_network		\N	3.5.3	\N	\N	0982757420
1476851963015-5	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.807141	315	EXECUTED	7:11261a0769e2265ac32a6b09cfdcb00d	addForeignKeyConstraint baseTableName=cors_site_network_relation, constraintName=fk_cors_site_network_relation_networkid, referencedTableName=cors_site_network		\N	3.5.3	\N	\N	0982757420
1476851963015-6	hong (generated)	db/add-site-network.xml	2016-12-06 00:06:00.812811	316	EXECUTED	7:afad96950627d89f1b1f24eb19a89953	addForeignKeyConstraint baseTableName=cors_site_network_relation, constraintName=fk_cors_site_network_relation_siteid, referencedTableName=cors_site		\N	3.5.3	\N	\N	0982757420
1476923463	HongJin	db/recreate-site-network-table.sql	2016-12-06 00:06:00.835439	317	EXECUTED	7:7a2986f49da3687b6485f10ad1dc0d3b	sql		\N	3.5.3	\N	\N	0982757420
1477355459	hongjin	db/add-records-to-site-network.xml	2016-12-06 00:06:00.84194	318	EXECUTED	7:294053b690b9c04887bfba7ea3540479	createProcedure		\N	3.5.3	\N	\N	0982757420
1477355830	hongjin	db/add-records-to-site-network.xml	2016-12-06 00:06:00.847565	319	EXECUTED	7:add0e41eece52c50727bc38ae14c441f	createProcedure		\N	3.5.3	\N	\N	0982757420
1477364071	HongJin	db/call-function-to-add-records-to-site-in-network.sql	2016-12-06 00:06:00.858909	320	EXECUTED	7:4cf0495cb6a006916683ae640b5df9b2	sql		\N	3.5.3	\N	\N	0982757420
1477527412	HongJin	db/add-missing-9-character.sql	2016-12-06 00:06:01.273508	321	EXECUTED	7:30ae826facdb006178584bf561500b5c	sql		\N	3.5.3	\N	\N	0982757420
1477623351128-1	hong (generated)	db/drop-temp-tables.xml	2016-12-06 00:06:01.278729	322	EXECUTED	7:8152bc20fa6f180e1fb73f69a8fa5310	dropTable tableName=temp_9_character_data		\N	3.5.3	\N	\N	0982757420
1477623351128-2	hong (generated)	db/drop-temp-tables.xml	2016-12-06 00:06:01.283972	323	EXECUTED	7:f4714d4137afa18dbfc011595c6e91e0	dropTable tableName=temp_site_network		\N	3.5.3	\N	\N	0982757420
1478057658650-1	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.292343	324	EXECUTED	7:9ea2605e38c351c3f5c767d8883acbb2	createTable tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478057658650-2	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.300542	325	EXECUTED	7:870bd3d11339c3733a0bafe940228cce	createTable tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478057658650-3	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.308135	326	EXECUTED	7:d2645f6e73949842c498a0a5e166f8a6	addPrimaryKey constraintName=pk_sitelog_responsible_party_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478057658650-4	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.315675	327	EXECUTED	7:14b1c2c08501df5134cfc67c8535b294	addPrimaryKey constraintName=pk_sitelog_responsible_party_role_id, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478057658650-5	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.322099	328	EXECUTED	7:788dce1ba968eddacf480c64426788a5	addForeignKeyConstraint baseTableName=sitelog_responsible_party, constraintName=fk_sitelog_responsible_party_responsiblerole, referencedTableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478057658650-6	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.328252	329	EXECUTED	7:ac347936b316c1cdb5121bfb36c95b60	addForeignKeyConstraint baseTableName=sitelog_responsible_party, constraintName=fk_sitelog_responsible_party_siteid, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	0982757420
1478057658650-7	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.333789	330	EXECUTED	7:7776a172d57528ec1be76b6478f0f8a2	dropForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_site_contactid		\N	3.5.3	\N	\N	0982757420
1478057658650-8	hong (generated)	db/creante-new-responsible-party-tables.xml	2016-12-06 00:06:01.339354	331	EXECUTED	7:d006da88c37134f39dd92d0b6f678899	dropForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_site_metadata_custodianid		\N	3.5.3	\N	\N	0982757420
1478058091	HongJin	db/migrate-site-responsible-party-data-to-new-table.sql	2016-12-06 00:06:01.349363	332	EXECUTED	7:b369f32e0400780c9ead61bed64a6726	sql		\N	3.5.3	\N	\N	0982757420
1478060335489-1	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.354113	333	EXECUTED	7:e54f5406e0963b70dead24dc47aa0037	setTableRemarks tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478060335489-2	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.358593	334	EXECUTED	7:82e2bc89e51283b80cd066e2306e23a7	setTableRemarks tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478060335489-3	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.36337	335	EXECUTED	7:69590dce648a42c70ddc3573e97b31c5	setColumnRemarks columnName=id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478060335489-4	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.368782	336	EXECUTED	7:e3c0c354cab77fbfc964930ab080c570	setColumnRemarks columnName=id, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478060335489-5	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.37362	337	EXECUTED	7:db9779ff8a8d8b41ba33d66227336193	setColumnRemarks columnName=responsible_party, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478060335489-6	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.378553	338	EXECUTED	7:a69fe92c55ec19683055ca65539e44f5	setColumnRemarks columnName=responsible_role, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478060335489-7	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.38328	339	EXECUTED	7:266deafcfff442e98f4a05d851599636	setColumnRemarks columnName=responsible_role_name, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478060335489-8	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.388068	340	EXECUTED	7:4b3ed381fc1170086ad5db3fb35f786e	setColumnRemarks columnName=responsible_role_xmltag, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	0982757420
1478060335489-9	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2016-12-06 00:06:01.392711	341	EXECUTED	7:b5c4b782426c52ad1c3cdc39acb3b5be	setColumnRemarks columnName=site_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
1478571328	HongJin	db/rename-responsible-party-column-name.sql	2016-12-06 00:06:01.397826	342	EXECUTED	7:92e3581d0f6464ae5f435e7402b5e50b	sql		\N	3.5.3	\N	\N	0982757420
1479093882	lbodor	db/drop-non-null-constraint.xml	2016-12-06 00:06:01.406331	343	EXECUTED	7:78da8e8451a1c34d46e074abbb6357b4	dropNotNullConstraint columnName=site_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	0982757420
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: domain_event; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY domain_event (event_name, id, error, retries, subscriber, time_handled, time_published, time_raised) FROM stdin;
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY equipment (equipment_type, id, manufacturer, serial_number, type, version) FROM stdin;
\.


--
-- Data for Name: equipment_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY equipment_configuration (equipment_configuration_id, equipment_id, configuration_time) FROM stdin;
\.


--
-- Data for Name: equipment_in_use; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY equipment_in_use (id, equipment_configuration_id, equipment_id, effective_from, effective_to, setup_id) FROM stdin;
\.


--
-- Data for Name: gnss_antenna_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY gnss_antenna_configuration (id, alignment_from_true_north, antenna_cable_length, antenna_cable_type, antenna_reference_point, marker_arp_east_eccentricity, marker_arp_north_eccentricity, marker_arp_up_eccentricity, notes, radome_serial_number, radome_type) FROM stdin;
\.


--
-- Data for Name: gnss_receiver_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY gnss_receiver_configuration (id, elevation_cutoff_setting, firmware_version, notes, satellite_system, temperature_stabilization) FROM stdin;
\.


--
-- Data for Name: humidity_sensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY humidity_sensor (aspiration, id) FROM stdin;
\.


--
-- Data for Name: humidity_sensor_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY humidity_sensor_configuration (id, height_diff_to_antenna, notes) FROM stdin;
\.


--
-- Data for Name: invalid_site_log_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY invalid_site_log_received (site_log_text, id) FROM stdin;
\.


--
-- Data for Name: monument; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY monument (id, description, foundation, height, marker_description) FROM stdin;
\.


--
-- Data for Name: node; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY node (id, effective_from, effective_to, invalidated, setup_id, site_id, version) FROM stdin;
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY "position" (id, as_at, datum_epsg_code, epoch, four_character_id, node_id, position_source_id, x, y) FROM stdin;
\.


--
-- Data for Name: responsible_party; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY responsible_party (id, iso_19115) FROM stdin;
\.


--
-- Name: seq_event; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_event', 1, false);


--
-- Name: seq_sitelogantenna; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogantenna', 651, true);


--
-- Name: seq_sitelogcollocationinfo; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogcollocationinfo', 151, true);


--
-- Name: seq_sitelogfrequencystandard; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogfrequencystandard', 601, true);


--
-- Name: seq_siteloghumiditysensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_siteloghumiditysensor', 551, true);


--
-- Name: seq_siteloglocalepisodicevent; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_siteloglocalepisodicevent', 101, true);


--
-- Name: seq_siteloglocaltie; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_siteloglocaltie', 551, true);


--
-- Name: seq_sitelogmultipathsource; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogmultipathsource', 1, false);


--
-- Name: seq_sitelogotherinstrument; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogotherinstrument', 1, false);


--
-- Name: seq_sitelogpressuresensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogpressuresensor', 551, true);


--
-- Name: seq_sitelogradiointerference; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogradiointerference', 1, false);


--
-- Name: seq_sitelogreceiver; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogreceiver', 651, true);


--
-- Name: seq_sitelogsignalobstruction; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogsignalobstruction', 1, false);


--
-- Name: seq_sitelogsite; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogsite', 651, true);


--
-- Name: seq_sitelogtemperaturesensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogtemperaturesensor', 551, true);


--
-- Name: seq_sitelogwatervaporsensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_sitelogwatervaporsensor', 551, true);


--
-- Name: seq_surrogate_keys; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('seq_surrogate_keys', 6151, true);


--
-- Data for Name: setup; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY setup (id, effective_from, effective_to, invalidated, name, site_id) FROM stdin;
\.


--
-- Data for Name: site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY site (id, date_installed, description, name, version, shape) FROM stdin;
\.


--
-- Data for Name: site_log_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY site_log_received (four_char_id, id) FROM stdin;
\.


--
-- Data for Name: site_updated; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY site_updated (four_character_id, id) FROM stdin;
\.


--
-- Data for Name: sitelog_collocationinformation; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_collocationinformation (id, effective_from, effective_to, instrument_type, notes, status, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_frequencystandard; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_frequencystandard (id, effective_from, effective_to, input_frequency, notes, type, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_gnssantenna; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_gnssantenna (id, alignment_from_true_north, antenna_cable_length, antenna_cable_type, antenna_radome_type, antenna_reference_point, date_installed, date_removed, marker_arp_east_ecc, marker_arp_north_ecc, marker_arp_up_ecc, notes, radome_serial_number, serial_number, antenna_type, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_gnssreceiver; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_gnssreceiver (id, date_installed, date_removed, elevation_cutoff_setting, firmware_version, notes, satellite_system, serial_number, temperature_stabilization, receiver_type, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_humiditysensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_humiditysensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accuracy_percent_rel_humidity, aspiration, data_sampling_interval, notes, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_localepisodicevent; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_localepisodicevent (id, event, site_id, effective_from, effective_to) FROM stdin;
\.


--
-- Data for Name: sitelog_mutlipathsource; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_mutlipathsource (id, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_otherinstrumentation; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_otherinstrumentation (id, effective_from, effective_to, instrumentation, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_pressuresensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_pressuresensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accuracy_hpa, data_sampling_interval, notes, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_radiointerference; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_radiointerference (id, observed_degradation, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_responsible_party; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_responsible_party (id, site_id, responsible_party, responsible_role_id) FROM stdin;
\.


--
-- Data for Name: sitelog_responsible_party_role; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_responsible_party_role (id, responsible_role_name, responsible_role_xmltag) FROM stdin;
601	Site Owner	SiteOwner
651	Site Contact	SiteContact
701	Site Metadata Custodian	SiteMetadataCustodian
751	Site Data Center	SiteDataCenter
801	Site Data Source	SiteDataSource
\.


--
-- Data for Name: sitelog_signalobstraction; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_signalobstraction (id, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_site (id, entrydate, form_date_prepared, form_prepared_by, form_report_type, mi_antenna_graphics, mi_hard_copy_on_file, mi_horizontal_mask, mi_text_graphics_from_antenna, mi_monument_description, mi_notes, mi_primary_data_center, mi_secondary_data_center, mi_site_diagram, mi_site_map, mi_site_pictires, mi_url_for_more_information, bedrock_condition, bedrock_type, cdp_number, date_installed, distance_activity, fault_zones_nearby, foundation_depth, four_character_id, fracture_spacing, geologic_characteristic, height_of_monument, iers_domes_number, marker_description, monument_description, monument_foundation, monument_inscription, notes, site_name, elevation_grs80, itrf_x, itrf_y, itrf_z, city, country, location_notes, state, tectonic_plate, site_contact_id, site_metadata_custodian_id, site_log_text, mi_doi, nine_character_id) FROM stdin;
\.


--
-- Data for Name: sitelog_surveyedlocaltie; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_surveyedlocaltie (id, date_measured, dx, dy, dz, local_site_tie_accuracy, notes, survey_method, tied_marker_cdp_number, tied_marker_domes_number, tied_marker_name, tied_marker_usage, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_temperaturesensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_temperaturesensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accurace_degree_celcius, aspiration, data_sampling_interval, notes, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_watervaporsensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY sitelog_watervaporsensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, distance_to_antenna, notes, site_id) FROM stdin;
\.


--
-- Data for Name: weekly_solution; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY weekly_solution (id, as_at, epoch, sinex_file_name) FROM stdin;
\.


--
-- Data for Name: weekly_solution_available; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY weekly_solution_available (weekly_solution_id, id) FROM stdin;
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY spatial_ref_sys  FROM stdin;
\.


SET search_path = geodesy, pg_catalog;

--
-- Name: pk_clock_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY clock_configuration
    ADD CONSTRAINT pk_clock_configuration_id PRIMARY KEY (id);


--
-- Name: pk_cors_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site
    ADD CONSTRAINT pk_cors_site_id PRIMARY KEY (id);


--
-- Name: pk_cors_site_in_network_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site_in_network
    ADD CONSTRAINT pk_cors_site_in_network_id PRIMARY KEY (id);


--
-- Name: pk_cors_site_network_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site_network
    ADD CONSTRAINT pk_cors_site_network_id PRIMARY KEY (id);


--
-- Name: pk_databasechangeloglock_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY databasechangeloglock
    ADD CONSTRAINT pk_databasechangeloglock_id PRIMARY KEY (id);


--
-- Name: pk_domain_event_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY domain_event
    ADD CONSTRAINT pk_domain_event_id PRIMARY KEY (id);


--
-- Name: pk_equipment_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_configuration
    ADD CONSTRAINT pk_equipment_configuration_id PRIMARY KEY (equipment_configuration_id);


--
-- Name: pk_equipment_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment
    ADD CONSTRAINT pk_equipment_id PRIMARY KEY (id);


--
-- Name: pk_equipment_in_use_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_in_use
    ADD CONSTRAINT pk_equipment_in_use_id PRIMARY KEY (id);


--
-- Name: pk_gnss_antenna_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_antenna_configuration
    ADD CONSTRAINT pk_gnss_antenna_configuration_id PRIMARY KEY (id);


--
-- Name: pk_gnss_receiver_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_receiver_configuration
    ADD CONSTRAINT pk_gnss_receiver_configuration_id PRIMARY KEY (id);


--
-- Name: pk_humidity_sensor_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor_configuration
    ADD CONSTRAINT pk_humidity_sensor_configuration_id PRIMARY KEY (id);


--
-- Name: pk_humidity_sensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor
    ADD CONSTRAINT pk_humidity_sensor_id PRIMARY KEY (id);


--
-- Name: pk_invalid_site_log_received_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY invalid_site_log_received
    ADD CONSTRAINT pk_invalid_site_log_received_id PRIMARY KEY (id);


--
-- Name: pk_monument_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY monument
    ADD CONSTRAINT pk_monument_id PRIMARY KEY (id);


--
-- Name: pk_node_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY node
    ADD CONSTRAINT pk_node_id PRIMARY KEY (id);


--
-- Name: pk_position_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT pk_position_id PRIMARY KEY (id);


--
-- Name: pk_responsible_party_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY responsible_party
    ADD CONSTRAINT pk_responsible_party_id PRIMARY KEY (id);


--
-- Name: pk_setup_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY setup
    ADD CONSTRAINT pk_setup_id PRIMARY KEY (id);


--
-- Name: pk_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site
    ADD CONSTRAINT pk_site_id PRIMARY KEY (id);


--
-- Name: pk_site_log_received_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_log_received
    ADD CONSTRAINT pk_site_log_received_id PRIMARY KEY (id);


--
-- Name: pk_site_updated_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_updated
    ADD CONSTRAINT pk_site_updated_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_collocationinformation_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_collocationinformation
    ADD CONSTRAINT pk_sitelog_collocationinformation_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_frequencystandard_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_frequencystandard
    ADD CONSTRAINT pk_sitelog_frequencystandard_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_gnssantenna_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssantenna
    ADD CONSTRAINT pk_sitelog_gnssantenna_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_gnssreceiver_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssreceiver
    ADD CONSTRAINT pk_sitelog_gnssreceiver_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_humiditysensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_humiditysensor
    ADD CONSTRAINT pk_sitelog_humiditysensor_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_localepisodicevent_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_localepisodicevent
    ADD CONSTRAINT pk_sitelog_localepisodicevent_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_mutlipathsource_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_mutlipathsource
    ADD CONSTRAINT pk_sitelog_mutlipathsource_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_otherinstrumentation_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_otherinstrumentation
    ADD CONSTRAINT pk_sitelog_otherinstrumentation_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_pressuresensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_pressuresensor
    ADD CONSTRAINT pk_sitelog_pressuresensor_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_radiointerference_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_radiointerference
    ADD CONSTRAINT pk_sitelog_radiointerference_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_responsible_party_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_responsible_party
    ADD CONSTRAINT pk_sitelog_responsible_party_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_responsible_party_role_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_responsible_party_role
    ADD CONSTRAINT pk_sitelog_responsible_party_role_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_signalobstraction_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_signalobstraction
    ADD CONSTRAINT pk_sitelog_signalobstraction_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_site
    ADD CONSTRAINT pk_sitelog_site_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_surveyedlocaltie_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_surveyedlocaltie
    ADD CONSTRAINT pk_sitelog_surveyedlocaltie_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_temperaturesensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_temperaturesensor
    ADD CONSTRAINT pk_sitelog_temperaturesensor_id PRIMARY KEY (id);


--
-- Name: pk_sitelog_watervaporsensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_watervaporsensor
    ADD CONSTRAINT pk_sitelog_watervaporsensor_id PRIMARY KEY (id);


--
-- Name: pk_weekly_solution_available_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY weekly_solution_available
    ADD CONSTRAINT pk_weekly_solution_available_id PRIMARY KEY (id);


--
-- Name: pk_weekly_solution_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY weekly_solution
    ADD CONSTRAINT pk_weekly_solution_id PRIMARY KEY (id);


--
-- Name: uk_cors_site_four_characterid; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site
    ADD CONSTRAINT uk_cors_site_four_characterid UNIQUE (four_character_id);


--
-- Name: fk3v3u8pev0722n8fjgvx596fsg; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor
    ADD CONSTRAINT fk3v3u8pev0722n8fjgvx596fsg FOREIGN KEY (id) REFERENCES equipment(id);


--
-- Name: fk4k5lbyl5p83qh9dikhri2m5v3; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_updated
    ADD CONSTRAINT fk4k5lbyl5p83qh9dikhri2m5v3 FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fk57s5rld01igqfu01k7fflrhpe; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY clock_configuration
    ADD CONSTRAINT fk57s5rld01igqfu01k7fflrhpe FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk5i8shb9ari8ytjddwg838qpjb; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_antenna_configuration
    ADD CONSTRAINT fk5i8shb9ari8ytjddwg838qpjb FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk5r69a2t8ikyj4vk6r6ian2ie9; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_receiver_configuration
    ADD CONSTRAINT fk5r69a2t8ikyj4vk6r6ian2ie9 FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk66u1s5twhejx5r71kce1xbndo; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_log_received
    ADD CONSTRAINT fk66u1s5twhejx5r71kce1xbndo FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fk6l38ggororukg4q0921somuq2; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_in_use
    ADD CONSTRAINT fk6l38ggororukg4q0921somuq2 FOREIGN KEY (setup_id) REFERENCES setup(id);


--
-- Name: fk7dbw7guod3rr8f902lsdc4scc; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_responsible_party
    ADD CONSTRAINT fk7dbw7guod3rr8f902lsdc4scc FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_clock_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY clock_configuration
    ADD CONSTRAINT fk_clock_configuration_id FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk_cors_site_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site
    ADD CONSTRAINT fk_cors_site_id FOREIGN KEY (id) REFERENCES site(id);


--
-- Name: fk_cors_site_in_network_networkid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site_in_network
    ADD CONSTRAINT fk_cors_site_in_network_networkid FOREIGN KEY (cors_site_network_id) REFERENCES cors_site_network(id);


--
-- Name: fk_cors_site_in_network_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site_in_network
    ADD CONSTRAINT fk_cors_site_in_network_siteid FOREIGN KEY (cors_site_id) REFERENCES cors_site(id);


--
-- Name: fk_cors_site_monument; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site
    ADD CONSTRAINT fk_cors_site_monument FOREIGN KEY (monument_id) REFERENCES monument(id);


--
-- Name: fk_equipment_configuration_equipment_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_configuration
    ADD CONSTRAINT fk_equipment_configuration_equipment_id FOREIGN KEY (equipment_id) REFERENCES equipment(id);


--
-- Name: fk_equipment_in_use_equipment_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_equipment_configuration_id FOREIGN KEY (equipment_configuration_id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk_equipment_in_use_equipmentid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_equipmentid FOREIGN KEY (equipment_id) REFERENCES equipment(id);


--
-- Name: fk_equipment_in_use_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_id FOREIGN KEY (setup_id) REFERENCES setup(id);


--
-- Name: fk_gnss_antenna_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_antenna_configuration
    ADD CONSTRAINT fk_gnss_antenna_configuration_id FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk_gnss_receiver_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY gnss_receiver_configuration
    ADD CONSTRAINT fk_gnss_receiver_configuration_id FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk_humidity_sensor_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor_configuration
    ADD CONSTRAINT fk_humidity_sensor_configuration_id FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fk_humidity_sensor_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor
    ADD CONSTRAINT fk_humidity_sensor_id FOREIGN KEY (id) REFERENCES equipment(id);


--
-- Name: fk_invalid_site_log_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY invalid_site_log_received
    ADD CONSTRAINT fk_invalid_site_log_received_id FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fk_setup_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY setup
    ADD CONSTRAINT fk_setup_siteid FOREIGN KEY (site_id) REFERENCES site(id);


--
-- Name: fk_site_log_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_log_received
    ADD CONSTRAINT fk_site_log_received_id FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fk_site_updated_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY site_updated
    ADD CONSTRAINT fk_site_updated_id FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fk_sitelog_collocationinformation_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_collocationinformation
    ADD CONSTRAINT fk_sitelog_collocationinformation_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_frequencystandard_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_frequencystandard
    ADD CONSTRAINT fk_sitelog_frequencystandard_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_gnssantenna_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssantenna
    ADD CONSTRAINT fk_sitelog_gnssantenna_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_gnssreceiver_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssreceiver
    ADD CONSTRAINT fk_sitelog_gnssreceiver_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_humiditysensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_humiditysensor
    ADD CONSTRAINT fk_sitelog_humiditysensor_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_localepisodicevent_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_localepisodicevent
    ADD CONSTRAINT fk_sitelog_localepisodicevent_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_mutlipathsource_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_mutlipathsource
    ADD CONSTRAINT fk_sitelog_mutlipathsource_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_otherinstrumentation_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_otherinstrumentation
    ADD CONSTRAINT fk_sitelog_otherinstrumentation_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_pressuresensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_pressuresensor
    ADD CONSTRAINT fk_sitelog_pressuresensor_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_radiointerference_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_radiointerference
    ADD CONSTRAINT fk_sitelog_radiointerference_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_responsible_party_responsible_roleid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_responsible_party
    ADD CONSTRAINT fk_sitelog_responsible_party_responsible_roleid FOREIGN KEY (responsible_role_id) REFERENCES sitelog_responsible_party_role(id);


--
-- Name: fk_sitelog_responsible_party_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_responsible_party
    ADD CONSTRAINT fk_sitelog_responsible_party_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_signalobstraction_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_signalobstraction
    ADD CONSTRAINT fk_sitelog_signalobstraction_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_collocationinformation; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_collocationinformation
    ADD CONSTRAINT fk_sitelog_site_sitelog_collocationinformation FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_gnss_antenna; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssantenna
    ADD CONSTRAINT fk_sitelog_site_sitelog_gnss_antenna FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_gnss_receiver; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_gnssreceiver
    ADD CONSTRAINT fk_sitelog_site_sitelog_gnss_receiver FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_humiditysensor; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_humiditysensor
    ADD CONSTRAINT fk_sitelog_site_sitelog_humiditysensor FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_localepisodicevent; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_localepisodicevent
    ADD CONSTRAINT fk_sitelog_site_sitelog_localepisodicevent FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_mutlipathsource; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_mutlipathsource
    ADD CONSTRAINT fk_sitelog_site_sitelog_mutlipathsource FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_otherinstrumentation; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_otherinstrumentation
    ADD CONSTRAINT fk_sitelog_site_sitelog_otherinstrumentation FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_pressuresensor; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_pressuresensor
    ADD CONSTRAINT fk_sitelog_site_sitelog_pressuresensor FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_radiointerference; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_radiointerference
    ADD CONSTRAINT fk_sitelog_site_sitelog_radiointerference FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_signalobstraction; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_signalobstraction
    ADD CONSTRAINT fk_sitelog_site_sitelog_signalobstraction FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_surveyedlocaltie; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_surveyedlocaltie
    ADD CONSTRAINT fk_sitelog_site_sitelog_surveyedlocaltie FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_temperaturesensor; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_temperaturesensor
    ADD CONSTRAINT fk_sitelog_site_sitelog_temperaturesensor FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelog_watervaporsensor; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_watervaporsensor
    ADD CONSTRAINT fk_sitelog_site_sitelog_watervaporsensor FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_site_sitelogfrequencystandard; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_frequencystandard
    ADD CONSTRAINT fk_sitelog_site_sitelogfrequencystandard FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_surveyedlocaltie_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_surveyedlocaltie
    ADD CONSTRAINT fk_sitelog_surveyedlocaltie_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_temperaturesensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_temperaturesensor
    ADD CONSTRAINT fk_sitelog_temperaturesensor_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_sitelog_watervaporsensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY sitelog_watervaporsensor
    ADD CONSTRAINT fk_sitelog_watervaporsensor_siteid FOREIGN KEY (site_id) REFERENCES sitelog_site(id);


--
-- Name: fk_weekly_solution_avaliable_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY weekly_solution_available
    ADD CONSTRAINT fk_weekly_solution_avaliable_id FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fkg3epjtncr7vsfl1b4qu8u78yw; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY humidity_sensor_configuration
    ADD CONSTRAINT fkg3epjtncr7vsfl1b4qu8u78yw FOREIGN KEY (id) REFERENCES equipment_configuration(equipment_configuration_id);


--
-- Name: fkhsotbco85rmtycrk2fydldkv5; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY cors_site
    ADD CONSTRAINT fkhsotbco85rmtycrk2fydldkv5 FOREIGN KEY (id) REFERENCES site(id);


--
-- Name: fkt0wcgi5uifpvl1m5vbxtbql2d; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY invalid_site_log_received
    ADD CONSTRAINT fkt0wcgi5uifpvl1m5vbxtbql2d FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: fktiaeyjhtj7j08vvfdab8ft66y; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY weekly_solution_available
    ADD CONSTRAINT fktiaeyjhtj7j08vvfdab8ft66y FOREIGN KEY (id) REFERENCES domain_event(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

