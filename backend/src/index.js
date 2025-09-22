// 1️⃣ Cargar variables de entorno ANTES que cualquier otra cosa
require('dotenv').config();

// 2️⃣ Importar módulos necesarios
const express = require('express');
const cors = require('cors');
const database = require('../src/config/database'); // Módulo de conexión a Oracle
const apiRouter = require('../src/routes');          // Enrutador principal (centraliza todas las sub-rutas)

const app = express();
const PORT = process.env.PORT || 3000;

// 3️⃣ Middlewares globales
app.use(cors());            // Permite peticiones desde Angular
app.use(express.json());    // Permite parsear cuerpos JSON

// 3️⃣.1 Logger de peticiones HTTP
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  next();
});

// 4️⃣ Rutas de la API
// Todas las rutas quedan centralizadas bajo /api/v1
// Los submódulos se gestionan desde apiRouter (regEstudiante, gestionUsuarios, auth, asistencia)
app.use('/api/v1', apiRouter);

// 5️⃣ Función principal de arranque
async function startup() {
  console.log('Iniciando aplicación...');
  try {
    console.log('Inicializando pool de la base de datos...');
    await database.initDB(); // Inicializa la conexión a Oracle

    // Si la BD conecta correctamente, iniciamos el servidor
    app.listen(PORT, () => {
      console.log(`Servidor escuchando en http://localhost:${PORT}`);
    });

  } catch (err) {
    console.error('❌ Error fatal al inicializar la base de datos:', err);
    process.exit(1); // Si la BD falla, la app no arranca
  }
}

// 6️⃣ Manejo del cierre ordenado de la aplicación
async function shutdown(e) {
  console.log('Cerrando aplicación...');
  try {
    await database.shutdownDB(); // Cierra pool de conexiones
  } catch (err) {
    console.error('Error al cerrar el pool de la base de datos:', err);
  }

  process.exit(e ? 1 : 0);
}

// 6️⃣.1 Señales del sistema
process.on('SIGTERM', () => shutdown());
process.on('SIGINT', () => shutdown()); // Ctrl+C
process.on('uncaughtException', (err) => {
  console.error('Excepción no capturada:', err);
  shutdown(err);
});

// 7️⃣ Arrancar la aplicación
startup();
