// backend/src/routes/empleados.routes.js
const { Router } = require('express');
const { getEmpleados } = require('../controllers/empleados.controller');

const router = Router();

// Definimos la ruta GET para /api/empleados
router.get('/empleados', getEmpleados);

module.exports = router;