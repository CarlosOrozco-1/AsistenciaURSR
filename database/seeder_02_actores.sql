-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Seeder Script 02: Población de Actores y Catálogos Dependientes
-- -- Versión: 2.0 (Robusta con manejo de transacciones explícito)
-- --
-- -- Descripción: Versión mejorada que asegura la atomicidad de la transacción.
-- -- O todo se inserta y se guarda (COMMIT), o todo se deshace (ROLLBACK)
-- -- si ocurre cualquier error.
-- --------------------------------------------------------------------------------

PROMPT Poblando tablas de actores y catálogos dependientes...
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;

DECLARE
    -- Variables para almacenar los IDs de las facultades
    v_id_fac_ingenieria     NUMBER;
    v_id_fac_economicas     NUMBER;
    v_id_fac_humanidades    NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando Seeder 02...');
    -- --------------------------------------------------------------------------------
    -- SECCIÓN 1: Obtener IDs de las Facultades (Dependencia)
    -- --------------------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('-> Obteniendo IDs de facultades...');
    SELECT ID_FACULTAD INTO v_id_fac_ingenieria FROM FACULTADES WHERE NOMBRE_FACULTAD = 'Facultad de Ingeniería';
    SELECT ID_FACULTAD INTO v_id_fac_economicas FROM FACULTADES WHERE NOMBRE_FACULTAD = 'Facultad de Ciencias Económicas';
    SELECT ID_FACULTAD INTO v_id_fac_humanidades FROM FACULTADES WHERE NOMBRE_FACULTAD = 'Facultad de Humanidades';
    DBMS_OUTPUT.PUT_LINE('-> IDs de facultades obtenidos correctamente.');

    -- --------------------------------------------------------------------------------
    -- SECCIÓN 2: CARRERAS
    -- --------------------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('-> Insertando datos en CARRERAS...');
    INSERT INTO CARRERAS (ID_FACULTAD_FK, NOMBRE_CARRERA) VALUES (v_id_fac_ingenieria, 'Ingeniería en Ciencias y Sistemas');
    INSERT INTO CARRERAS (ID_FACULTAD_FK, NOMBRE_CARRERA) VALUES (v_id_fac_ingenieria, 'Ingeniería Civil');
    INSERT INTO CARRERAS (ID_FACULTAD_FK, NOMBRE_CARRERA) VALUES (v_id_fac_economicas, 'Administración de Empresas');
    INSERT INTO CARRERAS (ID_FACULTAD_FK, NOMBRE_CARRERA) VALUES (v_id_fac_economicas, 'Auditoría');
    INSERT INTO CARRERAS (ID_FACULTAD_FK, NOMBRE_CARRERA) VALUES (v_id_fac_humanidades, 'Psicología');

    -- --------------------------------------------------------------------------------
    -- SECCIÓN 3: CATEDRATICOS
    -- --------------------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('-> Insertando datos en CATEDRATICOS...');
    INSERT INTO CATEDRATICOS (CODIGO_EMPLEADO, NOMBRES, APELLIDOS, EMAIL_INSTITUCIONAL) VALUES ('EMP001', 'Juan Alberto', 'Pérez López', 'jperezl@universidad.edu');
    INSERT INTO CATEDRATICOS (CODIGO_EMPLEADO, NOMBRES, APELLIDOS, EMAIL_INSTITUCIONAL) VALUES ('EMP002', 'Maria Fernanda', 'Gutiérrez Sosa', 'mgutierrezs@universidad.edu');
    INSERT INTO CATEDRATICOS (CODIGO_EMPLEADO, NOMBRES, APELLIDOS, EMAIL_INSTITUCIONAL) VALUES ('EMP003', 'Carlos David', 'Mendoza Roca', 'cmendozar@universidad.edu');

    -- --------------------------------------------------------------------------------
    -- SECCIÓN 4: ESTUDIANTES (¡Esto activará el trigger de auditoría!)
    -- --------------------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('-> Insertando datos en ESTUDIANTES...');
    DECLARE
        v_id_carrera_sistemas NUMBER;
        v_id_carrera_admon    NUMBER;
    BEGIN
        SELECT ID_CARRERA INTO v_id_carrera_sistemas FROM CARRERAS WHERE NOMBRE_CARRERA = 'Ingeniería en Ciencias y Sistemas';
        SELECT ID_CARRERA INTO v_id_carrera_admon FROM CARRERAS WHERE NOMBRE_CARRERA = 'Administración de Empresas';

        INSERT INTO ESTUDIANTES (ID_CARRERA_FK, NUMERO_CARNET, NOMBRES, APELLIDOS, EMAIL) VALUES (v_id_carrera_sistemas, '202510101', 'Ana Sofia', 'Morales Paz', 'amoralesp@correo.com');
        INSERT INTO ESTUDIANTES (ID_CARRERA_FK, NUMERO_CARNET, NOMBRES, APELLIDOS, EMAIL) VALUES (v_id_carrera_sistemas, '202420305', 'Luis Miguel', 'Castillo Solis', 'lcastillos@correo.com');
        INSERT INTO ESTUDIANTES (ID_CARRERA_FK, NUMERO_CARNET, NOMBRES, APELLIDOS, EMAIL) VALUES (v_id_carrera_admon, '202330890', 'Sofia Alejandra', 'Vargas Luna', 'svargasl@correo.com');
    END;

    -- Si el script llega hasta aquí sin errores, guardamos todos los cambios.
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('-> ¡ÉXITO! Todos los datos han sido insertados y guardados.');
    DBMS_OUTPUT.PUT_LINE('-> Verifique la tabla AUDITORIA para confirmar el funcionamiento del trigger.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK; -- Deshacer cualquier cambio parcial si algo falla.
        DBMS_OUTPUT.PUT_LINE('>> ERROR CRÍTICO: NO_DATA_FOUND <<');
        DBMS_OUTPUT.PUT_LINE('   No se encontró un ID de facultad o carrera requerido.');
        DBMS_OUTPUT.PUT_LINE('   CAUSA PROBABLE: El Seeder 01 no se ejecutó o los nombres no coinciden exactamente.');
        DBMS_OUTPUT.PUT_LINE('   ACCIÓN: Verifique los datos en FACULTADES y CARRERAS. La transacción ha sido revertida (ROLLBACK).');
    WHEN OTHERS THEN
        ROLLBACK; -- Deshacer cualquier cambio parcial si algo falla.
        DBMS_OUTPUT.PUT_LINE('>> ERROR CRÍTICO INESPERADO <<');
        DBMS_OUTPUT.PUT_LINE('   ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('   ACCIÓN: La transacción ha sido revertida (ROLLBACK).');
END;
/

SET FEEDBACK ON;
PROMPT Proceso de Seeder 02 finalizado.

