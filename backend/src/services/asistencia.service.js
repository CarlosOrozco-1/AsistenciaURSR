const oracledb = require('oracledb');
// Importamos el módulo de base de datos que creamos
const database = require('../config/database');

console.log('Cargando servicio de asistencia...');

/**
 * Llama al procedimiento almacenado para registrar la asistencia de un estudiante.
 * @param {string} qrCode - El código QR escaneado.
 * @param {string} carnet - El número de carnet del estudiante.
 * @returns {Promise<object>} Un objeto con el resultado de la operación.
 */
async function registrarAsistencia(qrCode, carnet) {
  // Mapeo directo al procedimiento almacenado en el paquete
  const sql = `
    BEGIN
      PKG_ASISTENCIA.registrar_asistencia(
        :p_codigo_qr, 
        :p_numero_carnet, 
        :p_tipo_registro, 
        :p_resultado, 
        :p_detalle
      );
    END;
  `;

  const binds = {
    p_codigo_qr: qrCode,
    p_numero_carnet: carnet,
    p_tipo_registro: 'ENTRADA', // Valor fijo por ahora
    p_resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 50 },
    p_detalle: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 200 }
  };

  // Añadimos { autoCommit: true } porque este procedimiento modifica datos.
  const result = await database.execute(sql, binds, { autoCommit: true });

  // Devolvemos un objeto claro con el resultado
  return {
    success: result.outBinds.p_resultado === 'EXITO',
    message: result.outBinds.p_detalle
  };
}


/**
 * Llama al procedimiento almacenado para crear una nueva sesión y su código QR.
 * @param {number} idCursoImpartido - El ID del curso para el que se crea la sesión.
 * @returns {Promise<object>} Un objeto con el resultado de la operación y el QR generado.
 */
async function crearSesionQR(idCursoImpartido) {
  console.log(`Servicio: Creando sesión QR para el curso impartido ID: ${idCursoImpartido}`);

  const sql = `
    BEGIN
      PKG_ASISTENCIA.crear_sesion_qr(
        :p_id_curso_impartido, 
        :p_codigo_qr_generado, 
        :p_resultado, 
        :p_detalle
      );
    END;
  `;

  const binds = {
    p_id_curso_impartido: idCursoImpartido,
    p_codigo_qr_generado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 200 },
    p_resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 50 },
    p_detalle: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 200 }
  };
  
  // --- CORRECCIÓN Y DEBUGGING AQUÍ ---
  console.log('--- DEBUG: Ejecutando SQL ---');
  console.log(sql);
  console.log('--- DEBUG: Con Binds ---');
  console.log(binds);
  console.log('-----------------------------');
  
  // Añadimos { autoCommit: true } porque este procedimiento inserta una nueva sesión.
  const result = await database.execute(sql, binds, { autoCommit: true });

  // Devolvemos un objeto claro con el resultado
  return {
    success: result.outBinds.p_resultado === 'EXITO',
    message: result.outBinds.p_detalle,
    qrCode: result.outBinds.p_codigo_qr_generado
  };
}


console.log('✅ Servicio de asistencia cargado.');

// Exportamos ambas funciones
module.exports = {
  registrarAsistencia,
  crearSesionQR
};

