-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Implementación 03c: Creación de Usuarios de Prueba para Validación de Roles
-- --
-- -- IMPORTANTE: Este script debe ser ejecutado por un usuario DBA (SYS o SYSTEM).
-- --------------------------------------------------------------------------------

PROMPT Creando usuarios de prueba para validar los roles...

-- Usamos un bloque anónimo para manejar la eliminación de usuarios si ya existen
BEGIN
   FOR rec IN (SELECT username FROM dba_users WHERE username IN ('TEST_ESTUDIANTE', 'TEST_CATEDRATICO', 'TEST_ADMIN')) LOOP
      EXECUTE IMMEDIATE 'DROP USER ' || rec.username || ' CASCADE';
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1918 THEN NULL; -- Ignorar error "user does not exist"
      ELSE RAISE;
      END IF;
END;
/

-- Crear los usuarios. Usamos una contraseña simple 'test1234' para pruebas.
PROMPT -> Creando usuario TEST_ESTUDIANTE...
CREATE USER test_estudiante IDENTIFIED BY test1234;

PROMPT -> Creando usuario TEST_CATEDRATICO...
CREATE USER test_catedratico IDENTIFIED BY test1234;

PROMPT -> Creando usuario TEST_ADMIN...
CREATE USER test_admin IDENTIFIED BY test1234;

-- Otorgar el permiso básico para poder conectarse a la base de datos
PROMPT Otorgando permiso de conexión...
GRANT CONNECT TO test_estudiante;
GRANT CONNECT TO test_catedratico;
GRANT CONNECT TO test_admin;

-- Asignar los roles que creamos anteriormente a cada usuario
PROMPT Asignando roles a los usuarios de prueba...
GRANT ROL_ESTUDIANTE TO test_estudiante;
GRANT ROL_CATEDRATICO TO test_catedratico;
GRANT ROL_ADMINISTRATIVO TO test_admin;

PROMPT Implementación 03c finalizada. Los usuarios de prueba han sido creados y tienen sus roles asignados.
