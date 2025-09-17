-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 02: Trigger de Lógica de Negocio Compleja
-- --
-- -- Descripción: Este script crea un trigger que impone una regla de negocio
-- -- crítica: un estudiante no puede estar inscrito en más de 7 cursos por
-- -- período académico.
-- --------------------------------------------------------------------------------

PROMPT Creando trigger para validar el límite de cursos por estudiante...

CREATE OR REPLACE TRIGGER TRG_BIU_INSCRIPCIONES_MAX_CURSOS
BEFORE INSERT OR UPDATE ON INSCRIPCIONES
FOR EACH ROW
DECLARE
    v_conteo_cursos NUMBER;
    v_id_periodo    NUMBER;
    v_limite_cursos CONSTANT NUMBER := 5; -- Límite definido como constante para la validación del total de cursos al que el estudiante puede estar inscrito
	
BEGIN
    -- Paso 1: Obtener el ID del período académico del curso al que se está intentando inscribir.
    -- La cláusula ':NEW' hace referencia a la fila que se está insertando/actualizando.
    SELECT ci.ID_PERIODO_FK INTO v_id_periodo
    FROM CURSOS_IMPARTIDOS ci
    WHERE ci.ID_CURSO_IMPARTIDO = :NEW.ID_CURSO_IMPARTIDO_FK;

    -- Paso 2: Contar en cuántos cursos ya está inscrito el estudiante DENTRO de ese mismo período.
    SELECT COUNT(*) INTO v_conteo_cursos
    FROM INSCRIPCIONES i
    JOIN CURSOS_IMPARTIDOS ci ON i.ID_CURSO_IMPARTIDO_FK = ci.ID_CURSO_IMPARTIDO
    WHERE i.ID_ESTUDIANTE_FK = :NEW.ID_ESTUDIANTE_FK
      AND ci.ID_PERIODO_FK = v_id_periodo;

    -- Paso 3: Validar la regla de negocio.
    -- Si el conteo ya es igual o mayor al límite, se rechaza la operación.
    IF v_conteo_cursos >= v_limite_cursos THEN
        -- RAISE_APPLICATION_ERROR es la forma profesional de lanzar un error
        -- personalizado desde PL/SQL que puede ser capturado por el backend.
        -- El código de error (-20001) es un estándar para errores de aplicación.
        RAISE_APPLICATION_ERROR(-20001, 'Límite de ' || v_limite_cursos || ' cursos por período académico alcanzado.');
    END IF;

EXCEPTION
    -- Manejo de error por si el curso impartido no existe (aunque una FK lo previene)
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'El curso impartido con ID ' || :NEW.ID_CURSO_IMPARTIDO_FK || ' no existe.');
END;
/

PROMPT Trigger TRG_BIU_INSCRIPCIONES_MAX_CURSOS creado exitosamente.
