-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 06: Tareas Programadas (Jobs) con DBMS_SCHEDULER
-- -- Versión: 5.0 (Alineado con lógica de negocio de QR de corta duración)
-- --
-- -- Descripción: Este script crea una tarea de mantenimiento automatizada.
-- -- 1. Crea un procedimiento que desactiva los códigos QR con más de 15 minutos de antigüedad.
-- -- 2. Crea y programa un "Job" que ejecuta ese procedimiento cada 5 minutos.
-- --------------------------------------------------------------------------------

PROMPT Actualizando la lógica de limpieza de QR para alinearse con la regla de negocio...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DEL PROCEDIMIENTO DE LIMPIEZA
-- --------------------------------------------------------------------------------
-- Este procedimiento contiene la lógica que el "robot" (job) ejecutará.
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_QRS_ANTIGUOS AS
BEGIN
    UPDATE SESIONES_CLASE_QR
    SET ESTADO = 'I' -- 'I' de Inactivo
    WHERE ESTADO = 'A'
      AND FROM_TZ(FECHA_CREACION, 'UTC') < (SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '15' MINUTE);

    COMMIT;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN Y PROGRAMACIÓN DEL JOB
-- --------------------------------------------------------------------------------
-- Este bloque crea el "robot" y le dice cuándo y qué hacer.
BEGIN
    -- Primero, intenta eliminar el job si ya existe, para asegurar una instalación limpia.
    DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_LIMPIEZA_QRS_HORARIA', force => TRUE);
EXCEPTION
    -- Ignora el error si el job no existe la primera vez.
    WHEN OTHERS THEN
        IF SQLCODE = -27475 THEN NULL; ELSE RAISE; END IF;
END;
/

-- Ahora, crea el job con la nueva programación.
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'JOB_LIMPIEZA_QRS_HORARIA',
       job_type             => 'PLSQL_BLOCK',
       job_action           => 'BEGIN SP_DESACTIVAR_QRS_ANTIGUTOS; END;',
       start_date           => SYSTIMESTAMP,
       repeat_interval      => 'FREQ=MINUTELY; INTERVAL=5', -- Se ejecuta cada 5 minutos
       enabled              => TRUE,
       comments             => 'Job que desactiva los códigos QR con más de 15 minutos de antigüedad.'
    );
END;
/

PROMPT Implementación 06 finalizada. El job ha sido creado/actualizado.

