// backend/src/routes/health.routes.js
// Define la ruta /api/health y la asocia al controlador

const router = require('express').Router();
const ctrl = require('../controllers/health.controller');

// GET /api/health -> estado del servidor y DB
router.get('/health', ctrl.health);

module.exports = router;
