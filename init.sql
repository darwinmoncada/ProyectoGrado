--
-- PostgreSQL database dump
--

\restrict gbR1PCgIZAeplt8Ovj0xNfi8TT5O5VpJSiH6BCZfTpcbMHh2YOc6bv32q1wknVL

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.areas (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    location character varying(150),
    floor character varying(20),
    building character varying(50),
    responsible_id bigint,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.areas_id_seq OWNED BY public.areas.id;


--
-- Name: asset_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_types (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    category character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: asset_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_types_id_seq OWNED BY public.asset_types.id;


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    brand character varying(50),
    model character varying(100),
    serial_number character varying(100),
    codigo character varying(50),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    purchase_date date,
    purchase_price numeric(14,2),
    warranty_expiry date,
    specifications text,
    notes text,
    asset_type_id bigint,
    area_id bigint,
    assigned_user_id bigint,
    created_by bigint,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    user_id bigint,
    username character varying(50),
    action character varying(50) NOT NULL,
    entity_type character varying(50),
    entity_id bigint,
    entity_description character varying(255),
    old_values text,
    new_values text,
    ip_address character varying(45),
    user_agent character varying(500),
    success boolean DEFAULT true,
    error_message character varying(500),
    "timestamp" timestamp without time zone DEFAULT now(),
    full_name character varying(100),
    role_name character varying(50)
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: inventory_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_movements (
    id bigint NOT NULL,
    asset_id bigint NOT NULL,
    movement_type character varying(30) NOT NULL,
    movement_date timestamp without time zone DEFAULT now() NOT NULL,
    from_area_id bigint,
    to_area_id bigint,
    from_user_id bigint,
    to_user_id bigint,
    reason character varying(255),
    notes text,
    reference_number character varying(50),
    created_by bigint,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: inventory_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_movements_id_seq OWNED BY public.inventory_movements.id;


--
-- Name: network_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.network_devices (
    id bigint NOT NULL,
    asset_id bigint,
    ip_address character varying(45),
    mac_address character varying(17),
    hostname character varying(100),
    subnet_mask character varying(15),
    gateway character varying(45),
    dns_primary character varying(45),
    dns_secondary character varying(45),
    vlan_id integer,
    port_number integer,
    is_dhcp boolean DEFAULT false,
    network_status character varying(20) DEFAULT 'UNKNOWN'::character varying,
    last_seen timestamp without time zone,
    location_detail character varying(255),
    firmware_version character varying(50),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: network_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.network_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: network_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.network_devices_id_seq OWNED BY public.network_devices.id;


--
-- Name: network_topology; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.network_topology (
    id bigint NOT NULL,
    source_device_id bigint NOT NULL,
    target_device_id bigint NOT NULL,
    connection_type character varying(30) NOT NULL,
    port_source character varying(20),
    port_target character varying(20),
    bandwidth character varying(20),
    notes text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: network_topology_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.network_topology_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: network_topology_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.network_topology_id_seq OWNED BY public.network_topology.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    full_name character varying(100) NOT NULL,
    phone character varying(20),
    document_number character varying(20),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas ALTER COLUMN id SET DEFAULT nextval('public.areas_id_seq'::regclass);


--
-- Name: asset_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_types ALTER COLUMN id SET DEFAULT nextval('public.asset_types_id_seq'::regclass);


--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: inventory_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements ALTER COLUMN id SET DEFAULT nextval('public.inventory_movements_id_seq'::regclass);


--
-- Name: network_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_devices ALTER COLUMN id SET DEFAULT nextval('public.network_devices_id_seq'::regclass);


--
-- Name: network_topology id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_topology ALTER COLUMN id SET DEFAULT nextval('public.network_topology_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.areas (id, name, description, location, floor, building, responsible_id, is_active, created_at, updated_at) FROM stdin;
1	Sala de Sistemas 1	Laboratorio de informática piso 1	Piso 1	\N	Bloque A	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
2	Sala de Sistemas 2	Laboratorio de informática piso 2	Piso 2	\N	Bloque A	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
4	Data Center	Centro de datos principal	Sótano	\N	Bloque B	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
5	Dirección Académica	Oficinas de dirección académica	Piso 4	\N	Bloque C	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
6	Rectoría	Oficina de rectoría	Piso 5	\N	Bloque C	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
7	Biblioteca	Biblioteca y sala de consulta	Piso 1	\N	Bloque D	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
8	Sala de Profesores	Área de profesores y preparación	Piso 2	\N	Bloque D	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
9	Bienestar Universitario	Área de bienestar estudiantil	Piso 1	\N	Bloque E	\N	t	2026-04-17 15:56:47.371	2026-04-17 15:56:47.371
10	Almacén TI	Bodega y almacén de equipos	Sótano	\N	Bloque A	\N	t	2026-04-17 15:56:47.371	2026-06-01 15:04:52.189
12	Bodega 2A1	Bodega 2A1	2	\N	A	\N	t	2026-06-03 13:09:39.878	2026-06-03 13:11:50.091
13	2C1	CUARTO TECNICO	2	\N	C	\N	t	2026-06-03 13:12:56.815	2026-06-03 13:12:56.815
14	Oficina Redes	Área de Redes y Comunicaciones 	2	\N	B	\N	t	2026-06-03 16:15:16.852	2026-06-03 16:18:26.526
3	Coordinación de Telecomunicaciones	Área administrativa Telecomunicaciones	Piso 3	\N	Bloque B	\N	t	2026-04-17 15:56:47.371	2026-06-10 16:25:32.429
15	Coordinación Sistemas	Área administrativa Telecomunicaciones	2	\N	c	\N	t	2026-06-10 16:24:37.625	2026-06-10 16:25:42.539
11	Sin asignar	Este equipo no cuenta con información de asignación	1-7	\N	Todo	\N	t	2026-06-02 22:08:52.178	2026-06-19 11:50:11.313
\.


--
-- Data for Name: asset_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asset_types (id, name, description, category, created_at) FROM stdin;
1	Monitor	Monitor de escritorio o pantalla	TECNOLOGIA	2026-05-30 08:44:16.936
2	Switch	Equipo de conmutación de red	TECNOLOGIA	2026-05-30 08:44:16.936
3	Cámara IP Domo	Cámara de seguridad tipo domo IP	SEGURIDAD	2026-05-30 08:44:16.936
4	Cámara IP Bala	Cámara de seguridad tipo bala IP	SEGURIDAD	2026-05-30 08:44:16.936
5	Cámara PTZ	Cámara IP pan-tilt-zoom	SEGURIDAD	2026-05-30 08:44:16.936
6	Grabador NVR	Grabador de video en red	SEGURIDAD	2026-05-30 08:44:16.936
7	Patch Panel	Panel de conexiones de red	TECNOLOGIA	2026-05-30 08:44:16.936
8	Teléfono IP	Teléfono sobre protocolo IP	TECNOLOGIA	2026-05-30 08:44:16.936
9	Probador de Red	Equipo para prueba y certificación de redes	TECNOLOGIA	2026-05-30 08:44:16.936
10	UPS	Sistema de alimentación ininterrumpida	TECNOLOGIA	2026-05-30 08:44:16.936
11	Router	Equipo de enrutamiento de red	TECNOLOGIA	2026-05-30 08:44:16.936
12	Rack	Bastidor o rack para equipos	INFRAESTRUCTURA	2026-05-30 08:44:16.936
13	Mobiliario	Muebles y elementos de oficina	MOBILIARIO	2026-05-30 08:44:16.936
14	Computador Escritorio	Equipo de cómputo de escritorio	TECNOLOGIA	2026-05-30 08:44:16.936
15	Portátil / Impresora	Computador portátil o impresora	TECNOLOGIA	2026-05-30 08:44:16.936
16	Servidor / Chasis	Servidor o chasis blade	TECNOLOGIA	2026-05-30 08:44:16.936
17	Estabilizador	Regulador o estabilizador de voltaje	TECNOLOGIA	2026-05-30 08:44:16.936
18	Teclado / Periférico	Teclado, mouse y periféricos	TECNOLOGIA	2026-05-30 08:44:16.936
19	Conmutador / Estante	Conmutador administrable o estante metálico	INFRAESTRUCTURA	2026-05-30 08:44:16.936
20	Bandeja de Fibra	Bandeja de conectorizacion de fibra óptica	INFRAESTRUCTURA	2026-05-30 08:44:16.936
21	Extintor / Botiquín	Elemento de seguridad y primeros auxilios	SEGURIDAD	2026-05-30 08:44:16.936
22	Herramienta	Herramientas y equipos de trabajo	HERRAMIENTAS	2026-05-30 08:44:16.936
23	Escalera	Escalera de aluminio	HERRAMIENTAS	2026-05-30 08:44:16.936
24	CPU	Unidad central de procesamiento	TECNOLOGIA	2026-05-30 08:44:16.936
25	Regleta	Regleta de alimentación para rack	INFRAESTRUCTURA	2026-05-30 08:44:16.936
\.


--
-- Data for Name: assets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assets (id, name, brand, model, serial_number, codigo, status, purchase_date, purchase_price, warranty_expiry, specifications, notes, asset_type_id, area_id, assigned_user_id, created_by, created_at, updated_at) FROM stdin;
57	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00078	2-07-A59321	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:06.149
1	Monitor 24"				2-07-A48284	LOST	\N	\N	\N	Monitor de 24 pulgadas		1	11	3	\N	2026-05-30 08:44:16.936	2026-06-30 21:05:01.76
3	Patch Panel 24P Cat6A Blindado			2	2-07-A58047	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	13	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:50:29.636
5	Switch 24P TP-Link TL-SG1024	TP-LINK	TL-SG1024	2152120000447	2-07-A59246	ACTIVE	\N	\N	\N	Switch 24 puertos 10/100/1000 TP-Link TL-SG1024. Contrato compraventa N° 001704-16		2	13	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:50:35.322
9	Switch 24P TP-Link TL-SG1024	TP-LINK	TL-SG1024	2152120000418	2-07-A59251	ACTIVE	\N	\N	\N	Switch 24 puertos 10/100/1000 TP-Link TL-SG1024. Contrato compraventa N° 001704-16	prueba	2	13	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:50:38.32
6	Switch 24P TP-Link TL-SG1024	TP-LINK	TL-SG1024	2152120000364	2-07-A59247	ACTIVE	\N	\N	\N	Switch 24 puertos 10/100/1000 TP-Link TL-SG1024. Contrato compraventa N° 001704-16		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:51:01.854
11	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00096	2-07-A59253	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:53:56.905
12	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00056	2-07-A59254	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16	Ok	3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:02.434
14	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00051	2-07-A59256	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:08.164
18	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00195	2-07-A59260	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:13.4
15	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00072	2-07-A59257	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:18.258
13	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00040	2-07-A59255	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:22.242
17	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00008	2-07-A59259	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:26.855
19	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00001	2-07-A59261	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:30.704
20	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00162	2-07-A59264	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:35.403
21	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00048	2-07-A59269	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:39.98
22	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00011	2-07-A59270	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:43.5
23	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00042	2-07-A59272	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:47.402
24	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00052	2-07-A59274	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:51.664
25	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00033	2-07-A59275	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:56.505
26	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00045	2-07-A59276	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:54:59.881
28	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00017	2-07-A59278	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:03.582
29	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00025	2-07-A59280	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:07.287
30	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00088	2-07-A59281	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:11.616
31	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00038	2-07-A59282	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:15.681
32	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00064	2-07-A59283	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:20.5
33	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00065	2-07-A59284	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:24.595
34	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00067	2-07-A59285	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:28.834
35	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00083	2-07-A59286	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:32.403
189	Archivador Superior			495	2-18-A13117	ACTIVE	\N	\N	\N	Archivador superior L 0.75 mts		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:37.348
49	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00046	2-07-A59307	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:58.46
50	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00054	2-07-A59308	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:07.796
51	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00094	2-07-A59309	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:16.645
52	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00032	2-07-A59312	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:26.781
54	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00127	2-07-A59315	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:35.509
55	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00068	2-07-A59317	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:46.761
56	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00179	2-07-A59320	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:58:56.651
58	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00055	2-07-A59322	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:15.884
59	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00030	2-07-A59323	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:25.587
60	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00044	2-07-A59324	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:34.684
61	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00094	2-07-A59325	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:43.398
62	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1C03532PAF00093	2-07-A59326	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:51.554
63	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00086	2-07-A59331	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:59:59.847
64	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00103	2-07-A59333	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:00:10.196
36	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00030	2-07-A59287	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:51:27.322
37	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00050	2-07-A59288	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:48.598
38	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00086	2-07-A59289	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:55:59.951
39	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00130	2-07-A59290	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:56:13.046
40	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00046	2-07-A59291	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:56:24.013
42	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00013	2-07-A59293	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:56:45.521
43	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00084	2-07-A59295	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:00.256
44	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	D02564PAF00007	2-07-A59297	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:10.577
45	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00081	2-07-A59298	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:19.177
46	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00060	2-07-A59299	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:29.947
47	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00161	2-07-A59304	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:38.522
48	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00091	2-07-A59306	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:57:48.436
65	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00095	2-07-A59334	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:00:21.751
66	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU0134	2-07-A59335	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:00:30.393
67	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00123	2-07-A59336	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:00:39.219
68	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00028	2-07-A59337	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:00:47.79
69	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00168	2-07-A59338	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:01:29.169
160	Patch Panel 24P Cat6A Blindado			2-07-A58046	2-07-A58046	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:28:06.526
71	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00179	2-07-A59341	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:13:44.728
72	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00102	2-07-A59342	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:14:51.9
242	Switch 48P			2-24-A48959	2-24-A48959	ACTIVE	\N	\N	\N	Switch X 48 puertos		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:16:16.564
73	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00139	2-07-A59343	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:16:29.467
101	Cámara PTZ 2MPX Dahua	DAHUA	SD59220TN-HN	1F01066YAZ00012	2-07-A59377	ACTIVE	\N	\N	\N	Cámara Ciber Domo PTZ 2MPX Dahua SD59220TN-HN. Contrato compraventa N° 001704-16		5	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:16:40.305
100	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00030	2-07-A59375	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:16:51.29
99	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00168	2-07-A59374	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:01.194
98	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00360	2-07-A59373	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:12.347
97	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00305	2-07-A59372	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:23.682
96	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00235	2-07-A59371	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:35.342
95	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00112	2-07-A59368	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:47.319
93	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00086	2-07-A59366	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:18:09.661
92	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00293	2-07-A59365	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:18:19.415
91	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00083	2-07-A59364	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:18:29.591
90	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00167	2-07-A59363	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:18:39.328
89	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00079	2-07-A59362	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:18:49.319
88	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00277	2-07-A59361	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:00.019
87	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00082	2-07-A59360	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:10.904
86	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00071	2-07-A59359	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:20.927
85	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00072	2-07-A59357	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:30.474
84	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00295	2-07-A59356	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:40.784
74	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00101	2-07-A59344	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:19:51.738
75	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00051	2-07-A59345	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:20:10.917
77	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00068	2-07-A59348	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:20:33.466
78	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00058	2-07-A59349	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:20:45.962
79	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00115	2-07-A59350	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:21:00.697
80	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00033	2-07-A59351	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:21:14.585
81	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00078	2-07-A59353	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:21:24.775
82	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00101	2-07-A59354	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:21:37.328
83	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1F01413PAU00189	2-07-A59355	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:21:47.293
165	Router Cloud CCR1016-12G	MIKROTIK	CCR1016-12G	2-07-A58751	2-07-A58751	ACTIVE	\N	\N	\N	Router Cloud Router Mikrotik CCR1016-12G, suministro de equipo para redes		11	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:29:23.664
188	Superficie de Trabajo Redes			2-18-A10404	2-18-A10404	ACTIVE	\N	\N	\N	Superficie de trabajo redes		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:36:12.21
108	Patch Panel 24P Cat6A			2-07-A59402	2-07-A59402	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat 6A. Contrato compraventa N° 001704-16		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:02:36.048
109	Patch Panel 24P Cat6A			2-07-A59404	2-07-A59404	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat 6A. Contrato compraventa N° 001704-16		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:02:52.078
110	Probador de Red WiFi Fluke	FLUKE	OOCO17-522E4E	2-07-A59405	2-07-A59405	ACTIVE	\N	\N	\N	Probador de red con WiFi Fluke OOCO17-522E4E. Contrato compraventa N° 001704-16		9	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:03:11.74
111	Switch HP 24P	HP		2-07-A59530	2-07-A59530	ACTIVE	\N	\N	\N	Switch Hewlett-Packard 24 puertos. Contrato de Obra N° 000215-16		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:03:29.954
112	Switch HP 24P	HP		2-07-A59531	2-07-A59531	ACTIVE	\N	\N	\N	Switch Hewlett-Packard 24 puertos. Contrato de Obra N° 000215-16		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:03:48.739
114	Altavoz Jabra Speak 510	JABRA	Speak 510	2-07-A59874	2-07-A59874	ACTIVE	\N	\N	\N	Altavoz Speak 510 Jabra. Factura de venta N° 108 de Soluciones TICS		12	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:04:22.089
115	Botiquín de Pared			2-11-A45369	2-11-A45369	ACTIVE	\N	\N	\N	Botiquín de pared medidas 60 cm de alto		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:04:41.527
116	Archivador Lateral 2x60			2-18-A1480	2-18-A1480	ACTIVE	\N	\N	\N	Archivador lateral 2x60		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:04:55.397
117	Archivador Inferior			2-18-A1543	2-18-A1543	ACTIVE	\N	\N	\N	Archivador inferior		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:05:09.933
118	Gabinete Superior			2-18-A1546	2-18-A1546	ACTIVE	\N	\N	\N	Gabinete superior		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:05:26.841
119	Silla Giratoria en Paño			2-18-A1548	2-18-A1548	ACTIVE	\N	\N	\N	Silla giratoria en paño		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:05:43.729
120	Archivador Inferior			2-18-A18259	2-18-A18259	ACTIVE	\N	\N	\N	Archivador inferior		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:06:03.086
121	Persiana			2-18-A22719	2-18-A22719	ACTIVE	\N	\N	\N	Persiana		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:06:20.845
123	Perforadora 3 Huecos			2-18-A46940	2-18-A46940	ACTIVE	\N	\N	\N	Perforadora de tres huecos		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:06:53.921
125	Silla Interlocutora sin Brazos			2-18-A57018	2-18-A57018	ACTIVE	\N	\N	\N	Silla interlocutora sin brazos, espaldar marco en polipropileno reforzado con interior en malla nylon		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:07:28.825
126	Silla Interlocutora sin Brazos			2-18-A57019	2-18-A57019	ACTIVE	\N	\N	\N	Silla interlocutora sin brazos, espaldar marco en polipropileno reforzado con interior en malla nylon		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:07:42.842
127	Módulo Puesto de Cómputo 80x60			2-18-A57044	2-18-A57044	ACTIVE	\N	\N	\N	Módulo para puesto de cómputo 80cm x 60cm		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:07:56.233
128	Módulo Puesto de Cómputo 80x60			2-18-A57045	2-18-A57045	ACTIVE	\N	\N	\N	Módulo para puesto de cómputo 80cm x 60cm		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:08:09.601
129	Módulo Puesto de Cómputo 210x60			2-18-A57508	2-18-A57508	ACTIVE	\N	\N	\N	Módulo para puesto de cómputo 210cm x 60cm con superficie en tablero laminado de 25mm de espesor		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:08:22.648
130	Cortina Enrollable Screen 2.03x2.40			2-18-A58285	2-18-A58285	ACTIVE	\N	\N	\N	Cortina enrollable en screen con visibilidad exterior, persiana enrollable 2.03m x 2.40m		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:08:38.275
131	Superficie de Trabajo			2-18-C16320	2-18-C16320	ACTIVE	\N	\N	\N	Superficie de trabajo		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:08:50.576
132	Archivador Inferior			2-18-C33123	2-18-C33123	ACTIVE	\N	\N	\N	Archivador inferior		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:09:02.858
135	UPS Online 2KVA			2-24-A18267	2-24-A18267	ACTIVE	\N	\N	\N	UPS Online 2KVA		10	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:10:13.257
136	Chasis Blade IBM	IBM		2-24-A40718	2-24-A40718	ACTIVE	\N	\N	\N	Chasis Enclosure de Blade IBM		16	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:10:30.338
137	Teclado HP con Mouse	HP		2-24-A47478	2-24-A47478	ACTIVE	\N	\N	\N	Teclado HP con mouse óptico		18	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:10:43.492
138	Monitor HP LV1911	HP	LV1911	6CM2240L1F	2-24-A47736	ACTIVE	\N	\N	\N	Monitor HP LV1911 19 pulgadas		1	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:10:55.679
140	Portátil Lenovo	LENOVO		PF00XKVK	2-24-A51205	ACTIVE	\N	\N	\N	Portátil Lenovo, procesador Core i5 2.5GHz, RAM 4GB DDR3, disco duro 750GB, monitor LED 14 pulgadas		15	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:11:19.821
141	Cámara IP Bala HD 2MP Dahua	DAHUA	IPC-HFW-1220SN-S3	4-07-C67205	4-07-C67205	ACTIVE	\N	\N	\N	Reposición por hurto (código anterior 4-07-C59330). Cámara HD IPC-HFW-1220SN-S3, bala IP metálica 2MP, lente 3.6mm, H.264+, 25/30fps@1080P, IR 30m, IP67, 12VDC		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:11:33.718
142	Cámara IP Bala HD 2MP Dahua	DAHUA	IPC-HFW-1220SN-S3	4-07-C67206	4-07-C67206	ACTIVE	\N	\N	\N	Reposición por hurto (código anterior 4-07-C59332). Cámara HD IPC-HFW-1220SN-S3, bala IP metálica 2MP, lente 3.6mm, H.264+, 25/30fps@1080P, IR 30m, IP67, 12VDC		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:11:50.399
144	Estante Metálico 6 Bandejas			04-18-C74149	04-18-C74149	ACTIVE	\N	\N	\N	Estante metálico, seis (6) bandejas, lámina Cold Rolled calibre 22, parales tipo uña calibre 16, medidas 2.00m alto x 0.93m ancho x 0.40m fondo, pintura electrostática. Contrato N° 002207-21		19	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:12:21.006
243	Switch 48P			2-24-A48960	2-24-A48960	ACTIVE	\N	\N	\N	Switch X 48 puertos		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:12:33.445
133	Archivador Inferior			2-18-C3404	2-18-C3404	ACTIVE	\N	\N	\N	Archivador inferior		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:12:48.111
105	Patch Panel 24P Cat6A			2-07-A59399	2-07-A59399	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat 6A. Contrato compraventa N° 001704-16		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:13:01.428
104	NVR 4K Dahua NVR4232	DAHUA	NVR4232-4K	1J03047PAYF9R61	2-07-A59398	ACTIVE	\N	\N	\N	Grabador de video en red NVR NVR4232-4K Dahua. Contrato compraventa N° 001704-16		6	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:13:21.798
103	NVR 4K Dahua NVR4232	DAHUA	NVR4232-4K	1L0394BPAYZ36ZC	2-07-A59397	ACTIVE	\N	\N	\N	Grabador de video en red NVR NVR4232-4K Dahua. Contrato compraventa N° 001704-16		6	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:13:55.361
102	NVR 4K Dahua NVR4232	DAHUA	NVR4232-4K	1J03047PAYL0J91	2-07-A59395	ACTIVE	\N	\N	\N	Grabador de video en red NVR NVR4232-4K Dahua. Contrato compraventa N° 001704-16		6	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:15:57.684
158	Patch Panel 24P Cat6A Blindado			2-07-A58043	2-07-A58043	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:27:35.476
159	Patch Panel 24P Cat6A Blindado			2-07-A58045	2-07-A58045	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:27:51.752
161	Patch Panel 24P Cat6A Blindado			2-07-A58226	2-07-A58226	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:28:21.294
106	Patch Panel 24P Cat6A			2-07-A59400	2-07-A59400	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat 6A. Contrato compraventa N° 001704-16		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:01:51.418
146	Estante Metálico 6 Bandejas			04-18-C74170	04-18-C74170	ACTIVE	\N	\N	\N	Estante metálico, seis (6) bandejas, lámina Cold Rolled calibre 22, parales tipo uña calibre 16, medidas 2.00m alto x 0.93m ancho x 0.40m fondo, pintura electrostática. Contrato N° 002207-21		19	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:22:35.935
162	Patch Panel 24P Cat6A Blindado			2-07-A58227	2-07-A58227	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:28:36.97
147	Switch de Core			2-07-A21343	2-07-A21343	ACTIVE	\N	\N	\N	Equipo activo de red Switch de Core		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:23:25.387
150	Bandeja Fibra LC - CRIA			2-07-A21368	2-07-A21368	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC - ubicado en CRIA		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:25:42.288
155	Patch Panel 24P Cat6A Blindado			2-07-A58040	2-07-A58040	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:25:57.824
156	Patch Panel 24P Cat6A Blindado			2-07-A58041	2-07-A58041	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:26:17.066
163	Patch Panel 24P Cat6A Blindado			2-07-A58228	2-07-A58228	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:28:51.545
164	Patch Panel 24P Cat6A Blindado			2-07-A58229	2-07-A58229	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:29:09.621
166	Switch Linksys 26P Gigabit	LINKSYS		2-07-A59903	2-07-A59903	ACTIVE	\N	\N	\N	Switch Linksys 26 port Smart Gigabit. Contrato de Obra N° 003259-16		2	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:29:38.3
149	Bandeja Fibra LC - CRIA	\N	\N	\N	2-07-A21367	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC - ubicado en CRIA	\N	20	13	\N	\N	2026-05-30 08:44:16.936	2026-06-10 16:41:34.075
154	Bandeja Fibra LC	\N	\N	\N	2-07-A21372	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC	\N	20	13	\N	\N	2026-05-30 08:44:16.936	2026-06-10 16:42:52.109
152	Bandeja Fibra LC Multipropósito	\N	\N	\N	2-07-A21370	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC - multipropósito	\N	20	13	\N	\N	2026-05-30 08:44:16.936	2026-06-10 16:44:27.429
151	Bandeja Fibra LC - CRIA	\N	\N	\N	2-07-A21369	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC - ubicado en CRIA	\N	20	13	\N	\N	2026-05-30 08:44:16.936	2026-06-10 16:44:55.652
157	Patch Panel 24P Cat6A Blindado			2-07-A58042	2-07-A58042	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat. 6A Blindado		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:26:34.929
167	Conmutador Administrable 48P PoE			2-07-A60157	2-07-A60157	ACTIVE	\N	\N	\N	Conmutador administrable 48 puertos RJ-45 10/100/1000 PoE, 4 puertos adicionales. Compra de artículos de tecnología según facturas #0586 del 22 de diciembre		19	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:29:50.265
168	iMac Pro	APPLE	iMac Pro	C02DR0SG0833	2-10-A70765	ACTIVE	\N	\N	\N	iMac Pro con memoria configurable hasta 1.5TB DDR4, almacenamiento 1TB a 8TB SSD, procesador Intel Xeon W 3.3GHz 12 núcleos, Turbo Boost 4.4GHz, cache 31.25MB		14	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:30:02.574
169	Processmeter 789		789	2-10-A72442	2-10-A72442	ACTIVE	\N	\N	\N	Equipo 789 Processmeter		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:30:16.72
171	Gabinete Pared 16U x 50cm			2-12-A60161	2-12-A60161	ACTIVE	\N	\N	\N	Gabinete de pared, tapas laterales desmontables, 16 UDR x 50cm de profundidad. Facturas #0586 del 22 de diciembre de 2017		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:30:46.717
172	Aire Acondicionado Mini Split 12000BTU			2-12-A86322	2-12-A86322	ACTIVE	\N	\N	\N	Equipo de aire acondicionado tipo mini split, capacidad 12.000 BTU, 220VAC tipo Inverter SEER, incluye evaporadora y condensadora. Contrato N° 002647-24		18	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:31:06.724
173	Patch Panel Cat5 Precableado 24P			2-12-APATCH CAT5	2-12-APATCH CAT5	ACTIVE	\N	\N	\N	Patch Panel precableado 24 puertos Cat5		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:32:16.754
174	Patch Panel Cat6 Precableado 24P			2-12-APATCH CAT6	2-12-APATCH CAT6	ACTIVE	\N	\N	\N	Patch Panel precableado 24 puertos Cat6 - ubicado en Investigaciones		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:32:32.448
175	Generador Chicharra Amplificador			2-14-A10217	2-14-A10217	ACTIVE	\N	\N	\N	Generador chicharra amplificador		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:32:45.347
176	Taladro Percutor			2-14-A50477	2-14-A50477	ACTIVE	\N	\N	\N	Taladro percutor		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:33:03.682
177	Tajalápiz Eléctrico			2-14-A52369	2-14-A52369	ACTIVE	\N	\N	\N	Tajalápiz eléctrico		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:33:22.893
178	Escalera Tijera Aluminio 3 Pasos			2-14-A58013	2-14-A58013	ACTIVE	\N	\N	\N	Escalera aluminio tijera 3 pasos, altura 0.90m		23	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:33:41.197
179	Escalera Extensión Aluminio 4 Secciones			2-14-A58014	2-14-A58014	ACTIVE	\N	\N	\N	Escalera aluminio extensión 4 secciones multifuncional		23	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:34:00.524
180	Sopladora Aspiradora 600W			2-14-A58240	2-14-A58240	ACTIVE	\N	\N	\N	Sopladora aspiradora 600W		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:34:13.06
181	Taladro Rotomartillo 800W			2-14-A60158	2-14-A60158	ACTIVE	\N	\N	\N	Taladro roto martillo potencia 800W. Facturas #0586 del 22 de diciembre de 2017 de Ingtel Ltda.		22	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:34:25.871
182	Gabinete Metálico Quest	QUEST		2-18-A07706	2-18-A07706	ACTIVE	\N	\N	\N	Gabinete metálico Quest		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:34:39.641
183	Estabilizador 1000VA Monofásico	MAGON		2-18-A08785	2-18-A08785	ACTIVE	\N	\N	\N	Estabilizador monofásico 1000 MAGON		17	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:34:53.354
184	Holt Metálico			2-18-A08823	2-18-A08823	ACTIVE	\N	\N	\N	Holt metálico		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:35:05.564
185	Gabinete Pared 19''			2-18-A08824	2-18-A08824	ACTIVE	\N	\N	\N	Gabinete de pared 19x20		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:35:23.929
186	Superficie de Trabajo			2-18-A08870	2-18-A08870	ACTIVE	\N	\N	\N	Superficie de trabajo ingeniería		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:35:37.209
187	Gabinete 19''			2-18-A09314	2-18-A09314	ACTIVE	\N	\N	\N	Gabinete 19x20		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:35:50.98
190	Gabinete Piso Madera			2-18-A1343	2-18-A1343	ACTIVE	\N	\N	\N	Gabinete de piso madera		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:36:37.421
208	Bandeja Fibra Óptica (Instalada)	\N	\N	\N	2-18-A55660	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica	\N	20	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
209	Gabinete de Piso (Instalado)	\N	\N	\N	2-18-A55661	ACTIVE	\N	\N	\N	Suministro e instalación de gabinete de piso	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
210	Bandeja Fibra Óptica (Instalada)	\N	\N	\N	2-18-A55662	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica	\N	20	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
211	Silla Giratoria Negra	\N	\N	\N	2-18-A55746	ACTIVE	\N	\N	\N	Silla para puesto de trabajo giratoria negra	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
212	Gabinete Pared 9U	\N	\N	\N	2-18-A59881	ACTIVE	\N	\N	\N	Gabinete de pared de 9 RU. Contrato de Obra N° 003259-16	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
213	Silla Gerencial con Cabecero	\N	\N	\N	2-18-A71536	ACTIVE	\N	\N	\N	Silla giratoria tipo gerencial con cabecero, espaldar malla negra, soporte lumbar ajustable, asiento tapizado, base estrella en nylon, rodachinas, brazos graduables en altura	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
214	Gabinete Madera	\N	\N	\N	2-18-C09946	ACTIVE	\N	\N	\N	Gabinete en madera	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
215	Estabilizador	\N	\N	\N	2-18-C11224	ACTIVE	\N	\N	\N	Estabilizador	\N	17	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
216	Archivador Inferior	\N	\N	\N	2-18-C18552A	ACTIVE	\N	\N	\N	Archivador inferior	\N	13	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
217	Rack Metálico	\N	\N	\N	2-24-A08876	ACTIVE	\N	\N	\N	Rack metálico	\N	12	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
218	Estabilizador 20KVA Trifásico	\N	\N	\N	2-24-A08878	ACTIVE	\N	\N	\N	Estabilizador de 20 KVA trifásico	\N	17	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
219	UPS Online 2KVA	\N	\N	\N	2-24-A08965	ACTIVE	\N	\N	\N	UPS de 2 KVA Online	\N	10	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
220	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09084	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
221	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09085	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
222	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09087	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
223	Patch Panel 24P Quest	QUEST	\N	\N	2-24-A09092	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Quest	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
224	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09094	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
226	Patch Panel 48P Quest	QUEST	\N	\N	2-24-A09097	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Quest	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
227	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09099	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
228	Patch Panel 48P Siemon	SIEMON	\N	\N	2-24-A09100	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
229	UPS Online 3.4KVA	\N	\N	\N	2-24-A32572	ACTIVE	\N	\N	\N	UPS ubicada en el sótano del Kakareo	\N	10	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
230	Teclado HP	HP	\N	\N	2-24-A40999	ACTIVE	\N	\N	\N	Teclado HP	\N	18	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
231	CPU HP	HP	\N	\N	2-24-A41276	ACTIVE	\N	\N	\N	CPU HP	\N	24	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
232	Switch 3Com 24P	3COM	\N	\N	2-24-A42524	ACTIVE	\N	\N	\N	Switch 3Com 24 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
233	Switch 3Com 48P	3COM	\N	\N	2-24-A42526	ACTIVE	\N	\N	\N	Switch 3Com 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
234	Switch 3Com 48P	3COM	\N	\N	2-24-A42527	ACTIVE	\N	\N	\N	Switch 3Com 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
235	Switch 3Com 48P	3COM	\N	\N	2-24-A42528	ACTIVE	\N	\N	\N	Switch 3Com 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
236	Switch 3Com 48P - Investigaciones	3COM	\N	\N	2-24-A42530	ACTIVE	\N	\N	\N	Switch 3Com 48 puertos - ubicado en Investigaciones	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
237	Patch Panel 48P	\N	\N	\N	2-24-A46643	ACTIVE	\N	\N	\N	Patch Panel 48 puertos	\N	7	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
238	Monitor HP LV1911	HP	LV1911	6CM22820XH	2-24-A47260	ACTIVE	\N	\N	\N	Monitor HP LV1911 19 pulgadas	\N	1	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
239	Teclado HP con Mouse	HP	\N	\N	2-24-A47261	ACTIVE	\N	\N	\N	Teclado HP con mouse óptico	\N	18	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
240	Rack Metálico	\N	\N	\N	2-24-A48145	ACTIVE	\N	\N	\N	Rack metálico	\N	12	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
241	Rack Metálico	\N	\N	\N	2-24-A48146	ACTIVE	\N	\N	\N	Rack metálico	\N	12	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
244	Switch 48P	\N	\N	\N	2-24-A48961	ACTIVE	\N	\N	\N	Switch X 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
191	Silla Interlocutora Fija			2-18-A16068	2-18-A16068	ACTIVE	\N	\N	\N	Silla interlocutora fija		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:36:55.712
193	Gabinete Piso 19'' - Rat Telefónico			2-18-A35104	2-18-A35104	ACTIVE	\N	\N	\N	Gabinete de piso formato 19 pulgadas - ubicado en Rat Telefónico		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:37:34.073
194	Mueble Madera 1.47x1.3x0.40			2-18-A4089	2-18-A4089	ACTIVE	\N	\N	\N	Mueble en madera de 1.47m x 1.3m x 0.40m		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:37:52.917
225	Patch Panel 48P Siemon	SIEMON		2-24-A09095	2-24-A09095	ACTIVE	\N	\N	\N	Patch Panel 48 puertos Siemon		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:38:21.301
196	Gabinete de Pared RMS			2-18-A45086	2-18-A45086	ACTIVE	\N	\N	\N	Gabinete de pared RMS		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:38:35.948
197	Gabinete de Pared RMS			2-18-A45119	2-18-A45119	ACTIVE	\N	\N	\N	Gabinete de pared RMS		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:38:50.313
198	Silla Giratoria			2-18-A48134	2-18-A48134	ACTIVE	\N	\N	\N	Silla giratoria		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:39:04.676
199	Gabinete de Piso (Instalado)			2-18-A55651	2-18-A55651	ACTIVE	\N	\N	\N	Suministro e instalación de gabinete de piso		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:39:21.884
201	Gabinete de Piso (Instalado)			2-18-A55653	2-18-A55653	ACTIVE	\N	\N	\N	Suministro e instalación de gabinete de piso		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:39:49.367
202	Bandeja Fibra Óptica (Instalada)			2-18-A55654	2-18-A55654	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:40:03.161
203	Bandeja Fibra Óptica (Instalada)			2-18-A55655	2-18-A55655	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:40:17.044
204	Gabinete de Piso (Instalado)			2-18-A55656	2-18-A55656	ACTIVE	\N	\N	\N	Suministro e instalación de gabinete de piso		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:40:31.812
205	Bandeja Fibra Óptica (Instalada)			2-18-A55657	2-18-A55657	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:40:45.28
206	Gabinete de Piso (Instalado)			2-18-A55658	2-18-A55658	ACTIVE	\N	\N	\N	Suministro e instalación de gabinete de piso		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:40:58.454
245	Switch 48P	\N	\N	\N	2-24-A48962	ACTIVE	\N	\N	\N	Switch X 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
246	Switch 48P	\N	\N	\N	2-24-A48963	ACTIVE	\N	\N	\N	Switch X 48 puertos	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
247	Regleta para Rack	\N	\N	\N	2-24-A48994	ACTIVE	\N	\N	\N	Regleta para rack	\N	25	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
248	Rack Switch UNE Huawei	HUAWEI	S2318TP-EI-AC	\N	2-24-A50590	ACTIVE	\N	\N	\N	Rack de UNE - Switch Quidway S2318TP-EI-AC 24P Huawei - Cucuta	\N	12	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
249	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50591	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
250	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50592	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
251	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50593	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
252	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50594	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
253	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50597	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
254	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50598	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
255	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50599	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
256	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A50600	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
257	Monitor LCD 20''	\N	\N	VNA1PV1	2-24-A50635	ACTIVE	\N	\N	\N	Monitor LCD 20 pulgadas o superior. Contrato de compra-venta N° 003001-13	\N	1	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
258	Monitor LCD 20''	\N	\N	VNA18VD	2-24-A50649	ACTIVE	\N	\N	\N	Monitor LCD 20 pulgadas o superior. Contrato de compra-venta N° 003001-13	\N	1	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
259	PC Escritorio Core i7-3770	\N	\N	MJ00CUPQ	2-24-A50650	ACTIVE	\N	\N	\N	Equipo de cómputo de escritorio, procesador Core i7-3770 de 3.4GHz, RAM 8GB DDR3, disco duro 1TB	\N	14	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
260	Switch Huawei S2318TP 24P	HUAWEI	S2318TP-EI-AC	\N	2-24-A51312	ACTIVE	\N	\N	\N	Switch Quidway S2318TP-EI-AC 24 puertos Huawei	\N	2	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
107	Patch Panel 24P Cat6A			2-07-A59401	2-07-A59401	ACTIVE	\N	\N	\N	Patch Panel 24 puertos Cat 6A. Contrato compraventa N° 001704-16		7	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:02:11.06
262	Portátil 14'' Certificación Militar	LENOVO	\N	5CD2254YWY	2-24-A81290	ACTIVE	\N	\N	\N	Portátil 14 pulgadas, peso máximo 1.8 kg, SSD 512GB PCIe, 16GB RAM, Windows 10 Pro, certificación EPEAT Gold, Energy Star 8.x, estándar militar MIL-STD 810H. Contrato N° 002566-23	\N	15	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
263	UPS Bifásica 3KVA	\N	\N	\N	2-24-A86324	ACTIVE	\N	\N	\N	UPS bifásica 3KVA 120/208V 60Hz. Contrato N° 002647-24	\N	10	\N	\N	\N	2026-05-30 08:44:16.936	2026-05-30 08:44:16.936
2	Monitor 24"	\N	\N	\N	2-07-A48285	ACTIVE	\N	\N	\N	Monitor de 24 pulgadas	\N	1	10	\N	\N	2026-05-30 08:44:16.936	2026-05-30 10:09:51.659
113	Cámara Web Logitech BC950	LOGITECH	BC950 Conference	2-07-A59873	2-07-A59873	ACTIVE	\N	\N	\N	Cámara Logitech BC950 Conference. Factura de venta N° 108 de Soluciones TICS		11	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:04:06.967
122	Cosedora de Grapa 26/6			2-18-A46634	2-18-A46634	ACTIVE	\N	\N	\N	Cosedora para grapa N° 26/6		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:06:37.021
124	Silla Interlocutora sin Brazos			2-18-A57013	2-18-A57013	ACTIVE	\N	\N	\N	Silla interlocutora sin brazos, espaldar marco en polipropileno reforzado con interior en malla nylon		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:07:13.887
7	Switch 24P TP-Link TL-SG1024	TP-LINK	TL-SG1024	2152120000417	2-07-A59248	ACTIVE	\N	\N	\N	Switch 24 puertos 10/100/1000 TP-Link TL-SG1024. Contrato compraventa N° 001704-16		2	6	1	\N	2026-05-30 08:44:16.936	2026-06-01 12:59:25.462
70	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1C02F57PAU00095	2-07-A59339	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:09:38.504
134	Extintor ABC 10 Libras			2-18-C45037	2-18-C45037	ACTIVE	\N	\N	\N	Extintor ABC multipropósito de 10 libras		21	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:10:00.388
139	PC Escritorio Core i7-3770			MJ00CUQB	2-24-A50940	ACTIVE	\N	\N	\N	Equipo de cómputo de escritorio, procesador Core i7-3770 de 3.4GHz, RAM 8GB DDR3, disco duro 1TB		14	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:11:07.292
143	Estante Metálico 6 Bandejas			04-18-C74144	04-18-C74144	ACTIVE	\N	\N	\N	Estante metálico, seis (6) bandejas, lámina Cold Rolled calibre 22, parales tipo uña calibre 16, medidas 2.00m alto x 0.93m ancho x 0.40m fondo, pintura electrostática. Contrato N° 002207-21		19	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:12:06.936
192	Gabinete Metálico			2-18-A2527	2-18-A2527	ACTIVE	\N	\N	\N	Gabinete metálico		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:37:17.732
261	Impresora Multifuncional Láser	HP	\N	VNBNM3Y7FN	2-24-A68533	ACTIVE	\N	\N	\N	Impresora multifuncional láser color, funciones: imprime, copia, escanea. Velocidad mínima 22 PPM negro/color, doble cara 13 PPM, ciclo mensual hasta 40.000 páginas, memoria 256MB, WiFi 802.11 b/g/n, USB 2.0, 110V. Serial: VNBNM3Y7FN	\N	15	9	\N	\N	2026-05-30 08:44:16.936	2026-06-01 18:31:43.04
4	Teléfono IP Yealink SIP-T20P	YEALINK	SIP-T20P	20758654	2-07-A58654	ACTIVE	\N	\N	\N	Teléfono IP marca Yealink SIP-T20P color gris (UNE)		8	13	1	\N	2026-05-30 08:44:16.936	2026-06-03 13:22:17.642
148	Switch de Core			0	2-07-A21344	ACTIVE	\N	\N	\N	Equipo activo de red Switch de Core		2	13	2	\N	2026-05-30 08:44:16.936	2026-06-10 16:39:42.366
153	Bandeja Fibra LC - Monitoreo	\N	\N	\N	2-07-A21371	ACTIVE	\N	\N	\N	Bandeja de fibra de conectores LC - ubicado en Monitoreo	\N	20	13	\N	\N	2026-05-30 08:44:16.936	2026-06-10 16:43:49.959
16	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00089	2-07-A59258	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	14	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:36:53.247
53	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	1D02564PAF00191	2-07-A59314	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	14	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:39:09.969
27	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00021	2-07-A59277	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	14	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:46:00.33
10	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00059	2-07-A59252	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:51:13.819
41	Cámara IP Domo 2MPX Dahua	DAHUA	IPC-HDWB 1200EN	IE02710PAX00054	2-07-A59292	ACTIVE	\N	\N	\N	Cámara IP Domo metálica 2MPX Dahua IPC-HDWB 1200EN. Contrato compraventa N° 001704-16		3	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 11:56:32.787
94	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00196	2-07-A59367	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:17:59.067
76	Cámara IP Bala 2MPX Dahua	DAHUA	IPS-HFW 1200SN	1E029A8PAU00074	2-07-A59347	ACTIVE	\N	\N	\N	Cámara IP Bala metálica 2MPX Dahua IPS-HFW 1200SN. Contrato compraventa N° 001704-16		4	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:20:23.249
145	Estante Metálico 6 Bandejas			04-18-C74150	04-18-C74150	ACTIVE	\N	\N	\N	Estante metálico, seis (6) bandejas, lámina Cold Rolled calibre 22, parales tipo uña calibre 16, medidas 2.00m alto x 0.93m ancho x 0.40m fondo, pintura electrostática. Contrato N° 002207-21		19	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:22:16.081
170	Portátil Lenovo ThinkPad E14	LENOVO	ThinkPad E14	PF37MYTA	2-10-A72818	ACTIVE	\N	\N	\N	Portátil Lenovo ThinkPad E14, procesador Intel Core i5 4.3GHz, RAM 8GB DDR4, disco SSD 256GB, pantalla 14 pulgadas, WiFi 802.11b/g/n, Bluetooth, Windows Professional 64bits, cargador, mouse USB, garantía mínima 3 años. Incluye diadema Bluetooth y PTZ Webcam 1080P. Contrato N° 002214-21		15	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:30:27.826
195	Gabinete RMS - Decanatura C. Naturales			2-18-A45085	2-18-A45085	ACTIVE	\N	\N	\N	Gabinete de pared RMS - Decanatura de Ciencias Naturales		13	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:38:07.652
200	Bandeja Fibra Óptica (Instalada)			2-18-A55652	2-18-A55652	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:39:36.188
207	Bandeja Fibra Óptica (Instalada)			2-18-A55659	2-18-A55659	ACTIVE	\N	\N	\N	Suministro e instalación de bandeja de conectorizacion de fibra óptica		20	11	3	\N	2026-05-30 08:44:16.936	2026-06-19 12:41:13.696
8	Switch 24P TP-Link TL-SG1024	TP-LINK	TL-SG1024	2152120000445	2-07-A59250	LOST	\N	\N	\N	Switch 24 puertos 10/100/1000 TP-Link TL-SG1024. Contrato compraventa N° 001704-16		2	9	3	\N	2026-05-30 08:44:16.936	2026-06-19 15:04:55.31
269	ORUEB	RUTU	123654	123456	123456	LOST	\N	\N	\N	RUEBNADF	QUIEN SABE	20	9	3	1	2026-06-30 23:16:38.597	2026-06-30 23:26:45.693
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, user_id, username, action, entity_type, entity_id, entity_description, old_values, new_values, ip_address, user_agent, success, error_message, "timestamp", full_name, role_name) FROM stdin;
1	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-17 16:14:59.891	\N	\N
2	1	admin	CREATE	Asset	1	sw-ppa	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-17 16:34:26.756	\N	\N
3	1	admin	UPDATE	Asset	1	sw-ppa	{name:'sw-ppa',status:'ACTIVE',area:'Data Center'}	{name:'sw-ppa',status:'ACTIVE',area:'Data Center'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-17 17:47:14.876	\N	\N
4	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 09:05:25.275	\N	\N
5	1	admin	CREATE	Asset	2	sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 09:22:40.618	\N	\N
6	1	admin	CREATE	Asset	3	pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 09:28:19.684	\N	\N
7	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 09:38:54.757	\N	\N
8	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 09:40:22.084	\N	\N
9	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-04-18 10:04:48.59	\N	\N
10	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:53:29.289	\N	\N
11	1	admin	CREATE	InventoryMovement	1	Préstamo - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:57:05.056	\N	\N
12	1	admin	CREATE	InventoryMovement	2	Traslado - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:57:11.488	\N	\N
13	1	admin	CREATE	InventoryMovement	3	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:11.288	\N	\N
14	1	admin	CREATE	InventoryMovement	4	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:22.677	\N	\N
15	1	admin	CREATE	InventoryMovement	5	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:33.787	\N	\N
16	1	admin	CREATE	InventoryMovement	6	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:34.935	\N	\N
17	1	admin	CREATE	InventoryMovement	7	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:35.434	\N	\N
18	1	admin	CREATE	InventoryMovement	8	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:35.633	\N	\N
19	1	admin	CREATE	InventoryMovement	9	Préstamo - pc	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 06:58:35.793	\N	\N
20	1	admin	CREATE	InventoryMovement	10	Entrada - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:21:21.768	\N	\N
21	1	admin	CREATE	InventoryMovement	11	Entrada - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:21:31.501	\N	\N
22	1	admin	UPDATE	Asset	2	sw	{name:'sw',status:'ACTIVE',area:'Biblioteca'}	{name:'sw',status:'MAINTENANCE',area:'Biblioteca'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:37:13.752	\N	\N
23	1	admin	CREATE	InventoryMovement	12	Entrada a Mantenimiento - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:37:49.777	\N	\N
24	1	admin	CREATE	InventoryMovement	13	Traslado - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:39:30.11	\N	\N
25	1	admin	CREATE	InventoryMovement	14	Devolución - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:45:32.647	\N	\N
26	1	admin	CREATE	InventoryMovement	15	Devolución - sw	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 07:46:52.119	\N	\N
27	1	admin	CREATE	Asset	4	vr	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 08:08:48.429	\N	\N
28	1	admin	UPDATE	Asset	4	vr	{name:'vr',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'vr',status:'ACTIVE',area:'Bienestar Universitario'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 08:09:32.853	\N	\N
29	1	admin	CREATE	InventoryMovement	16	Préstamo - Monitor 24"	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 09:39:12.431	\N	\N
30	1	admin	CREATE	InventoryMovement	17	Traslado - Monitor 24"	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 09:56:35.008	\N	\N
31	1	admin	CREATE	InventoryMovement	18	Salida - Monitor 24"	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 10:09:51.659	\N	\N
32	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 10:23:55.924	\N	\N
33	1	admin	CREATE	NetworkDevice	1	IP: 192.168.25.5	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-05-30 10:29:48.44	\N	\N
72	1	admin	CREATE	Asset	268	Pepito	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:08:35.182	\N	\N
73	1	admin	DELETE	Asset	265	Prueba	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:19:10.094	\N	\N
74	1	admin	DELETE	Asset	267	CRUDR	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:19:14.368	\N	\N
75	1	admin	DELETE	Asset	268	Pepito	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:19:17.282	\N	\N
76	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:22:37.801	\N	\N
77	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:23:36.997	\N	\N
78	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 16:32:55.464	\N	\N
79	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-01 16:35:19.892	\N	\N
80	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 17:43:13.044	\N	\N
81	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 18:22:02.892	\N	\N
82	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 18:23:57.942	\N	\N
83	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-01 18:24:31.545	\N	\N
84	1	admin	LOGIN	User	1	admin	\N	\N	181.68.206.168	\N	t	\N	2026-06-01 18:25:06.134	\N	\N
85	1	admin	CREATE	InventoryMovement	22	Préstamo - Impresora Multifuncional Láser	\N	\N	190.0.244.122	\N	t	\N	2026-06-01 18:31:43.043	\N	\N
86	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 18:46:46.309	\N	\N
87	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 19:07:25.785	\N	\N
88	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 19:21:47.017	\N	\N
89	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 19:22:56.445	\N	\N
90	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 19:25:36.671	\N	\N
91	1	admin	CREATE	InventoryMovement	23	Entrada - Patch Panel 24P Cat6A Blindado	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 19:51:31.082	\N	\N
92	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 20:04:32.118	\N	\N
93	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-01 20:12:01.985	\N	\N
94	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 20:19:05.28	\N	\N
95	1	admin	LOGIN	User	1	admin	\N	\N	181.224.35.21	\N	t	\N	2026-06-01 20:28:53.901	\N	\N
96	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-01 20:34:28.791	\N	\N
97	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-01 21:58:19.678	\N	\N
98	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-02 22:02:48.473	\N	\N
99	1	admin	LOGIN	User	1	admin	\N	\N	186.103.39.9	\N	t	\N	2026-06-02 22:10:12.707	\N	\N
100	1	admin	CREATE	InventoryMovement	24	Traslado - Teléfono IP Yealink SIP-T20P	\N	\N	186.103.39.9	\N	t	\N	2026-06-02 22:55:13.933	\N	\N
101	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-02 22:55:24.484	\N	\N
102	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.57	\N	t	\N	2026-06-03 01:20:24.813	\N	\N
103	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.53	\N	t	\N	2026-06-03 12:08:20.59	\N	\N
104	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'ACTIVE',area:'N/A'}	{name:'Monitor 24"',status:'ACTIVE',area:'Bodega'}	190.145.218.88	\N	t	\N	2026-06-03 13:10:17.381	\N	\N
105	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-03 13:19:28.625	\N	\N
106	1	admin	UPDATE	Asset	3	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'2C1'}	190.145.218.88	\N	t	\N	2026-06-03 13:20:02.548	\N	\N
107	1	admin	UPDATE	Asset	4	Teléfono IP Yealink SIP-T20P	{name:'Teléfono IP Yealink SIP-T20P',status:'ACTIVE',area:'Pasillo'}	{name:'Teléfono IP Yealink SIP-T20P',status:'ACTIVE',area:'2C1'}	190.145.218.88	\N	t	\N	2026-06-03 13:22:17.646	\N	\N
108	1	admin	UPDATE	Asset	5	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'N/A'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	190.145.218.88	\N	t	\N	2026-06-03 13:23:53.56	\N	\N
109	1	admin	UPDATE	Asset	5	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	190.145.218.88	\N	t	\N	2026-06-03 13:24:30.954	\N	\N
110	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-03 15:49:07.535	\N	\N
111	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-03 16:10:38.79	\N	\N
112	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-03 16:12:55.636	\N	\N
113	1	admin	LOGIN	User	1	admin	\N	\N	191.156.159.108	\N	t	\N	2026-06-03 20:20:23.871	\N	\N
114	1	admin	LOGIN	User	1	admin	\N	\N	181.236.162.226	\N	t	\N	2026-06-04 02:52:59.985	\N	\N
115	1	admin	LOGIN	User	1	admin	\N	\N	186.103.7.79	\N	t	\N	2026-06-05 13:06:13.193	\N	\N
116	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:22:35.102	\N	\N
117	1	admin	UPDATE	Asset	9	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'N/A'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	190.0.244.122	\N	t	\N	2026-06-10 16:33:36.758	\N	\N
118	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:35:52.068	\N	\N
119	1	admin	UPDATE	Asset	148	Switch de Core	{name:'Switch de Core',status:'ACTIVE',area:'N/A'}	{name:'Switch de Core',status:'ACTIVE',area:'2C1'}	190.0.244.122	\N	t	\N	2026-06-10 16:38:52.246	\N	\N
120	1	admin	UPDATE	Asset	148	Switch de Core	{name:'Switch de Core',status:'ACTIVE',area:'2C1'}	{name:'Switch de Core',status:'ACTIVE',area:'2C1'}	190.0.244.122	\N	t	\N	2026-06-10 16:39:42.37	\N	\N
121	1	admin	CREATE	InventoryMovement	25	Entrada - Bandeja Fibra LC - CRIA	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:41:34.079	\N	\N
122	1	admin	CREATE	InventoryMovement	26	Entrada - Bandeja Fibra LC	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:42:52.112	\N	\N
123	1	admin	CREATE	InventoryMovement	27	Entrada - Bandeja Fibra LC - Monitoreo	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:43:49.974	\N	\N
124	1	admin	CREATE	InventoryMovement	28	Entrada - Bandeja Fibra LC Multipropósito	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:44:27.432	\N	\N
125	1	admin	CREATE	InventoryMovement	29	Entrada - Bandeja Fibra LC - CRIA	\N	\N	190.0.244.122	\N	t	\N	2026-06-10 16:44:55.663	\N	\N
126	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-12 22:21:42.984	\N	\N
127	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-13 14:34:18.926	\N	\N
128	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-13 14:43:30.372	\N	\N
129	2	pepe	LOGIN	User	2	pepe	\N	\N	104.28.153.55	\N	t	\N	2026-06-13 14:48:36.109	\N	\N
130	2	pepe	LOGIN	User	2	pepe	\N	\N	181.55.20.97	\N	t	\N	2026-06-13 14:58:57.368	\N	\N
131	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.74	\N	t	\N	2026-06-15 12:51:45	\N	\N
132	3	IngOscar	LOGIN	User	3	IngOscar	\N	\N	104.28.153.74	\N	t	\N	2026-06-15 12:51:58.237	\N	\N
133	3	IngOscar	LOGIN	User	3	IngOscar	\N	\N	104.28.153.74	\N	t	\N	2026-06-15 12:53:13.943	\N	\N
134	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.54	\N	t	\N	2026-06-16 01:57:26.571	\N	\N
135	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-16 15:03:35.11	\N	\N
136	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-16 15:12:40.236	\N	\N
137	4	usuario	LOGIN	User	4	usuario	\N	\N	190.0.244.122	\N	t	\N	2026-06-16 15:35:50.745	\N	\N
138	2	pepe	LOGIN	User	2	pepe	\N	\N	190.0.244.122	\N	t	\N	2026-06-16 15:36:15.211	\N	\N
139	1	admin	UPDATE	Asset	8	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	190.0.244.122	\N	t	\N	2026-06-16 15:53:51.374	\N	\N
140	1	admin	LOGIN	User	1	admin	\N	\N	181.55.20.97	\N	t	\N	2026-06-19 04:25:15.818	\N	\N
141	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-19 11:34:55.168	\N	\N
142	1	admin	UPDATE	Asset	10	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:35:30.647	\N	\N
143	1	admin	UPDATE	Asset	11	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:35:41.822	\N	\N
144	1	admin	UPDATE	Asset	12	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:36:06.8	\N	\N
145	1	admin	UPDATE	Asset	14	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:36:40.686	\N	\N
146	1	admin	UPDATE	Asset	16	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:36:53.251	\N	\N
147	1	admin	UPDATE	Asset	18	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:37:02.881	\N	\N
148	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.55	\N	t	\N	2026-06-19 11:37:36.994	\N	\N
149	1	admin	UPDATE	Asset	15	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:38:28.007	\N	\N
150	1	admin	UPDATE	Asset	53	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.153.55	\N	t	\N	2026-06-19 11:39:09.974	\N	\N
151	3	IngOscar	LOGIN	User	3	IngOscar	\N	\N	104.28.166.238	\N	t	\N	2026-06-19 11:42:35.778	\N	\N
152	3	IngOscar	UPDATE	Asset	13	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:44:43.149	\N	\N
153	3	IngOscar	UPDATE	Asset	17	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:44:56.571	\N	\N
154	3	IngOscar	UPDATE	Asset	19	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:08.929	\N	\N
155	3	IngOscar	UPDATE	Asset	20	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:15.421	\N	\N
156	3	IngOscar	UPDATE	Asset	21	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:22.389	\N	\N
157	3	IngOscar	UPDATE	Asset	22	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:29.004	\N	\N
158	3	IngOscar	UPDATE	Asset	23	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:35.977	\N	\N
159	3	IngOscar	UPDATE	Asset	24	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:42.108	\N	\N
160	3	IngOscar	UPDATE	Asset	25	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:49.934	\N	\N
161	3	IngOscar	UPDATE	Asset	26	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:45:55.72	\N	\N
162	3	IngOscar	UPDATE	Asset	27	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:00.334	\N	\N
163	3	IngOscar	UPDATE	Asset	28	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:10.037	\N	\N
164	3	IngOscar	UPDATE	Asset	29	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:15.941	\N	\N
165	3	IngOscar	UPDATE	Asset	30	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:21.179	\N	\N
424	1	admin	LOGIN	User	1	admin	\N	\N	181.68.227.37	\N	t	\N	2026-07-06 00:36:15.157	SuperAdministrador del Sistema	ROLE_SUPERADMIN
166	3	IngOscar	UPDATE	Asset	31	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:26.317	\N	\N
168	3	IngOscar	UPDATE	Asset	33	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:37.035	\N	\N
170	3	IngOscar	UPDATE	Asset	35	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:48.228	\N	\N
172	3	IngOscar	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'ACTIVE',area:'Bodega 2A1'}	{name:'Monitor 24"',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:23.458	\N	\N
174	3	IngOscar	UPDATE	Asset	5	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:35.326	\N	\N
176	3	IngOscar	UPDATE	Asset	8	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:43.339	\N	\N
177	3	IngOscar	UPDATE	Asset	8	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:46.384	\N	\N
178	3	IngOscar	UPDATE	Asset	10	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:50.432	\N	\N
179	3	IngOscar	UPDATE	Asset	10	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:53.748	\N	\N
181	3	IngOscar	UPDATE	Asset	10	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:51:13.822	\N	\N
183	3	IngOscar	UPDATE	Asset	11	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:53:56.909	\N	\N
185	3	IngOscar	UPDATE	Asset	14	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:08.168	\N	\N
187	3	IngOscar	UPDATE	Asset	15	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:18.262	\N	\N
189	3	IngOscar	UPDATE	Asset	17	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:26.859	\N	\N
191	3	IngOscar	UPDATE	Asset	20	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:35.407	\N	\N
193	3	IngOscar	UPDATE	Asset	22	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:43.504	\N	\N
195	3	IngOscar	UPDATE	Asset	24	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:51.667	\N	\N
167	3	IngOscar	UPDATE	Asset	32	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:31.44	\N	\N
169	3	IngOscar	UPDATE	Asset	34	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:46:42.697	\N	\N
171	3	IngOscar	UPDATE	Asset	189	Archivador Superior	{name:'Archivador Superior',status:'ACTIVE',area:'N/A'}	{name:'Archivador Superior',status:'ACTIVE',area:'Oficina Redes'}	104.28.166.238	\N	t	\N	2026-06-19 11:47:51.19	\N	\N
173	3	IngOscar	UPDATE	Asset	3	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'2C1'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'2C1'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:29.64	\N	\N
175	3	IngOscar	UPDATE	Asset	9	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'2C1'}	104.28.166.238	\N	t	\N	2026-06-19 11:50:38.324	\N	\N
180	3	IngOscar	UPDATE	Asset	6	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'N/A'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:51:01.857	\N	\N
182	3	IngOscar	UPDATE	Asset	36	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:51:27.326	\N	\N
184	3	IngOscar	UPDATE	Asset	12	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:02.438	\N	\N
186	3	IngOscar	UPDATE	Asset	18	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:13.404	\N	\N
188	3	IngOscar	UPDATE	Asset	13	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:22.246	\N	\N
190	3	IngOscar	UPDATE	Asset	19	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:30.708	\N	\N
192	3	IngOscar	UPDATE	Asset	21	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:39.983	\N	\N
194	3	IngOscar	UPDATE	Asset	23	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:47.406	\N	\N
196	3	IngOscar	UPDATE	Asset	25	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:56.509	\N	\N
197	3	IngOscar	UPDATE	Asset	26	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:54:59.885	\N	\N
198	3	IngOscar	UPDATE	Asset	28	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:03.586	\N	\N
199	3	IngOscar	UPDATE	Asset	29	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:07.291	\N	\N
200	3	IngOscar	UPDATE	Asset	30	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:11.62	\N	\N
201	3	IngOscar	UPDATE	Asset	31	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:15.685	\N	\N
202	3	IngOscar	UPDATE	Asset	32	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:20.504	\N	\N
203	3	IngOscar	UPDATE	Asset	33	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:24.599	\N	\N
204	3	IngOscar	UPDATE	Asset	34	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:28.838	\N	\N
205	3	IngOscar	UPDATE	Asset	35	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Oficina Redes'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:32.406	\N	\N
206	3	IngOscar	UPDATE	Asset	189	Archivador Superior	{name:'Archivador Superior',status:'ACTIVE',area:'Oficina Redes'}	{name:'Archivador Superior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:37.352	\N	\N
207	3	IngOscar	UPDATE	Asset	37	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:48.602	\N	\N
208	3	IngOscar	UPDATE	Asset	38	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:55:59.955	\N	\N
209	3	IngOscar	UPDATE	Asset	39	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:56:13.049	\N	\N
210	3	IngOscar	UPDATE	Asset	40	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:56:24.016	\N	\N
211	3	IngOscar	UPDATE	Asset	41	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:56:32.791	\N	\N
212	3	IngOscar	UPDATE	Asset	42	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:56:45.525	\N	\N
213	3	IngOscar	UPDATE	Asset	43	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:00.26	\N	\N
214	3	IngOscar	UPDATE	Asset	44	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:10.581	\N	\N
215	3	IngOscar	UPDATE	Asset	45	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:19.18	\N	\N
217	3	IngOscar	UPDATE	Asset	47	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:38.526	\N	\N
219	3	IngOscar	UPDATE	Asset	49	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:58.464	\N	\N
221	3	IngOscar	UPDATE	Asset	51	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:16.649	\N	\N
223	3	IngOscar	UPDATE	Asset	54	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:35.513	\N	\N
225	3	IngOscar	UPDATE	Asset	56	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:56.655	\N	\N
227	3	IngOscar	UPDATE	Asset	58	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:15.888	\N	\N
229	3	IngOscar	UPDATE	Asset	60	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:34.688	\N	\N
231	3	IngOscar	UPDATE	Asset	62	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:51.559	\N	\N
233	3	IngOscar	UPDATE	Asset	64	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:00:10.2	\N	\N
234	3	IngOscar	UPDATE	Asset	65	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:00:21.755	\N	\N
216	3	IngOscar	UPDATE	Asset	46	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:29.951	\N	\N
218	3	IngOscar	UPDATE	Asset	48	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:57:48.44	\N	\N
220	3	IngOscar	UPDATE	Asset	50	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:07.8	\N	\N
222	3	IngOscar	UPDATE	Asset	52	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:26.785	\N	\N
224	3	IngOscar	UPDATE	Asset	55	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:58:46.766	\N	\N
226	3	IngOscar	UPDATE	Asset	57	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:06.153	\N	\N
228	3	IngOscar	UPDATE	Asset	59	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:25.591	\N	\N
230	3	IngOscar	UPDATE	Asset	61	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:43.402	\N	\N
232	3	IngOscar	UPDATE	Asset	63	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 11:59:59.851	\N	\N
235	3	IngOscar	UPDATE	Asset	66	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:00:30.397	\N	\N
237	3	IngOscar	UPDATE	Asset	68	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:00:47.795	\N	\N
426	1	admin	LOGIN	User	1	admin	\N	\N	172.18.0.1	\N	t	\N	2026-07-06 13:08:11.238027	SuperAdministrador del Sistema	ROLE_SUPERADMIN
239	3	IngOscar	UPDATE	Asset	106	Patch Panel 24P Cat6A	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:01:51.422	\N	\N
241	3	IngOscar	UPDATE	Asset	108	Patch Panel 24P Cat6A	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:02:36.051	\N	\N
243	3	IngOscar	UPDATE	Asset	110	Probador de Red WiFi Fluke	{name:'Probador de Red WiFi Fluke',status:'ACTIVE',area:'N/A'}	{name:'Probador de Red WiFi Fluke',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:03:11.743	\N	\N
244	3	IngOscar	UPDATE	Asset	111	Switch HP 24P	{name:'Switch HP 24P',status:'ACTIVE',area:'N/A'}	{name:'Switch HP 24P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:03:29.959	\N	\N
246	3	IngOscar	UPDATE	Asset	113	Cámara Web Logitech BC950	{name:'Cámara Web Logitech BC950',status:'ACTIVE',area:'N/A'}	{name:'Cámara Web Logitech BC950',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:04:06.971	\N	\N
248	3	IngOscar	UPDATE	Asset	115	Botiquín de Pared	{name:'Botiquín de Pared',status:'ACTIVE',area:'N/A'}	{name:'Botiquín de Pared',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:04:41.531	\N	\N
250	3	IngOscar	UPDATE	Asset	117	Archivador Inferior	{name:'Archivador Inferior',status:'ACTIVE',area:'N/A'}	{name:'Archivador Inferior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:05:09.937	\N	\N
252	3	IngOscar	UPDATE	Asset	119	Silla Giratoria en Paño	{name:'Silla Giratoria en Paño',status:'ACTIVE',area:'N/A'}	{name:'Silla Giratoria en Paño',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:05:43.732	\N	\N
254	3	IngOscar	UPDATE	Asset	121	Persiana	{name:'Persiana',status:'ACTIVE',area:'N/A'}	{name:'Persiana',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:06:20.849	\N	\N
256	3	IngOscar	UPDATE	Asset	123	Perforadora 3 Huecos	{name:'Perforadora 3 Huecos',status:'ACTIVE',area:'N/A'}	{name:'Perforadora 3 Huecos',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:06:53.925	\N	\N
258	3	IngOscar	UPDATE	Asset	125	Silla Interlocutora sin Brazos	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'N/A'}	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:07:28.828	\N	\N
260	3	IngOscar	UPDATE	Asset	127	Módulo Puesto de Cómputo 80x60	{name:'Módulo Puesto de Cómputo 80x60',status:'ACTIVE',area:'N/A'}	{name:'Módulo Puesto de Cómputo 80x60',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:07:56.237	\N	\N
262	3	IngOscar	UPDATE	Asset	129	Módulo Puesto de Cómputo 210x60	{name:'Módulo Puesto de Cómputo 210x60',status:'ACTIVE',area:'N/A'}	{name:'Módulo Puesto de Cómputo 210x60',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:08:22.653	\N	\N
264	3	IngOscar	UPDATE	Asset	131	Superficie de Trabajo	{name:'Superficie de Trabajo',status:'ACTIVE',area:'N/A'}	{name:'Superficie de Trabajo',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:08:50.58	\N	\N
236	3	IngOscar	UPDATE	Asset	67	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:00:39.223	\N	\N
238	3	IngOscar	UPDATE	Asset	69	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:01:29.173	\N	\N
240	3	IngOscar	UPDATE	Asset	107	Patch Panel 24P Cat6A	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:02:11.064	\N	\N
242	3	IngOscar	UPDATE	Asset	109	Patch Panel 24P Cat6A	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:02:52.082	\N	\N
245	3	IngOscar	UPDATE	Asset	112	Switch HP 24P	{name:'Switch HP 24P',status:'ACTIVE',area:'N/A'}	{name:'Switch HP 24P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:03:48.742	\N	\N
247	3	IngOscar	UPDATE	Asset	114	Altavoz Jabra Speak 510	{name:'Altavoz Jabra Speak 510',status:'ACTIVE',area:'N/A'}	{name:'Altavoz Jabra Speak 510',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:04:22.093	\N	\N
249	3	IngOscar	UPDATE	Asset	116	Archivador Lateral 2x60	{name:'Archivador Lateral 2x60',status:'ACTIVE',area:'N/A'}	{name:'Archivador Lateral 2x60',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:04:55.4	\N	\N
251	3	IngOscar	UPDATE	Asset	118	Gabinete Superior	{name:'Gabinete Superior',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Superior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:05:26.845	\N	\N
253	3	IngOscar	UPDATE	Asset	120	Archivador Inferior	{name:'Archivador Inferior',status:'ACTIVE',area:'N/A'}	{name:'Archivador Inferior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:06:03.09	\N	\N
255	3	IngOscar	UPDATE	Asset	122	Cosedora de Grapa 26/6	{name:'Cosedora de Grapa 26/6',status:'ACTIVE',area:'N/A'}	{name:'Cosedora de Grapa 26/6',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:06:37.024	\N	\N
257	3	IngOscar	UPDATE	Asset	124	Silla Interlocutora sin Brazos	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'N/A'}	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:07:13.891	\N	\N
259	3	IngOscar	UPDATE	Asset	126	Silla Interlocutora sin Brazos	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'N/A'}	{name:'Silla Interlocutora sin Brazos',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:07:42.845	\N	\N
261	3	IngOscar	UPDATE	Asset	128	Módulo Puesto de Cómputo 80x60	{name:'Módulo Puesto de Cómputo 80x60',status:'ACTIVE',area:'N/A'}	{name:'Módulo Puesto de Cómputo 80x60',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:08:09.605	\N	\N
263	3	IngOscar	UPDATE	Asset	130	Cortina Enrollable Screen 2.03x2.40	{name:'Cortina Enrollable Screen 2.03x2.40',status:'ACTIVE',area:'N/A'}	{name:'Cortina Enrollable Screen 2.03x2.40',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:08:38.278	\N	\N
265	3	IngOscar	UPDATE	Asset	132	Archivador Inferior	{name:'Archivador Inferior',status:'ACTIVE',area:'N/A'}	{name:'Archivador Inferior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:09:02.863	\N	\N
266	3	IngOscar	UPDATE	Asset	70	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:09:38.508	\N	\N
267	3	IngOscar	UPDATE	Asset	134	Extintor ABC 10 Libras	{name:'Extintor ABC 10 Libras',status:'ACTIVE',area:'N/A'}	{name:'Extintor ABC 10 Libras',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:10:00.392	\N	\N
268	3	IngOscar	UPDATE	Asset	135	UPS Online 2KVA	{name:'UPS Online 2KVA',status:'ACTIVE',area:'N/A'}	{name:'UPS Online 2KVA',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:10:13.26	\N	\N
269	3	IngOscar	UPDATE	Asset	136	Chasis Blade IBM	{name:'Chasis Blade IBM',status:'ACTIVE',area:'N/A'}	{name:'Chasis Blade IBM',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:10:30.341	\N	\N
270	3	IngOscar	UPDATE	Asset	137	Teclado HP con Mouse	{name:'Teclado HP con Mouse',status:'ACTIVE',area:'N/A'}	{name:'Teclado HP con Mouse',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:10:43.497	\N	\N
271	3	IngOscar	UPDATE	Asset	138	Monitor HP LV1911	{name:'Monitor HP LV1911',status:'ACTIVE',area:'N/A'}	{name:'Monitor HP LV1911',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:10:55.683	\N	\N
272	3	IngOscar	UPDATE	Asset	139	PC Escritorio Core i7-3770	{name:'PC Escritorio Core i7-3770',status:'ACTIVE',area:'N/A'}	{name:'PC Escritorio Core i7-3770',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:11:07.296	\N	\N
273	3	IngOscar	UPDATE	Asset	140	Portátil Lenovo	{name:'Portátil Lenovo',status:'ACTIVE',area:'N/A'}	{name:'Portátil Lenovo',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:11:19.824	\N	\N
274	3	IngOscar	UPDATE	Asset	141	Cámara IP Bala HD 2MP Dahua	{name:'Cámara IP Bala HD 2MP Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala HD 2MP Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:11:33.721	\N	\N
275	3	IngOscar	UPDATE	Asset	142	Cámara IP Bala HD 2MP Dahua	{name:'Cámara IP Bala HD 2MP Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala HD 2MP Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:11:50.403	\N	\N
276	3	IngOscar	UPDATE	Asset	143	Estante Metálico 6 Bandejas	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'N/A'}	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:12:06.94	\N	\N
277	3	IngOscar	UPDATE	Asset	144	Estante Metálico 6 Bandejas	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'N/A'}	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:12:21.009	\N	\N
278	3	IngOscar	UPDATE	Asset	243	Switch 48P	{name:'Switch 48P',status:'ACTIVE',area:'N/A'}	{name:'Switch 48P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:12:33.449	\N	\N
279	3	IngOscar	UPDATE	Asset	133	Archivador Inferior	{name:'Archivador Inferior',status:'ACTIVE',area:'N/A'}	{name:'Archivador Inferior',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:12:48.115	\N	\N
280	3	IngOscar	UPDATE	Asset	105	Patch Panel 24P Cat6A	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:13:01.431	\N	\N
281	3	IngOscar	UPDATE	Asset	104	NVR 4K Dahua NVR4232	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'N/A'}	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:13:21.801	\N	\N
282	3	IngOscar	UPDATE	Asset	14	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:13:30.361	\N	\N
284	3	IngOscar	UPDATE	Asset	103	NVR 4K Dahua NVR4232	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'N/A'}	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:13:55.365	\N	\N
285	3	IngOscar	UPDATE	Asset	57	Cámara IP Domo 2MPX Dahua	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	{name:'Cámara IP Domo 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:14:04.188	\N	\N
288	3	IngOscar	UPDATE	Asset	102	NVR 4K Dahua NVR4232	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'N/A'}	{name:'NVR 4K Dahua NVR4232',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:15:57.688	\N	\N
290	3	IngOscar	UPDATE	Asset	73	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:16:29.471	\N	\N
292	3	IngOscar	UPDATE	Asset	100	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:16:51.294	\N	\N
294	3	IngOscar	UPDATE	Asset	98	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:12.351	\N	\N
296	3	IngOscar	UPDATE	Asset	96	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:35.346	\N	\N
297	3	IngOscar	UPDATE	Asset	95	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:47.326	\N	\N
299	3	IngOscar	UPDATE	Asset	93	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:18:09.665	\N	\N
301	3	IngOscar	UPDATE	Asset	91	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:18:29.595	\N	\N
303	3	IngOscar	UPDATE	Asset	89	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:18:49.323	\N	\N
305	3	IngOscar	UPDATE	Asset	87	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:10.908	\N	\N
306	3	IngOscar	UPDATE	Asset	86	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:20.932	\N	\N
308	3	IngOscar	UPDATE	Asset	84	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:40.788	\N	\N
310	3	IngOscar	UPDATE	Asset	75	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:20:10.92	\N	\N
312	3	IngOscar	UPDATE	Asset	77	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:20:33.47	\N	\N
314	3	IngOscar	UPDATE	Asset	79	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:21:00.701	\N	\N
316	3	IngOscar	UPDATE	Asset	81	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:21:24.779	\N	\N
318	3	IngOscar	UPDATE	Asset	83	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:21:47.297	\N	\N
320	3	IngOscar	UPDATE	Asset	146	Estante Metálico 6 Bandejas	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'N/A'}	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:22:35.939	\N	\N
322	3	IngOscar	UPDATE	Asset	150	Bandeja Fibra LC - CRIA	{name:'Bandeja Fibra LC - CRIA',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra LC - CRIA',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:25:42.292	\N	\N
283	3	IngOscar	UPDATE	Asset	71	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:13:44.731	\N	\N
286	3	IngOscar	UPDATE	Asset	72	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:14:51.904	\N	\N
287	3	IngOscar	UPDATE	Asset	8	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	104.28.166.238	\N	t	\N	2026-06-19 12:15:44.236	\N	\N
289	3	IngOscar	UPDATE	Asset	242	Switch 48P	{name:'Switch 48P',status:'ACTIVE',area:'N/A'}	{name:'Switch 48P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:16:16.567	\N	\N
291	3	IngOscar	UPDATE	Asset	101	Cámara PTZ 2MPX Dahua	{name:'Cámara PTZ 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara PTZ 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:16:40.308	\N	\N
293	3	IngOscar	UPDATE	Asset	99	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:01.198	\N	\N
295	3	IngOscar	UPDATE	Asset	97	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:23.686	\N	\N
298	3	IngOscar	UPDATE	Asset	94	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:17:59.071	\N	\N
300	3	IngOscar	UPDATE	Asset	92	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:18:19.419	\N	\N
302	3	IngOscar	UPDATE	Asset	90	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:18:39.331	\N	\N
304	3	IngOscar	UPDATE	Asset	88	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:00.023	\N	\N
307	3	IngOscar	UPDATE	Asset	85	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:30.478	\N	\N
309	3	IngOscar	UPDATE	Asset	74	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:19:51.742	\N	\N
311	3	IngOscar	UPDATE	Asset	76	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:20:23.252	\N	\N
313	3	IngOscar	UPDATE	Asset	78	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:20:45.965	\N	\N
315	3	IngOscar	UPDATE	Asset	80	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:21:14.588	\N	\N
317	3	IngOscar	UPDATE	Asset	82	Cámara IP Bala 2MPX Dahua	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'N/A'}	{name:'Cámara IP Bala 2MPX Dahua',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:21:37.332	\N	\N
319	3	IngOscar	UPDATE	Asset	145	Estante Metálico 6 Bandejas	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'N/A'}	{name:'Estante Metálico 6 Bandejas',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:22:16.085	\N	\N
321	3	IngOscar	UPDATE	Asset	147	Switch de Core	{name:'Switch de Core',status:'ACTIVE',area:'N/A'}	{name:'Switch de Core',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:23:25.391	\N	\N
323	3	IngOscar	UPDATE	Asset	155	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:25:57.827	\N	\N
324	3	IngOscar	UPDATE	Asset	156	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:26:17.07	\N	\N
325	3	IngOscar	UPDATE	Asset	157	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:26:34.933	\N	\N
326	3	IngOscar	UPDATE	Asset	158	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:27:35.48	\N	\N
327	3	IngOscar	UPDATE	Asset	159	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:27:51.756	\N	\N
328	3	IngOscar	UPDATE	Asset	160	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:28:06.53	\N	\N
329	3	IngOscar	UPDATE	Asset	161	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:28:21.298	\N	\N
330	3	IngOscar	UPDATE	Asset	162	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:28:36.974	\N	\N
331	3	IngOscar	UPDATE	Asset	163	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:28:51.548	\N	\N
332	3	IngOscar	UPDATE	Asset	164	Patch Panel 24P Cat6A Blindado	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 24P Cat6A Blindado',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:29:09.625	\N	\N
333	3	IngOscar	UPDATE	Asset	165	Router Cloud CCR1016-12G	{name:'Router Cloud CCR1016-12G',status:'ACTIVE',area:'N/A'}	{name:'Router Cloud CCR1016-12G',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:29:23.668	\N	\N
335	3	IngOscar	UPDATE	Asset	167	Conmutador Administrable 48P PoE	{name:'Conmutador Administrable 48P PoE',status:'ACTIVE',area:'N/A'}	{name:'Conmutador Administrable 48P PoE',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:29:50.269	\N	\N
337	3	IngOscar	UPDATE	Asset	169	Processmeter 789	{name:'Processmeter 789',status:'ACTIVE',area:'N/A'}	{name:'Processmeter 789',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:30:16.724	\N	\N
339	3	IngOscar	UPDATE	Asset	171	Gabinete Pared 16U x 50cm	{name:'Gabinete Pared 16U x 50cm',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Pared 16U x 50cm',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:30:46.721	\N	\N
334	3	IngOscar	UPDATE	Asset	166	Switch Linksys 26P Gigabit	{name:'Switch Linksys 26P Gigabit',status:'ACTIVE',area:'N/A'}	{name:'Switch Linksys 26P Gigabit',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:29:38.304	\N	\N
336	3	IngOscar	UPDATE	Asset	168	iMac Pro	{name:'iMac Pro',status:'ACTIVE',area:'N/A'}	{name:'iMac Pro',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:30:02.578	\N	\N
338	3	IngOscar	UPDATE	Asset	170	Portátil Lenovo ThinkPad E14	{name:'Portátil Lenovo ThinkPad E14',status:'ACTIVE',area:'N/A'}	{name:'Portátil Lenovo ThinkPad E14',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:30:27.829	\N	\N
340	3	IngOscar	UPDATE	Asset	172	Aire Acondicionado Mini Split 12000BTU	{name:'Aire Acondicionado Mini Split 12000BTU',status:'ACTIVE',area:'N/A'}	{name:'Aire Acondicionado Mini Split 12000BTU',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:31:06.727	\N	\N
341	3	IngOscar	UPDATE	Asset	173	Patch Panel Cat5 Precableado 24P	{name:'Patch Panel Cat5 Precableado 24P',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel Cat5 Precableado 24P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:32:16.757	\N	\N
342	3	IngOscar	UPDATE	Asset	174	Patch Panel Cat6 Precableado 24P	{name:'Patch Panel Cat6 Precableado 24P',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel Cat6 Precableado 24P',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:32:32.452	\N	\N
343	3	IngOscar	UPDATE	Asset	175	Generador Chicharra Amplificador	{name:'Generador Chicharra Amplificador',status:'ACTIVE',area:'N/A'}	{name:'Generador Chicharra Amplificador',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:32:45.351	\N	\N
344	3	IngOscar	UPDATE	Asset	176	Taladro Percutor	{name:'Taladro Percutor',status:'ACTIVE',area:'N/A'}	{name:'Taladro Percutor',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:33:03.686	\N	\N
345	3	IngOscar	UPDATE	Asset	177	Tajalápiz Eléctrico	{name:'Tajalápiz Eléctrico',status:'ACTIVE',area:'N/A'}	{name:'Tajalápiz Eléctrico',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:33:22.897	\N	\N
346	3	IngOscar	UPDATE	Asset	178	Escalera Tijera Aluminio 3 Pasos	{name:'Escalera Tijera Aluminio 3 Pasos',status:'ACTIVE',area:'N/A'}	{name:'Escalera Tijera Aluminio 3 Pasos',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:33:41.201	\N	\N
347	3	IngOscar	UPDATE	Asset	179	Escalera Extensión Aluminio 4 Secciones	{name:'Escalera Extensión Aluminio 4 Secciones',status:'ACTIVE',area:'N/A'}	{name:'Escalera Extensión Aluminio 4 Secciones',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:34:00.527	\N	\N
348	3	IngOscar	UPDATE	Asset	180	Sopladora Aspiradora 600W	{name:'Sopladora Aspiradora 600W',status:'ACTIVE',area:'N/A'}	{name:'Sopladora Aspiradora 600W',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:34:13.064	\N	\N
349	3	IngOscar	UPDATE	Asset	181	Taladro Rotomartillo 800W	{name:'Taladro Rotomartillo 800W',status:'ACTIVE',area:'N/A'}	{name:'Taladro Rotomartillo 800W',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:34:25.875	\N	\N
350	3	IngOscar	UPDATE	Asset	182	Gabinete Metálico Quest	{name:'Gabinete Metálico Quest',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Metálico Quest',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:34:39.645	\N	\N
351	3	IngOscar	UPDATE	Asset	183	Estabilizador 1000VA Monofásico	{name:'Estabilizador 1000VA Monofásico',status:'ACTIVE',area:'N/A'}	{name:'Estabilizador 1000VA Monofásico',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:34:53.358	\N	\N
352	3	IngOscar	UPDATE	Asset	184	Holt Metálico	{name:'Holt Metálico',status:'ACTIVE',area:'N/A'}	{name:'Holt Metálico',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:35:05.571	\N	\N
353	3	IngOscar	UPDATE	Asset	185	Gabinete Pared 19''	{name:'Gabinete Pared 19''',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Pared 19''',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:35:23.933	\N	\N
354	3	IngOscar	UPDATE	Asset	186	Superficie de Trabajo	{name:'Superficie de Trabajo',status:'ACTIVE',area:'N/A'}	{name:'Superficie de Trabajo',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:35:37.212	\N	\N
355	3	IngOscar	UPDATE	Asset	187	Gabinete 19''	{name:'Gabinete 19''',status:'ACTIVE',area:'N/A'}	{name:'Gabinete 19''',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:35:50.983	\N	\N
356	3	IngOscar	UPDATE	Asset	188	Superficie de Trabajo Redes	{name:'Superficie de Trabajo Redes',status:'ACTIVE',area:'N/A'}	{name:'Superficie de Trabajo Redes',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:36:12.214	\N	\N
357	3	IngOscar	UPDATE	Asset	190	Gabinete Piso Madera	{name:'Gabinete Piso Madera',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Piso Madera',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:36:37.425	\N	\N
358	3	IngOscar	UPDATE	Asset	191	Silla Interlocutora Fija	{name:'Silla Interlocutora Fija',status:'ACTIVE',area:'N/A'}	{name:'Silla Interlocutora Fija',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:36:55.717	\N	\N
359	3	IngOscar	UPDATE	Asset	192	Gabinete Metálico	{name:'Gabinete Metálico',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Metálico',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:37:17.736	\N	\N
360	3	IngOscar	UPDATE	Asset	193	Gabinete Piso 19'' - Rat Telefónico	{name:'Gabinete Piso 19'' - Rat Telefónico',status:'ACTIVE',area:'N/A'}	{name:'Gabinete Piso 19'' - Rat Telefónico',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:37:34.077	\N	\N
361	3	IngOscar	UPDATE	Asset	194	Mueble Madera 1.47x1.3x0.40	{name:'Mueble Madera 1.47x1.3x0.40',status:'ACTIVE',area:'N/A'}	{name:'Mueble Madera 1.47x1.3x0.40',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:37:52.92	\N	\N
362	3	IngOscar	UPDATE	Asset	195	Gabinete RMS - Decanatura C. Naturales	{name:'Gabinete RMS - Decanatura C. Naturales',status:'ACTIVE',area:'N/A'}	{name:'Gabinete RMS - Decanatura C. Naturales',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:38:07.656	\N	\N
363	3	IngOscar	UPDATE	Asset	225	Patch Panel 48P Siemon	{name:'Patch Panel 48P Siemon',status:'ACTIVE',area:'N/A'}	{name:'Patch Panel 48P Siemon',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:38:21.304	\N	\N
364	3	IngOscar	UPDATE	Asset	196	Gabinete de Pared RMS	{name:'Gabinete de Pared RMS',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Pared RMS',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:38:35.952	\N	\N
365	3	IngOscar	UPDATE	Asset	197	Gabinete de Pared RMS	{name:'Gabinete de Pared RMS',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Pared RMS',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:38:50.317	\N	\N
366	3	IngOscar	UPDATE	Asset	198	Silla Giratoria	{name:'Silla Giratoria',status:'ACTIVE',area:'N/A'}	{name:'Silla Giratoria',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:39:04.68	\N	\N
367	3	IngOscar	UPDATE	Asset	199	Gabinete de Piso (Instalado)	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:39:21.888	\N	\N
369	3	IngOscar	UPDATE	Asset	201	Gabinete de Piso (Instalado)	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:39:49.371	\N	\N
371	3	IngOscar	UPDATE	Asset	203	Bandeja Fibra Óptica (Instalada)	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:40:17.048	\N	\N
373	3	IngOscar	UPDATE	Asset	205	Bandeja Fibra Óptica (Instalada)	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:40:45.283	\N	\N
375	3	IngOscar	UPDATE	Asset	207	Bandeja Fibra Óptica (Instalada)	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:41:13.7	\N	\N
368	3	IngOscar	UPDATE	Asset	200	Bandeja Fibra Óptica (Instalada)	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:39:36.192	\N	\N
370	3	IngOscar	UPDATE	Asset	202	Bandeja Fibra Óptica (Instalada)	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'N/A'}	{name:'Bandeja Fibra Óptica (Instalada)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:40:03.165	\N	\N
372	3	IngOscar	UPDATE	Asset	204	Gabinete de Piso (Instalado)	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:40:31.816	\N	\N
374	3	IngOscar	UPDATE	Asset	206	Gabinete de Piso (Instalado)	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'N/A'}	{name:'Gabinete de Piso (Instalado)',status:'ACTIVE',area:'Sin asignar'}	104.28.166.238	\N	t	\N	2026-06-19 12:40:58.458	\N	\N
376	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-19 13:44:33.642	\N	\N
377	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-19 14:56:30.048	\N	\N
378	1	admin	UPDATE	Asset	8	Switch 24P TP-Link TL-SG1024	{name:'Switch 24P TP-Link TL-SG1024',status:'ACTIVE',area:'Bienestar Universitario'}	{name:'Switch 24P TP-Link TL-SG1024',status:'LOST',area:'Bienestar Universitario'}	190.0.244.122	\N	t	\N	2026-06-19 15:04:55.313	\N	\N
379	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'ACTIVE',area:'Sin asignar'}	{name:'Monitor 24"',status:'RETIRED',area:'Sin asignar'}	190.0.244.122	\N	t	\N	2026-06-19 15:06:40.775	\N	\N
380	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-19 15:09:12.37	\N	\N
381	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-06-19 15:12:29.955	\N	\N
382	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-06-30 15:19:57.647	\N	\N
383	1	admin	LOGIN	User	1	admin	\N	\N	104.28.166.240	\N	t	\N	2026-07-01 01:20:12.791	\N	\N
384	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 20:44:21.14	\N	\N
385	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 20:55:05.514	\N	\N
386	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'RETIRED',area:'Sin asignar'}	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 21:05:01.838	\N	\N
387	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 21:07:57.767	\N	\N
388	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 21:08:11.527	\N	\N
389	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:13:36.05	\N	\N
390	1	admin	UPDATE	Asset	1	Monitor 24"	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	{name:'Monitor 24"',status:'LOST',area:'Sin asignar'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:13:52.074	\N	\N
391	1	admin	CREATE	Asset	269	ORUEB	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:16:38.818	\N	\N
392	4	usuario	LOGIN	User	4	usuario	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:21:46.365	\N	\N
393	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:22:19.292	\N	\N
394	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:25:41.182	\N	\N
395	1	admin	UPDATE	Asset	269	ORUEB	{name:'ORUEB',status:'LOST',area:'Bienestar Universitario'}	{name:'ORUEB',status:'RETIRED',area:'Bienestar Universitario'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:25:56.514	\N	\N
396	1	admin	UPDATE	Asset	269	ORUEB	{name:'ORUEB',status:'RETIRED',area:'Bienestar Universitario'}	{name:'ORUEB',status:'RETIRED',area:'Bienestar Universitario'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:26:15.135	\N	\N
397	1	admin	UPDATE	Asset	269	ORUEB	{name:'ORUEB',status:'RETIRED',area:'Bienestar Universitario'}	{name:'ORUEB',status:'LOST',area:'Bienestar Universitario'}	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:26:45.763	\N	\N
398	1	admin	LOGIN	User	1	admin	\N	\N	181.55.20.97	\N	t	\N	2026-07-01 04:29:20.626	\N	\N
399	1	admin	LOGIN	User	1	admin	\N	\N	0:0:0:0:0:0:0:1	\N	t	\N	2026-06-30 23:37:55.826	\N	\N
400	1	admin	LOGIN	User	1	admin	\N	\N	181.55.20.97	\N	t	\N	2026-07-01 18:57:12.483	\N	\N
401	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.53	\N	t	\N	2026-07-02 01:49:42.597	\N	\N
402	1	admin	LOGIN	User	1	admin	\N	\N	104.28.166.241	\N	t	\N	2026-07-02 02:01:01.638	\N	\N
403	1	admin	LOGIN	User	1	admin	\N	\N	104.28.166.241	\N	t	\N	2026-07-02 02:06:00.638	\N	\N
404	1	admin	LOGIN	User	1	admin	\N	\N	181.55.20.97	\N	t	\N	2026-07-02 02:06:54.639	\N	\N
405	1	admin	LOGIN	User	1	admin	\N	\N	104.28.166.241	\N	t	\N	2026-07-02 02:08:03.455	\N	\N
406	1	admin	LOGIN	User	1	admin	\N	\N	104.28.153.53	\N	t	\N	2026-07-02 02:41:00.02	\N	\N
407	4	usuario	LOGIN	User	4	usuario	\N	\N	104.28.153.53	\N	t	\N	2026-07-02 03:33:06.963	\N	\N
408	1	admin	LOGIN	User	1	admin	\N	\N	181.55.20.97	\N	t	\N	2026-07-02 04:25:00.267	\N	\N
409	1	admin	LOGIN	User	1	admin	\N	\N	190.145.218.88	\N	t	\N	2026-07-02 16:19:41.088	\N	\N
410	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-07-02 17:05:38.551	\N	\N
411	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 02:11:02.507	\N	\N
412	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 03:19:59.502	\N	\N
413	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 04:03:12.069	\N	\N
415	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 04:05:22.055	\N	\N
417	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 04:22:35.265	\N	\N
418	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 05:31:31.859	\N	\N
414	\N	admin1	LOGIN	User	6	admin1	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 04:04:56.271	\N	\N
416	\N	admin1	LOGIN	User	6	admin1	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 04:05:47.587	\N	\N
419	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 12:08:02.711	\N	\N
420	1	admin	LOGIN	User	1	admin	\N	\N	181.68.236.237	\N	t	\N	2026-07-03 12:45:04.702	SuperAdministrador del Sistema	ROLE_SUPERADMIN
421	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-07-03 13:33:01.237	SuperAdministrador del Sistema	ROLE_SUPERADMIN
422	1	admin	LOGIN	User	1	admin	\N	\N	190.0.244.122	\N	t	\N	2026-07-03 13:35:57.59	SuperAdministrador del Sistema	ROLE_SUPERADMIN
423	1	admin	LOGIN	User	1	admin	\N	\N	181.68.227.37	\N	t	\N	2026-07-06 00:33:38.77	SuperAdministrador del Sistema	ROLE_SUPERADMIN
425	1	admin	LOGIN	User	1	admin	\N	\N	172.18.0.1	\N	t	\N	2026-07-06 12:54:04.308786	SuperAdministrador del Sistema	ROLE_SUPERADMIN
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	init schema	SQL	V1__init_schema.sql	-283020922	postgres	2026-04-17 15:56:47.194	142	t
2	2	seed data	SQL	V2__seed_data.sql	-1350184923	postgres	2026-04-17 15:56:47.364	9	t
3	3	rename asset tag to codigo	SQL	V3__rename_asset_tag_to_codigo.sql	-597118417	postgres	2026-04-17 17:44:57.373	6	t
4	4	drop image url column	SQL	V4__drop_image_url_column.sql	-590639649	postgres	2026-04-18 09:27:30.51	20	t
5	5	add superadmin role	SQL	V5__add_superadmin_role.sql	-1357750151	postgres	2026-07-03 04:01:42.637	544	t
6	6	add audit log user snapshot	SQL	V6__add_audit_log_user_snapshot.sql	450898978	postgres	2026-07-03 12:41:38.361	384	t
\.


--
-- Data for Name: inventory_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_movements (id, asset_id, movement_type, movement_date, from_area_id, to_area_id, from_user_id, to_user_id, reason, notes, reference_number, created_by, created_at) FROM stdin;
22	261	LOAN	2026-06-14 13:31:00	\N	9	\N	\N	\N	Re	\N	1	2026-06-01 18:31:43.027
23	3	ENTRY	2026-06-01 14:51:00	\N	\N	\N	\N	\N	Prueba	\N	1	2026-06-01 19:51:31.056
24	4	TRANSFER	2026-06-24 17:55:00	\N	11	\N	\N	\N	Prueba 	\N	1	2026-06-02 22:55:13.912
25	149	ENTRY	2026-06-10 11:41:00	\N	13	\N	\N	\N	\N	\N	1	2026-06-10 16:41:34.063
26	154	ENTRY	2026-06-10 11:42:00	\N	13	\N	\N	\N	\N	\N	1	2026-06-10 16:42:52.102
27	153	ENTRY	2026-06-10 16:43:49.929	\N	13	\N	\N	\N	\N	\N	1	2026-06-10 16:43:49.943
28	152	ENTRY	2026-06-10 16:44:27.419	\N	13	\N	\N	\N	\N	\N	1	2026-06-10 16:44:27.423
29	151	ENTRY	2026-06-10 16:44:55.627	\N	13	\N	\N	\N	\N	\N	1	2026-06-10 16:44:55.639
\.


--
-- Data for Name: network_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.network_devices (id, asset_id, ip_address, mac_address, hostname, subnet_mask, gateway, dns_primary, dns_secondary, vlan_id, port_number, is_dhcp, network_status, last_seen, location_detail, firmware_version, created_at, updated_at) FROM stdin;
1	6	192.168.25.5	78:78:FF:12:44:53	ppa-2w	255.255.255.0	192.168.25.1	\N	\N	45	78	f	ONLINE	\N	rack 3 piso	cat 6	2026-05-30 10:29:48.426	2026-05-30 10:29:48.426
\.


--
-- Data for Name: network_topology; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.network_topology (id, source_device_id, target_device_id, connection_type, port_source, port_target, bandwidth, notes, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, created_at) FROM stdin;
1	ROLE_ADMIN	Administrador con acceso total al sistema	2026-04-17 15:56:47.371
2	ROLE_TECNICO	Técnico de soporte con acceso a gestión de activos y red	2026-04-17 15:56:47.371
3	ROLE_USUARIO	Usuario estándar con acceso de consulta	2026-04-17 15:56:47.371
4	ROLE_SUPERADMIN	Super administrador con control total del sistema	2026-07-03 04:01:42.904
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (user_id, role_id) FROM stdin;
2	2
3	1
4	3
1	4
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, email, password, full_name, phone, document_number, is_active, created_at, updated_at) FROM stdin;
2	pepe	tecnico@uts.edu.co	$2a$10$ji4foI7vtuiOcy2KakyXk.RaJendGeoo4ZcP3FNpLbrEA6OLRRg..	Prueba	3001234567	\N	t	2026-04-17 15:56:47.371	2026-07-03 05:35:33.207
3	IngOscar	omonsalve@correo.uts.edu.co	$2a$10$ji4foI7vtuiOcy2KakyXk.RaJendGeoo4ZcP3FNpLbrEA6OLRRg..	Ingeniero Oscar	3187518491	\N	t	2026-06-15 12:49:16.877	2026-06-15 12:49:16.877
4	usuario	usuario@uts.edu.co	$2a$10$ji4foI7vtuiOcy2KakyXk.RaJendGeoo4ZcP3FNpLbrEA6OLRRg..	Usuario normal	3214287973	\N	t	2026-06-16 15:30:14.389	2026-06-16 15:30:14.389
1	admin	admin@uts.edu.co	$2a$10$n0qvpx7Qz9dCCVvcXaIsQO7ZGgCi3WSHTWDxjJ9Ps/luq6G8u9P42	SuperAdministrador del Sistema	6076543210	\N	t	2026-04-17 15:56:47.371	2026-07-06 13:21:00.206562
\.


--
-- Name: areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.areas_id_seq', 15, true);


--
-- Name: asset_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asset_types_id_seq', 25, true);


--
-- Name: assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assets_id_seq', 269, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 426, true);


--
-- Name: inventory_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_movements_id_seq', 29, true);


--
-- Name: network_devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.network_devices_id_seq', 1, true);


--
-- Name: network_topology_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.network_topology_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: areas areas_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_name_key UNIQUE (name);


--
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (id);


--
-- Name: asset_types asset_types_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_types
    ADD CONSTRAINT asset_types_name_key UNIQUE (name);


--
-- Name: asset_types asset_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_types
    ADD CONSTRAINT asset_types_pkey PRIMARY KEY (id);


--
-- Name: assets assets_asset_tag_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_asset_tag_key UNIQUE (codigo);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: assets assets_serial_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_serial_number_key UNIQUE (serial_number);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: inventory_movements inventory_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_pkey PRIMARY KEY (id);


--
-- Name: network_devices network_devices_asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_devices
    ADD CONSTRAINT network_devices_asset_id_key UNIQUE (asset_id);


--
-- Name: network_devices network_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_devices
    ADD CONSTRAINT network_devices_pkey PRIMARY KEY (id);


--
-- Name: network_topology network_topology_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_topology
    ADD CONSTRAINT network_topology_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: network_topology uq_topology; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_topology
    ADD CONSTRAINT uq_topology UNIQUE (source_device_id, target_device_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_assets_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assets_area ON public.assets USING btree (area_id);


--
-- Name: idx_assets_assigned_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assets_assigned_user ON public.assets USING btree (assigned_user_id);


--
-- Name: idx_assets_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assets_status ON public.assets USING btree (status);


--
-- Name: idx_assets_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assets_type ON public.assets USING btree (asset_type_id);


--
-- Name: idx_audit_logs_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity_type, entity_id);


--
-- Name: idx_audit_logs_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_timestamp ON public.audit_logs USING btree ("timestamp");


--
-- Name: idx_audit_logs_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_user ON public.audit_logs USING btree (user_id);


--
-- Name: idx_inventory_movements_asset; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_movements_asset ON public.inventory_movements USING btree (asset_id);


--
-- Name: idx_inventory_movements_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_movements_date ON public.inventory_movements USING btree (movement_date);


--
-- Name: idx_network_devices_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_network_devices_ip ON public.network_devices USING btree (ip_address);


--
-- Name: idx_network_devices_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_network_devices_status ON public.network_devices USING btree (network_status);


--
-- Name: areas areas_responsible_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_responsible_id_fkey FOREIGN KEY (responsible_id) REFERENCES public.users(id);


--
-- Name: assets assets_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id);


--
-- Name: assets assets_asset_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_asset_type_id_fkey FOREIGN KEY (asset_type_id) REFERENCES public.asset_types(id);


--
-- Name: assets assets_assigned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_assigned_user_id_fkey FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: assets assets_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: inventory_movements inventory_movements_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id);


--
-- Name: inventory_movements inventory_movements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: inventory_movements inventory_movements_from_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_from_area_id_fkey FOREIGN KEY (from_area_id) REFERENCES public.areas(id);


--
-- Name: inventory_movements inventory_movements_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.users(id);


--
-- Name: inventory_movements inventory_movements_to_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_to_area_id_fkey FOREIGN KEY (to_area_id) REFERENCES public.areas(id);


--
-- Name: inventory_movements inventory_movements_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES public.users(id);


--
-- Name: network_devices network_devices_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_devices
    ADD CONSTRAINT network_devices_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: network_topology network_topology_source_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_topology
    ADD CONSTRAINT network_topology_source_device_id_fkey FOREIGN KEY (source_device_id) REFERENCES public.network_devices(id) ON DELETE CASCADE;


--
-- Name: network_topology network_topology_target_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_topology
    ADD CONSTRAINT network_topology_target_device_id_fkey FOREIGN KEY (target_device_id) REFERENCES public.network_devices(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gbR1PCgIZAeplt8Ovj0xNfi8TT5O5VpJSiH6BCZfTpcbMHh2YOc6bv32q1wknVL

