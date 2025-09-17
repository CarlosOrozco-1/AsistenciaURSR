-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 03b: Modificación de Paquete y Otorgamiento de Permisos
-- -- Versión: 2.0 (Incluye permisos para ROL_ADMINISTRATIVO)
-- --
-- -- IMPORTANTE: Este script debe ser ejecutado por el dueño de los objetos (app_prueba).
-- --------------------------------------------------------------------------------

PROMPT Modificando el paquete PKG_ASISTENCIA para incluir la creación de sesiones QR...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: ACTUALIZACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE
-- --------------------------------------------------------------------------------
-- Añadimos el nuevo procedimiento a la parte pública del paquete.
CREATE OR REPLACE PACKAGE PKG_ASISTENCIA AS

    PROCEDURE registrar_asistencia (
        p_codigo_qr           IN VARCHAR2,
        p_numero_carnet       IN VARCHAR2,
        p_tipo_registro       IN VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    );

    /**
     * Crea una nueva sesión de clase y genera un código QR único para ella.
     * @param p_id_curso_impartido El ID del curso para el cual se crea la sesión.
     * @param p_codigo_qr_generado Devuelve el código QR único que se generó.
     * @param p_resultado          Devuelve 'EXITO' o 'ERROR'.
     * @param p_detalle            Devuelve un mensaje descriptivo del resultado.
     */
    PROCEDURE crear_sesion_qr (
        p_id_curso_impartido  IN NUMBER,
        p_codigo_qr_generado  OUT VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    );

END PKG_ASISTENCIA;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: ACTUALIZACIÓN DEL CUERPO DEL PAQUETE
-- --------------------------------------------------------------------------------
-- Añadimos la lógica del nuevo procedimiento al cuerpo del paquete.
CREATE OR REPLACE PACKAGE BODY PKG_ASISTENCIA AS

    PROCEDURE registrar_asistencia (
        p_codigo_qr           IN VARCHAR2,
        p_numero_carnet       IN VARCHAR2,
        p_tipo_registro       IN VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    ) AS
        -- La lógica existente no cambia
        v_id_estudiante         NUMBER;
        v_id_curso_impartido    NUMBER;
        v_id_inscripcion        NUMBER;
        v_conteo_entrada        NUMBER;
        v_conteo_salida         NUMBER;
    BEGIN
        -- ... (La lógica que ya validamos sigue aquí, sin cambios) ...
        -- 1. Validar el código QR y obtener el curso impartido
        BEGIN
            SELECT ID_CURSO_IMPARTIDO_FK INTO v_id_curso_impartido
            FROM SESIONES_CLASE_QR
            WHERE CODIGO_QR = p_codigo_qr AND ESTADO = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_resultado := 'ERROR';
                p_detalle := 'Código QR inválido o expirado.';
                RETURN;
        END;

        -- 2. Obtener ID del estudiante
        BEGIN
            SELECT ID_ESTUDIANTE INTO v_id_estudiante FROM ESTUDIANTES WHERE NUMERO_CARNET = p_numero_carnet;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_resultado := 'ERROR';
                p_detalle := 'Número de carnet no encontrado.';
                RETURN;
        END;

        -- 3. Obtener ID de la inscripción
        BEGIN
            SELECT ID_INSCRIPCION INTO v_id_inscripcion
            FROM INSCRIPCIONES
            WHERE ID_ESTUDIANTE_FK = v_id_estudiante
              AND ID_CURSO_IMPARTIDO_FK = v_id_curso_impartido;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_resultado := 'ERROR';
                p_detalle := 'El estudiante no está inscrito en este curso.';
                RETURN;
        END;

        -- 4. Aplicar lógica de Entrada/Salida
        SELECT COUNT(*) INTO v_conteo_entrada
        FROM REGISTROS_ASISTENCIA
        WHERE ID_INSCRIPCION_FK = v_id_inscripcion
          AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(SYSDATE)
          AND TIPO_REGISTRO = 'ENTRADA';

        SELECT COUNT(*) INTO v_conteo_salida
        FROM REGISTROS_ASISTENCIA
        WHERE ID_INSCRIPCION_FK = v_id_inscripcion
          AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(SYSDATE)
          AND TIPO_REGISTRO = 'SALIDA';

        IF p_tipo_registro = 'ENTRADA' THEN
            IF v_conteo_entrada > 0 THEN
                p_resultado := 'AVISO';
                p_detalle := 'La entrada ya fue registrada para hoy.';
                RETURN;
            END IF;
        ELSIF p_tipo_registro = 'SALIDA' THEN
            IF v_conteo_entrada = 0 THEN
                p_resultado := 'ERROR';
                p_detalle := 'Debe registrar una entrada antes de registrar una salida.';
                RETURN;
            END IF;
            IF v_conteo_salida > 0 THEN
                p_resultado := 'AVISO';
                p_detalle := 'La salida ya fue registrada para hoy.';
                RETURN;
            END IF;
        ELSE
            p_resultado := 'ERROR';
            p_detalle := 'Tipo de registro inválido.';
            RETURN;
        END IF;

        -- 5. Insertar el registro
        INSERT INTO REGISTROS_ASISTENCIA (ID_INSCRIPCION_FK, TIPO_REGISTRO)
        VALUES (v_id_inscripcion, p_tipo_registro);

        COMMIT;
        p_resultado := 'EXITO';
        p_detalle := 'Registro de ' || p_tipo_registro || ' guardado correctamente.';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_resultado := 'ERROR';
            p_detalle := 'Ocurrió un error inesperado: ' || SQLERRM;
    END registrar_asistencia;


    -- NUEVO PROCEDIMIENTO AÑADIDO
    PROCEDURE crear_sesion_qr (
        p_id_curso_impartido  IN NUMBER,
        p_codigo_qr_generado  OUT VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    ) AS
        v_nuevo_codigo_qr VARCHAR2(255);
    BEGIN
        -- Generamos un código único. Usamos el ID del curso y la fecha/hora exacta.
        v_nuevo_codigo_qr := 'SGAE-QR-' || p_id_curso_impartido || '-' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF');

        INSERT INTO SESIONES_CLASE_QR (ID_CURSO_IMPARTIDO_FK, CODIGO_QR)
        VALUES (p_id_curso_impartido, v_nuevo_codigo_qr);

        COMMIT;

        p_codigo_qr_generado := v_nuevo_codigo_qr;
        p_resultado := 'EXITO';
        p_detalle := 'Sesión de clase y código QR creados exitosamente.';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_resultado := 'ERROR';
            p_detalle := 'No se pudo crear la sesión de clase: ' || SQLERRM;
            p_codigo_qr_generado := NULL;
    END crear_sesion_qr;

END PKG_ASISTENCIA;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: OTORGAMIENTO DE PERMISOS A LOS ROLES
-- --------------------------------------------------------------------------------
PROMPT Otorgando permisos a los roles...

-- Permisos para ROL_ESTUDIANTE (Solo puede ejecutar la acción de registrar asistencia)
PROMPT -> Permisos para ROL_ESTUDIANTE...
GRANT EXECUTE ON PKG_ASISTENCIA TO ROL_ESTUDIANTE;

-- Permisos para ROL_CATEDRATICO (Puede ejecutar ambas acciones del paquete y ver el reporte)
PROMPT -> Permisos para ROL_CATEDRATICO...
GRANT EXECUTE ON PKG_ASISTENCIA TO ROL_CATEDRATICO;
GRANT SELECT ON V_REPORTE_ASISTENCIA_DIARIA TO ROL_CATEDRATICO;

-- **NUEVO** Permisos para ROL_ADMINISTRATIVO (Solo lectura de reportes y tablas de auditoría)
PROMPT -> Permisos para ROL_ADMINISTRATIVO...
GRANT SELECT ON V_REPORTE_ASISTENCIA_DIARIA TO ROL_ADMINISTRATIVO;
GRANT SELECT ON ESTUDIANTES TO ROL_ADMINISTRATIVO;
GRANT SELECT ON CATEDRATICOS TO ROL_ADMINISTRATIVO;
GRANT SELECT ON CURSOS_IMPARTIDOS TO ROL_ADMINISTRATIVO;
GRANT SELECT ON REGISTROS_ASISTENCIA TO ROL_ADMINISTRATIVO;
GRANT SELECT ON AUDITORIA TO ROL_ADMINISTRATIVO;

PROMPT Implementación 03 finalizada. Los roles ahora tienen sus permisos asignados.

