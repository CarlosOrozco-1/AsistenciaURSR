-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 07: Validación del Procedimiento de Registro de Estudiantes
-- --------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

PROMPT [TEST-7] Probando el procedimiento de registro de estudiantes...

DECLARE
    v_id_carrera NUMBER;
    v_resultado  VARCHAR2(10);
    v_detalle    VARCHAR2(500);
BEGIN
    -- Obtenemos el ID de una carrera para la prueba
    SELECT ID_CARRERA INTO v_id_carrera FROM CARRERAS WHERE NOMBRE_CARRERA = 'Psicología';

    -- PRUEBA 1: Registro exitoso
    DBMS_OUTPUT.PUT_LINE('-> Prueba 1: Intentando un registro exitoso...');
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

    -- PRUEBA 2: Intento de registro con email duplicado (debe fallar)
    DBMS_OUTPUT.PUT_LINE('-> Prueba 2: Intentando registrar con email duplicado (debe fallar)...');
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

    -- PRUEBA 3: Intento de registro con carnet duplicado (debe fallar)
    DBMS_OUTPUT.PUT_LINE('-> Prueba 3: Intentando registrar con carnet duplicado (debe fallar)...');
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

PROMPT
PROMPT Verificación final:
PROMPT SELECT e.NOMBRES, e.APELLIDOS, u.NOMBRE_USUARIO, u.TIPO_USUARIO FROM ESTUDIANTES e JOIN USUARIOS u ON e.ID_ESTUDIANTE = u.ID_ESTUDIANTE_FK WHERE e.NUMERO_CARNET = '202599001';

