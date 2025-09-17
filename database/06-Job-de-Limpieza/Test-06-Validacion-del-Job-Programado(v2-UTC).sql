-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 06: Validación de la Tarea Programada
-- -- Versión: 2.0 (Corregido para ser inmune a zonas horarias usando UTC)
-- --------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT [TEST-6] Preparando escenario para validar el job de limpieza...

-- 1. Crear un QR de prueba "antiguo" que debería ser desactivado por el job.
DECLARE
    v_id_curso_impartido NUMBER;
BEGIN
    -- Limpiar cualquier QR de prueba anterior para un test limpio
    DELETE FROM SESIONES_CLASE_QR WHERE CODIGO_QR = 'QR-TEST-ANTIGUO-12345';
    COMMIT;

    -- Tomamos cualquier curso impartido como ejemplo
    SELECT ID_CURSO_IMPARTIDO INTO v_id_curso_impartido FROM CURSOS_IMPARTIDOS WHERE ROWNUM = 1;

    -- Creamos un QR con una fecha de creación de hace 9 horas en formato UTC
    INSERT INTO SESIONES_CLASE_QR (ID_CURSO_IMPARTIDO_FK, CODIGO_QR, FECHA_CREACION, ESTADO)
    VALUES (v_id_curso_impartido, 'QR-TEST-ANTIGUO-12345', (SYS_EXTRACT_UTC(SYSTIMESTAMP) - INTERVAL '9' HOUR), 'A');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('-> Se ha creado un QR de prueba antiguo con ESTADO = ''A'' y fecha en UTC.');
END;
/

-- 2. Consultas de Monitoreo
PROMPT
PROMPT --- INSTRUCCIONES DE VALIDACIÓN ---
PROMPT
PROMPT 1. Verifique que el QR de prueba existe y está activo:
PROMPT    SELECT CODIGO_QR, ESTADO, FECHA_CREACION FROM SESIONES_CLASE_QR WHERE CODIGO_QR = 'QR-TEST-ANTIGUO-12345';
PROMPT
PROMPT 2. Verifique que el job está programado correctamente:
PROMPT    SELECT JOB_NAME, ENABLED, REPEAT_INTERVAL FROM USER_SCHEDULER_JOBS WHERE JOB_NAME = 'JOB_LIMPIEZA_QRS_HORARIA';
PROMPT
PROMPT 3. (OPCIONAL) Vea el log de ejecución del job (puede estar vacío al principio):
PROMPT    SELECT LOG_DATE, STATUS FROM USER_SCHEDULER_JOB_LOG WHERE JOB_NAME = 'JOB_LIMPIEZA_QRS_HORARIA' ORDER BY LOG_DATE DESC;
PROMPT
PROMPT 4. **ESPERE UNOS MINUTOS** para que el scheduler ejecute el job.
PROMPT
PROMPT 5. Vuelva a ejecutar la consulta del paso 1. El ESTADO del QR debería haber cambiado a 'I'.
PROMPT    Si el estado ha cambiado, la prueba ha sido un ÉXITO.
PROMPT
PROMPT 6. (OPCIONAL) Cuando termine, puede eliminar el job de prueba con:
PROMPT    -- EXEC DBMS_SCHEDULER.DROP_JOB('JOB_LIMPIEZA_QRS_HORARIA');
PROMPT

