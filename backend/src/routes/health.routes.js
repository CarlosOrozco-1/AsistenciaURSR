// src/routes/health.routes.js
const { Router } = require('express');
const { dbHealth, listTables } = require('../controllers/health.controller');

const router = Router();

router.get('/db', dbHealth);
router.get('/tables', listTables);

module.exports = router;
