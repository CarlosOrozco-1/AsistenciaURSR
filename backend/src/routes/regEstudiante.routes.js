// Importamos Express para crear el enrutador y el controlador de usuario.
const express = require('express');
const router = express.Router();

// Importamos el controlador de regEstudiante
const regEstudiantecontroller = require('../controllers/regEstudiante.controller'); 

console.log('Cargando rutas de regEstudiante...');

// --- Definición de la ruta para crear una cuenta de estudiante ---
// Esta ruta debe ser pública y no debe requerir validación de token
router.post('/estudiante', regEstudiantecontroller.postCrearCuentaEstudiante); 

// En el futuro, aquí podrías añadir otras rutas si es necesario, como:
// router.post('/catedratico', regEstudiantecontroller.postCrearCuentaCatedratico);
// router.put('/:id/estado', regEstudiantecontroller.putActualizarEstado);

// --- Aquí se puede agregar más rutas privadas que requieran validación de token ---
/*
router.use(verificarToken); // Aplica el middleware de validación de token a las rutas que lo requieran
router.put('/estudiante/:id', regEstudiantecontroller.putActualizarEstudiante);
router.delete('/estudiante/:id', regEstudiantecontroller.deleteEstudiante);
*/

console.log("Rutas de '/regEstudiante' cargadas.");

module.exports = router;
