-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Seeder Script 01: Población de Tablas de Catálogo Base
-- --
-- -- Descripción: Este script inserta los datos iniciales y fundamentales
-- -- en las tablas de catálogo que no tienen dependencias externas. Es el
-- -- primer paso obligatorio para poblar la base de datos.
-- --
-- -- IMPORTANTE: Se asume que las tablas ya existen. Este script solo
-- -- ejecuta sentencias INSERT.
-- --------------------------------------------------------------------------------

PROMPT Poblando tablas de catálogo base...

-- Desactivar la salida de '1 row inserted' para un log más limpio
SET FEEDBACK OFF;

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: FACULTADES
-- --------------------------------------------------------------------------------
PROMPT Insertando datos en FACULTADES...
INSERT INTO FACULTADES (NOMBRE_FACULTAD) VALUES ('Facultad de Ingeniería');
INSERT INTO FACULTADES (NOMBRE_FACULTAD) VALUES ('Facultad de Ciencias Económicas');
INSERT INTO FACULTADES (NOMBRE_FACULTAD) VALUES ('Facultad de Humanidades');
INSERT INTO FACULTADES (NOMBRE_FACULTAD) VALUES ('Facultad de Ciencias de la Salud');

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: PERIODOS_ACADEMICOS
-- --------------------------------------------------------------------------------
-- Nota: Usamos TO_DATE para asegurar el formato correcto de las fechas.
PROMPT Insertando datos en PERIODOS_ACADEMICOS...
INSERT INTO PERIODOS_ACADEMICOS (NOMBRE_PERIODO, FECHA_INICIO, FECHA_FIN, ESTADO) VALUES ('SEMESTRE 2-2025', TO_DATE('01-07-2025', 'DD-MM-YYYY'), TO_DATE('30-11-2025', 'DD-MM-YYYY'), 'A');
INSERT INTO PERIODOS_ACADEMICOS (NOMBRE_PERIODO, FECHA_INICIO, FECHA_FIN, ESTADO) VALUES ('SEMESTRE 1-2026', TO_DATE('15-01-2026', 'DD-MM-YYYY'), TO_DATE('31-05-2026', 'DD-MM-YYYY'), 'I');

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: CURSOS
-- --------------------------------------------------------------------------------
PROMPT Insertando datos en CURSOS...
INSERT INTO CURSOS (CODIGO_CURSO, NOMBRE_CURSO, CREDITOS) VALUES ('CS001', 'Introducción a la Programación', 5);
INSERT INTO CURSOS (CODIGO_CURSO, NOMBRE_CURSO, CREDITOS) VALUES ('DB101', 'Bases de Datos I', 4);
INSERT INTO CURSOS (CODIGO_CURSO, NOMBRE_CURSO, CREDITOS) VALUES ('MA201', 'Cálculo II', 5);
INSERT INTO CURSOS (CODIGO_CURSO, NOMBRE_CURSO, CREDITOS) VALUES ('EC100', 'Principios de Microeconomía', 4);
INSERT INTO CURSOS (CODIGO_CURSO, NOMBRE_CURSO, CREDITOS) VALUES ('HU050', 'Filosofía General', 3);

-- --------------------------------------------------------------------------------
-- SECCIÓN 4: AULAS
-- --------------------------------------------------------------------------------
PROMPT Insertando datos en AULAS...
INSERT INTO AULAS (CODIGO_AULA, EDIFICIO, CAPACIDAD) VALUES ('T1-101', 'Edificio T1', 50);
INSERT INTO AULAS (CODIGO_AULA, EDIFICIO, CAPACIDAD) VALUES ('T3-305', 'Edificio T3', 40);
INSERT INTO AULAS (CODIGO_AULA, EDIFICIO, CAPACIDAD) VALUES ('S2-208', 'Edificio S2', 60);
INSERT INTO AULAS (CODIGO_AULA, EDIFICIO, CAPACIDAD) VALUES ('LAB-C1', 'Laboratorios Centrales', 25);

-- --------------------------------------------------------------------------------
-- SECCIÓN 5: SECCIONES
-- --------------------------------------------------------------------------------
PROMPT Insertando datos en SECCIONES...
INSERT INTO SECCIONES (CODIGO_SECCION) VALUES ('A');
INSERT INTO SECCIONES (CODIGO_SECCION) VALUES ('B');
INSERT INTO SECCIONES (CODIGO_SECCION) VALUES ('C');
INSERT INTO SECCIONES (CODIGO_SECCION) VALUES ('UNICA');

-- --------------------------------------------------------------------------------
-- Finalización
-- --------------------------------------------------------------------------------

-- Volver a activar la salida para el commit final
SET FEEDBACK ON;

-- Guardar todos los cambios
COMMIT;

PROMPT Proceso de Seeder 01 finalizado. Las tablas de catálogo base han sido pobladas.
