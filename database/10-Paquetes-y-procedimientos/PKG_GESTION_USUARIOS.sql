-- ============================================================
-- Script: PKG_GESTION_USUARIOS.sql
-- Descripción: Especificación del paquete para gestión de usuarios.
-- Define las funciones y procedimientos disponibles públicamente.
-- ============================================================
CREATE OR REPLACE PACKAGE PKG_GESTION_USUARIOS AS

  ---------------------------------------------------------------------
  -- 1. Listar usuarios con filtros opcionales y paginación
  ---------------------------------------------------------------------
  FUNCTION FN_LISTAR_USUARIOS(
    p_tipo_usuario IN VARCHAR2 DEFAULT NULL, -- ESTUDIANTE, CATEDRATICO, ADMIN
    p_estado       IN CHAR DEFAULT 'A',      -- A = activo, I = inactivo
    p_offset       IN NUMBER DEFAULT 0,
    p_limit        IN NUMBER DEFAULT 10
  ) RETURN CLOB;

  ---------------------------------------------------------------------
  -- 2. Obtener un usuario por ID
  ---------------------------------------------------------------------
  FUNCTION FN_OBTENER_USUARIO(
    p_id_usuario IN NUMBER
  ) RETURN CLOB;

  ---------------------------------------------------------------------
  -- 3. Actualizar datos de usuario (sin contraseña)
  ---------------------------------------------------------------------
  PROCEDURE PRC_ACTUALIZAR_USUARIO(
    p_id_usuario     IN NUMBER,
    p_nombre_usuario IN VARCHAR2,
    p_tipo_usuario   IN VARCHAR2,
    p_resultado      OUT VARCHAR2,
    p_detalle        OUT VARCHAR2
  );

  ---------------------------------------------------------------------
  -- 4. Cambiar estado de usuario (activar/inactivar)
  ---------------------------------------------------------------------
  PROCEDURE PRC_CAMBIAR_ESTADO_USUARIO(
    p_id_usuario IN NUMBER,
    p_estado     IN CHAR, -- A = activo, I = inactivo
    p_resultado OUT VARCHAR2,
    p_detalle   OUT VARCHAR2
  );

  ---------------------------------------------------------------------
  -- 5. Baja lógica de usuario (soft delete)
  ---------------------------------------------------------------------
  PROCEDURE PRC_ELIMINAR_USUARIO(
    p_id_usuario IN NUMBER,
    p_resultado OUT VARCHAR2,
    p_detalle   OUT VARCHAR2
  );

END PKG_GESTION_USUARIOS;
/
