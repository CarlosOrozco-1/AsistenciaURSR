// backend/src/controllers/tables.controller.js
// Lista las tablas visibles para el usuario actual (PARCIAL_1)
// Nota: USER_TABLES solo muestra tablas del esquema actual.

const { execute } = require('../database');

exports.listTables = async (_req, res) => {
  try {
    console.log('[DB] Consultando USER_TABLES');
    const result = await execute(`
      SELECT TABLE_NAME
      FROM USER_TABLES
      ORDER BY TABLE_NAME
    `);
    const tables = (result.rows || []).map(r => r.TABLE_NAME);
    res.json({ tables, count: tables.length });
  } catch (e) {
    console.error('[DB] Error listTables:', e.message);
    res.status(500).json({ error: e.message });
  }
};

