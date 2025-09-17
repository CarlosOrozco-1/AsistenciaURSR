-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 09: Función de Validación de Credenciales
-- --
-- -- Descripción: Este script actualiza el paquete PKG_USUARIOS para añadir
-- -- una función de seguridad que centraliza la lógica de validación de login.
-- --------------------------------------------------------------------------------

PROMPT Actualizando el paquete PKG_USUARIOS con una función de validación de credenciales...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: ACTUALIZACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_USUARIOS AS

    -- Procedimiento existente
    PROCEDURE crear_cuenta_estudiante(
        p_nombres           IN VARCHAR2,
        p_apellidos         IN VARCHAR2,
        p_email             IN VARCHAR2,
        p_numero_carnet     IN VARCHAR2,
        p_id_carrera        IN NUMBER,
        p_contrasena_hash   IN VARCHAR2,
        p_resultado         OUT VARCHAR2,
        p_detalle           OUT VARCHAR2
    );

    /**
     * Valida las credenciales de un usuario y devuelve su perfil en formato JSON.
     * @param p_nombre_usuario  El nombre de usuario (email) que intenta iniciar sesión.
     * @param p_contrasena_hash El hash de la contraseña proporcionada.
     * @return CLOB             Un objeto JSON con los datos del usuario si el login es exitoso, o NULL si falla.
     */
    FUNCTION FN_VALIDAR_CREDENCIALES(
        p_nombre_usuario    IN VARCHAR2,
        p_contrasena_hash   IN VARCHAR2
    ) RETURN CLOB;

END PKG_USUARIOS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: ACTUALIZACIÓN DEL CUERPO DEL PAQUETE
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_USUARIOS AS

    -- Procedimiento existente (código omitido por brevedad, no se modifica)
    PROCEDURE crear_cuenta_estudiante(p_nombres IN VARCHAR2, p_apellidos IN VARCHAR2, p_email IN VARCHAR2, p_numero_carnet IN VARCHAR2, p_id_carrera IN NUMBER, p_contrasena_hash IN VARCHAR2, p_resultado OUT VARCHAR2, p_detalle OUT VARCHAR2) AS v_nuevo_id_estudiante NUMBER; BEGIN INSERT INTO ESTUDIANTES (NOMBRES, APELLIDOS, EMAIL, NUMERO_CARNET, ID_Carrera_FK) VALUES (p_nombres, p_apellidos, p_email, p_numero_carnet, p_id_carrera) RETURNING ID_ESTUDIANTE INTO v_nuevo_id_estudiante; INSERT INTO USUARIOS (ID_ESTUDIANTE_FK, NOMBRE_USUARIO, CONTRASENA_HASH, TIPO_USUARIO) VALUES (v_nuevo_id_estudiante, p_email, p_contrasena_hash, 'ESTUDIANTE'); COMMIT; p_resultado := 'EXITO'; p_detalle := 'La cuenta del estudiante ha sido creada exitosamente.'; EXCEPTION WHEN DUP_VAL_ON_INDEX THEN ROLLBACK; p_resultado := 'ERROR'; p_detalle := 'El correo electrónico o el número de carnet ya se encuentran registrados.'; WHEN OTHERS THEN ROLLBACK; p_resultado := 'ERROR'; p_detalle := 'Ocurrió un error inesperado al crear la cuenta: ' || SQLERRM; END crear_cuenta_estudiante;


    -- NUEVA FUNCIÓN AÑADIDA
    FUNCTION FN_VALIDAR_CREDENCIALES(
        p_nombre_usuario    IN VARCHAR2,
        p_contrasena_hash   IN VARCHAR2
    ) RETURN CLOB
    AS
        v_json_perfil CLOB;
    BEGIN
        -- Buscamos un usuario que coincida con el nombre de usuario, la contraseña Y que esté activo.
        SELECT
            JSON_OBJECT(
                'id_usuario'     VALUE u.ID_USUARIO,
                'nombre_usuario' VALUE u.NOMBRE_USUARIO,
                'tipo_usuario'   VALUE u.TIPO_USUARIO,
                -- Añadimos un objeto anidado 'perfil' con los detalles específicos
                'perfil'         VALUE (
                    CASE u.TIPO_USUARIO
                        WHEN 'ESTUDIANTE' THEN (
                            SELECT JSON_OBJECT(
                                'id_estudiante' VALUE e.ID_ESTUDIANTE,
                                'nombres'       VALUE e.NOMBRES,
                                'apellidos'     VALUE e.APELLIDOS,
                                'carnet'        VALUE e.NUMERO_CARNET
                            )
                            FROM ESTUDIANTES e WHERE e.ID_ESTUDIANTE = u.ID_ESTUDIANTE_FK
                        )
                        WHEN 'CATEDRATICO' THEN (
                            SELECT JSON_OBJECT(
                                'id_catedratico' VALUE c.ID_CATEDRATICO,
                                'nombres'        VALUE c.NOMBRES,
                                'apellidos'      VALUE c.APELLIDOS,
                                'codigo_empleado' VALUE c.CODIGO_EMPLEADO
                            )
                            FROM CATEDRATICOS c WHERE c.ID_CATEDRATICO = u.ID_CATEDRATICO_FK
                        )
                        ELSE JSON_OBJECT('rol' VALUE 'ADMIN')
                    END
                )
                RETURNING CLOB
            )
        INTO v_json_perfil
        FROM USUARIOS u
        WHERE u.NOMBRE_USUARIO = p_nombre_usuario
          AND u.CONTRASENA_HASH = p_contrasena_hash
          AND u.ESTADO = 'A';

        -- Si la consulta no encuentra ninguna fila (login incorrecto), devolverá NULL.
        RETURN v_json_perfil;

    EXCEPTION
        -- Si ocurre cualquier otro error, también devolvemos NULL para un fallo seguro.
        WHEN OTHERS THEN
            RETURN NULL;
    END FN_VALIDAR_CREDENCIALES;

END PKG_USUARIOS;
/

PROMPT Implementación 09 finalizada. El paquete PKG_USUARIOS ha sido actualizado.
