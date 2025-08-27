// Importamos la función que ejecuta las consultas
const { ejecutarConsulta } = require('../database');

// Definimos una función asíncrona para obtener todos los estudiantes
const getEstudiantes = async (req, res) => {
    try {
        // Definimos el query SQL
        const query = 'SELECT * FROM estudiantes';

        // Ejecutamos la consulta y guardamos el resultado
        const resultados = await ejecutarConsulta(query);

        // Respondemos al cliente con los resultados en formato JSON
        res.json(resultados);

    } catch (error) {
        // Si hay un error, lo mostramos en la consola del servidor
        console.error('Error al obtener estudiantes:', error);
        // Y enviamos una respuesta de error al cliente
        res.status(500).send('Error en el servidor al obtener estudiantes');
    }
};

// Exportamos la función para que las rutas puedan usarla
module.exports = {
    getEstudiantes
};