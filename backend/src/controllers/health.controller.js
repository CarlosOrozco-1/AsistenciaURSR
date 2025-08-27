// src/controllers/health.controller.js
const { ejecutarConsulta } = require('../database');

// Verifica conexión básica a Oracle
async function dbHealth(req, res) {
  try {
    // Una sola consulta con 3 datos útiles
    const q = `
      SELECT
        1 AS ok,
        SYS_CONTEXT('USERENV','SESSION_USER') AS usuario,
        SYSDATE AS fecha
      FROM dual
    `;
    const r = await ejecutarConsulta(q);
    const row = r.rows && r.rows[0];

    res.json({
      ok: row?.OK === 1 || row?.OK === '1',
      user: row?.USUARIO,
      sysdate: row?.FECHA, // Express lo serializa como ISO si viene como Date
    });
  } catch (e) {
    console.error('Health DB error:', e);
    res.status(500).json({ ok: false, error: e.message || e });
  }
}

// Lista tablas del usuario (o busca por nombre)
async function listTables(req, res) {
  try {
    const { search } = req.query;

    let result;
    if (search && search.trim() !== '') {
      // Busca en todas las tablas accesibles por nombre
      result = await ejecutarConsulta(
        `SELECT owner, table_name
           FROM all_tables
          WHERE UPPER(table_name) LIKE :pattern
          ORDER BY owner, table_name`,
        { pattern: `%${search.toUpperCase()}%` }
      );
    } else {
      // Lista tablas del esquema actual (usuario con el que te conectas)
      result = await ejecutarConsulta(
        `SELECT table_name
           FROM user_tables
          ORDER BY table_name`
      );
    }

    res.json(result.rows);
  } catch (e) {
    console.error('Health listTables error:', e);
    res.status(500).json({ error: e.message || e });
  }
}

module.exports = { dbHealth, listTables };
