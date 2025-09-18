// Importamos el servicio de usuario que contiene la lógica de negocio.
const usuarioService = require('../services/usuario.service');

console.log('Cargando controlador de usuarios...');

/**
 * Maneja la petición HTTP para crear una nueva cuenta de estudiante.
 * Valida los datos de entrada y llama al servicio correspondiente.
 * @param {object} req - El objeto de la petición (request).
 * @param {object} res - El objeto de la respuesta (response).
 */
async function postCrearCuentaEstudiante(req, res) {
    console.log('Controlador: Petición recibida para crear cuenta de estudiante.');
    try {
        // Extraemos todos los datos necesarios del cuerpo de la petición.
        const { nombres, apellidos, email, numeroCarnet, idCarrera, contrasena } = req.body;

        // --- Validación de Entrada ---
        // Verificamos que todos los campos obligatorios estén presentes.
        if (!nombres || !apellidos || !email || !numeroCarnet || !idCarrera || !contrasena) {
            return res.status(400).json({
                success: false,
                message: 'Faltan datos obligatorios. Se requieren nombres, apellidos, email, numeroCarnet, idCarrera y contrasena.'
            });
        }

        // --- Llamada al Servicio ---
        // Le pasamos la responsabilidad al servicio, que contiene la lógica compleja.
        const resultado = await usuarioService.crearCuentaEstudiante(req.body);

        // --- Envío de la Respuesta ---
        // Respondemos al cliente basándonos en el resultado del servicio.
        if (resultado.success) {
            // 201 Created es el código de estado correcto para una creación exitosa.
            res.status(201).json(resultado);
        } else {
            // 400 Bad Request si la lógica de negocio falló (ej. carnet duplicado).
            res.status(400).json(resultado);
        }

    } catch (error) {
        // Si ocurre un error inesperado (ej. el servicio falla), lo capturamos.
        console.error('Error en postCrearCuentaEstudiante:', error.message);
        res.status(500).json({
            success: false,
            message: 'Ocurrió un error interno en el servidor.'
        });
    }
}

console.log('✅ Controlador de usuarios cargado.');

module.exports = {
    postCrearCuentaEstudiante
};
