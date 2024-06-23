INSERT INTO symmetricds.sym_trigger_router(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('xmen', 'nodos_pg2master', 1, 100, current_timestamp, 'sortiz', current_timestamp)
     ) TRRT_PERSONA(trigger_id, router_id, enabled, initial_load_order, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger_router TRR
    WHERE TRR.trigger_id = TRRT_PERSONA.trigger_id
      AND TRR.router_id = TRRT_PERSONA.router_id
);

-- CONFIGURAR THE TRIGGER - LA TABLA
SELECT * FROM symmetricds.sym_trigger;

INSERT INTO symmetricds.sym_trigger(trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
SELECT *
FROM (
    VALUES('xmen', 'public', 'xmen', 'catalogos', 1, 1, 1, current_timestamp, 'sortiz', current_timestamp)
     ) TRIGGER_PERSONA (trigger_id, source_schema_name, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, create_time, last_update_by, last_update_time)
WHERE NOT EXISTS(
    SELECT 1
    FROM symmetricds.sym_trigger TR
    WHERE TR.trigger_id = TRIGGER_PERSONA.trigger_id
);




-- TO CHECK HOW IS WORKING
select * from xmen order by 1;
SELECT * FROM symmetricds.sym_outgoing_batch where status <> 'OK';
SELECT * FROM symmetricds.sym_incoming_batch where status <> 'OK';

CREATE TABLE public.xmen (
    id INT PRIMARY KEY NOT NULL,
    full_name VARCHAR(50) NOT NULL,
    nick_name VARCHAR(50) NOT NULL
);

-- CASE WHEN WHE HAVE MANY SUSCRIBERS PUSH - UPDATE EXISTING DATA FROM ANOTHER NODE - 
-- IN THIS CASE ADD A NEW COLUMN INTO THE PRIMARY KEY CONSTRAIN FOR THE UNIQUENES OF VALUES FROM DIFFERENT NODES

ALTER TABLE public.xmen ADD COLUMN generation INTEGER

alter table xmen
drop constraint xmen_pkey,
add primary key (id, generation);

update xmen
set full_name = upper(full_name), nick_name = upper(nick_name)
WHERE id = 3;


-- CASE VTA DOCUMENTO PAGO - CHECK HOW SYM_TRIGGER WORKS - HOW MANAGMENT WORKS IN SYMMETRIC
select * from public.vta_documento_pago
CREATE TABLE public.vta_documento_pago
(
  n_id_documento serial NOT NULL,
  c_tipo_documento character varying(2) NOT NULL,
  n_numero_documento integer NOT NULL,
  d_fecha_documento timestamp without time zone NOT NULL,
  n_id_cliente integer NOT NULL,
  c_nombre_cliente character varying(100) NOT NULL,
  c_numero_provicional character varying(10),
  n_total_aplicar numeric(18,2),
  c_concepto character varying(500),
  c_observacion character varying(500),
  c_estatus character varying(2) NOT NULL DEFAULT 'AC'::character varying,
  c_usuario_crea character varying(25) NOT NULL,
  c_usuario_modifica character varying(25),
  d_fecha_crea timestamp without time zone NOT NULL,
  d_fecha_modifica timestamp without time zone,
  c_motivo_anulacion character varying(500),
  n_impuesto_iva numeric(18,2),
  c_direccion_cliente character varying(500),
  departamento_name character varying(255),
  municipio_name character varying(255),
  telefono character varying(15),
  n_porcentaje_descuento smallint,
  n_descuento numeric(18,2),
  n_subtotal numeric(18,2),
  n_id_factura_devol integer,
  n_id_documento_saldo_favor integer,
  b_nc_provicional_por_devolucion boolean DEFAULT false,
  n_monto_devolucion numeric(18,2) NOT NULL DEFAULT 0,
  enviado_conta boolean NOT NULL DEFAULT false,
  contiene_error boolean NOT NULL DEFAULT false,
  n_excepcion_id smallint,
  producto_vencido boolean DEFAULT true,
  cumple_permanencia_fuera_empresa boolean DEFAULT true,
  cumple_precio boolean DEFAULT true,
  cumple_temperatura boolean DEFAULT true,
  cumple_estado_emp_secundario boolean DEFAULT true,
  cumple_estado_emp_primario boolean DEFAULT true,
  cumple_componente_empaque boolean DEFAULT true,
  n_id_ejecutivo_venta_historico integer DEFAULT 0,
  n_id_salida_dev integer,
  n_id_ejecutivo_venta_cobrador integer DEFAULT 0,
  propietario character varying(255),
  codigo_rarpe character varying(12),
  n_saldo numeric(18,2) DEFAULT 0,
  n_cve_entidad integer NOT NULL,
  c_tipo_nc character varying(5),
  n_id_direccion_cliente integer,
  n_id_roc_ref integer,
  c_numero_nc_ref character varying,
  CONSTRAINT pk_vta_documento_pago PRIMARY KEY (n_id_documento, n_cve_entidad)
)
WITH (
  OIDS=TRUE
);

