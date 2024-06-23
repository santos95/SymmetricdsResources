-- SCRIPT CREAR NODO SUSCRIPTOR REPLICACION SYMMETRIC

-- CREA LA BASE DE DATOS DE PRUEBA
CREATE DATABASE symmetric_lab WITH OWNER = postgres ENCODING = 'UTF-8';

-- CREATE SCHEMA FOR SYMMETRIC
CREATE SCHEMA symmetricds;

-- CREA EL USUARIO PARA SYMMETRIC CON PERMISOS EN EL ESQUEMA
CREATE USER symmetric_user LOGIN SUPERUSER ENCRYPTED PASSWORD '123456';

-- alter para que el usuario por defecto use el esquema symmetric
ALTER USER symmetric_user SET search_path TO symmetricds;


-- AGREGAR NODO 2
-- AGREGAR UN NUEVO NODO
INSERT INTO symmetricds.sym_node
SELECT *
FROM (
    VALUES ('suscriptor2', 'nodos_pg', 'suscriptor2')
     ) NODO (node_id, node_group_id, external_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM symmetricds.sym_node sn
    WHERE sn.node_id = NODO.node_id
);


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

