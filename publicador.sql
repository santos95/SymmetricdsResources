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