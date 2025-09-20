// src/services/auth.service.js
const oracledb = require('oracledb');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
require('dotenv').config();

// Si quieres que los CLOB OUT lleguen como string directamente:
oracledb.fetchAsString = [oracledb.CLOB];

const validarCredenciales = async (email, password) => {
  let connection;

  try {
    connection = await oracledb.getConnection({
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      connectString: `${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_SERVICE}`,
    });

    // 1) Traer hash almacenado (y estado)
    const userRes = await connection.execute(
      `
      SELECT 
        ID_USUARIO,
        NOMBRE_USUARIO,
        TIPO_USUARIO,
        CONTRASENA_HASH,
        ESTADO
      FROM USUARIOS
      WHERE NOMBRE_USUARIO = :email
      `,
      { email },
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    if (userRes.rows.length === 0) {
      // Usuario no existe
      return null;
    }

    const u = userRes.rows[0];
    if ((u.ESTADO || '').trim().toUpperCase() !== 'A') {
      // Usuario inactivo
      return null;
    }

    // 2) Validar contraseña con bcrypt.compare
    const ok = await bcrypt.compare(password, u.CONTRASENA_HASH);
    if (!ok) {
      // Password incorrecto
      return null;
    }

    // 3) Obtener el perfil JSON desde Oracle usando tu función existente.
    //    Le pasamos el hash almacenado (el que acabamos de validar).
    const perfilRes = await connection.execute(
      `BEGIN :resultado := PKG_USUARIOS.FN_VALIDAR_CREDENCIALES(:email, :stored_hash); END;`,
      {
        resultado: { dir: oracledb.BIND_OUT, type: oracledb.CLOB }, // con fetchAsString será string
        email,
        stored_hash: u.CONTRASENA_HASH,
      }
    );

    let jsonString = perfilRes.outBinds.resultado;

    // Si no activaste fetchAsString, 'resultado' será un LOB:
    if (jsonString && typeof jsonString !== 'string' && jsonString.getData) {
      jsonString = await jsonString.getData();
    }

    if (!jsonString) {
      // Si por alguna razón el perfil no salió (p.ej. inconsistencia), como fallback arma un perfil mínimo:
      jsonString = JSON.stringify({
        id_usuario: u.ID_USUARIO,
        nombre_usuario: u.NOMBRE_USUARIO,
        tipo_usuario: u.TIPO_USUARIO,
        perfil: null,
      });
    }

    const perfil = JSON.parse(jsonString);

    // 4) Generar JWT
    const token = jwt.sign(
      {
        id: perfil.id_usuario ?? u.ID_USUARIO,
        tipo: perfil.tipo_usuario ?? u.TIPO_USUARIO,
        nombre: perfil.nombre_usuario ?? u.NOMBRE_USUARIO,
      },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    return { token, perfil };
  } catch (error) {
    console.error('Error en validarCredenciales:', error);
    return null;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error('Error al cerrar la conexión:', err);
      }
    }
  }
};

module.exports = { validarCredenciales };
