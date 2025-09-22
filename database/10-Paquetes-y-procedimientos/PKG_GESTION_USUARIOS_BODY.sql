-- ============================================================
-- Script: PKG_GESTION_USUARIOS_BODY.sql
-- Descripción: Implementación del paquete PKG_GESTION_USUARIOS.
-- Contiene la lógica de negocio para cada función y procedimiento.
-- ============================================================

CREATE OR REPLACE PACKAGE BODY PKG_GESTION_USUARIOS AS

  ---------------------------------------------------------------------
  -- 1. Listar usuarios con filtros opcionales y paginación
  ---------------------------------------------------------------------
FUNCTION FN_LISTAR_USUARIOS(
  p_tipo_usuario IN VARCHAR2 DEFAULT NULL,
  p_estado       IN CHAR DEFAULT 'A',
  p_offset       IN NUMBER DEFAULT 0,
  p_limit        IN NUMBER DEFAULT 10
) RETURN CLOB IS
  v_json CLOB;
BEGIN
  SELECT JSON_ARRAYAGG(
           JSON_OBJECT(
             KEY 'id_usuario'     VALUE id_usuario,
             KEY 'nombre_usuario' VALUE nombre_usuario,
             KEY 'tipo_usuario'   VALUE tipo_usuario,
             KEY 'estado'         VALUE estado
           ) RETURNING CLOB
         )
    INTO v_json
    FROM (
      SELECT id_usuario, nombre_usuario, tipo_usuario, estado
      FROM usuarios
      WHERE (p_tipo_usuario IS NULL OR tipo_usuario = p_tipo_usuario)
        AND (p_estado IS NULL OR estado = p_estado)
      ORDER BY id_usuario
      OFFSET p_offset ROWS FETCH NEXT p_limit ROWS ONLY
    );

  IF v_json IS NULL THEN
    RETURN to_clob('[]');
  ELSE
    RETURN v_json;
  END IF;
END FN_LISTAR_USUARIOS;
-- realizar prueba de la función
SELECT pkg_gestion_usuarios.fn_listar_usuarios(NULL,'A',0,10) AS RESULTADO FROM DUAL;


  ---------------------------------------------------------------------
  -- 2. Obtener un usuario por ID
  ---------------------------------------------------------------------
  FUNCTION FN_OBTENER_USUARIO(
    p_id_usuario IN NUMBER
  ) RETURN CLOB IS
    v_json CLOB;
  BEGIN
    SELECT JSON_OBJECT(
             KEY 'id_usuario'     VALUE u.id_usuario,
             KEY 'nombre_usuario' VALUE u.nombre_usuario,
             KEY 'tipo_usuario'   VALUE u.tipo_usuario,
             KEY 'estado'         VALUE estado
           RETURNING CLOB)
      INTO v_json
      FROM usuarios u
      WHERE u.id_usuario = p_id_usuario;
    RETURN v_json;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN to_clob('{}');
  END FN_OBTENER_USUARIO;

  ---------------------------------------------------------------------
  -- 3. Actualizar datos de usuario
  ---------------------------------------------------------------------
  PROCEDURE PRC_ACTUALIZAR_USUARIO(
    p_id_usuario     IN NUMBER,
    p_nombre_usuario IN VARCHAR2,
    p_tipo_usuario   IN VARCHAR2,
    p_resultado      OUT VARCHAR2,
    p_detalle        OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE usuarios
    SET nombre_usuario = p_nombre_usuario,
        tipo_usuario   = p_tipo_usuario
    WHERE id_usuario   = p_id_usuario;

    IF SQL%ROWCOUNT = 1 THEN
      p_resultado := 'OK';
      p_detalle   := 'Usuario actualizado correctamente.';
    ELSE
      p_resultado := 'ERROR';
      p_detalle   := 'Usuario no encontrado.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_resultado := 'ERROR';
      p_detalle   := 'Error: ' || SUBSTR(SQLERRM, 1, 200);
  END PRC_ACTUALIZAR_USUARIO;

  ---------------------------------------------------------------------
  -- 4. Cambiar estado de usuario
  ---------------------------------------------------------------------
  PROCEDURE PRC_CAMBIAR_ESTADO_USUARIO(
    p_id_usuario IN NUMBER,
    p_estado     IN CHAR,
    p_resultado  OUT VARCHAR2,
    p_detalle    OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE usuarios
    SET estado = p_estado
    WHERE id_usuario = p_id_usuario;

    IF SQL%ROWCOUNT = 1 THEN
      p_resultado := 'OK';
      IF p_estado = 'A' THEN
        p_detalle := 'Usuario activado correctamente.';
      ELSIF p_estado = 'I' THEN
        p_detalle := 'Usuario inactivado correctamente.';
      ELSE
        p_detalle := 'Estado de usuario actualizado.';
      END IF;
    ELSE
      p_resultado := 'ERROR';
      p_detalle   := 'Usuario no encontrado.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_resultado := 'ERROR';
      p_detalle   := 'Error: ' || SUBSTR(SQLERRM, 1, 200);
  END PRC_CAMBIAR_ESTADO_USUARIO;

  ---------------------------------------------------------------------
  -- 5. Baja lógica de usuario
  ---------------------------------------------------------------------
  PROCEDURE PRC_ELIMINAR_USUARIO(
    p_id_usuario IN NUMBER,
    p_resultado  OUT VARCHAR2,
    p_detalle    OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE usuarios
    SET estado = 'I'
    WHERE id_usuario = p_id_usuario;

    IF SQL%ROWCOUNT = 1 THEN
      p_resultado := 'OK';
      p_detalle   := 'Usuario eliminado correctamente.';
    ELSE
      p_resultado := 'ERROR';
      p_detalle   := 'Usuario no encontrado.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_resultado := 'ERROR';
      p_detalle   := 'Error: ' || SUBSTR(SQLERRM, 1, 200);
  END PRC_ELIMINAR_USUARIO;

END PKG_GESTION_USUARIOS;
/
