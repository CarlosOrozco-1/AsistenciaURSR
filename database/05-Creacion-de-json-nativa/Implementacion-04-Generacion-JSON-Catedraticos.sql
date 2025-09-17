-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 05: Reporte de Catedráticos con JSON Anidado
-- --
-- -- Descripción: Este script actualiza el paquete PKG_CONSULTAS para añadir
-- -- una nueva función. Esta función demuestra una técnica más avanzada: generar
-- -- un JSON con objetos que contienen arrays anidados.
-- --------------------------------------------------------------------------------

PROMPT Actualizando el paquete PKG_CONSULTAS con una nueva función de reporte...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: ACTUALIZACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_CONSULTAS AS

    -- Función existente (no se toca)
    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(
        p_id_carrera IN NUMBER
    ) RETURN CLOB;

    /**
     * Devuelve un array JSON con todos los catedráticos y una lista
     * anidada de los cursos que imparten en el período académico activo.
     * @return CLOB Un CLOB que contiene el string del array JSON.
     */
    FUNCTION F_GET_CATEDRATICOS_CON_CURSOS_JSON
    RETURN CLOB;

END PKG_CONSULTAS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: ACTUALIZACIÓN DEL CUERPO DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_CONSULTAS AS

    -- Función existente (no se toca)
    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(
        p_id_carrera IN NUMBER
    ) RETURN CLOB
    AS
        v_json_clob CLOB;
    BEGIN
        SELECT
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'        VALUE e.ID_ESTUDIANTE,
                    'carnet'    VALUE e.NUMERO_CARNET,
                    'nombres'   VALUE e.NOMBRES,
                    'apellidos' VALUE e.APELLIDOS,
                    'email'     VALUE e.EMAIL
                )
                ORDER BY e.APELLIDOS, e.NOMBRES
                RETURNING CLOB
            )
        INTO v_json_clob
        FROM ESTUDIANTES e
        WHERE e.ID_CARRERA_FK = p_id_carrera;
        RETURN NVL(v_json_clob, '[]');
    END F_GET_ESTUDIANTES_POR_CARRERA_JSON;


    -- NUEVA FUNCIÓN AÑADIDA
    FUNCTION F_GET_CATEDRATICOS_CON_CURSOS_JSON
    RETURN CLOB
    AS
        v_json_clob CLOB;
    BEGIN
        -- Esta consulta es más avanzada. Agrupa por catedrático y luego
        -- anida los cursos de cada uno en un sub-array.
        SELECT
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id_catedratico'    VALUE cat.ID_CATEDRATICO,
                    'nombres'           VALUE cat.NOMBRES,
                    'apellidos'         VALUE cat.APELLIDOS,
                    'email'             VALUE cat.EMAIL_INSTITUCIONAL,
                    -- Clave: 'cursos' contendrá el resultado de otra consulta JSON
                    'cursos_impartidos' VALUE (
                        -- Esta subconsulta genera el array de cursos SOLO para el catedrático actual
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id_curso_impartido' VALUE ci.ID_CURSO_IMPARTIDO,
                                'nombre_curso'       VALUE cur.NOMBRE_CURSO,
                                'codigo_curso'       VALUE cur.CODIGO_CURSO,
                                'horario'            VALUE ci.HORARIO,
                                'aula'               VALUE aul.CODIGO_AULA
                            )
                        )
                        FROM CURSOS_IMPARTIDOS ci
                        JOIN CURSOS cur ON ci.ID_CURSO_FK = cur.ID_CURSO
                        JOIN AULAS aul ON ci.ID_AULA_FK = aul.ID_AULA
                        JOIN PERIODOS_ACADEMICOS per ON ci.ID_PERIODO_FK = per.ID_PERIODO
                        WHERE ci.ID_CATEDRATICO_FK = cat.ID_CATEDRATICO
                          AND per.ESTADO = 'A' -- Solo cursos del período activo
                    )
                )
                RETURNING CLOB
            )
        INTO v_json_clob
        FROM CATEDRATICOS cat;

        RETURN NVL(v_json_clob, '[]');

    END F_GET_CATEDRATICOS_CON_CURSOS_JSON;

END PKG_CONSULTAS;
/

PROMPT Implementación 05 finalizada. El paquete PKG_CONSULTAS ha sido actualizado.
