// backend/src/routes/crud.routes.js
const router = require('express').Router();
const ctrl = require('../controllers/CRUD.controller');

// Metadata de tabla (columnas, tipos, PK)
router.get('/dev/:table/meta', ctrl.meta);

// Listar con paginación
router.get('/dev/:table', ctrl.list);

// Obtener por PK
router.get('/dev/:table/:id', ctrl.getById);

// Crear
router.post('/dev/:table', ctrl.create);

// Actualizar
router.put('/dev/:table/:id', ctrl.update);

// Eliminar
router.delete('/dev/:table/:id', ctrl.remove);

module.exports = router;
