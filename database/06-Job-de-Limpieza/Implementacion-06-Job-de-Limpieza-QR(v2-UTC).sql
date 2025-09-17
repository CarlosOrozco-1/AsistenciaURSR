-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 06: Tareas Programadas (Jobs) con DBMS_SCHEDULER
-- -- Versión: 2.0 (Corregido para ser inmune a zonas horarias usando UTC)
-- --
-- -- Descripción: Este script crea una tarea de mantenimiento automatizada.
-- -- 1. Crea un procedimiento que desactiva los códigos QR antiguos.
-- -- 2. Crea un "Job" que ejecuta ese procedimiento cada hora.
-- --------------------------------------------------------------------------------

PROMPT Creando la tarea programada para la limpieza de códigos QR...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DEL PROCEDIMIENTO DE LIMPIEZA (VERSIÓN UTC)
-- --------------------------------------------------------------------------------
-- Se modifica el procedimiento para usar SYS_EXTRACT_UTC y evitar problemas de zona horaria.
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_QRS_ANTIGUOS AS
BEGIN
    UPDATE SESIONES_CLASE_QR
    SET ESTADO = 'I' -- 'I' de Inactivo
    WHERE ESTADO = 'A'
      -- La comparación ahora es consistente y universal (UTC vs UTC)
      AND FECHA_CREACION < (SYS_EXTRACT_UTC(SYSTIMESTAMP) - INTERVAL '8' HOUR);

    COMMIT;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN Y PROGRAMACIÓN DEL JOB
-- --------------------------------------------------------------------------------
-- Este bloque no cambia, solo se asegura de que el job exista y esté programado.
BEGIN
    DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_LIMPIEZA_QRS_HORARIA', force => TRUE);
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -27475 THEN
            NULL;
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'JOB_LIMPIEZA_QRS_HORARIA',
       job_type             => 'PLSQL_BLOCK',
       job_action           => 'BEGIN SP_DESACTIVAR_QRS_ANTIGUOS; END;',
       start_date           => SYSTIMESTAMP,
       repeat_interval      => 'FREQ=HOURLY; INTERVAL=1',
       enabled              => TRUE,
       comments             => 'Job que desactiva los códigos QR de sesiones de clase que tienen más de 8 horas de antigüedad.'
    );
END;
/

PROMPT Implementación 06 finalizada. El job 'JOB_LIMPIEZA_QRS_HORARIA' ha sido creado y programado con lógica UTC.

