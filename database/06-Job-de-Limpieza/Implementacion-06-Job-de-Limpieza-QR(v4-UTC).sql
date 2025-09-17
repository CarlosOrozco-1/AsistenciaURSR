-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 06: Tareas Programadas (Jobs) con DBMS_SCHEDULER
-- -- Versión: 4.0 (Lógica de tiempo simplificada y robusta)
-- --------------------------------------------------------------------------------

PROMPT Actualizando la lógica de limpieza de QR a la versión final...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DEL PROCEDIMIENTO DE LIMPIEZA (VERSIÓN SIMPLIFICADA)
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_QRS_ANTIGUOS AS
BEGIN
    UPDATE SESIONES_CLASE_QR
    SET ESTADO = 'I' -- 'I' de Inactivo
    WHERE ESTADO = 'A'
      -- Lógica simplificada: Compara directamente la fecha de creación (tratada como UTC)
      -- con la hora actual del servidor (convertida a UTC) menos el intervalo.
      AND FROM_TZ(FECHA_CREACION, 'UTC') < (SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '8' HOUR);

    COMMIT;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN Y PROGRAMACIÓN DEL JOB
-- --------------------------------------------------------------------------------
-- Este bloque asegura que el job se vuelva a crear apuntando al nuevo procedimiento.
BEGIN
    DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_LIMPIEZA_QRS_HORARIA', force => TRUE);
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -27475 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'JOB_LIMPIEZA_QRS_HORARIA',
       job_type             => 'PLSQL_BLOCK',
       job_action           => 'BEGIN SP_DESACTIVAR_QRS_ANTIGUOS; END;',
       start_date           => SYSTIMESTAMP,
       repeat_interval      => 'FREQ=MINUTELY; INTERVAL=5', -- Lo mantenemos cada 5 mins para la prueba
       enabled              => TRUE,
       comments             => 'Job que desactiva los códigos QR de sesiones de clase que tienen más de 8 horas de antigüedad.'
    );
END;
/

PROMPT Implementación 06 finalizada. El job ha sido actualizado a la versión final.

