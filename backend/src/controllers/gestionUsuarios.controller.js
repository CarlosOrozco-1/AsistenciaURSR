// controllers/gestionUsuarios.controller.js
const gestionUsuariosService = require('../services/gestionUsuarios.service');

console.log('Cargando controlador de gestión de usuarios...');

/**
 * Listar usuarios con filtros y paginación.
 */
async function listarUsuarios(req, res) {
    try {
        const { tipo_usuario, estado, offset = 0, limit = 50 } = req.query;

        const resultado = await gestionUsuariosService.listarUsuarios({
            tipo_usuario,
            estado,
            offset: Number(offset),
            limit: Number(limit)
        });

        res.status(200).json({
            success: true,
            data: resultado
        });
    } catch (error) {
        console.error('Error en listarUsuarios:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno al listar usuarios.'
        });
    }
}

/**
 * Obtener un usuario por ID.
 */
async function obtenerUsuario(req, res) {
    try {
        const { id } = req.params;
        const resultado = await gestionUsuariosService.obtenerUsuario(Number(id));

        if (!resultado) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado.'
            });
        }

        res.status(200).json({
            success: true,
            data: resultado
        });
    } catch (error) {
        console.error('Error en obtenerUsuario:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno al obtener el usuario.'
        });
    }
}

/**
 * Actualizar datos de un usuario (sin contraseña).
 */
async function actualizarUsuario(req, res) {
    try {
        const { id } = req.params;
        const { nombre_usuario, tipo_usuario } = req.body;

        if (!nombre_usuario || !tipo_usuario) {
            return res.status(400).json({
                success: false,
                message: 'Faltan datos obligatorios para actualizar el usuario.'
            });
        }

        const resultado = await gestionUsuariosService.actualizarUsuario(Number(id), {
            nombre_usuario,
            tipo_usuario
        });

        if (resultado.success) {
            res.status(200).json(resultado);
        } else {
            res.status(400).json(resultado);
        }
    } catch (error) {
        console.error('Error en actualizarUsuario:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno al actualizar el usuario.'
        });
    }
}

/**
 * Cambiar estado de un usuario (activar/inactivar)
 */
async function cambiarEstadoUsuario(req, res) {
    try {
        const { id } = req.params;
        const { estado } = req.body;

        if (!estado || !['A', 'I'].includes(estado)) {
            return res.status(400).json({
                success: false,
                message: 'Estado inválido. Debe ser "A" (activo) o "I" (inactivo).'
            });
        }

        const resultado = await gestionUsuariosService.cambiarEstadoUsuario(Number(id), estado);

        if (resultado.success) {
            res.status(200).json(resultado);
        } else {
            res.status(400).json(resultado);
        }
    } catch (error) {
        console.error('Error en cambiarEstadoUsuario:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno al cambiar el estado del usuario.'
        });
    }
}

/**
 * Baja lógica de usuario (soft delete)
 */
async function eliminarUsuario(req, res) {
    try {
        const { id } = req.params;

        const resultado = await gestionUsuariosService.eliminarUsuario(Number(id));

        if (resultado.success) {
            res.status(200).json(resultado);
        } else {
            res.status(400).json(resultado);
        }
    } catch (error) {
        console.error('Error en eliminarUsuario:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno al eliminar el usuario.'
        });
    }
}

// Listar usuarios inactivos
async function listarUsuariosInactivos(req, res) {
  const resultado = await gestionUsuariosService.listarUsuariosInactivos();

  if (resultado.success) {
    res.status(200).json(resultado);
  } else {
    res.status(500).json(resultado);
  }
}


console.log('Controlador de gestión de usuarios cargado.');

module.exports = {
    listarUsuarios,
    obtenerUsuario,
    actualizarUsuario,
    cambiarEstadoUsuario,
    eliminarUsuario,
    listarUsuariosInactivos
};
