-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 01: Validación Funcional del Paquete PKG_ASISTENCIA
-- --
-- -- Descripción: Este script realiza una prueba de extremo a extremo para validar
-- -- el procedimiento 'registrar_asistencia'. Primero, crea un escenario de
-- -- prueba completo y luego ejecuta una llamada al procedimiento para simular
-- -- el registro de una 'ENTRADA'.
-- --------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
SET FEEDBACK OFF;

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: PREPARACIÓN DEL ESCENARIO DE PRUEBA
-- --------------------------------------------------------------------------------
-- Descripción: Este bloque crea todos los registros necesarios para simular
-- una clase real lista para recibir asistencia.
PROMPT [TEST-1] Preparando el escenario de prueba...
DECLARE
    v_id_curso              NUMBER;
    v_id_catedratico        NUMBER;
    v_id_seccion            NUMBER;
    v_id_periodo            NUMBER;
    v_id_aula               NUMBER;
    v_id_estudiante         NUMBER;
    v_id_curso_impartido    NUMBER;
    v_id_inscripcion        NUMBER;
BEGIN
    -- Obtener IDs de los datos maestros que creamos con los seeders
    SELECT ID_CURSO INTO v_id_curso FROM CURSOS WHERE CODIGO_CURSO = 'DB101';
    SELECT ID_CATEDRATICO INTO v_id_catedratico FROM CATEDRATICOS WHERE CODIGO_EMPLEADO = 'EMP001';
    SELECT ID_SECCION INTO v_id_seccion FROM SECCIONES WHERE CODIGO_SECCION = 'A';
    SELECT ID_PERIODO INTO v_id_periodo FROM PERIODOS_ACADEMICOS WHERE ESTADO = 'A';
    SELECT ID_AULA INTO v_id_aula FROM AULAS WHERE CODIGO_AULA = 'T1-101';
    SELECT ID_ESTUDIANTE INTO v_id_estudiante FROM ESTUDIANTES WHERE NUMERO_CARNET = '202510101';

    -- 1. Crear el curso impartido: "Bases de Datos I" por "Juan Pérez"
    INSERT INTO CURSOS_IMPARTIDOS (ID_CURSO_FK, ID_CATEDRATICO_FK, ID_SECCION_FK, ID_PERIODO_FK, ID_AULA_FK, HORARIO)
    VALUES (v_id_curso, v_id_catedratico, v_id_seccion, v_id_periodo, v_id_aula, 'LUN-MIE 07:00-09:00')
    RETURNING ID_CURSO_IMPARTIDO INTO v_id_curso_impartido;

    -- 2. Inscribir al estudiante "Ana Sofia" en este curso
    INSERT INTO INSCRIPCIONES (ID_ESTUDIANTE_FK, ID_CURSO_IMPARTIDO_FK)
    VALUES (v_id_estudiante, v_id_curso_impartido)
    RETURNING ID_INSCRIPCION INTO v_id_inscripcion;

    -- 3. Crear una sesión de clase con un código QR conocido para esta prueba
    INSERT INTO SESIONES_CLASE_QR (ID_CURSO_IMPARTIDO_FK, CODIGO_QR)
    VALUES (v_id_curso_impartido, 'QR-TEST-DB101-2025-09-15');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('-> Escenario creado: Estudiante ' || v_id_estudiante || ' inscrito en curso ' || v_id_curso_impartido || ' con QR activo.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en la preparación del escenario: ' || SQLERRM);
        ROLLBACK;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: EJECUCIÓN DE LA PRUEBA
-- --------------------------------------------------------------------------------
-- Descripción: Este bloque simula la acción del estudiante escaneando el QR.
-- Llama al procedimiento dentro de nuestro paquete y muestra los resultados.
PROMPT [TEST-2] Ejecutando la llamada al paquete PKG_ASISTENCIA...
DECLARE
    -- Parámetros de entrada para la prueba
    v_qr_code         VARCHAR2(100) := 'QR-TEST-DB101-2025-09-15';
    v_student_carnet  VARCHAR2(20)  := '202510101';
    v_register_type   VARCHAR2(10)  := 'ENTRADA';

    -- Variables para capturar la salida del procedimiento
    v_resultado       VARCHAR2(10);
    v_detalle         VARCHAR2(255);
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Llamando a PKG_ASISTENCIA.registrar_asistencia con:');
    DBMS_OUTPUT.PUT_LINE('  - Código QR: ' || v_qr_code);
    DBMS_OUTPUT.PUT_LINE('  - Carnet: ' || v_student_carnet);
    DBMS_OUTPUT.PUT_LINE('  - Tipo: ' || v_register_type);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- Ejecutar la lógica de negocio encapsulada en el paquete
    PKG_ASISTENCIA.registrar_asistencia(
        p_codigo_qr     => v_qr_code,
        p_numero_carnet => v_student_carnet,
        p_tipo_registro => v_register_type,
        p_resultado     => v_resultado,
        p_detalle       => v_detalle
    );

    -- Mostrar los resultados
    DBMS_OUTPUT.PUT_LINE('Resultado de la ejecución:');
    DBMS_OUTPUT.PUT_LINE('  - p_resultado: ' || v_resultado);
    DBMS_OUTPUT.PUT_LINE('  - p_detalle:   ' || v_detalle);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: VERIFICACIÓN FINAL
-- --------------------------------------------------------------------------------
PROMPT [TEST-3] Verificación final. Ejecute las siguientes consultas para auditar los resultados:
PROMPT SELECT * FROM REGISTROS_ASISTENCIA ORDER BY ID_REGISTRO DESC;
PROMPT SELECT * FROM AUDITORIA WHERE NOMBRE_TABLA = 'REGISTROS_ASISTENCIA' ORDER BY ID_AUDITORIA DESC;

SET FEEDBACK ON;
