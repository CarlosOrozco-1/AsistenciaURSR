// Importamos Express y creamos el enrutador principal
const express = require('express');
const router = express.Router();

// --- Importación de todos los enrutadores de la aplicación ---
// A medida que crees nuevas entidades, simplemente las importarás y registrarás aquí.
const asistenciaRoutes = require('./asistencia.routes');
const regEstudianteRoutes = require('./regEstudiante.routes'); // Nombre más claro
const authRoutes = require('./auth.routes');

console.log('Cargando enrutador principal...');

// --- Definición de las rutas base ---
// Cada grupo de rutas se monta bajo un prefijo, por ejemplo:
// '/api/v1/asistencia/registrar' si asistencia.routes.js tiene una ruta '/registrar'
router.use('/asistencia', asistenciaRoutes);

// CORREGIDO: Montamos las rutas de estudiante bajo el prefijo '/regEstudiante'
// Esto significa que la ruta '/estudiante' definida en regEstudiante.routes.js
// será accesible como: POST /api/v1/regEstudiante/estudiante
router.use('/regEstudiante', regEstudianteRoutes);

// Rutas para autenticación
router.use('/auth', authRoutes);

// --- Ruta de salud (Health Check) ---
// Verifica que la API esté activa y funcionando correctamente
router.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'API saludable y lista para recibir peticiones.',
    uptime: process.uptime(), // Tiempo activo en segundos
  });
});

console.log('Enrutador principal cargado correctamente.');

module.exports = router;
