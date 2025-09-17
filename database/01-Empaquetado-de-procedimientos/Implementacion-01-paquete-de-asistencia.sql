-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 01: Encapsulación de Lógica en Paquetes
-- --
-- -- Descripción: Este script refactoriza la lógica de negocio existente,
-- -- moviendo el procedimiento SP_REGISTRAR_ASISTENCIA dentro de un paquete
-- -- PL/SQL llamado PKG_ASISTENCIA. Esto mejora la organización, seguridad y
-- -- mantenibilidad del código en la base de datos.
-- --------------------------------------------------------------------------------

PROMPT Iniciando implementación de Paquetes...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: LIMPIEZA DEL PROCEDIMIENTO ANTERIOR
-- --------------------------------------------------------------------------------
PROMPT Eliminando el procedimiento SP_REGISTRAR_ASISTENCIA si existe...
BEGIN
   EXECUTE IMMEDIATE 'DROP PROCEDURE SP_REGISTRAR_ASISTENCIA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4043 THEN
         RAISE;
      END IF;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE (PARTE PÚBLICA)
-- --------------------------------------------------------------------------------
-- Descripción: La especificación es la interfaz pública del paquete.
-- Define los procedimientos y funciones que pueden ser llamados desde fuera.
PROMPT Creando la especificación del paquete PKG_ASISTENCIA...
CREATE OR REPLACE PACKAGE PKG_ASISTENCIA AS

    /**
     * Procesa el registro de asistencia (entrada o salida) de un estudiante.
     * @param p_codigo_qr         El código único de la sesión de clase.
     * @param p_numero_carnet     El carnet del estudiante que se registra.
     * @param p_tipo_registro     Debe ser 'ENTRADA' o 'SALIDA'.
     * @param p_resultado         Devuelve 'EXITO', 'AVISO' o 'ERROR'.
     * @param p_detalle           Devuelve un mensaje descriptivo del resultado.
     */
    PROCEDURE registrar_asistencia (
        p_codigo_qr           IN VARCHAR2,
        p_numero_carnet       IN VARCHAR2,
        p_tipo_registro       IN VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    );

END PKG_ASISTENCIA;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: CREACIÓN DEL CUERPO DEL PAQUETE (LÓGICA PRIVADA)
-- --------------------------------------------------------------------------------
-- Descripción: El cuerpo del paquete contiene la implementación real
-- de los procedimientos y funciones declarados en la especificación.
PROMPT Creando el cuerpo del paquete PKG_ASISTENCIA...
CREATE OR REPLACE PACKAGE BODY PKG_ASISTENCIA AS

    PROCEDURE registrar_asistencia (
        p_codigo_qr           IN VARCHAR2,
        p_numero_carnet       IN VARCHAR2,
        p_tipo_registro       IN VARCHAR2,
        p_resultado           OUT VARCHAR2,
        p_detalle             OUT VARCHAR2
    ) AS
        v_id_estudiante         NUMBER;
        v_id_curso_impartido    NUMBER;
        v_id_inscripcion        NUMBER;
        v_conteo_entrada        NUMBER;
        v_conteo_salida         NUMBER;
    BEGIN
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

END PKG_ASISTENCIA;
/

PROMPT Implementación 01 finalizada. El paquete PKG_ASISTENCIA ha sido creado.
