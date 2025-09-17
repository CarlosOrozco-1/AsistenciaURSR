-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 04: Validación de la Función de Generación de JSON
-- --
-- -- Descripción: Este script prueba la función F_GET_ESTUDIANTES_POR_CARRERA_JSON
-- -- para asegurar que devuelve un documento JSON válido y bien formado.
-- --------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT [TEST-4] Probando la función de generación de JSON...

DECLARE
    v_id_carrera_sistemas   NUMBER;
    v_json_resultado        CLOB;
BEGIN
    -- 1. Obtener el ID de una carrera de prueba
    SELECT ID_CARRERA INTO v_id_carrera_sistemas
    FROM CARRERAS
    WHERE NOMBRE_CARRERA = 'Ingeniería en Ciencias y Sistemas';

    DBMS_OUTPUT.PUT_LINE('-> Consultando estudiantes para la carrera con ID: ' || v_id_carrera_sistemas);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- 2. Llamar a la función del paquete para generar el JSON
    -- Nos conectamos como app_prueba para la prueba
    v_json_resultado := app_prueba.PKG_CONSULTAS.F_GET_ESTUDIANTES_POR_CARRERA_JSON(
        p_id_carrera => v_id_carrera_sistemas
    );

    -- 3. Imprimir el resultado
    DBMS_OUTPUT.PUT_LINE('Resultado JSON devuelto por la función:');
    DBMS_OUTPUT.PUT_LINE(v_json_resultado);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró la carrera de prueba. Asegúrese de que los seeders se ejecutaron.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/


-- resultado devuelto en la practica
-> Consultando estudiantes para la carrera con ID: 1
----------------------------------------------------
Resultado JSON devuelto por la función:
[
	{"id":2,"carnet":"202420305","nombres":"Luis Miguel","apellidos":"Castillo Solis","email":"lcastillos@correo.com"},
	{"id":1,"carnet":"202510101","nombres":"Ana Sofia","apellidos":"Morales Paz","email":"amoralesp@correo.com"}
]