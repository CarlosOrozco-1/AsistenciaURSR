-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Script de Prueba 02: Validación del Trigger TRG_BIU_INSCRIPCIONES_MAX_CURSOS
-- --
-- -- Descripción: Este script prueba la regla de negocio del límite de cursos.
-- -- 1. Crea 7 cursos de prueba.
-- -- 2. Inscribe a un estudiante en esos 7 cursos.
-- -- 3. Intenta inscribir al estudiante en un 8vo curso, lo que debe fallar.
-- --------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

PROMPT [TEST-2] Iniciando prueba del trigger de límite de cursos...
DECLARE
    v_id_estudiante     NUMBER;
    v_id_catedratico    NUMBER;
    v_id_seccion        NUMBER;
    v_id_periodo        NUMBER;
    v_id_aula           NUMBER;
    v_id_curso_impartido NUMBER;
BEGIN
    -- Obtenemos los IDs necesarios de los datos de nuestros seeders
    SELECT ID_ESTUDIANTE INTO v_id_estudiante FROM ESTUDIANTES WHERE NUMERO_CARNET = '202420305'; -- Estudiante "Luis Miguel"
    SELECT ID_CATEDRATICO INTO v_id_catedratico FROM CATEDRATICOS WHERE CODIGO_EMPLEADO = 'EMP002';
    SELECT ID_SECCION INTO v_id_seccion FROM SECCIONES WHERE CODIGO_SECCION = 'B';
    SELECT ID_PERIODO INTO v_id_periodo FROM PERIODOS_ACADEMICOS WHERE ESTADO = 'A';
    SELECT ID_AULA INTO v_id_aula FROM AULAS WHERE CODIGO_AULA = 'T3-305';

    DBMS_OUTPUT.PUT_LINE('-> Preparando escenario para el estudiante ' || v_id_estudiante || ' en el período ' || v_id_periodo);

    -- 1. Creamos 5 cursos impartidos de prueba e inscribimos al estudiante
    DBMS_OUTPUT.PUT_LINE('-> Inscribiendo al estudiante en 7 cursos...');
    FOR i IN 1..5 LOOP
        -- Creamos un curso de prueba
        INSERT INTO CURSOS_IMPARTIDOS (ID_CURSO_FK, ID_CATEDRATICO_FK, ID_SECCION_FK, ID_PERIODO_FK, ID_AULA_FK, HORARIO)
        VALUES ((SELECT ID_CURSO FROM CURSOS WHERE ROWNUM = 1), v_id_catedratico, v_id_seccion, v_id_periodo, v_id_aula, 'HORARIO_PRUEBA_' || i)
        RETURNING ID_CURSO_IMPARTIDO INTO v_id_curso_impartido;

        -- Inscribimos al estudiante
        INSERT INTO INSCRIPCIONES (ID_ESTUDIANTE_FK, ID_CURSO_IMPARTIDO_FK)
        VALUES (v_id_estudiante, v_id_curso_impartido);
        DBMS_OUTPUT.PUT_LINE('   Inscripción #' || i || ' exitosa.');
    END LOOP;

    -- 2. Intentamos inscribir al estudiante en el 8vo curso
    DBMS_OUTPUT.PUT_LINE('-> Intentando inscribir en el 8vo curso (esta operación debe fallar)...');
    
    -- Creamos el 8vo curso impartido
    INSERT INTO CURSOS_IMPARTIDOS (ID_CURSO_FK, ID_CATEDRATICO_FK, ID_SECCION_FK, ID_PERIODO_FK, ID_AULA_FK, HORARIO)
    VALUES ((SELECT ID_CURSO FROM CURSOS WHERE ROWNUM = 1), v_id_catedratico, v_id_seccion, v_id_periodo, v_id_aula, 'HORARIO_PRUEBA_8')
    RETURNING ID_CURSO_IMPARTIDO INTO v_id_curso_impartido;

    -- Este INSERT debe ser bloqueado por el trigger y lanzar un error ORA-20001
    INSERT INTO INSCRIPCIONES (ID_ESTUDIANTE_FK, ID_CURSO_IMPARTIDO_FK)
    VALUES (v_id_estudiante, v_id_curso_impartido);

    DBMS_OUTPUT.PUT_LINE('>> ATENCIÓN: Si ve este mensaje, el trigger NO funcionó. <<');
    COMMIT; -- Esto no debería ejecutarse si el trigger funciona

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('-> ¡ÉXITO! El trigger ha funcionado correctamente.');
            DBMS_OUTPUT.PUT_LINE('   La base de datos rechazó la 8va inscripción con el error esperado:');
            DBMS_OUTPUT.PUT_LINE('   ' || SQLERRM);
            ROLLBACK; -- Deshacemos la creación del 8vo curso para limpiar
        ELSE
            DBMS_OUTPUT.PUT_LINE('>> ERROR INESPERADO DURANTE LA PRUEBA <<');
            DBMS_OUTPUT.PUT_LINE('   ' || SQLERRM);
            ROLLBACK; -- Deshacer todo si algo más falló
        END IF;
END;
/

-- Limpieza final para no dejar los cursos de prueba
ROLLBACK;
PROMPT Prueba finalizada.
