// gestionUsuarios.routes.js
const express = require('express');
const router = express.Router();

// Importamos el controlador correspondiente
const gestionUsuariosController = require('../controllers/gestionUsuarios.controller');

// Importamos el middleware de autenticación y rol
const {
    verificarToken
} = require('../middleware/auth.Middleware');
//const { requireRole } = require('../middleware/roleMiddleware'); // middleware para verificar rol ADMIN

console.log('Cargando rutas de gestión de usuarios...');

// Todas las rutas de gestión de usuarios requieren token y rol ADMIN
router.use(verificarToken);
//router.use(requireRole('ADMIN'));

//Ruta especifica para listar usuarios inactivos
router.get('/inactivos', gestionUsuariosController.listarUsuariosInactivos);

// --- Definición de rutas administrativas ---

// Listar usuarios con filtros y paginación
router.get('/', gestionUsuariosController.listarUsuarios);
// Obtener un usuario específico por ID
router.get('/:id', gestionUsuariosController.obtenerUsuario);
// Actualizar datos de un usuario
router.put('/:id', gestionUsuariosController.actualizarUsuario);
// Cambiar estado de un usuario (activar/inactivar)
router.patch('/:id/estado', gestionUsuariosController.cambiarEstadoUsuario);
// Baja lógica de usuario (soft delete)
router.delete('/:id', gestionUsuariosController.eliminarUsuario);

console.log("Rutas de '/gestionUsuarios' cargadas.");

module.exports = router;