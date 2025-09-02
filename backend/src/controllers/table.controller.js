// backend/src/controllers/table.controller.js
// Endpoint de lectura genérico SOLO para desarrollo.
// Permite inspeccionar datos de cualquier tabla del esquema actual con paginación.
// Ejemplo: GET /api/table/CLIENTE?limit=5&offset=0

const { execute } = require('../database');

exports.getTable = async (req, res) => {
  try {
    // (Seguridad) Si no estamos en desarrollo, bloquea este endpoint.
    if (process.env.NODE_ENV !== 'development') {
      return res.status(403).json({ error: 'Endpoint deshabilitado fuera de desarrollo' });
    }

    // 1) Validar nombre de tabla (nombres de objetos no aceptan binds en Oracle)
    //    Permitimos solo A-Z, 0-9 y _. Convertimos a MAYÚSCULAS.
    const raw = String(req.params.name || '');
    const TABLE = raw.toUpperCase().replace(/[^A-Z0-9_]/g, '');
    if (!TABLE) {
      return res.status(400).json({ error: 'Nombre de tabla inválido' });
    }

    // 2) Confirmar existencia en el esquema actual
    const exists = await execute(
      `SELECT COUNT(*) AS CNT FROM USER_TABLES WHERE TABLE_NAME = :t`,
      { t: TABLE }
    );
    if ((exists.rows?.[0]?.CNT || 0) === 0) {
      return res.status(404).json({ error: `Tabla ${TABLE} no encontrada en el esquema actual` });
    }

    // 3) Paginación con límites seguros
    const limit = Math.max(1, Math.min(100, Number(req.query.limit) || 20));
    const offset = Math.max(0, Number(req.query.offset) || 0);

    console.log(`[DB] Leyendo ${TABLE} offset=${offset} limit=${limit}`);

    // 4) Total de filas
    const totalRes = await execute(`SELECT COUNT(*) AS TOTAL FROM ${TABLE}`);
    const total = totalRes.rows?.[0]?.TOTAL || 0;

    // 5) Página de resultados (Oracle 12c+: OFFSET/FETCH)
    const pageSql = `SELECT * FROM ${TABLE} OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY`;
    const pageRes = await execute(pageSql);

    return res.json({
      table: TABLE,
      total,
      limit,
      offset,
      rows: pageRes.rows || []
    });
  } catch (e) {
    console.error('[DB] Error getTable:', e.message);
    return res.status(500).json({ error: e.message });
  }
};
