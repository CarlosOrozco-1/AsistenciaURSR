// Importamos la librería para encriptar contraseñas y el driver de Oracle
const bcrypt = require('bcrypt');
const oracledb = require('oracledb');
const database = require('../config/database');

console.log('Cargando servicio de usuarios...');

/**
 * Lógica de negocio para crear una nueva cuenta de estudiante.
 * Se encarga de hashear la contraseña antes de enviarla a la base de datos.
 * @param {object} datosEstudiante - Contiene los datos del nuevo estudiante.
 * @returns {object} - Un objeto con el resultado de la operación.
 */
async function crearCuentaEstudiante(datosEstudiante) {
    const { nombres, apellidos, email, numeroCarnet, idCarrera, contrasena } = datosEstudiante;

    console.log(`Servicio: Creando cuenta para el estudiante con carnet ${numeroCarnet}`);

    // --- Hashing de la Contraseña ---
    // Generamos un 'salt' (factor de aleatoriedad) y luego hasheamos la contraseña.
    // 10 es el número de rondas de hashing, un valor estándar y seguro.
    const salt = await bcrypt.genSalt(10);
    const contrasenaHash = await bcrypt.hash(contrasena, salt);

    // --- Llamada al Procedimiento Almacenado ---
    const sql = `
        BEGIN
            PKG_USUARIOS.crear_cuenta_estudiante(
                :p_nombres,
                :p_apellidos,
                :p_email,
                :p_numero_carnet,
                :p_id_carrera,
                :p_contrasena_hash,
                :p_resultado,
                :p_detalle
            );
        END;
    `;

    const binds = {
        p_nombres: nombres,
        p_apellidos: apellidos,
        p_email: email,
        p_numero_carnet: numeroCarnet,
        p_id_carrera: idCarrera,
        p_contrasena_hash: contrasenaHash,
        p_resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 50 },
        p_detalle: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 200 }
    };

    try {
        const result = await database.execute(sql, binds, { autoCommit: false }); // El SP ya hace COMMIT/ROLLBACK

        // Devolvemos un objeto claro con la respuesta del procedimiento almacenado
        return {
            success: result.outBinds.p_resultado === 'EXITO',
            message: result.outBinds.p_detalle
        };
    } catch (error) {
        console.error('Error al ejecutar PKG_USUARIOS.crear_cuenta_estudiante:', error);
        // Devolvemos un error genérico si la llamada a la BD falla
        return {
            success: false,
            message: 'Ocurrió un error inesperado en el servicio al crear la cuenta.'
        };
    }
}

console.log('✅ Servicio de usuarios cargado.');

module.exports = {
    crearCuentaEstudiante
};
