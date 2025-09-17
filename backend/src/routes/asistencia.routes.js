const express = require('express');
const router = express.Router();

// Importaremos el controlador de asistencia, que contendrá la lógica
// para manejar la petición. Lo crearemos en el siguiente paso.
const asistenciaController = require('../controllers/asistencia.controller');

console.log('Cargando rutas de asistencia...');

// --- Definición de la ruta ---
// Cuando llegue una petición POST a '/api/v1/asistencia/registrar',
// se ejecutará la función 'postRegistrarAsistencia' del controlador.
router.post('/registrar', asistenciaController.postRegistrarAsistencia);

console.log("✅ Rutas de '/asistencia' cargadas.");

module.exports = router;
