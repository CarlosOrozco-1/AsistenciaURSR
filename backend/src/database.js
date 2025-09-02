// backend/src/database.js

// Cargamos el driver oficial de Oracle para Node.js
const oracledb = require('oracledb');

// Carga las variables de entorno desde el archivo .env
// (Esto debe ejecutarse una sola vez al inicio del proceso)
require('dotenv').config();

/**
 * La cadena de conexión de Oracle en formato host:puerto/servicio
 * - DB_HOST: normalmente 127.0.0.1 si es local
 * - DB_PORT: por defecto 1521
 * - DB_SERVICE: en Oracle XE suele ser XEPDB1 (el PDB por defecto)
 */
const connectString = `${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_SERVICE}`;

/**
 * Inicializa un "pool" de conexiones a Oracle.
 * ¿Por qué un pool? Abrir/cerrar conexiones a cada petición es caro.
 * Un pool mantiene un conjunto de conexiones reutilizables, mejorando rendimiento.
 *
 * Esta función debe llamarse una sola vez al arrancar el servidor (por ejemplo, en src/index.js).
 */
async function initDB() {
  await oracledb.createPool({
    user: process.env.DB_USER,            // Usuario/esquema dueño de tus tablas
    password: process.env.DB_PASSWORD,    // Contraseña del usuario
    connectString,                        // host:puerto/servicio
    // Parámetros del pool (ajústalos según tu carga)
    poolMin: Number(process.env.DB_POOL_MIN ?? 1), // conexiones mínimas abiertas
    poolMax: Number(process.env.DB_POOL_MAX ?? 5), // conexiones máximas
    poolIncrement: 1,                                // cuántas conexiones abre al crecer
    poolTimeout: Number(process.env.DB_POOL_IDLE ?? 60), // cierra inactivas (seg)
  });

  console.log(`✅ [DB] Pool Oracle listo -> ${connectString}`);
}

/**
 * Cierra ordenadamente el pool de conexiones.
 * Útil al apagar el servidor (ej. en SIGINT / Ctrl+C).
 */
async function shutdownDB() {
  try {
    await oracledb.getPool().close(0); // 0 = no esperar sesiones en uso (apaga inmediato)
    console.log('🧹 [DB] Pool cerrado');
  } catch (e) {
    console.error('⚠️ [DB] Error al cerrar pool:', e.message);
  }
}

/**
 * Ejecuta una sentencia SQL usando una conexión del pool.
 *
 * @param {string} sql - La sentencia SQL (SELECT/INSERT/UPDATE/DELETE/PL/SQL)
 * @param {Array|Object} [binds=[]] - Valores a enlazar (:id, :nombre, etc.)
 *   Ej: { id: 10, nombre: 'Ana' }    o    [10, 'Ana']
 * @param {Object} [options={}] - Opciones extra
 *   - autoCommit: true para confirmar DML (INSERT/UPDATE/DELETE) automáticamente
 *
 * @returns {Promise<oracledb.Result>} - Devuelve el objeto result del driver
 *   - Para SELECT: result.rows contendrá las filas (como objetos por outFormat)
 *   - Para DML: result.rowsAffected/lastRowid serán útiles
 */
async function execute(sql, binds = [], options = {}) {
  // Toma una conexión disponible del pool
  const conn = await oracledb.getConnection();

  try {
    const result = await conn.execute(sql, binds, {
      // OUT_FORMAT_OBJECT devuelve filas como objetos {COLUMNA: valor}
      outFormat: oracledb.OUT_FORMAT_OBJECT,
      // autoCommit por defecto en false (recomendado en transacciones)
      autoCommit: options.autoCommit ?? false,
    });

    return result;
  } finally {
    // MUY IMPORTANTE: siempre liberar la conexión al terminar
    await conn.close();
  }
}

// Exportamos las utilidades para usarlas en otros módulos (controladores, etc.)
module.exports = { initDB, shutdownDB, execute, oracledb };
