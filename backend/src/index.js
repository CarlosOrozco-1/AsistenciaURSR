// backend/src/index.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDB, shutdownDB } = require('./database');

const app = express();
app.use(express.json());

// --- Logger simple ---
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  next();
});

// Habilitar CORS para todas las peticiones ANTES de tus rutas
app.use(cors());

// --- Ping sin DB, para verificar que el server está arriba ---
app.get('/api/__ping', (_req, res) => res.json({ ok: true, msg: 'pong' }));

// --- Rutas  ---
app.use('/api', require('./routes/health.routes.js'));  // GET /api/health
app.use('/api', require('./routes/tables.routes.js'));  // GET /api/tables
app.use('api' , require('./routes/table.routes')) //GET /Table/api/name
app.use('/api', require('./routes/CRUD.routes.js')); //GET /api/CRUD
app.use('/api', require('./routes/cliente.routes.js')); // POST /api/cliente

// 1) Levantamos el server YA MISMO (así /api/__ping responde aunque la DB falle)
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`🚀 API escuchando en http://localhost:${port}`);
});

// 2) Inicializamos la DB en segundo paso (con logs explícitos)
(async () => {
  try {
    console.log('[DB] Inicializando pool...');
    await initDB();
    console.log('✅ [DB] Pool Oracle listo');
  } catch (err) {
    console.error('❌ [DB] No se pudo inicializar el pool:', err.message);
  }
})();

// Cierre ordenado
process.on('SIGINT', async () => {
  await shutdownDB();
  process.exit(0);
});
