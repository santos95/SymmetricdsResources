-- Suscriptor

ALTER USER symmetric_nodo SET search_path TO symmetricds;

SELECT * FROM symmetricds.sym_node;

SELECT * FROM symmetricds.sym_node_group;

SELECT * FROM symmetricds.sym_node_security;

SELECT * FROM symmetricds.sym_node_identity;

-- Creacion de tabla para replicar
CREATE TABLE personas(
    id_persona INTEGER PRIMARY KEY,
    nombre CHARACTER VARYING(100),
    apellido CHARACTER VARYING(100),
    node_external_id CHARACTER VARYING(50)
);

SELECT * FROM personas;