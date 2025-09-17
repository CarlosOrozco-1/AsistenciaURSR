-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 04: Generación de JSON Nativa
-- --
-- -- Descripción: Este script crea un nuevo paquete (PKG_CONSULTAS) para
-- -- centralizar las funciones de solo lectura. Se implementa una función que
-- -- utiliza las capacidades nativas de Oracle para convertir un conjunto de
-- -- filas en un documento JSON, minimizando la lógica en el backend.
-- --------------------------------------------------------------------------------

PROMPT Creando el paquete de consultas y la función de generación de JSON...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE PKG_CONSULTAS
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_CONSULTAS AS

    /**
     * Devuelve un array JSON con los estudiantes de una carrera específica.
     * @param p_id_carrera El ID de la carrera a consultar.
     * @return CLOB       Un CLOB que contiene el string del array JSON.
     */
    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(
        p_id_carrera IN NUMBER
    ) RETURN CLOB;

END PKG_CONSULTAS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN DEL CUERPO DEL PAQUETE PKG_CONSULTAS
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_CONSULTAS AS

    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(
        p_id_carrera IN NUMBER
    ) RETURN CLOB
    AS
        v_json_clob CLOB;
    BEGIN
        -- Esta es la consulta clave. Oracle se encarga de todo el trabajo.
        SELECT
            -- JSON_ARRAYAGG agrupa todas las filas resultantes en un único array JSON.
            JSON_ARRAYAGG(
                -- JSON_OBJECT convierte cada fila en un objeto JSON,
                -- mapeando nombres de clave ('id', 'carnet') a valores de columna.
                JSON_OBJECT(
                    'id'        VALUE e.ID_ESTUDIANTE,
                    'carnet'    VALUE e.NUMERO_CARNET,
                    'nombres'   VALUE e.NOMBRES,
                    'apellidos' VALUE e.APELLIDOS,
                    'email'     VALUE e.EMAIL
                )
                ORDER BY e.APELLIDOS, e.NOMBRES -- Opcional: ordenar los resultados dentro del JSON
                RETURNING CLOB -- Asegura que el resultado sea un CLOB
            )
        INTO v_json_clob
        FROM ESTUDIANTES e
        WHERE e.ID_CARRERA_FK = p_id_carrera;

        -- Si no se encontraron estudiantes, la consulta devuelve NULL.
        -- Devolvemos un array vacío '[]' para un comportamiento de API consistente.
        RETURN NVL(v_json_clob, '[]');

    END F_GET_ESTUDIANTES_POR_CARRERA_JSON;

END PKG_CONSULTAS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: OTORGAMIENTO DE PERMISOS A LOS ROLES
-- --------------------------------------------------------------------------------
PROMPT Otorgando permisos de ejecución sobre el nuevo paquete...
GRANT EXECUTE ON PKG_CONSULTAS TO ROL_CATEDRATICO;
GRANT EXECUTE ON PKG_CONSULTAS TO ROL_ADMINISTRATIVO;
-- El ROL_ESTUDIANTE no necesita este permiso.

PROMPT Implementación 04 finalizada.
