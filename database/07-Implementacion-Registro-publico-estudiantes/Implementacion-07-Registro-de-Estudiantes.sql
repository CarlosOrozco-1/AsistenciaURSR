-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 07: Lógica para el Registro de Nuevos Estudiantes
-- --
-- -- Descripción: Este script crea un nuevo paquete (PKG_USUARIOS) y un
-- -- procedimiento para manejar la creación de cuentas de estudiantes de forma
-- -- atómica y segura.
-- --------------------------------------------------------------------------------

PROMPT Creando el paquete PKG_USUARIOS y el procedimiento de registro de estudiantes...

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: CREACIÓN DE LA ESPECIFICACIÓN DEL PAQUETE PKG_USUARIOS
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_USUARIOS AS

    /**
     * Crea un nuevo estudiante y su cuenta de usuario asociada.
     * Es una transacción atómica: o se crean ambos registros, o no se crea ninguno.
     * @param p_nombres         Nombres del estudiante.
     * @param p_apellidos       Apellidos del estudiante.
     * @param p_email           Email del estudiante (debe ser único).
     * @param p_numero_carnet   Carnet del estudiante (debe ser único).
     * @param p_id_carrera      ID de la carrera a la que se inscribe.
     * @param p_contrasena_hash Hash de la contraseña (generado por el backend).
     * @param p_resultado       Devuelve 'EXITO' o 'ERROR'.
     * @param p_detalle         Devuelve un mensaje descriptivo.
     */
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

END PKG_USUARIOS;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN DEL CUERPO DEL PAQUETE PKG_USUARIOS
-- --------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_USUARIOS AS

    PROCEDURE crear_cuenta_estudiante(
        p_nombres           IN VARCHAR2,
        p_apellidos         IN VARCHAR2,
        p_email             IN VARCHAR2,
        p_numero_carnet     IN VARCHAR2,
        p_id_carrera        IN NUMBER,
        p_contrasena_hash   IN VARCHAR2,
        p_resultado         OUT VARCHAR2,
        p_detalle           OUT VARCHAR2
    ) AS
        v_nuevo_id_estudiante NUMBER;
    BEGIN
        -- Paso 1: Insertar en la tabla de ESTUDIANTES.
        -- Usamos la cláusula RETURNING para obtener el ID recién creado.
        INSERT INTO ESTUDIANTES (NOMBRES, APELLIDOS, EMAIL, NUMERO_CARNET, ID_CARRERA_FK)
        VALUES (p_nombres, p_apellidos, p_email, p_numero_carnet, p_id_carrera)
        RETURNING ID_ESTUDIANTE INTO v_nuevo_id_estudiante;

        -- Paso 2: Usar el nuevo ID para crear el registro en la tabla de USUARIOS.
        INSERT INTO USUARIOS (ID_ESTUDIANTE_FK, NOMBRE_USUARIO, CONTRASENA_HASH, TIPO_USUARIO)
        VALUES (v_nuevo_id_estudiante, p_email, p_contrasena_hash, 'ESTUDIANTE');

        COMMIT;
        p_resultado := 'EXITO';
        p_detalle := 'La cuenta del estudiante ha sido creada exitosamente.';

    EXCEPTION
        -- Manejo de errores de duplicidad (gracias a nuestras constraints UNIQUE)
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            p_resultado := 'ERROR';
            p_detalle := 'El correo electrónico o el número de carnet ya se encuentran registrados.';
        WHEN OTHERS THEN
            ROLLBACK;
            p_resultado := 'ERROR';
            p_detalle := 'Ocurrió un error inesperado al crear la cuenta: ' || SQLERRM;
    END crear_cuenta_estudiante;

END PKG_USUARIOS;
/

PROMPT Implementación 07 finalizada.
