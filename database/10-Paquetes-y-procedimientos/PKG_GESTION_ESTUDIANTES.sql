CREATE OR REPLACE PACKAGE PKG_GESTION_ESTUDIANTES AS

  -- 1. Listado de estudiantes (con filtros y paginación)
  FUNCTION FN_LISTAR_ESTUDIANTES(
    p_id_carrera IN NUMBER DEFAULT NULL,
    p_estado     IN CHAR DEFAULT 'A',
    p_offset     IN NUMBER DEFAULT 0,
    p_limit      IN NUMBER DEFAULT 50
  ) RETURN CLOB;

  -- 2. Obtener estudiante por ID
  FUNCTION FN_OBTENER_ESTUDIANTE(
    p_id_estudiante IN NUMBER
  ) RETURN CLOB;

  -- 3. Actualizar datos de estudiante
  PROCEDURE PRC_ACTUALIZAR_ESTUDIANTE(
    p_id_estudiante IN NUMBER,
    p_nombres       IN VARCHAR2,
    p_apellidos     IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_id_carrera    IN NUMBER,
    p_resultado     OUT VARCHAR2,
    p_detalle       OUT VARCHAR2
  );

  -- 4. Cambiar estado (activar/inactivar)
  PROCEDURE PRC_CAMBIAR_ESTADO_ESTUDIANTE(
    p_id_estudiante IN NUMBER,
    p_estado        IN CHAR, -- 'A' activo, 'I' inactivo
    p_resultado     OUT VARCHAR2,
    p_detalle       OUT VARCHAR2
  );

  -- 5. Baja lógica (soft delete)
  PROCEDURE PRC_ELIMINAR_ESTUDIANTE(
    p_id_estudiante IN NUMBER,
    p_resultado     OUT VARCHAR2,
    p_detalle       OUT VARCHAR2
  );

END PKG_GESTION_ESTUDIANTES;
/
