-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 08: Validación de la Función de Cálculo de Minutos
-- --------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

PROMPT [TEST-8] Probando la función de cálculo de minutos de asistencia...

DECLARE
    v_id_inscripcion NUMBER;
    v_minutos_calculados NUMBER;
BEGIN
    -- 1. Preparar el escenario:
    --    - Tomamos la inscripción de "Ana Sofia" en "Bases de Datos I"
    --    - Insertamos un registro de SALIDA para simular una clase completa.
    DBMS_OUTPUT.PUT_LINE('-> Preparando escenario de prueba...');
    SELECT i.ID_INSCRIPCION INTO v_id_inscripcion
    FROM INSCRIPCIONES i
    JOIN ESTUDIANTES e ON i.ID_ESTUDIANTE_FK = e.ID_ESTUDIANTE
    WHERE e.NUMERO_CARNET = '202510101'; -- Ana Sofia

    -- Insertamos una entrada (si no existe) y una salida con 110 minutos de diferencia
    INSERT INTO REGISTROS_ASISTENCIA (ID_INSCRIPCION_FK, TIPO_REGISTRO, FECHA_HORA_REGISTRO)
    SELECT v_id_inscripcion, 'ENTRADA', SYSTIMESTAMP FROM dual
    WHERE NOT EXISTS (SELECT 1 FROM REGISTROS_ASISTENCIA WHERE ID_INSCRIPCION_FK = v_id_inscripcion AND TIPO_REGISTRO = 'ENTRADA' AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(SYSDATE));

    INSERT INTO REGISTROS_ASISTENCIA (ID_INSCRIPCION_FK, TIPO_REGISTRO, FECHA_HORA_REGISTRO)
    VALUES (v_id_inscripcion, 'SALIDA', SYSTIMESTAMP + INTERVAL '110' MINUTE);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('-> Escenario preparado: Se han registrado ENTRADA y SALIDA para la inscripción ' || v_id_inscripcion);


    -- 2. Llamar a la función para realizar el cálculo
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Llamando a PKG_CONSULTAS.FN_CALCULAR_MINUTOS_ASISTENCIA...');

    v_minutos_calculados := PKG_CONSULTAS.FN_CALCULAR_MINUTOS_ASISTENCIA(
        p_id_inscripcion => v_id_inscripcion,
        p_fecha          => SYSDATE
    );

    -- 3. Imprimir el resultado
    DBMS_OUTPUT.PUT_LINE('Resultado del cálculo:');
    DBMS_OUTPUT.PUT_LINE('   -> Total de minutos de asistencia calculados: ' || v_minutos_calculados);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- Limpieza
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('-> Prueba finalizada. Los datos de prueba han sido revertidos (ROLLBACK).');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        ROLLBACK;
END;
/
