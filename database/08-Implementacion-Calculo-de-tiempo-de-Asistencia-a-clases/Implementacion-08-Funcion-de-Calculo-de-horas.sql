-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 08: Función para Cálculos Reutilizables
-- --
-- -- Descripción: Este script actualiza el paquete PKG_CONSULTAS para añadir
-- -- una función que encapsula un cálculo de negocio: el total de minutos
-- -- de asistencia de un estudiante en una clase en un día específico.
-- --------------------------------------------------------------------------------

PROMPT Actualizando el paquete PKG_CONSULTAS con una nueva función de cálculo...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: ACTUALIZACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_CONSULTAS AS

    -- Funciones existentes
    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(p_id_carrera IN NUMBER) RETURN CLOB;
    FUNCTION F_GET_CATEDRATICOS_CON_CURSOS_JSON RETURN CLOB;

    /**
     * Calcula el total de minutos de asistencia para una inscripción en una fecha específica.
     * @param p_id_inscripcion El ID de la inscripción del estudiante en el curso.
     * @param p_fecha          La fecha para la cual se quiere calcular la asistencia.
     * @return NUMBER          El total de minutos de asistencia. Devuelve 0 si no hay entrada/salida.
     */
    FUNCTION FN_CALCULAR_MINUTOS_ASISTENCIA(
        p_id_inscripcion IN NUMBER,
        p_fecha          IN DATE
    ) RETURN NUMBER;

END PKG_CONSULTAS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: ACTUALIZACIÓN DEL CUERPO DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_CONSULTAS AS

    -- Funciones existentes (código omitido por brevedad, no se modifica)
    FUNCTION F_GET_ESTUDIANTES_POR_CARRERA_JSON(p_id_carrera IN NUMBER) RETURN CLOB AS v_json_clob CLOB; BEGIN SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE e.ID_ESTUDIANTE, 'carnet' VALUE e.NUMERO_CARNET, 'nombres' VALUE e.NOMBRES, 'apellidos' VALUE e.APELLIDOS, 'email' VALUE e.EMAIL) ORDER BY e.APELLIDOS, e.NOMBRES RETURNING CLOB) INTO v_json_clob FROM ESTUDIANTES e WHERE e.ID_CARRERA_FK = p_id_carrera; RETURN NVL(v_json_clob, '[]'); END F_GET_ESTUDIANTES_POR_CARRERA_JSON;
    FUNCTION F_GET_CATEDRATICOS_CON_CURSOS_JSON RETURN CLOB AS v_json_clob CLOB; BEGIN SELECT JSON_ARRAYAGG(JSON_OBJECT('id_catedratico' VALUE cat.ID_CATEDRATICO, 'nombres' VALUE cat.NOMBRES, 'apellidos' VALUE cat.APELLIDOS, 'email' VALUE cat.EMAIL_INSTITUCIONAL, 'cursos_impartidos' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id_curso_impartido' VALUE ci.ID_CURSO_IMPARTIDO, 'nombre_curso' VALUE cur.NOMBRE_CURSO, 'codigo_curso' VALUE cur.CODIGO_CURSO, 'horario' VALUE ci.HORARIO, 'aula' VALUE aul.CODIGO_AULA)) FROM CURSOS_IMPARTIDOS ci JOIN CURSOS cur ON ci.ID_CURSO_FK = cur.ID_CURSO JOIN AULAS aul ON ci.ID_AULA_FK = aul.ID_AULA JOIN PERIODOS_ACADEMICOS per ON ci.ID_PERIODO_FK = per.ID_PERIODO WHERE ci.ID_CATEDRATICO_FK = cat.ID_CATEDRATICO AND per.ESTADO = 'A')) RETURNING CLOB) INTO v_json_clob FROM CATEDRATICOS cat; RETURN NVL(v_json_clob, '[]'); END F_GET_CATEDRATICOS_CON_CURSOS_JSON;


    -- NUEVA FUNCIÓN AÑADIDA
    FUNCTION FN_CALCULAR_MINUTOS_ASISTENCIA(
        p_id_inscripcion IN NUMBER,
        p_fecha          IN DATE
    ) RETURN NUMBER
    AS
        v_hora_entrada  TIMESTAMP;
        v_hora_salida   TIMESTAMP;
        v_minutos_total NUMBER;
    BEGIN
        -- Buscar la hora de ENTRADA para la inscripción en la fecha dada
        BEGIN
            SELECT FECHA_HORA_REGISTRO INTO v_hora_entrada
            FROM REGISTROS_ASISTENCIA
            WHERE ID_INSCRIPCION_FK = p_id_inscripcion
              AND TIPO_REGISTRO = 'ENTRADA'
              AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(p_fecha);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_hora_entrada := NULL;
        END;

        -- Buscar la hora de SALIDA para la inscripción en la fecha dada
        BEGIN
            SELECT FECHA_HORA_REGISTRO INTO v_hora_salida
            FROM REGISTROS_ASISTENCIA
            WHERE ID_INSCRIPCION_FK = p_id_inscripcion
              AND TIPO_REGISTRO = 'SALIDA'
              AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(p_fecha);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_hora_salida := NULL;
        END;

        -- Si tenemos tanto la entrada como la salida, calculamos la diferencia
        IF v_hora_entrada IS NOT NULL AND v_hora_salida IS NOT NULL THEN
            -- Restar timestamps devuelve un tipo INTERVAL. Lo extraemos en minutos.
            v_minutos_total :=
                EXTRACT(HOUR FROM (v_hora_salida - v_hora_entrada)) * 60 +
                EXTRACT(MINUTE FROM (v_hora_salida - v_hora_entrada));
        ELSE
            -- Si falta alguno de los dos registros, el tiempo de asistencia es 0
            v_minutos_total := 0;
        END IF;

        RETURN v_minutos_total;

    END FN_CALCULAR_MINUTOS_ASISTENCIA;

END PKG_CONSULTAS;
/

PROMPT Implementación 08 finalizada. El paquete PKG_CONSULTAS ha sido actualizado.
