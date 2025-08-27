// Importamos el Router de Express
const { Router } = require('express');
// Importamos el controlador de estudiantes
const { getEstudiantes } = require('../controllers/estudiante.controller');

// Creamos una nueva instancia del Router
const router = Router();

// Definimos la ruta. Cuando se haga una petición GET a '/', se ejecutará la función getEstudiantes
router.get('/', getEstudiantes);

// Exportamos el router para usarlo en el archivo principal
module.exports = router;