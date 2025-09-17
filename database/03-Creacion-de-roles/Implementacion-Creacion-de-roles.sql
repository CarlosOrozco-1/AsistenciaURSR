-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 03a: Creación de Roles de Base de Datos
-- -- Versión: 2.0 (Incluye Rol Administrativo)
-- --
-- -- IMPORTANTE: Este script debe ser ejecutado por un usuario DBA (SYS o SYSTEM).
-- --------------------------------------------------------------------------------

PROMPT Creando roles de la aplicación SGAE...

-- Eliminar roles si ya existen para permitir la re-ejecución
DECLARE
   role_exists EXCEPTION;
   PRAGMA EXCEPTION_INIT(role_exists, -1921);
BEGIN
   -- Usamos un bucle para simplificar la eliminación
   FOR rec IN (SELECT role FROM dba_roles WHERE role IN ('ROL_ESTUDIANTE', 'ROL_CATEDRATICO', 'ROL_ADMINISTRATIVO')) LOOP
      EXECUTE IMMEDIATE 'DROP ROLE ' || rec.role;
   END LOOP;
EXCEPTION
   WHEN role_exists THEN NULL; -- Ignorar error si el rol no existe
   WHEN OTHERS THEN
        IF SQLCODE = -1921 OR SQLCODE = -1919 THEN
            NULL; -- Ignorar errores comunes de "no existe"
        ELSE
            RAISE;
        END IF;
END;
/

-- Crear los roles vacíos
PROMPT Creando ROL_ESTUDIANTE...
CREATE ROLE ROL_ESTUDIANTE;

PROMPT Creando ROL_CATEDRATICO...
CREATE ROLE ROL_CATEDRATICO;

PROMPT Creando ROL_ADMINISTRATIVO para personal de solo lectura (coordinadores, asistentes)...
CREATE ROLE ROL_ADMINISTRATIVO;

PROMPT Los tres roles han sido creados exitosamente.

