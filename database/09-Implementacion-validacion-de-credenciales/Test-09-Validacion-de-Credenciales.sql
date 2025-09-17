-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 09: Validación de la Función de Login
-- --------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

PROMPT [TEST-9] Probando la función de validación de credenciales...

DECLARE
    v_json_resultado CLOB;
BEGIN
    -- PRUEBA 1: Login exitoso de un estudiante
    DBMS_OUTPUT.PUT_LINE('-> Prueba 1: Login exitoso para "laura.gomez@correo.com"...');
    v_json_resultado := PKG_USUARIOS.FN_VALIDAR_CREDENCIALES(
        p_nombre_usuario  => 'laura.gomez@correo.com',
        p_contrasena_hash => 'hash_de_contraseña_segura_generado_por_backend'
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || NVL(v_json_resultado, 'NULL (Login incorrecto)'));
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- PRUEBA 2: Login con contraseña incorrecta (debe fallar)
    DBMS_OUTPUT.PUT_LINE('-> Prueba 2: Login con contraseña incorrecta...');
    v_json_resultado := PKG_USUARIOS.FN_VALIDAR_CREDENCIALES(
        p_nombre_usuario  => 'laura.gomez@correo.com',
        p_contrasena_hash => 'contraseña_incorrecta'
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || NVL(v_json_resultado, 'NULL (Login incorrecto)'));
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

    -- PRUEBA 3: Login con usuario inexistente (debe fallar)
    DBMS_OUTPUT.PUT_LINE('-> Prueba 3: Login con usuario inexistente...');
    v_json_resultado := PKG_USUARIOS.FN_VALIDAR_CREDENCIALES(
        p_nombre_usuario  => 'no.existe@correo.com',
        p_contrasena_hash => 'cualquier_cosa'
    );
    DBMS_OUTPUT.PUT_LINE('   Resultado: ' || NVL(v_json_resultado, 'NULL (Login incorrecto)'));
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
END;
/
