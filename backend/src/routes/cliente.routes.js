// backend/src/routes/cliente.routes.js
// Expone el endpoint POST /api/cliente que usa el controlador.

const router = require('express').Router();
const ctrl = require('../controllers/cliente.controller');

// POST /api/cliente -> crea un cliente vía SP_INS_CLIENTE
router.post('/cliente', ctrl.create);

module.exports = router;
