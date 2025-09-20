// Importamos Express para crear el enrutador y el controlador de usuario.
const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/regEstudiante.controller');

console.log('Cargando rutas de usuarios...');

// --- Definición de la ruta para crear una cuenta de estudiante ---
// Cuando llegue una petición POST a '/api/v1/usuarios/estudiante',
// se ejecutará la función 'postCrearCuentaEstudiante' del controlador.
router.post('/estudiante', usuarioController.postCrearCuentaEstudiante);

// En el futuro, aquí se podrían añadir otras rutas como:
// router.post('/catedratico', usuarioController.postCrearCuentaCatedratico);
// router.put('/:id/estado', usuarioController.putActualizarEstado);

console.log("Rutas de '/usuarios' cargadas.");

module.exports = router;
