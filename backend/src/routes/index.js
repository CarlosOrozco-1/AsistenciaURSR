// src/routes/index.js

// 1️⃣ Importamos Express y creamos el enrutador principal
const express = require('express');
const router = express.Router();

// 2️⃣ Importación de todos los enrutadores de la aplicación
const asistenciaRoutes = require('./asistencia.routes');
const regEstudianteRoutes = require('./regEstudiante.routes'); // Registro público
const authRoutes = require('./auth.routes');                     // Login / JWT
const gestionUsuariosRoutes = require('./gestionUsuarios.routes'); // CRUD administrativo

console.log('Cargando enrutador principal...');

// 3️⃣ Montaje de rutas públicas
router.use('/asistencia', asistenciaRoutes);
router.use('/regEstudiante', regEstudianteRoutes);
router.use('/auth', authRoutes);

// 4️⃣ Montaje de rutas administrativas (gestionUsuarios)
// Estas rutas ya manejan middleware de token y verificación de rol dentro de su archivo
router.use('/gestionUsuarios', gestionUsuariosRoutes);

// 5️⃣ Health check
router.get('/health', (_req, res) => {
    res.status(200).json({
        status: 'ok',
        message: 'API saludable y lista para recibir peticiones.',
        uptime: process.uptime()
    });
});

console.log('Enrutador principal cargado correctamente.');

module.exports = router;
