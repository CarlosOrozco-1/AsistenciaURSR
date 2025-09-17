-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 06: Tareas Programadas (Jobs) con DBMS_SCHEDULER
-- --
-- -- Descripción: Este script crea una tarea de mantenimiento automatizada.
-- -- 1. Crea un procedimiento que desactiva los códigos QR antiguos.
-- -- 2. Crea un "Job" que ejecuta ese procedimiento cada hora.
-- --------------------------------------------------------------------------------

PROMPT Creando la tarea programada para la limpieza de códigos QR...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DEL PROCEDIMIENTO DE LIMPIEZA
-- --------------------------------------------------------------------------------
-- Es una buena práctica encapsular la lógica del job en un procedimiento.
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_QRS_ANTIGUOS AS
    -- Define la antigüedad máxima de un QR en horas.
    v_horas_expiracion CONSTANT NUMBER := 8;
BEGIN
    UPDATE SESIONES_CLASE_QR
    SET ESTADO = 'I' -- 'I' de Inactivo
    WHERE ESTADO = 'A'
      AND FECHA_CREACION < (SYSTIMESTAMP - INTERVAL '8' HOUR);

    -- Opcional: Registrar en la auditoría que el job se ejecutó.
    -- SP_AUDITAR_TABLA('SISTEMA', 'JOB_EXEC', NULL, NULL, 'Job de limpieza de QR ejecutado', 'SISTEMA');
    COMMIT;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN Y PROGRAMACIÓN DEL JOB
-- --------------------------------------------------------------------------------
-- Usamos un bloque anónimo para poder eliminar el job si ya existe.
BEGIN
    -- Intentar eliminar el job si ya existe para permitir re-ejecución
    DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_LIMPIEZA_QRS_HORARIA', force => TRUE);
EXCEPTION
    -- Ignorar el error si el job no existe (es el comportamiento esperado la primera vez)
    WHEN OTHERS THEN
        IF SQLCODE = -27475 THEN
            NULL;
        ELSE
            RAISE;
        END IF;
END;
/

-- Crear el job
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'JOB_LIMPIEZA_QRS_HORARIA',
       job_type             => 'PLSQL_BLOCK',
       job_action           => 'BEGIN SP_DESACTIVAR_QRS_ANTIGUOS; END;',
       start_date           => SYSTIMESTAMP,
       repeat_interval      => 'FREQ=HOURLY; INTERVAL=1', -- Se ejecuta cada hora
       enabled              => TRUE,
       comments             => 'Job que desactiva los códigos QR de sesiones de clase que tienen más de 8 horas de antigüedad.'
    );
END;
/

PROMPT Implementación 06 finalizada. El job 'JOB_LIMPIEZA_QRS_HORARIA' ha sido creado y programado.



-- en esta ejecución se tuvo el erro por privilegios, se concedio privilegios de GRANT CREATE JOB TO app_prueba; COMMIT; 
-- para poder ejecutar el script (este proceso se debe ejecutar en el usuario SYSTEM o DBA.
