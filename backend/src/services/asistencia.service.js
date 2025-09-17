// Importamos la utilidad para ejecutar sentencias y el driver de Oracle
const { execute, oracledb } = require('../config/database');

console.log('Cargando servicio de asistencia...');

/**
 * Contiene la lógica de negocio pura para el módulo de asistencia.
 * Llama al procedimiento 'registrar_asistencia' del paquete 'PKG_ASISTENCIA'.
 * @param {string} qrCode - El código QR recibido desde el frontend.
 * @param {string} carnet - El carnet del estudiante.
 * @returns {Promise<{success: boolean, message: string}>} Un objeto con el resultado de la operación.
 */
async function registrarAsistencia(qrCode, carnet) {
  console.log(`Servicio: Ejecutando lógica para registrar asistencia del carnet ${carnet}`);

  // Llamada al procedimiento almacenado DENTRO del paquete PKG_ASISTENCIA
  const plsql = `
    BEGIN
      PKG_ASISTENCIA.registrar_asistencia(
        p_codigo_qr     => :qrCode,
        p_numero_carnet => :carnet,
        p_tipo_registro => :tipoRegistro, -- TODO: Este valor debería ser dinámico (ej: 'ENTRADA'/'SALIDA')
        p_resultado     => :resultado,
        p_detalle       => :detalle
      );
    END;
  `;

  // Mapeamos las variables de JavaScript a los parámetros del procedimiento.
  const binds = {
    qrCode: qrCode,
    carnet: carnet,
    tipoRegistro: 'ENTRADA', // Por ahora, lo dejamos fijo como 'ENTRADA'
    // Definimos los parámetros de SALIDA (OUT) para que Oracle nos devuelva sus valores.
    resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 20 },
    detalle: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 255 }
  };

  try {
    const result = await execute(plsql, binds, { autoCommit: true });

    // Extraemos los valores de los parámetros de salida
    const resultadoBD = result.outBinds.resultado;
    const detalleBD = result.outBinds.detalle;
    const exito = resultadoBD === 'EXITO';

    console.log(`Servicio: Respuesta de la BD -> Resultado: ${resultadoBD}, Detalle: "${detalleBD}"`);

    // Devolvemos un objeto estandarizado al controlador.
    return {
      success: exito,
      message: detalleBD,
    };
  } catch (error) {
    console.error('Error al ejecutar PKG_ASISTENCIA.registrar_asistencia:', error);
    // Relanzamos el error para que el controlador lo capture y devuelva un 500.
    throw new Error('Ocurrió un error al procesar el registro en la base de datos.');
  }
}

console.log('✅ Servicio de asistencia cargado.');

module.exports = {
  registrarAsistencia,
};

