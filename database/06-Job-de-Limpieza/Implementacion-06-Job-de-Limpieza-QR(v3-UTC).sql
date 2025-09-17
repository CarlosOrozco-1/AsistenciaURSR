-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 06: Tareas Programadas (Jobs) con DBMS_SCHEDULER
-- -- Versión: 3.0 (Versión final y robusta, explícita con zonas horarias)
-- --------------------------------------------------------------------------------

PROMPT Actualizando la lógica de limpieza de QR a la versión final...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DEL PROCEDIMIENTO DE LIMPIEZA (VERSIÓN FINAL)
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_QRS_ANTIGUOS AS
    -- Obtenemos la hora actual en UTC, asegurando que no haya ambigüedad.
    v_ahora_utc TIMESTAMP WITH TIME ZONE := FROM_TZ(CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS TIMESTAMP), 'UTC');
    v_fecha_corte TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Calculamos la fecha de corte restando el intervalo.
    v_fecha_corte := v_ahora_utc - INTERVAL '8' HOUR;

    UPDATE SESIONES_CLASE_QR
    SET ESTADO = 'I' -- 'I' de Inactivo
    WHERE ESTADO = 'A'
      -- Hacemos una comparación explícita de TIMESTAMP WITH TIME ZONE
      AND CAST(FECHA_CREACION AS TIMESTAMP WITH TIME ZONE) < v_fecha_corte;

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
       repeat_interval      => 'FREQ=MINUTELY; INTERVAL=5', -- CAMBIO: Lo ponemos cada 5 mins para una prueba más rápida
       enabled              => TRUE,
       comments             => 'Job que desactiva los códigos QR de sesiones de clase que tienen más de 8 horas de antigüedad.'
    );
END;
/

PROMPT Implementación 06 finalizada. El job ha sido actualizado a la versión final.

