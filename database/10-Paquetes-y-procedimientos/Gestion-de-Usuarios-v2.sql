	CREATE OR REPLACE PACKAGE BODY PKG_USUARIOS AS

	  --------------------------------------------------------------------
	  -- Procedimiento existente 
	  --------------------------------------------------------------------
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
		INSERT INTO ESTUDIANTES (NOMBRES, APELLIDOS, EMAIL, NUMERO_CARNET, ID_Carrera_FK)
		VALUES (p_nombres, p_apellidos, p_email, p_numero_carnet, p_id_carrera)
		RETURNING ID_ESTUDIANTE INTO v_nuevo_id_estudiante;

		INSERT INTO USUARIOS (ID_ESTUDIANTE_FK, NOMBRE_USUARIO, CONTRASENA_HASH, TIPO_USUARIO, ESTADO)
		VALUES (v_nuevo_id_estudiante, p_email, p_contrasena_hash, 'ESTUDIANTE', 'A');

		COMMIT; -- (Opcional refactor futuro: manejar commit en capa app)
		p_resultado := 'EXITO';
		p_detalle   := 'La cuenta del estudiante ha sido creada exitosamente.';

	  EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
		  ROLLBACK;
		  p_resultado := 'ERROR';
		  p_detalle   := 'El correo electrónico o el número de carnet ya se encuentran registrados.';
		WHEN OTHERS THEN
		  ROLLBACK;
		  p_resultado := 'ERROR';
		  p_detalle   := 'Ocurrió un error inesperado al crear la cuenta: ' || SQLERRM;
	  END crear_cuenta_estudiante;

	  --------------------------------------------------------------------
	  -- MISMO NOMBRE Y MISMA FIRMA:
	  --   FN_VALIDAR_CREDENCIALES(p_nombre_usuario, p_contrasena_hash)
	  -- CAMBIO: ya NO compara password; solo arma el perfil si el usuario está ACTIVO.
	  --         El segundo parámetro queda sin usar para mantener compatibilidad.
	  --------------------------------------------------------------------
	  FUNCTION FN_VALIDAR_CREDENCIALES(
		p_nombre_usuario   IN VARCHAR2,
		p_contrasena_hash  IN VARCHAR2
	  ) RETURN CLOB
	  AS
		v_json_perfil CLOB;
	  BEGIN
		SELECT JSON_OBJECT(
				 'id_usuario'     VALUE u.ID_USUARIO,
				 'nombre_usuario' VALUE u.NOMBRE_USUARIO,
				 'tipo_usuario'   VALUE u.TIPO_USUARIO,
				 'perfil' VALUE (
				   CASE u.TIPO_USUARIO
					 WHEN 'ESTUDIANTE' THEN (
					   SELECT JSON_OBJECT(
								'id_estudiante' VALUE e.ID_ESTUDIANTE,
								'nombres'       VALUE e.NOMBRES,
								'apellidos'     VALUE e.APELLIDOS,
								'carnet'        VALUE e.NUMERO_CARNET
							  )
					   FROM ESTUDIANTES e
					   WHERE e.ID_ESTUDIANTE = u.ID_ESTUDIANTE_FK
					 )
					 WHEN 'CATEDRATICO' THEN (
					   SELECT JSON_OBJECT(
								'id_catedratico'  VALUE c.ID_CATEDRATICO,
								'nombres'         VALUE c.NOMBRES,
								'apellidos'       VALUE c.APELLIDOS,
								'codigo_empleado' VALUE c.CODIGO_EMPLEADO
							  )
					   FROM CATEDRATICOS c
					   WHERE c.ID_CATEDRATICO = u.ID_CATEDRATICO_FK
					 )
					 ELSE JSON_OBJECT('rol' VALUE 'ADMIN')
				   END
				 )
				 RETURNING CLOB
			   )
		INTO v_json_perfil
		FROM USUARIOS u
		WHERE LOWER(TRIM(u.NOMBRE_USUARIO)) = LOWER(TRIM(p_nombre_usuario))
		  AND u.ESTADO = 'A';

		RETURN v_json_perfil;

	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  RETURN NULL; -- usuario no existe o inactivo
		WHEN OTHERS THEN
		  -- (Opcional: registrar en tabla de auditoría y relanzar)
		  RETURN NULL;
	  END FN_VALIDAR_CREDENCIALES;

	END PKG_USUARIOS;
	/
