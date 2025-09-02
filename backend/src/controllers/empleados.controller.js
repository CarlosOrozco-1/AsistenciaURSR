// backend/src/controllers/empleados.controller.js
const { execute } = require('../database'); // Importamos nuestra función execute

const getEmpleados = async (req, res) => {
  try {
    const sql = 'SELECT id, nombre, puesto, salario FROM empleados ORDER BY id';
    const result = await execute(sql);

    // Enviamos los resultados como una respuesta JSON
    res.status(200).json(result.rows);

  } catch (error) {
    // En caso de un error, lo registramos en la consola del servidor
    console.error('Error al obtener empleados:', error.message);
    // Y enviamos una respuesta de error genérica al cliente
    res.status(500).json({ error: 'Error interno del servidor al obtener los empleados.' });
  }
};

module.exports = {
  getEmpleados,
};