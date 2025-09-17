-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 03: Protocolo de Auditoría de Roles
-- --
-- -- Descripción: Este script contiene las pruebas para validar que cada rol
-- -- tiene exactamente los permisos que necesita y no más.
-- --------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

-- ********************************************************************************
-- PRUEBA 1: CONECTADO COMO test_estudiante
-- ********************************************************************************
PROMPT --- INICIANDO PRUEBAS COMO test_estudiante ---

-- PRUEBA 1.1: Intentar registrar asistencia (DEBE FUNCIONAR)
-- Nota: Usamos el dueño del paquete (app_prueba) para llamar al procedimiento.
PROMPT [Prueba 1.1] Intentando registrar asistencia... (DEBE FUNCIONAR)
DECLARE
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(255);
BEGIN
    app_prueba.PKG_ASISTENCIA.registrar_asistencia(
        p_codigo_qr     => 'QR-TEST-DB101-2025-09-15', -- Usamos el QR de la prueba anterior
        p_numero_carnet => '202420305', -- Estudiante "Luis Miguel"
        p_tipo_registro => 'ENTRADA',
        p_resultado     => v_resultado,
        p_detalle       => v_detalle
    );
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_detalle);
END;
/

/*
En el proceso se valido que el estudiante no esta inscrito en el curso (el codigo QR generado del curso base de datos),
el estudiante Luis Miguel no esta inscrito a este curso por lo cual nos genero el error controlado, dando el mensaje que el estudiante no se encuentra inscrito a este curso
*/

-- PRUEBA 1.2: Intentar ver el reporte de asistencia (DEBE FALLAR)
PROMPT [Prueba 1.2] Intentando ver el reporte de asistencia... (DEBE FALLAR con ORA-00942 o ORA-01031)
SELECT * FROM app_prueba.V_REPORTE_ASISTENCIA_DIARIA;


-- PRUEBA 1.3: Intentar crear una sesión de QR (DEBE FALLAR)
PROMPT [Prueba 1.3] Intentando crear una sesión de QR... (DEBE FALLAR con PLS-00201)
DECLARE
    v_qr VARCHAR2(255);
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(255);
BEGIN
    -- El estudiante no debería tener acceso a este procedimiento del paquete.
    app_prueba.PKG_ASISTENCIA.crear_sesion_qr(1, v_qr, v_resultado, v_detalle);
END;
/


-- ********************************************************************************
-- PRUEBA 2: CONECTADO COMO test_catedratico
-- ********************************************************************************
PROMPT --- INICIANDO PRUEBAS COMO test_catedratico ---

-- PRUEBA 2.1: Intentar ver el reporte de asistencia (DEBE FUNCIONAR)
PROMPT [Prueba 2.1] Intentando ver el reporte de asistencia... (DEBE FUNCIONAR)
SELECT COUNT(*) FROM app_prueba.V_REPORTE_ASISTENCIA_DIARIA;


-- PRUEBA 2.2: Intentar crear una sesión de QR (DEBE FUNCIONAR)
PROMPT [Prueba 2.2] Intentando crear una sesión de QR... (DEBE FUNCIONAR)
DECLARE
    v_qr VARCHAR2(255);
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(255);
    v_id_curso_impartido NUMBER;
BEGIN
    SELECT ID_CURSO_IMPARTIDO INTO v_id_curso_impartido FROM app_prueba.CURSOS_IMPARTIDOS WHERE ROWNUM = 1;
    app_prueba.PKG_ASISTENCIA.crear_sesion_qr(v_id_curso_impartido, v_qr, v_resultado, v_detalle);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_detalle || '. QR Generado: ' || v_qr);
END;
/

-- PRUEBA 2.3: Intentar ver la tabla de auditoría (DEBE FALLAR)
PROMPT [Prueba 2.3] Intentando ver la tabla de auditoría... (DEBE FALLAR con ORA-00942)
SELECT * FROM app_prueba.AUDITORIA;


-- ********************************************************************************
-- PRUEBA 3: CONECTADO COMO test_admin
-- ********************************************************************************
PROMPT --- INICIANDO PRUEBAS COMO test_admin ---

-- PRUEBA 3.1: Intentar ver el reporte de asistencia (DEBE FUNCIONAR)
PROMPT [Prueba 3.1] Intentando ver el reporte de asistencia... (DEBE FUNCIONAR)
SELECT COUNT(*) FROM app_prueba.V_REPORTE_ASISTENCIA_DIARIA;


-- PRUEBA 3.2: Intentar ver la tabla de auditoría (DEBE FUNCIONAR)
PROMPT [Prueba 3.2] Intentando ver la tabla de auditoría... (DEBE FUNCIONAR)
SELECT COUNT(*) FROM app_prueba.AUDITORIA;


-- PRUEBA 3.3: Intentar registrar asistencia (DEBE FALLAR)
PROMPT [Prueba 3.3] Intentando registrar asistencia... (DEBE FALLAR con PLS-00201)
DECLARE
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(255);
BEGIN
    app_prueba.PKG_ASISTENCIA.registrar_asistencia('QR-TEST', 'CARNET-TEST', 'ENTRADA', v_resultado, v_detalle);
END;
/
