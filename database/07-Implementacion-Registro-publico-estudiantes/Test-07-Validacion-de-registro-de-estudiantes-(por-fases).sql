-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 07: Validación del Procedimiento de Registro de Estudiantes
-- -- Versión: 2.0 (Estructurado por fases de prueba independientes)
-- --------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

-- --------------------------------------------------------------------------------
-- FASE 0: LIMPIEZA (Ejecutar antes de las pruebas)
-- --------------------------------------------------------------------------------
-- Este bloque elimina el usuario de prueba para asegurar que los tests sean repetibles.
PROMPT [FASE 0] Limpiando datos de pruebas anteriores...
DECLARE
    v_id_estudiante_a_borrar NUMBER;
BEGIN
    -- Buscamos el ID del estudiante para poder borrar el usuario asociado
    SELECT ID_ESTUDIANTE INTO v_id_estudiante_a_borrar FROM ESTUDIANTES WHERE NUMERO_CARNET = '202599001';

    -- Borramos el usuario y luego el estudiante
    DELETE FROM USUARIOS WHERE ID_ESTUDIANTE_FK = v_id_estudiante_a_borrar;
    DELETE FROM ESTUDIANTES WHERE ID_ESTUDIANTE = v_id_estudiante_a_borrar;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('-> Datos de prueba de "Laura Gómez" eliminados.');
EXCEPTION
    -- Si el estudiante no existe, no hacemos nada.
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('-> No se encontraron datos de prueba anteriores para limpiar.');
END;
/


-- --------------------------------------------------------------------------------
-- FASE 1: PRUEBA DE REGISTRO EXITOSO
-- --------------------------------------------------------------------------------
PROMPT [FASE 1] Probando un registro exitoso...
DECLARE
    v_id_carrera NUMBER;
    v_resultado  VARCHAR2(10);
    v_detalle    VARCHAR2(500);
BEGIN
    SELECT ID_CARRERA INTO v_id_carrera FROM CARRERAS WHERE NOMBRE_CARRERA = 'Psicología';

    PKG_USUARIOS.crear_cuenta_estudiante(
        p_nombres           => 'Laura',
        p_apellidos         => 'Gómez',
        p_email             => 'laura.gomez@correo.com',
        p_numero_carnet     => '202599001',
        p_id_carrera        => v_id_carrera,
        p_contrasena_hash   => 'hash_de_contraseña_segura_generado_por_backend',
        p_resultado         => v_resultado,
        p_detalle           => v_detalle
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || v_resultado || ' - ' || v_detalle);
END;
/


-- --------------------------------------------------------------------------------
-- FASE 2: PRUEBA DE EMAIL DUPLICADO (DEBE FALLAR)
-- --------------------------------------------------------------------------------
PROMPT [FASE 2] Probando registrar con email duplicado (debe fallar)...
DECLARE
    v_id_carrera NUMBER;
    v_resultado  VARCHAR2(10);
    v_detalle    VARCHAR2(500);
BEGIN
    SELECT ID_CARRERA INTO v_id_carrera FROM CARRERAS WHERE NOMBRE_CARRERA = 'Psicología';

    PKG_USUARIOS.crear_cuenta_estudiante(
        p_nombres           => 'Otra Persona',
        p_apellidos         => 'Apellido',
        p_email             => 'laura.gomez@correo.com', -- Email repetido
        p_numero_carnet     => '202599002',
        p_id_carrera        => v_id_carrera,
        p_contrasena_hash   => 'otro_hash',
        p_resultado         => v_resultado,
        p_detalle           => v_detalle
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || v_resultado || ' - ' || v_detalle);
END;
/


-- --------------------------------------------------------------------------------
-- FASE 3: PRUEBA DE CARNET DUPLICADO (DEBE FALLAR)
-- --------------------------------------------------------------------------------
PROMPT [FASE 3] Probando registrar con carnet duplicado (debe fallar)...
DECLARE
    v_id_carrera NUMBER;
    v_resultado  VARCHAR2(10);
    v_detalle    VARCHAR2(500);
BEGIN
    SELECT ID_CARRERA INTO v_id_carrera FROM CARRERAS WHERE NOMBRE_CARRERA = 'Psicología';

    PKG_USUARIOS.crear_cuenta_estudiante(
        p_nombres           => 'Tercera Persona',
        p_apellidos         => 'Apellido',
        p_email             => 'tercero@correo.com',
        p_numero_carnet     => '202599001', -- Carnet repetido
        p_id_carrera        => v_id_carrera,
        p_contrasena_hash   => 'tercer_hash',
        p_resultado         => v_resultado,
        p_detalle           => v_detalle
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || v_resultado || ' - ' || v_detalle);
END;
/


-- --------------------------------------------------------------------------------
-- FASE 4: VERIFICACIÓN MANUAL
-- --------------------------------------------------------------------------------
PROMPT
PROMPT [FASE 4] Verificación final (ejecutar como sentencia separada):
PROMPT SELECT e.NOMBRES, e.APELLIDOS, u.NOMBRE_USUARIO, u.TIPO_USUARIO FROM ESTUDIANTES e JOIN USUARIOS u ON e.ID_ESTUDIANTE = u.ID_ESTUDIANTE_FK WHERE e.NUMERO_CARNET = '202599001';

