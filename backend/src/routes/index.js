const express = require('express');
const router = express.Router();

// --- Importación de todos los enrutadores de la aplicación ---
// A medida que crees nuevas entidades, simplemente las importarás y registrarás aquí.
const asistenciaRoutes = require('./asistencia.routes');
const usuarioRoutes = require('./usuario.routes');

console.log('Cargando enrutador principal...');

// --- Definición de las rutas base ---
// Todo lo que se defina en 'asistencia.routes.js' ahora estará bajo '/asistencia'
// Ejemplo: una ruta '/registrar' en ese archivo será accesible en '/api/v1/asistencia/registrar'
router.use('/asistencia', asistenciaRoutes);
router.use('/usuarios', usuarioRoutes); // Rutas para la gestión de usuarios



router




// --- Ruta de salud (Health Check) ---
// Es una buena práctica tener un endpoint que verifique que la API y sus servicios funcionan.
router.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'API saludable y lista para recibir peticiones.',
    uptime: process.uptime(), // Devuelve el tiempo que la app lleva activa en segundos
  });
});

console.log('✅ Enrutador principal cargado correctamente.');

module.exports = router;
