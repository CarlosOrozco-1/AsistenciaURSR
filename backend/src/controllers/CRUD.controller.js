// backend/src/controllers/crud.controller.js
// CRUD genérico SOLO para desarrollo: /api/dev/:table/...
// Usa metadata de Oracle para validar tabla, columnas y PK.
// Requiere: NODE_ENV=development

const { execute, oracledb } = require('../database');

function assertDev(req, res) {
  if (process.env.NODE_ENV !== 'development') {
    res.status(403).json({ error: 'Endpoint deshabilitado fuera de desarrollo' });
    return false;
  }
  return true;
}

async function resolveTable(t) {
  const TABLE = String(t || '').toUpperCase().replace(/[^A-Z0-9_]/g, '');
  if (!TABLE) throw new Error('Nombre de tabla inválido');

  const exists = await execute(
    `SELECT COUNT(*) AS CNT FROM USER_TABLES WHERE TABLE_NAME = :t`,
    { t: TABLE }
  );
  if ((exists.rows?.[0]?.CNT || 0) === 0) {
    throw new Error(`Tabla ${TABLE} no existe en el esquema actual`);
  }
  return TABLE;
}

async function getColumns(TABLE) {
  const colsRes = await execute(`
    SELECT COLUMN_NAME, DATA_TYPE, NULLABLE
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = :t
    ORDER BY COLUMN_ID
  `, { t: TABLE });
  const cols = colsRes.rows || [];

  const idRes = await execute(`
    SELECT COLUMN_NAME
    FROM USER_TAB_IDENTITY_COLS
    WHERE TABLE_NAME = :t
  `, { t: TABLE });
  const identity = new Set((idRes.rows || []).map(r => r.COLUMN_NAME));

  return { cols, identity };
}

async function getPrimaryKey(TABLE) {
  const pkRes = await execute(`
    SELECT acc.COLUMN_NAME, acc.POSITION
    FROM USER_CONS_COLUMNS acc
    JOIN USER_CONSTRAINTS ac
      ON ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
    WHERE ac.TABLE_NAME = :t
      AND ac.CONSTRAINT_TYPE = 'P'
    ORDER BY acc.POSITION
  `, { t: TABLE });

  const pks = pkRes.rows || [];
  if (pks.length === 0) return null;
  if (pks.length > 1) return { composite: true, columns: pks.map(r => r.COLUMN_NAME) };
  return { composite: false, column: pks[0].COLUMN_NAME };
}

exports.meta = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const { cols, identity } = await getColumns(TABLE);
    const pk = await getPrimaryKey(TABLE);
    res.json({
      table: TABLE,
      primaryKey: pk && (pk.composite ? { composite: true, columns: pk.columns } : { composite: false, column: pk.column }),
      columns: cols.map(c => ({
        name: c.COLUMN_NAME,
        type: c.DATA_TYPE,
        nullable: c.NULLABLE === 'Y',
        identity: identity.has(c.COLUMN_NAME)
      }))
    });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

exports.list = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const limit = Math.max(1, Math.min(100, Number(req.query.limit) || 20));
    const offset = Math.max(0, Number(req.query.offset) || 0);

    const totalRes = await execute(`SELECT COUNT(*) AS TOTAL FROM ${TABLE}`);
    const total = totalRes.rows?.[0]?.TOTAL || 0;

    const pageRes = await execute(`SELECT * FROM ${TABLE} OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY`);
    res.json({ table: TABLE, total, limit, offset, rows: pageRes.rows || [] });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

exports.getById = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const pk = await getPrimaryKey(TABLE);
    if (!pk || pk.composite) throw new Error('PK no definida o compuesta (no soportado en este CRUD)');

    const rowRes = await execute(`SELECT * FROM ${TABLE} WHERE ${pk.column} = :id`, { id: req.params.id });
    const row = rowRes.rows?.[0];
    if (!row) return res.status(404).json({ error: 'No encontrado' });
    res.json(row);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

exports.create = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const { cols, identity } = await getColumns(TABLE);

    // Validar keys del body con columnas existentes
    const body = req.body || {};
    const bodyKeys = Object.keys(body).map(k => k.toUpperCase());
    const validCols = cols.map(c => c.COLUMN_NAME);
    const insertCols = bodyKeys.filter(k => validCols.includes(k) && !identity.has(k)); // omite identity

    if (insertCols.length === 0) {
      return res.status(400).json({ error: 'No hay columnas válidas en el body para insertar' });
    }

    // Construir binds
    const bindValues = {};
    const bindNames = insertCols.map(c => {
      bindValues[c] = body[c] ?? body[c.toLowerCase()];
      return `:${c}`;
    });

    // RETURNING ROWID para leer la fila insertada
    const sql = `INSERT INTO ${TABLE} (${insertCols.join(',')}) VALUES (${bindNames.join(',')}) RETURNING ROWID INTO :rid`;
    bindValues.rid = { dir: oracledb.BIND_OUT, type: oracledb.STRING };

    const ins = await execute(sql, bindValues, { autoCommit: true });
    const rid = ins.outBinds?.rid;
    if (!rid) return res.status(201).json({ ok: true }); // fallback

    const rowRes = await execute(`SELECT * FROM ${TABLE} WHERE ROWID = :rid`, { rid });
    res.status(201).json(rowRes.rows?.[0] || { ok: true });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

exports.update = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const pk = await getPrimaryKey(TABLE);
    if (!pk || pk.composite) throw new Error('PK no definida o compuesta (no soportado en este CRUD)');

    const { cols, identity } = await getColumns(TABLE);
    const validCols = new Set(cols.map(c => c.COLUMN_NAME));

    const body = req.body || {};
    const bodyKeys = Object.keys(body).map(k => k.toUpperCase());

    // columnas a actualizar (excluye PK e identity)
    const setCols = bodyKeys.filter(k => validCols.has(k) && k !== pk.column && !identity.has(k));
    if (setCols.length === 0) return res.status(400).json({ error: 'Nada para actualizar' });

    const binds = { id: req.params.id };
    const setExpr = setCols.map(c => {
      binds[c] = body[c] ?? body[c.toLowerCase()];
      return `${c} = :${c}`;
    }).join(', ');

    const up = await execute(`UPDATE ${TABLE} SET ${setExpr} WHERE ${pk.column} = :id`, binds, { autoCommit: true });
    if ((up.rowsAffected || 0) === 0) return res.status(404).json({ error: 'No encontrado' });

    const rowRes = await execute(`SELECT * FROM ${TABLE} WHERE ${pk.column} = :id`, { id: req.params.id });
    res.json(rowRes.rows?.[0] || { ok: true });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};

exports.remove = async (req, res) => {
  try {
    if (!assertDev(req, res)) return;
    const TABLE = await resolveTable(req.params.table);
    const pk = await getPrimaryKey(TABLE);
    if (!pk || pk.composite) throw new Error('PK no definida o compuesta (no soportado en este CRUD)');

    const del = await execute(`DELETE FROM ${TABLE} WHERE ${pk.column} = :id`, { id: req.params.id }, { autoCommit: true });
    if ((del.rowsAffected || 0) === 0) return res.status(404).json({ error: 'No encontrado' });
    res.json({ ok: true, rowsAffected: del.rowsAffected });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
};
