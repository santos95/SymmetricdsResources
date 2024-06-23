-- ### 3 crear la base de datos - PARA N
CREATE DATABASE replicacion WITH OWNER = postgres ENCODING='UTF-8';

\l - para listar bases de datos
\c replicacion - usar la base de datos especificada

-- ### 4 crear el esquema 
CREATE SCHEMA symmetricds 

-- ### 5 crea el usuario para symmetric 
CREATE USER symmetric_user LOGIN SUPERUSER ENCRYPTED PASSWORD '123456'; 

-- ### 6 alter para que el usuario por defecto use el esquema symmetric
ALTER USER symmetric_user SET search_path TO symmetricds;



--  Publicador
SELECT * FROM symmetricds.sym_node;

SELECT * FROM symmetricds.sym_node_group;

SELECT * FROM symmetricds.sym_node_security;

SELECT * FROM symmetricds.sym_node_identity;

SELECT
    *
FROM symmetricds.sym_node_group;

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

SELECT *
FROM symmetricds.sym_node;

INSERT INTO symmetricds.sym_node (node_id, node_group_id, external_id)
SELECT
    *
FROM (
    VALUES('nodo1', 'nodos_pg', 'nodo1')
     ) NODO1 (node_id, node_group_id, external_id)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node SN
    WHERE SN.node_id = NODO1.node_id
);

SELECT * FROM symmetricds.sym_node_group_link;

INSERT INTO symmetricds.sym_node_group_link(source_node_group_id, target_node_group_id, data_event_action, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('publicador', 'nodos_pg', 'W', current_timestamp, 'sortiz', current_timestamp)
     ) GROUPLINK
    (source_node_group_id, target_note_group_id, data_event_action, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node_group_link GP
    WHERE GP.source_node_group_id = GROUPLINK.source_node_group_id
      AND GP.target_node_group_id = GROUPLINK.target_note_group_id
      AND GP.data_event_action = GROUPLINK.data_event_action
);

-- Creacion de tabla para replicar
CREATE TABLE personas(
    id_persona SERIAL PRIMARY KEY NOT NULL,
    nombre CHARACTER VARYING(100) NOT NULL,
    apellido CHARACTER VARYING(100),
    node_external_id CHARACTER VARYING(50)
);

SELECT * FROM personas;

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
    VALUES('personas', 'public', 'personas', 'catalogos', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
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
    VALUES('publicador2nodos_pg', 'public', 'personas', 'publicador', 'nodos_pg', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
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
    VALUES('personas', 'publicador2nodos_pg', 1, 100, current_timestamp, 'sortiz', current_timestamp)
     ) TRRT_PERSONA(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger_router TRR
    WHERE TRR.trigger_id = TRRT_PERSONA.trigger_id
      AND TRR.router_id = TRRT_PERSONA.router_id
);

INSERT INTO personas(nombre, apellido, node_external_id)
VALUES ('John', 'Connor', 100),
       ('Peter', 'Quill', 50);

SELECT * FROM personas;

-- ## AGREGAR NODO2 - Para agregar un nodo a que se replique la tabla personas simplemente se agrega el node
--    con el id, el grupo a que pertenece y el external id
--    En caso a que pertenezca a otro grupo, uno nuevo se debe realizar la configuracion para el nuevo grupo,
--    agregarlo y proseguir a configurar las demas tablas, como routers y demas
--    En caso de una nueva tabla, se procederia a crear el trigger, router, channel (si utiliza un nuevo channel) y el trigger_router

INSERT INTO symmetricds.sym_node (node_id, node_group_id, external_id)
SELECT
    *
FROM (
    VALUES('nodo2', 'nodos_pg', 'nodo2')
     ) NODO1 (node_id, node_group_id, external_id)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node SN
    WHERE SN.node_id = NODO1.node_id
);

SELECT * FROM symmetricds.sym_node;

SELECT * FROM personas;

-- ## AGREGA UN NUEVO CAMPO A LA TABLA PERSONAS
ALTER TABLE personas
ADD COLUMN estado BOOL;

SELECT * FROM personas;

INSERT INTO personas(nombre, apellido, node_external_id)
VALUES ('Itachi', 'Uchiha', 100),
       ('Tobirama', 'Senju', 50);

SELECT * FROM personas;
select * from symmetricds.sym_node;

-- Agrega el nuevo campo nombre apellido
ALTER TABLE personas
ADD COLUMN nombre_apellido CHARACTER VARYING;


-- Setear datos para el nuevo campo nombre_apellido
WITH personas_name AS (
    SELECT
        p.id_persona,
        concat_ws('', p.nombre, ' ', p.apellido) AS nombre_apellido
    FROM personas P
)
UPDATE personas
SET nombre_apellido = PN.nombre_apellido
FROM personas_name PN
WHERE PN.id_persona = personas.id_persona;

SELECT * FROM personas;


INSERT INTO personas(nombre, apellido, node_external_id, estado, nombre_apellido)
VALUES ('Son', 'Goku', 100, true, 'Son Goku'),
       ('Matt', 'Murdok', 50, false, 'Matt Murdock');

INSERT INTO personas(nombre, apellido, node_external_id, estado, nombre_apellido)
VALUES ('Scott', 'Summer', 100, true, 'Scott Summer');

SELECT * FROM personas;


--  AGREGAR PARA CONFIGURAR Y REPLICAR AL GRUPO DE MYSQL

-- Agrega el node group
INSERT INTO symmetricds.sym_node_group(node_group_id)
SELECT *
FROM (
VALUES ('nodos_mdb')
) GRUPO (node_group_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM symmetricds.sym_node_group ng
    WHERE ng.node_group_id = GRUPO.node_group_id
);

select * from symmetricds.sym_node_group;

SELECT *
FROM symmetricds.sym_node;

INSERT INTO symmetricds.sym_node (node_id, node_group_id, external_id)
SELECT
    *
FROM (
    VALUES('nodo4', 'nodos_mdb', 'nodo4')
     ) NODO1 (node_id, node_group_id, external_id)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node SN
    WHERE SN.node_id = NODO1.node_id
);

-- SE CREA EL group link para el nuevo grupo

SELECT * FROM symmetricds.sym_node_group_link;

INSERT INTO symmetricds.sym_node_group_link(source_node_group_id, target_node_group_id, data_event_action, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('publicador', 'nodos_mdb', 'W', current_timestamp, 'sortiz', current_timestamp)
     ) GROUPLINK
    (source_node_group_id, target_note_group_id, data_event_action, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_node_group_link GP
    WHERE GP.source_node_group_id = GROUPLINK.source_node_group_id
      AND GP.target_node_group_id = GROUPLINK.target_note_group_id
      AND GP.data_event_action = GROUPLINK.data_event_action
);


-- Configurar route - la ruta - la forma de enviar
SELECT * FROM symmetricds.sym_router;

-- configura la ruta con el nuevo grupo
INSERT INTO symmetricds.sym_router(router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT
    *
FROM (
    VALUES('publicador2nodos_mdb', '', 'personas', 'publicador', 'nodos_mdb', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
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
    VALUES('personas', 'publicador2nodos_mdb', 1, 100, current_timestamp, 'sortiz', current_timestamp)
     ) TRRT_PERSONA(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger_router TRR
    WHERE TRR.trigger_id = TRRT_PERSONA.trigger_id
      AND TRR.router_id = TRRT_PERSONA.router_id
);

-- PROBAR SET ACTIVAR LA CARGA INICIAL PARA ESTE NODO DEBIDO A QUE NO SE REALIZO AUNQUE NO MOSTRO ERROR
select * from symmetricds.sym_node_security;


-- sym_node_security - tiene informacion de todos los nodos
-- Tiene atributo - initial_load_enabled - no se recomienda cuando ya lleva tiempo en produccion el nodo que se pretende tocar
update symmetricds.sym_node_security
set initial_load_enabled = 1
where node_id = 'nodo4';

select * from symmetricds.sym_node_security
where node_id = 'nodo4';

select * from symmetricds.sym_node;


INSERT INTO personas(nombre, apellido, node_external_id, estado, nombre_apellido)
VALUES ('Charles', 'Xavier', 100, true, 'Charles Xavier');


INSERT INTO personas(nombre, apellido, node_external_id, estado, nombre_apellido)
VALUES ('Nagato', 'Uzumaki', 100, true, 'Nagato Uzumaki');

select * from personas;

-- AGREGAR NUEVA TABLA REPLICACION

CREATE TABLE videojuegos(
  id_videojuego SERIAL PRIMARY KEY NOT NULL,
  nombre CHARACTER VARYING(100) NOT NULL,
  categoria CHARACTER VARYING(100) NOT NULL
);

SELECT * FROM videojuegos;

INSERT INTO videojuegos (nombre, categoria)
VALUES('LIKE A DRAGON', 'RPG'),
      ('THE MAN WHO ERASE HIS NAME', 'BEATING UP'),
      ('RESIDEN EVIL 2 REMAKE', 'SURVIVAL HORROR');

INSERT INTO videojuegos (nombre, categoria)
VALUES('RESIDENT EVIL 3 REMAKE', 'SURVIVAL HORROR');


--CREAR EL TRIGGER


-- CONFIGURAR THE TRIGGER - LA TABLA
SELECT * FROM symmetricds.sym_trigger;


-- crea una trigger para la tabla videojuegos
-- id - videojuegos, usa el channel catalogos
INSERT INTO symmetricds.sym_trigger(trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('videojuegos', 'public', 'videojuegos', 'catalogos', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) TRIGGER_PERSONA (trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger TR
    WHERE TR.trigger_id = TRIGGER_PERSONA.trigger_id
);


--  ## crear ruta para la nueva tabla

    SELECT * FROM symmetricds.sym_router;

-- configura la ruta con el nuevo grupo
INSERT INTO symmetricds.sym_router(router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT
    *
FROM (
    VALUES('videojuegos_publicador2nodos_mdb', '', 'videojuegos', 'publicador', 'nodos_mdb', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp),
          ('videojuegos_publicador2nodos_pg', 'public', 'videojuegos', 'publicador', 'nodos_pg', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) ROUTER_PERSONA (router_id, target_schema_name, target_table_name, source_node_group_id, target_node_group_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_router RT
    WHERE RT.router_id = ROUTER_PERSONA.router_id
);

-- # Configurar trigger router
INSERT INTO symmetricds.sym_trigger_router(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('videojuegos', 'videojuegos_publicador2nodos_mdb', 1, 100, current_timestamp, 'sortiz', current_timestamp),
          ('videojuegos', 'videojuegos_publicador2nodos_pg', 1, 100, current_timestamp, 'sortiz', current_timestamp)
     ) TRRT_PERSONA(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger_router TRR
    WHERE TRR.trigger_id = TRRT_PERSONA.trigger_id
      AND TRR.router_id = TRRT_PERSONA.router_id
);

select * from videojuegos;