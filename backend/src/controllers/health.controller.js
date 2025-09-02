// backend/src/controllers/health.controller.js
// Controlador que verifica que:
// 1) El servidor está vivo
// 2) La DB responde a una consulta simple

const { execute } = require('../database');

exports.health = async (req, res) => {
  try {
    // SELECT mínimo contra Oracle. 'dual' es una tabla virtual de Oracle.
    const result = await execute(
      `SELECT 
         1 AS OK, 
         USER AS CURRENT_USER, 
         SYS_CONTEXT('USERENV','DB_NAME') AS DB_NAME
       FROM dual`
    );

    // Tomamos la primera (y única) fila
    const row = result.rows?.[0] || {};
    res.json({
      ok: row.OK === 1,
      db_user: row.CURRENT_USER,
      db_name: row.DB_NAME,
      service: process.env.DB_SERVICE
    });
  } catch (e) {
    // Si algo falla en la conexión o la consulta, devolvemos 500
    res.status(500).json({
      ok: false,
      error: e.message
    });
  }
};
