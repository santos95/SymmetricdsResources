-- SCRIPT CREAR NODO MAESTRO REPLICACION SYMMETRIC

-- CREA LA BASE DE DATOS DE PRUEBA
CREATE DATABASE symmetric_lab WITH OWNER = postgres ENCODING = 'UTF-8';

-- CREATE SCHEMA FOR SYMMETRIC
CREATE SCHEMA symmetricds;

-- CREA EL USUARIO PARA SYMMETRIC CON PERMISOS EN EL ESQUEMA
CREATE USER symmetric_user LOGIN SUPERUSER ENCRYPTED PASSWORD '123456';

-- alter para que el usuario por defecto use el esquema symmetric
ALTER USER symmetric_user SET search_path TO symmetricds;

-- CHECK IF WORKS OK
SELECT * FROM symmetricds.sym_node;
SELECT * FROM symmetricds.sym_node_group;
SELECT * FROM symmetricds.sym_node_security;-- Hash password para autenticadion entre nodos
SELECT * FROM symmetricds.sym_node_identity;


-- AGREGAR CONFIGURACIONES PARA EL NUEVO SUSCRIPTOR

-- Verificar node_group

   SELECT * FROM symmetricds.sym_node_group;

-- Solo se encuentra el grupo master - si se agrega el engine para el suscriptor y usamos otro grupo no se puede registrar
-- solo veriamos un solo grupo - master
--por tanto se debe agregar el nuevo grupo

--    * inserta en nuevo grupo
INSERT INTO symmetricds.sym_node_group(node_group_id)
SELECT *
FROM (
VALUES ('nodos_pg')
) GRUPO (node_group_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM symmetricds.sym_node_group ng
    WHERE ng.node_group_id = GRUPO.node_group_id
);

SELECT * FROM symmetricds.sym_node_group;


-- # el proceso solo se realiza cuando se crea un nuevo grupo para nodos
-- en este caso un grupo para un grupo de suscriptores - por base de datos

-- # 2 se procede a insertar los datos del nodo1 en la tabla sym_nodo

SELECT * FROM symmetricds.sym_node;

INSERT INTO symmetricds.sym_node (node_id, node_group_id, external_id)
SELECT
    *
FROM (
    VALUES('suscriptor1', 'nodos_pg', 'suscriptor1')
     ) NODO1 (node_id, node_group_id, external_id)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node SN
    WHERE SN.node_id = NODO1.node_id
);

-- # 3 se levanta el servicio para verificar que se creen las tablas en el esquema symmetric en la base respaldo del nodo1
-- asi como la correspondiente insercion de los datos y que symmetric reconozca el nodo1 y se conecte a la base para ese nodo

-- -sudo ./sym


-- # Por tanto se procede a crear el group link
--  # Crear el group link

--  # # cada una de estas configuraciones como agregar el grupo, grupolinks y asi se debe hacer en el publicador - configuracion general
--  a partir de la cual los subscriptores obtienen su configuracion base

 -- tabla de los group links SELECT * FROM symmetricds.sym_node_group_link

--  # se agrega el nuevo group link - es necesario realizar esta accion siempre que se agregue un nuevo grupo
--  # Debido a que symmetric trabaja con grupos
SELECT * FROM symmetricds.sym_node_group;


INSERT INTO symmetricds.sym_node_group_link(source_node_group_id, target_node_group_id, data_event_action, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('master', 'nodos_pg', 'W', current_timestamp, 'sortiz', current_timestamp)
     ) GROUPLINK
    (source_node_group_id, target_note_group_id, data_event_action, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node_group_link GP
    WHERE GP.source_node_group_id = GROUPLINK.source_node_group_id
      AND GP.target_node_group_id = GROUPLINK.target_note_group_id
      AND GP.data_event_action = GROUPLINK.data_event_action
);

SELECT * FROM symmetricds.sym_node_group_link GP


-- CREATE TEST TABLE DATA TO REPLICATE

-- IN THE MASTER
CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	gender VARCHAR(50),
	ip_address VARCHAR(20)
);

insert into customers (first_name, last_name, email, gender, ip_address) values ('Chadd', 'Sherington', 'csherington0@ow.ly', 'Male', '6.9.47.23');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Vladamir', 'Barras', 'vbarras1@prlog.org', 'Male', '187.173.54.66');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Pasquale', 'Mewis', 'pmewis2@usa.gov', 'Male', '228.139.15.147');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Field', 'Goare', 'fgoare3@japanpost.jp', 'Male', '120.236.171.147');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Layne', 'Padly', 'lpadly4@sfgate.com', 'Female', '46.41.186.241');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Eba', 'Pren', 'epren5@mediafire.com', 'Female', '160.35.246.86');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Lyon', 'Smye', 'lsmye6@yellowpages.com', 'Male', '84.35.102.215');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Roderic', 'Bolzen', 'rbolzen7@fc2.com', 'Genderfluid', '122.106.82.47');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Madison', 'Lombardo', 'mlombardo8@reverbnation.com', 'Male', '65.174.82.247');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Yetta', 'Pedrielli', 'ypedrielli9@jigsy.com', 'Female', '87.120.175.160');

SELECT * FROM customers;

-- FOR THE SUSCRIBER
-- ## Suscriptor - El serial se elimina para evitar perdida de integridad y las restricciones
CREATE TABLE public.customers (
    id INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	gender VARCHAR(50),
	ip_address VARCHAR(20)
);


-- add configuration for the table to replicate

-- CONFIGURAR sym_channel
SELECT * FROM symmetricds.sym_channel;

INSERT INTO symmetricds.sym_channel(channel_id, processing_order, max_batch_size, max_batch_to_send, max_data_to_route,
                                    description, create_time, last_update_by, last_update_time)
SELECT
    *
FROM (
    VALUES('catalogos', 100, 1000, 50, 10000, 'Tablas de Catalogo', current_timestamp, 'sortiz', current_timestamp)
     ) CHANNEL (channel_id, processing_order, max_batch_size, max_batch_to_send, max_data_to_route, description, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_channel CH
    WHERE CH.channel_id = CHANNEL.channel_id
);

-- CONFIGURAR THE TRIGGER - LA TABLA
SELECT * FROM symmetricds.sym_trigger;

INSERT INTO symmetricds.sym_trigger(trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('customers', 'public', 'customers', 'catalogos', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) TRIGGER_PERSONA (trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger TR
    WHERE TR.trigger_id = TRIGGER_PERSONA.trigger_id
);

-- Configurar route - la ruta - la forma de enviar
SELECT * FROM symmetricds.sym_router;

INSERT INTO symmetricds.sym_router(router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT
    *
FROM (
    VALUES('master2nodos_pg', 'public', 'customers', 'master', 'nodos_pg', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) ROUTER_PERSONA (router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_router RT
    WHERE RT.router_id = ROUTER_PERSONA.router_id
);


-- Establecer configuracion para sym_trigger_router
SELECT * FROM symmetricds.sym_trigger_router;


INSERT INTO symmetricds.sym_trigger_router(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('customers', 'master2nodos_pg', 1, 100, current_timestamp, 'sortiz', current_timestamp)
     ) TRRT_PERSONA(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger_router TRR
    WHERE TRR.trigger_id = TRRT_PERSONA.trigger_id
      AND TRR.router_id = TRRT_PERSONA.router_id
);


-- REPLICATE DATA 

SELECT * FROM public.customers;


insert into customers (first_name, last_name, email, gender, ip_address) values ('Ring', 'Daud', 'rdauda@telegraph.co.uk', 'Male', '242.79.159.221');
insert into customers (first_name, last_name, email, gender, ip_address) values ('Donny', 'Saltrese', 'dsaltreseb@dyndns.org', 'Female', '35.17.191.102');


-- CONFIGURACION MAESTRO - CASO push_case - AGREGA sym_node_group_link push between publicador y suscriptor


INSERT INTO symmetricds.sym_node_group_link(source_node_group_id, target_node_group_id, data_event_action, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('nodos_pg', 'master', 'P', current_timestamp, 'sortiz', current_timestamp)
     ) GROUPLINK
    (source_node_group_id, target_note_group_id, data_event_action, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node_group_link GP
    WHERE GP.source_node_group_id = GROUPLINK.source_node_group_id
      AND GP.target_node_group_id = GROUPLINK.target_note_group_id
      AND GP.data_event_action = GROUPLINK.data_event_action
);


INSERT INTO symmetricds.sym_router(router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT
    *
FROM (
    VALUES('nodos_pg2master', 'public', '', 'nodos_pg', 'master', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) ROUTER_PERSONA (router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_router RT
    WHERE RT.router_id = ROUTER_PERSONA.router_id
);



