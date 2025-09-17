-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 05: Validación de la Función de Reporte de Catedráticos
-- --------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT [TEST-5] Probando la nueva función de reporte de catedráticos...

DECLARE
    v_json_resultado CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-> Llamando a PKG_CONSULTAS.F_GET_CATEDRATICOS_CON_CURSOS_JSON...');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- Llamar a la nueva función
    v_json_resultado := app_prueba.PKG_CONSULTAS.F_GET_CATEDRATICOS_CON_CURSOS_JSON();

    -- Imprimir el resultado
    DBMS_OUTPUT.PUT_LINE('Resultado JSON anidado devuelto por la función:');
    DBMS_OUTPUT.PUT_LINE(v_json_resultado);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

END;
/


-- Valores devueltos en este ejemplo

-> Llamando a PKG_CONSULTAS.F_GET_CATEDRATICOS_CON_CURSOS_JSON...
----------------------------------------------------
Resultado JSON anidado devuelto por la función:
[
	{"id_catedratico":1,"nombres":"Juan Alberto","apellidos":"Pérez López","email":"jperezl@universidad.edu","cursos_impartidos":
		[
		{"id_curso_impartido":1,"nombre_curso":"Bases de Datos I","codigo_curso":"DB101","horario":"LUN-MIE 07:00-09:00","aula":"T1-101"}
		]},
	{"id_catedratico":2,"nombres":"Maria Fernanda","apellidos":"Gutiérrez Sosa","email":"mgutierrezs@universidad.edu","cursos_impartidos":null},
		{"id_catedratico":3,"nombres":"Carlos David","apellidos":"Mendoza Roca","email":"cmendozar@universidad.edu","cursos_impartidos":null}
]
----------------------------------------------------


