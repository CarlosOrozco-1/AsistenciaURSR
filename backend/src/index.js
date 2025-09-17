// 1. Cargar variables de entorno ANTES que cualquier otra cosa.
require('dotenv').config();

// Importamos los módulos necesarios
const express = require('express');
const cors = require('cors');
const database = require('../src/config/database'); // Tu módulo de conexión
const apiRouter = require('../src/routes');   // ¡NUEVO! Este será nuestro enrutador principal

// Creamos la aplicación de Express
const app = express();
const PORT = process.env.PORT || 3000;

// --- Middlewares ---
app.use(cors()); // Habilita CORS para permitir peticiones desde Angular
app.use(express.json()); // Permite al servidor entender cuerpos de petición en formato JSON

// Logger simple para cada petición (tomado de tu código, ¡buena idea!)
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  next();
});

// --- Rutas de la API ---
// Centralizamos todas las rutas bajo un prefijo /api/v1
// El archivo './src/routes' se encargará de gestionar todas las sub-rutas.
app.use('/api/v1', apiRouter);

// --- Función principal de arranque ---
async function startup() {
  console.log('Iniciando aplicación...');
  try {
    console.log('Inicializando pool de la base de datos...');
    await database.initDB();

    // SOLO si la BD conecta, iniciamos el servidor web
    app.listen(PORT, () => {
      console.log(`✅ Servidor escuchando en http://localhost:${PORT}`);
    });

  } catch (err) {
    console.error('❌ Error fatal al inicializar la base de datos:', err);
    process.exit(1); // Si la BD no funciona, la app no puede arrancar
  }
}

// --- Manejo del cierre ordenado ---
async function shutdown(e) {
  console.log('Cerrando aplicación...');
  try {
    await database.shutdownDB();
  } catch (err) {
    console.error('Error al cerrar el pool de la base de datos:', err);
  }

  process.exit(e ? 1 : 0);
}

// Escuchamos las señales del sistema para apagar la aplicación correctamente
process.on('SIGTERM', () => shutdown());
process.on('SIGINT', () => shutdown()); // Para Ctrl+C
process.on('uncaughtException', (err) => {
  console.error('Excepción no capturada:', err);
  shutdown(err);
});

// ¡Arrancamos la aplicación!
startup();

