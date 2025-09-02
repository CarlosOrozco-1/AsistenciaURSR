// backend/src/controllers/cliente.controller.js
// Controlador para CREAR un cliente usando el procedimiento SP_INS_CLIENTE.
// Aún no montamos la ruta; primero dejemos listo el controlador.

const { execute, oracledb } = require('../database');

exports.create = async (req, res) => {
  try {
    // 1) Tomar los campos del body (acepta mayúsculas o minúsculas)
    const NOMBRE = req.body.NOMBRE ?? req.body.nombre;
    const IDENTIFICACION = req.body.IDENTIFICACION ?? req.body.identificacion;
    const TELEFONO = req.body.TELEFONO ?? req.body.telefono;

    // 2) Validación mínima
    if (!NOMBRE || !IDENTIFICACION || !TELEFONO) {
      return res.status(400).json({
        error: 'Faltan campos requeridos: NOMBRE, IDENTIFICACION, TELEFONO'
      });
    }

    console.log('[PROC] SP_INS_CLIENTE IN:', { NOMBRE, IDENTIFICACION, TELEFONO });

    // 3) Llamar al procedimiento (IN, IN, IN, OUT)
    const plsql = `
      BEGIN
        SP_INS_CLIENTE(:p_nombre, :p_identificacion, :p_telefono, :p_id_cliente);
      END;`;

    const binds = {
      p_nombre: NOMBRE,
      p_identificacion: IDENTIFICACION,
      p_telefono: TELEFONO,
      p_id_cliente: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER } // OUT: devuelve el ID generado
    };

    // autoCommit: true porque el procedimiento hace un INSERT
    const r = await execute(plsql, binds, { autoCommit: true });
    const newId = r.outBinds?.p_id_cliente;

    console.log('[PROC] SP_INS_CLIENTE OUT id:', newId);

    // 4) Leer la fila insertada para devolverla al cliente
    const sel = await execute(
      `SELECT ID_CLIENTE, NOMBRE, IDENTIFICACION, TELEFONO
         FROM CLIENTE
        WHERE ID_CLIENTE = :id`,
      { id: newId }
    );

    const row = sel.rows?.[0] || { ID_CLIENTE: newId };
    return res.status(201).json(row);
  } catch (e) {
    console.error('[PROC] Error SP_INS_CLIENTE:', e.message);
    return res.status(500).json({ error: e.message });
  }
};
