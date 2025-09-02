// backend/src/routes/table.routes.js
const router = require('express').Router();
const ctrl = require('../controllers/table.controller');

// GET /api/table/:name?limit=&offset=
router.get('/table/:name', ctrl.getTable);

module.exports = router;
