// backend/src/routes/tables.routes.js
// Ruta: GET /api/tables

const router = require('express').Router();
const ctrl = require('../controllers/tables.controller');

// GET /api/tables -> lista tablas del esquema actual (PARCIAL_1)
router.get('/tables', ctrl.listTables);

module.exports = router;
