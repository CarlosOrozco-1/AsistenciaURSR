-- --------------------------------------------------------------------------------
-- -- Proyecto: Sistema de Gestión de Asistencia Estudiantil (SGAE)
-- -- Versión: 1.1 (Con Módulo de Auditoría)
-- -- Autor: [Su Nombre/Equipo de Desarrollo]
-- -- Fecha de Creación: 28-08-2025
-- -- Motor de BD: Oracle
-- --
-- -- Descripción: Script DDL para la creación de todos los objetos de base de
-- -- datos necesarios para la aplicación SGAE. Incluye tablas, secuencias,
-- -- constraints, índices, vistas, procedimientos almacenados y triggers de auditoría.
-- --------------------------------------------------------------------------------

-- Inicio de la ejecución y creación de un log
SPOOL creacion_bd_sgae.log

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: ELIMINACIÓN DE OBJETOS EXISTENTES (PARA RE-EJECUCIÓN)
-- --------------------------------------------------------------------------------
-- Descripción: Esta sección asegura que el script pueda ser ejecutado múltiples
-- veces sin errores. Elimina todos los objetos en el orden correcto (procedimientos,
-- vistas, tablas y secuencias) para evitar conflictos de dependencias antes de
-- volver a crearlos desde cero. Es una práctica de seguridad para garantizar
-- un entorno limpio en cada ejecución.
PROMPT Eliminando objetos existentes...
DECLARE
    CURSOR c_tablas IS SELECT table_name FROM user_tables;
    CURSOR c_secuencias IS SELECT sequence_name FROM user_sequences;
    CURSOR c_vistas IS SELECT view_name FROM user_views;
    CURSOR c_procedimientos IS SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE';
BEGIN
    FOR rec IN c_procedimientos LOOP
        EXECUTE IMMEDIATE 'DROP PROCEDURE ' || rec.object_name;
    END LOOP;
    FOR rec IN c_vistas LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || rec.view_name;
    END LOOP;
    FOR rec IN c_tablas LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
    FOR rec IN c_secuencias LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
    END LOOP;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: CREACIÓN DE SECUENCIAS
-- --------------------------------------------------------------------------------
-- Descripción: En Oracle, las secuencias son objetos que generan números únicos
-- en un orden determinado. Las usaremos para alimentar las claves primarias (PK)
-- de nuestras tablas, asegurando que cada nueva fila tenga un ID único e irrepetible.
-- Se crea una secuencia por cada tabla que requiera un ID numérico.
PROMPT Creando secuencias para claves primarias...
CREATE SEQUENCE SEQ_USUARIOS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_CATEDRATICOS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_ESTUDIANTES START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_FACULTADES START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_CARRERAS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PERIODOS_ACADEMICOS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_CURSOS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_AULAS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_SECCIONES START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_CURSOS_IMPARTIDOS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_INSCRIPCIONES START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_REGISTROS_ASISTENCIA START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_AUDITORIA_ACCIONES START WITH 1 INCREMENT BY 1 NOCACHE;

-- --------------------------------------------------------------------------------
-- SECCIÓN 3: CREACIÓN DE TABLAS
-- --------------------------------------------------------------------------------
-- Descripción: Aquí se define la estructura de todas las tablas del sistema.
-- Se establecen las columnas, sus tipos de datos y las restricciones a nivel
-- de tabla (PRIMARY KEY, UNIQUE, CHECK). Las relaciones (FOREIGN KEY) se
-- definen por separado en la Sección 4 para mayor claridad.
PROMPT Creando tablas...

-- Tablas de Catálogo
CREATE TABLE FACULTADES (
    ID_FACULTAD         NUMBER NOT NULL,
    NOMBRE_FACULTAD     VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_FACULTADES PRIMARY KEY (ID_FACULTAD),
    CONSTRAINT UQ_FACULTADES_NOMBRE UNIQUE (NOMBRE_FACULTAD)
);

CREATE TABLE CARRERAS (
    ID_CARRERA          NUMBER NOT NULL,
    ID_FACULTAD_FK      NUMBER NOT NULL,
    NOMBRE_CARRERA      VARCHAR2(150) NOT NULL,
    CONSTRAINT PK_CARRERAS PRIMARY KEY (ID_CARRERA),
    CONSTRAINT UQ_CARRERAS_NOMBRE UNIQUE (NOMBRE_CARRERA)
);

CREATE TABLE ESTUDIANTES (
    ID_ESTUDIANTE       NUMBER NOT NULL,
    ID_CARRERA_FK       NUMBER NOT NULL,
    NUMERO_CARNET       VARCHAR2(20) NOT NULL,
    NOMBRES             VARCHAR2(100) NOT NULL,
    APELLIDOS           VARCHAR2(100) NOT NULL,
    EMAIL               VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_ESTUDIANTES PRIMARY KEY (ID_ESTUDIANTE),
    CONSTRAINT UQ_ESTUDIANTES_CARNET UNIQUE (NUMERO_CARNET),
    CONSTRAINT UQ_ESTUDIANTES_EMAIL UNIQUE (EMAIL)
);

CREATE TABLE CATEDRATICOS (
    ID_CATEDRATICOS      NUMBER NOT NULL,
    CODIGO_EMPLEADO     VARCHAR2(20) NOT NULL,
    NOMBRES             VARCHAR2(100) NOT NULL,
    APELLIDOS           VARCHAR2(100) NOT NULL,
    EMAIL_INSTITUCIONAL VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_CATEDRATICOS PRIMARY KEY (ID_CATEDRATICO),
    CONSTRAINT UQ_CATEDRATICOS_CODIGO UNIQUE (CODIGO_EMPLEADO),
    CONSTRAINT UQ_CATEDRATICOS_EMAIL UNIQUE (EMAIL_INSTITUCIONAL)
);

CREATE TABLE USUARIOS (
    ID_USUARIO          NUMBER NOT NULL,
    ID_ESTUDIANTE_FK    NUMBER,
    ID_CATEDRATICO_FK   NUMBER,
    NOMBRE_USUARIO      VARCHAR2(50) NOT NULL,
    CONTRASENA_HASH     VARCHAR2(256) NOT NULL,
    TIPO_USUARIO        CHAR(3) NOT NULL,
    ESTADO              CHAR(1) DEFAULT 'A' NOT NULL,
    FECHA_CREACION      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_USUARIOS PRIMARY KEY (ID_USUARIO),
    CONSTRAINT UQ_USUARIOS_NOMBRE UNIQUE (NOMBRE_USUARIO),
    CONSTRAINT CK_USUARIOS_TIPO CHECK (TIPO_USUARIO IN ('EST', 'CAT', 'ADM')),
    CONSTRAINT CK_USUarios_ESTADO CHECK (ESTADO IN ('A', 'I')),
    CONSTRAINT CK_USUARIOS_FK_EXCLUSIVA CHECK (
        (ID_ESTUDIANTE_FK IS NOT NULL AND ID_CATEDRATICO_FK IS NULL) OR
        (ID_ESTUDIANTe_FK IS NULL AND ID_CATEDRATICO_FK IS NOT NULL) OR
        (ID_ESTUDIANTE_FK IS NULL AND ID_CATEDRATICO_FK IS NULL AND TIPO_USUARIO = 'ADM')
    )
);

CREATE TABLE PERIODOS_ACADEMICOS (
    ID_PERIODO          NUMBER NOT NULL,
    NOMBRE_PERIODO      VARCHAR2(50) NOT NULL,
    FECHA_INICIO        DATE NOT NULL,
    FECHA_FIN           DATE NOT NULL,
    ESTADO              CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_PERIODOS_ACADEMICOS PRIMARY KEY (ID_PERIODO),
    CONSTRAINT UQ_PERIODOS_NOMBRE UNIQUE (NOMBRE_PERIODO),
    CONSTRAINT CK_PERIODOS_ESTADO CHECK (ESTADO IN ('A', 'I', 'C'))
);

CREATE TABLE CURSOS (
    ID_CURSO            NUMBER NOT NULL,
    CODIGO_CURSO        VARCHAR2(15) NOT NULL,
    NOMBRE_CURSO        VARCHAR2(150) NOT NULL,
    CREDITOS            NUMBER(2) NOT NULL,
    CONSTRAINT PK_CURSOS PRIMARY KEY (ID_CURSO),
    CONSTRAINT UQ_CURSOS_CODIGO UNIQUE (CODIGO_CURSO)
);

CREATE TABLE AULAS (
    ID_AULA             NUMBER NOT NULL,
    CODIGO_AULA         VARCHAR2(20) NOT NULL,
    EDIFICIO            VARCHAR2(50),
    CAPACIDAD           NUMBER(3),
    CONSTRAINT PK_AULAS PRIMARY KEY (ID_AULA),
    CONSTRAINT UQ_AULAS_CODIGO UNIQUE (CODIGO_AULA)
);

CREATE TABLE SECCIONES (
    ID_SECCION          NUMBER NOT NULL,
    CODIGO_SECCION      VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_SECCIONES PRIMARY KEY (ID_SECCION),
    CONSTRAINT UQ_SECCIONES_CODIGO UNIQUE (CODIGO_SECCION)
);

-- Tablas Transaccionales
CREATE TABLE CURSOS_IMPARTIDOS (
    ID_CURSO_IMPARTIDO  NUMBER NOT NULL,
    ID_CURSO_FK         NUMBER NOT NULL,
    ID_CATEDRATICO_FK   NUMBER NOT NULL,
    ID_SECCION_FK       NUMBER NOT NULL,
    ID_PERIODO_FK       NUMBER NOT NULL,
    ID_AULA_FK          NUMBER NOT NULL,
    HORARIO             VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_CURSOS_IMPARTIDOS PRIMARY KEY (ID_CURSO_IMPARTIDO)
);

CREATE TABLE INSCRIPCIONES (
    ID_INSCRIPCION          NUMBER NOT NULL,
    ID_ESTUDIANTE_FK        NUMBER NOT NULL,
    ID_CURSO_IMPARTIDO_FK   NUMBER NOT NULL,
    FECHA_PRIMER_REGISTRO   TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_INSCRIPCIONES PRIMARY KEY (ID_INSCRIPCION),
    CONSTRAINT UQ_INSCRIPCION_UNICA UNIQUE (ID_ESTUDIANTE_FK, ID_CURSO_IMPARTIDO_FK)
);

CREATE TABLE REGISTROS_ASISTENCIA (
    ID_REGISTRO             NUMBER NOT NULL,
    ID_INSCRIPCION_FK       NUMBER NOT NULL,
    FECHA_HORA_REGISTRO     TIMESTAMP NOT NULL,
    TIPO_ASISTENCIA         CHAR(1) NOT NULL,
    CONSTRAINT PK_REGISTROS_ASISTENCIA PRIMARY KEY (ID_REGISTRO),
    CONSTRAINT CK_TIPO_ASISTENCIA CHECK (TIPO_ASISTENCIA IN ('P', 'T'))
);

-- Tabla de Auditoría
CREATE TABLE AUDITORIA_ACCIONES (
    ID_AUDITORIA            NUMBER NOT NULL,
    NOMBRE_TABLA            VARCHAR2(30) NOT NULL,
    ID_REGISTRO_AFECTADO    NUMBER,
    TIPO_ACCION             CHAR(1) NOT NULL, -- I: Insert, U: Update, D: Delete
    VALORES_ANTERIORES      CLOB,
    VALORES_NUEVOS          CLOB,
    NOMBRE_USUARIO_BD       VARCHAR2(100) NOT NULL,
    FECHA_ACCION            TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_AUDITORIA_ACCIONES PRIMARY KEY (ID_AUDITORIA),
    CONSTRAINT CK_AUDITORIA_TIPO_ACCION CHECK (TIPO_ACCION IN ('I', 'U', 'D'))
);


-- --------------------------------------------------------------------------------
-- SECCIÓN 4: CREACIÓN DE CONSTRAINTS (FOREIGN KEYS)
-- --------------------------------------------------------------------------------
-- Descripción: Esta sección establece las relaciones lógicas entre las tablas
-- mediante claves foráneas (FOREIGN KEY). Esto garantiza la integridad referencial
-- de la base de datos, lo que significa que no se puede, por ejemplo, crear un
-- estudiante para una carrera que no existe.
PROMPT Creando Foreign Keys...
ALTER TABLE CARRERAS ADD CONSTRAINT FK_CARRERAS_FACULTAD FOREIGN KEY (ID_FACULTAD_FK) REFERENCES FACULTADES(ID_FACULTAD);
ALTER TABLE ESTUDIANTES ADD CONSTRAINT FK_ESTUDIANTES_CARRERA FOREIGN KEY (ID_CARRERA_FK) REFERENCES CARRERAS(ID_CARRERA);
ALTER TABLE USUARIOS ADD CONSTRAINT FK_USUARIOS_ESTUDIANTE FOREIGN KEY (ID_ESTUDIANTE_FK) REFERENCES ESTUDIANTES(ID_ESTUDIANTE);
ALTER TABLE USUARIOS ADD CONSTRAINT FK_USUARIOS_CATEDRATICO FOREIGN KEY (ID_CATEDRATICO_FK) REFERENCES CATEDRATICOS(ID_CATEDRATICO);
ALTER TABLE CURSOS_IMPARTIDOS ADD CONSTRAINT FK_CI_CURSO FOREIGN KEY (ID_CURSO_FK) REFERENCES CURSOS(ID_CURSO);
ALTER TABLE CURSOS_IMPARTIDOS ADD CONSTRAINT FK_CI_CATEDRATICO FOREIGN KEY (ID_CATEDRATICO_FK) REFERENCES CATEDRATICOS(ID_CATEDRATICO);
ALTER TABLE CURSOS_IMPARTIDOS ADD CONSTRAINT FK_CI_SECCION FOREIGN KEY (ID_SECCION_FK) REFERENCES SECCIONES(ID_SECCION);
ALTER TABLE CURSOS_IMPARTIDOS ADD CONSTRAINT FK_CI_PERIODO FOREIGN KEY (ID_PERIODO_FK) REFERENCES PERIODOS_ACADEMICOS(ID_PERIODO);
ALTER TABLE CURSOS_IMPARTIDOS ADD CONSTRAINT FK_CI_AULA FOREIGN KEY (ID_AULA_FK) REFERENCES AULAS(ID_AULA);
ALTER TABLE INSCRIPCIONES ADD CONSTRAINT FK_INSCRIPCIONES_ESTUDIANTE FOREIGN KEY (ID_ESTUDIANTE_FK) REFERENCES ESTUDIANTES(ID_ESTUDIANTE);
ALTER TABLE INSCRIPCIONES ADD CONSTRAINT FK_INSCRIPCIONES_CI FOREIGN KEY (ID_CURSO_IMPARTIDO_FK) REFERENCES CURSOS_IMPARTIDOS(ID_CURSO_IMPARTIDO);
ALTER TABLE REGISTROS_ASISTENCIA ADD CONSTRAINT FK_RA_INSCRIPCION FOREIGN KEY (ID_INSCRIPCION_FK) REFERENCES INSCRIPCIONES(ID_INSCRIPCION) ON DELETE CASCADE;

-- --------------------------------------------------------------------------------
-- SECCIÓN 5: CREACIÓN DE ÍNDICES
-- --------------------------------------------------------------------------------
-- Descripción: Los índices son estructuras especiales que la base de datos utiliza
-- para acelerar la búsqueda y recuperación de datos. Aunque las claves primarias
-- crean un índice automáticamente, es una buena práctica crear índices en todas
-- las claves foráneas (FK) y en cualquier otra columna que se use frecuentemente
-- en las cláusulas WHERE de las consultas.
PROMPT Creando Índices para optimización de consultas...
-- Índices en todas las claves foráneas
CREATE INDEX IDX_CARRERAS_FACULTAD_FK ON CARRERAS(ID_FACULTAD_FK);
CREATE INDEX IDX_ESTUDIANTES_CARRERA_FK ON ESTUDIANTES(ID_CARRERA_FK);
CREATE INDEX IDX_USUARIOS_ESTUDIANTE_FK ON USUARIOS(ID_ESTUDIANTE_FK);
CREATE INDEX IDX_USUARIOS_CATEDRATICO_FK ON USUARIOS(ID_CATEDRATICO_FK);
CREATE INDEX IDX_CI_CURSO_FK ON CURSOS_IMPARTIDOS(ID_CURSO_FK);
CREATE INDEX IDX_CI_CATEDRATICO_FK ON CURSOS_IMPARTIDOS(ID_CATEDRATICO_FK);
CREATE INDEX IDX_CI_SECCION_FK ON CURSOS_IMPARTIDOS(ID_SECCION_FK);
CREATE INDEX IDX_CI_PERIODO_FK ON CURSOS_IMPARTIDOS(ID_PERIODO_FK);
CREATE INDEX IDX_CI_AULA_FK ON CURSOS_IMPARTIDOS(ID_AULA_FK);
CREATE INDEX IDX_INS_ESTUDIANTE_FK ON INSCRIPCIONES(ID_ESTUDIANTE_FK);
CREATE INDEX IDX_INS_CI_FK ON INSCRIPCIONES(ID_CURSO_IMPARTIDO_FK);
CREATE INDEX IDX_RA_INSCRIPCION_FK ON REGISTROS_ASISTENCIA(ID_INSCRIPCION_FK);

-- --------------------------------------------------------------------------------
-- SECCIÓN 6: CREACIÓN DE TRIGGERS PARA AUTO-GENERAR PKs
-- --------------------------------------------------------------------------------
-- Descripción: A diferencia de otras bases de datos, Oracle no tiene una propiedad
-- "autoincrement" nativa en las tablas. Para lograr este comportamiento, combinamos
-- las secuencias (Sección 2) con los triggers. Un trigger es un bloque de código
-- que se ejecuta automáticamente ANTES (BEFORE) o DESPUÉS (AFTER) de un evento
-- (INSERT, UPDATE, DELETE).
--
-- Estos triggers se disparan 'BEFORE INSERT' en cada tabla. Su única función es
-- tomar el siguiente valor de la secuencia correspondiente (SEQ_*.NEXTVAL) y
-- asignarlo a la columna de la clave primaria (:NEW.ID_*) antes de que la fila
-- sea guardada. Esto automatiza por completo la generación de IDs.
PROMPT Creando Triggers para auto-generar claves primarias...
CREATE OR REPLACE TRIGGER TRG_BI_FACULTADES BEFORE INSERT ON FACULTADES FOR EACH ROW BEGIN :NEW.ID_FACULTAD := SEQ_FACULTADES.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_CARRERAS BEFORE INSERT ON CARRERAS FOR EACH ROW BEGIN :NEW.ID_CARRERA := SEQ_CARRERAS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_ESTUDIANTES BEFORE INSERT ON ESTUDIANTES FOR EACH ROW BEGIN :NEW.ID_ESTUDIANTE := SEQ_ESTUDIANTES.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_CATEDRATICOS BEFORE INSERT ON CATEDRATICOS FOR EACH ROW BEGIN :NEW.ID_CATEDRATICO := SEQ_CATEDRATICOS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_USUARIOS BEFORE INSERT ON USUARIOS FOR EACH ROW BEGIN :NEW.ID_USUARIO := SEQ_USUARIOS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_PERIODOS BEFORE INSERT ON PERIODOS_ACADEMICOS FOR EACH ROW BEGIN :NEW.ID_PERIODO := SEQ_PERIODOS_ACADEMICOS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_CURSOS BEFORE INSERT ON CURSOS FOR EACH ROW BEGIN :NEW.ID_CURSO := SEQ_CURSOS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_AULAS BEFORE INSERT ON AULAS FOR EACH ROW BEGIN :NEW.ID_AULA := SEQ_AULAS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_SECCIONES BEFORE INSERT ON SECCIONES FOR EACH ROW BEGIN :NEW.ID_SECCION := SEQ_SECCIONES.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_CURSOS_IMPARTIDOS BEFORE INSERT ON CURSOS_IMPARTIDOS FOR EACH ROW BEGIN :NEW.ID_CURSO_IMPARTIDO := SEQ_CURSOS_IMPARTIDOS.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_INSCRIPCIONES BEFORE INSERT ON INSCRIPCIONES FOR EACH ROW BEGIN :NEW.ID_INSCRIPCION := SEQ_INSCRIPCIONES.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_REGISTROS_ASISTENCIA BEFORE INSERT ON REGISTROS_ASISTENCIA FOR EACH ROW BEGIN :NEW.ID_REGISTRO := SEQ_REGISTROS_ASISTENCIA.NEXTVAL; END;
/
CREATE OR REPLACE TRIGGER TRG_BI_AUDITORIA_ACCIONES BEFORE INSERT ON AUDITORIA_ACCIONES FOR EACH ROW BEGIN :NEW.ID_AUDITORIA := SEQ_AUDITORIA_ACCIONES.NEXTVAL; END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 7: CREACIÓN DE VISTAS
-- --------------------------------------------------------------------------------
-- Descripción: Una vista es una consulta almacenada que se presenta como una tabla
-- virtual. Su propósito es simplificar el acceso a datos que requieren uniones
-- (JOINs) complejas entre múltiples tablas. El backend puede consultar esta vista
-- (V_REPORTE_ASISTENCIA) como si fuera una sola tabla, sin tener que reescribir
-- la lógica de los JOINs, haciendo el código de la aplicación más limpio y seguro.
PROMPT Creando vistas para simplificar consultas...
CREATE OR REPLACE VIEW V_REPORTE_ASISTENCIA AS
SELECT
    RA.FECHA_HORA_REGISTRO,
    RA.TIPO_ASISTENCIA,
    E.NUMERO_CARNET,
    E.NOMBRES || ' ' || E.APELLIDOS AS NOMBRE_ESTUDIANTE,
    C.NOMBRE_CURSO,
    S.CODIGO_SECCION,
    CAT.NOMBRES || ' ' || CAT.APELLIDOS AS NOMBRE_CATEDRATICO,
    P.NOMBRE_PERIODO
FROM REGISTROS_ASISTENCIA RA
JOIN INSCRIPCIONES I ON RA.ID_INSCRIPCION_FK = I.ID_INSCRIPCION
JOIN ESTUDIANTES E ON I.ID_ESTUDIANTE_FK = E.ID_ESTUDIANTE
JOIN CURSOS_IMPARTIDOS CI ON I.ID_CURSO_IMPARTIDO_FK = CI.ID_CURSO_IMPARTIDO
JOIN CURSOS C ON CI.ID_CURSO_FK = C.ID_CURSO
JOIN SECCIONES S ON CI.ID_SECCION_FK = S.ID_SECCION
JOIN CATEDRATICOS CAT ON CI.ID_CATEDRATICO_FK = CAT.ID_CATEDRATICO
JOIN PERIODOS_ACADEMICOS P ON CI.ID_PERIODO_FK = P.ID_PERIODO;

-- --------------------------------------------------------------------------------
-- SECCIÓN 8: CREACIÓN DE PROCEDIMIENTOS ALMACENADOS
-- --------------------------------------------------------------------------------
-- Descripción: Los procedimientos almacenados encapsulan la lógica de negocio
-- crítica directamente en la base de datos. En lugar de que el backend construya
-- múltiples sentencias SQL para registrar una asistencia, simplemente llama a este
-- procedimiento (SP_REGISTRAR_ASISTENCIA) con los parámetros necesarios.
-- Esto mejora la seguridad (previene inyección SQL), el rendimiento y la
-- mantenibilidad, ya que la lógica de registro está en un solo lugar.
PROMPT Creando procedimientos almacenados para la lógica de negocio...
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_ASISTENCIA (
    p_id_curso_impartido IN NUMBER,
    p_numero_carnet       IN VARCHAR2,
    p_resultado           OUT VARCHAR2
) AS
    v_id_estudiante   NUMBER;
    v_id_inscripcion  NUMBER;
    v_conteo_asist    NUMBER := 0;
BEGIN
    -- 1. Obtener el ID del estudiante a partir de su carnet
    BEGIN
        SELECT ID_ESTUDIANTE INTO v_id_estudiante FROM ESTUDIANTES WHERE NUMERO_CARNET = p_numero_carnet;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := 'ERROR: Numero de carnet no encontrado.';
            RETURN;
    END;

    -- 2. Verificar/Crear inscripción
    BEGIN
        SELECT ID_INSCRIPCION INTO v_id_inscripcion
        FROM INSCRIPCIONES
        WHERE ID_ESTUDIANTE_FK = v_id_estudiante
          AND ID_CURSO_IMPARTIDO_FK = p_id_curso_impartido;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO INSCRIPCIONES (ID_ESTUDIANTE_FK, ID_CURSO_IMPARTIDO_FK)
            VALUES (v_id_estudiante, p_id_curso_impartido)
            RETURNING ID_INSCRIPCION INTO v_id_inscripcion;
    END;

    -- 3. Verificar que no haya registrado asistencia para hoy
    SELECT COUNT(*) INTO v_conteo_asist
    FROM REGISTROS_ASISTENCIA
    WHERE ID_INSCRIPCION_FK = v_id_inscripcion
      AND TRUNC(FECHA_HORA_REGISTRO) = TRUNC(SYSDATE);

    IF v_conteo_asist > 0 THEN
        p_resultado := 'AVISO: Asistencia ya registrada para hoy.';
        RETURN;
    END IF;

    -- 4. Insertar el registro de asistencia
    INSERT INTO REGISTROS_ASISTENCIA (ID_INSCRIPCION_FK, FECHA_HORA_REGISTRO, TIPO_ASISTENCIA)
    VALUES (v_id_inscripcion, SYSTIMESTAMP, 'P');
    
    COMMIT;
    p_resultado := 'EXITO: Asistencia registrada correctamente.';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := 'ERROR: Ocurrio un error inesperado. ' || SQLERRM;
END;
/

-- --------------------------------------------------------------------------------
-- SECCIÓN 9: CREACIÓN DE TRIGGERS DE AUDITORÍA
-- --------------------------------------------------------------------------------
-- Descripción: Estos triggers se encargan de registrar automáticamente los cambios
-- en las tablas más importantes. Se disparan DESPUÉS (AFTER) de una operación
-- de INSERT, UPDATE o DELETE y guardan una fila en la tabla AUDITORIA_ACCIONES
-- con los detalles de la operación: qué tabla se modificó, qué fila, qué tipo
-- de acción fue, quién la realizó y cuándo.
PROMPT Creando Triggers de Auditoría...

CREATE OR REPLACE TRIGGER TRG_AUD_INSCRIPCIONES
AFTER INSERT OR UPDATE OR DELETE ON INSCRIPCIONES
FOR EACH ROW
DECLARE
    v_tipo_accion CHAR(1);
    v_valores_antiguos CLOB;
    v_valores_nuevos CLOB;
BEGIN
    IF INSERTING THEN
        v_tipo_accion := 'I';
        v_valores_nuevos := 'ID_ESTUDIANTE_FK: ' || :NEW.ID_ESTUDIANTE_FK || ', ID_CURSO_IMPARTIDO_FK: ' || :NEW.ID_CURSO_IMPARTIDO_FK;
    ELSIF UPDATING THEN
        v_tipo_accion := 'U';
        v_valores_antiguos := 'ID_ESTUDIANTE_FK: ' || :OLD.ID_ESTUDIANTE_FK || ', ID_CURSO_IMPARTIDO_FK: ' || :OLD.ID_CURSO_IMPARTIDO_FK;
        v_valores_nuevos := 'ID_ESTUDIANTE_FK: ' || :NEW.ID_ESTUDIANTE_FK || ', ID_CURSO_IMPARTIDO_FK: ' || :NEW.ID_CURSO_IMPARTIDO_FK;
    ELSIF DELETING THEN
        v_tipo_accion := 'D';
        v_valores_antiguos := 'ID_ESTUDIANTE_FK: ' || :OLD.ID_ESTUDIANTE_FK || ', ID_CURSO_IMPARTIDO_FK: ' || :OLD.ID_CURSO_IMPARTIDO_FK;
    END IF;

    INSERT INTO AUDITORIA_ACCIONES (
        NOMBRE_TABLA,
        ID_REGISTRO_AFECTADO,
        TIPO_ACCION,
        VALORES_ANTERIORES,
        VALORES_NUEVOS,
        NOMBRE_USUARIO_BD
    ) VALUES (
        'INSCRIPCIONES',
        NVL(:NEW.ID_INSCRIPCION, :OLD.ID_INSCRIPCION),
        v_tipo_accion,
        v_valores_antiguos,
        v_valores_nuevos,
        USER
    );
END;
/

CREATE OR REPLACE TRIGGER TRG_AUD_REGISTROS_ASISTENCIA
AFTER INSERT OR UPDATE OR DELETE ON REGISTROS_ASISTENCIA
FOR EACH ROW
DECLARE
    v_tipo_accion CHAR(1);
BEGIN
    IF INSERTING THEN
        v_tipo_accion := 'I';
        INSERT INTO AUDITORIA_ACCIONES (NOMBRE_TABLA, ID_REGISTRO_AFECTADO, TIPO_ACCION, VALORES_NUEVOS, NOMBRE_USUARIO_BD)
        VALUES ('REGISTROS_ASISTENCIA', :NEW.ID_REGISTRO, v_tipo_accion, 'TIPO_ASISTENCIA: ' || :NEW.TIPO_ASISTENCIA, USER);
    ELSIF DELETING THEN
        v_tipo_accion := 'D';
        INSERT INTO AUDITORIA_ACCIONES (NOMBRE_TABLA, ID_REGISTRO_AFECTADO, TIPO_ACCION, VALORES_ANTERIORES, NOMBRE_USUARIO_BD)
        VALUES ('REGISTROS_ASISTENCIA', :OLD.ID_REGISTRO, v_tipo_accion, 'TIPO_ASISTENCIA: ' || :OLD.TIPO_ASISTENCIA, USER);
    END IF;
END;
/

PROMPT Proceso de creación de base de datos finalizado.
-- Finalizar el log
SPOOL OFF

