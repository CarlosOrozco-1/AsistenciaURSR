// services/gestionUsuarios.service.js
const oracledb = require('oracledb');
const database = require('../config/database');

console.log('Cargando servicio de gestión de usuarios...');

/**
 * Listar usuarios con filtros y paginación
 */
async function listarUsuarios() {
  try {
    const sql = `
      DECLARE
        v_resultado CLOB;
      BEGIN
        :resultado := PKG_GESTION_USUARIOS.FN_LISTAR_USUARIOS(NULL, 'A', 0, 10);
      END;
    `;

    const binds = {
      resultado: { dir: oracledb.BIND_OUT, type: oracledb.CLOB }
    };

    const result = await database.execute(sql, binds);

    const clob = result.outBinds.resultado;

    // ✅ Leer el contenido del CLOB correctamente
    const json = await clob.getData(); // node-oracledb >= v5

    return {
      success: true,
      data: JSON.parse(json)
    };
  } catch (error) {
    console.error('Error en listarUsuarios:', error);
    return {
      success: false,
      message: 'Error al listar usuarios.'
    };
  }
}

module.exports = {
  listarUsuarios
};

/**
 * Obtener un usuario por ID
 */

async function obtenerUsuario(idUsuario) {
  try {
    const sql = `
      DECLARE
        v_resultado CLOB;
      BEGIN
        :resultado := PKG_GESTION_USUARIOS.FN_OBTENER_USUARIO(:id_usuario);
      END;
    `;

    const binds = {
      id_usuario: idUsuario,
      resultado: { dir: oracledb.BIND_OUT, type: oracledb.CLOB }
    };

    const result = await database.execute(sql, binds);

    const clob = result.outBinds.resultado;

    // Leer el contenido del CLOB
    const json = await clob.getData(); // node-oracledb >= v5

    const data = JSON.parse(json);

    // Validar si el objeto está vacío
    if (Object.keys(data).length === 0) {
      return {
        success: false,
        message: 'Usuario no encontrado.'
      };
    }

    return {
      success: true,
      data
    };
  } catch (error) {
    console.error('Error en obtenerUsuario:', error);
    return {
      success: false,
      message: 'Error al obtener usuario.'
    };
  }
}

module.exports = {
  obtenerUsuario
};


/**
 * Actualizar datos de un usuario
 */

async function actualizarUsuario(idUsuario, datos) {
  try {
    const sql = `
      BEGIN
        PKG_GESTION_USUARIOS.PRC_ACTUALIZAR_USUARIO(
          :p_id_usuario,
          :p_nombre_usuario,
          :p_tipo_usuario,
          :p_resultado,
          :p_detalle
        );
      END;
    `;

    const binds = {
      p_id_usuario: idUsuario,
      p_nombre_usuario: datos.nombre_usuario,
      p_tipo_usuario: datos.tipo_usuario,
      p_resultado: { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 50 },
      p_detalle:   { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 200 }
    };

    const result = await database.execute(sql, binds, { autoCommit: true });

    return {
      success: result.outBinds.p_resultado === 'OK',
      message: result.outBinds.p_detalle
    };
  } catch (error) {
    console.error('Error en actualizarUsuario:', error);
    return {
      success: false,
      message: 'Ocurrió un error inesperado al actualizar el usuario.'
    };
  }
}

module.exports = {
  actualizarUsuario
};


/**
 * Cambiar estado de un usuario (activar/inactivar)
 */

async function cambiarEstadoUsuario(idUsuario, nuevoEstado) {
  try {
    const sql = `
      BEGIN
        PKG_GESTION_USUARIOS.PRC_CAMBIAR_ESTADO_USUARIO(
          :p_id_usuario,
          :p_estado,
          :p_resultado,
          :p_detalle
        );
      END;
    `;

    const binds = {
      p_id_usuario: idUsuario,
      p_estado: nuevoEstado,
      p_resultado: { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 50 },
      p_detalle:   { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 200 }
    };

    const result = await database.execute(sql, binds, { autoCommit: true });

    return {
      success: result.outBinds.p_resultado === 'OK',
      message: result.outBinds.p_detalle
    };
  } catch (error) {
    console.error('Error en cambiarEstadoUsuario:', error);
    return {
      success: false,
      message: 'Ocurrió un error inesperado al cambiar el estado del usuario.'
    };
  }
}

module.exports = {
  cambiarEstadoUsuario
};

// Listar usuarios inactivos

async function listarUsuariosInactivos() {
  try {
    const sql = `
      DECLARE
        v_resultado CLOB;
      BEGIN
        :resultado := PKG_GESTION_USUARIOS.FN_LISTAR_USUARIOS(NULL, 'I', 0, 100);
      END;
    `;

    const binds = {
      resultado: { dir: database.oracledb.BIND_OUT, type: database.oracledb.CLOB }
    };

    const result = await database.execute(sql, binds);
    const clob = result.outBinds.resultado;
    const json = await clob.getData();

    return {
      success: true,
      data: JSON.parse(json)
    };
  } catch (error) {
    console.error('Error en listarUsuariosInactivos:', error);
    return {
      success: false,
      message: 'Error al listar usuarios inactivos.'
    };
  }
}

/**
 * Baja lógica de usuario (soft delete)
 */

async function eliminarUsuario(id_usuario) {
  try {
    const sql = `
      BEGIN
        PKG_GESTION_USUARIOS.PRC_ELIMINAR_USUARIO(
          :p_id_usuario,
          :p_resultado,
          :p_detalle
        );
      END;
    `;

    const binds = {
      p_id_usuario: id_usuario,
      p_resultado: { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 50 },
      p_detalle:   { dir: database.oracledb.BIND_OUT, type: database.oracledb.STRING, maxSize: 200 }
    };

    const result = await database.execute(sql, binds, { autoCommit: true });

    return {
      success: result.outBinds.p_resultado === 'OK',
      message: result.outBinds.p_detalle
    };
  } catch (error) {
    console.error('Error en eliminarUsuario:', error);
    return {
      success: false,
      message: 'Ocurrió un error inesperado al eliminar el usuario.'
    };
  }
}

module.exports = {
  eliminarUsuario
};

console.log('Servicio de gestión de usuarios cargado.');

module.exports = {
    listarUsuarios,
    obtenerUsuario,
    actualizarUsuario,
    cambiarEstadoUsuario,
    eliminarUsuario,
    listarUsuariosInactivos
};
