// Importaremos el servicio de asistencia, que contendrá la lógica de negocio real.
// Lo crearemos en el siguiente y último paso de esta secuencia.
const asistenciaService = require('../services/asistencia.service');

console.log('Cargando controlador de asistencia...');

/**
 * Maneja la petición HTTP para registrar una nueva asistencia.
 * Su responsabilidad es:
 * 1. Validar los datos de entrada (el cuerpo de la petición).
 * 2. Llamar al servicio correspondiente para ejecutar la lógica de negocio.
 * 3. Enviar una respuesta HTTP (éxito o error) al cliente.
 */
async function postRegistrarAsistencia(req, res) {
  try {
    // 1. Extraemos y validamos los datos del cuerpo de la petición
    const { qrCode, carnet } = req.body;

    if (!qrCode || !carnet) {
      // Si faltan datos, enviamos un error 400 (Bad Request)
      return res.status(400).json({
        success: false,
        message: 'Los campos "qrCode" y "carnet" son obligatorios.',
      });
    }

    // 2. Llamamos al servicio para que haga el trabajo pesado
    console.log(`Controlador: Recibida petición para registrar asistencia del carnet ${carnet}`);
    const resultado = await asistenciaService.registrarAsistencia(qrCode, carnet);

    // 3. Enviamos la respuesta basándonos en el resultado del servicio
    if (resultado.success) {
      res.status(200).json(resultado); // 200 OK
    } else {
      // Si la lógica de negocio falló (ej. QR no válido), sigue siendo un error del cliente.
      res.status(400).json(resultado); // 400 Bad Request
    }

  } catch (error) {
    // Si ocurre un error inesperado (ej. fallo de la base de datos),
    // lo capturamos y enviamos un error 500 (Internal Server Error).
    console.error('Error en postRegistrarAsistencia:', error.message);
    res.status(500).json({
      success: false,
      message: 'Ocurrió un error interno en el servidor.',
    });
  }
}

/**
 * Maneja la petición POST para crear una nueva sesión de clase con un código QR.
 * @param {object} req - El objeto de la petición (request).
 * @param {object} res - El objeto de la respuesta (response).
 */
async function postCrearSesionQR(req, res) {
  try {
    const { idCursoImpartido } = req.body;

    // Validación de entrada: nos aseguramos de recibir un número.
    if (!idCursoImpartido || typeof idCursoImpartido !== 'number') {
      return res.status(400).json({ success: false, message: 'El parámetro "idCursoImpartido" es obligatorio y debe ser un número.' });
    }

    const resultado = await asistenciaService.crearSesionQR(idCursoImpartido);

    if (resultado.success) {
      // Si la operación es exitosa, devolvemos un 201 (Created) que es más específico.
      return res.status(201).json(resultado);
    } else {
      return res.status(400).json(resultado);
    }

  } catch (error) {
    console.error('Error en postCrearSesionQR:', error.message);
    res.status(500).json({ success: false, message: 'Error interno del servidor.' });
  }
}

console.log('✅ Controlador de asistencia cargado.');

module.exports = {
  postRegistrarAsistencia, // Exportamos la función para que pueda ser usada en las rutas
  postCrearSesionQR, // Exportamos la función para que pueda ser usada en las rutas
};
