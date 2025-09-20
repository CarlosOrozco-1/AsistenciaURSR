// src/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const { login } = require('../controllers/auth.controller');
const { verificarToken } = require('../middleware/auth.Middleware');

// Ruta para iniciar sesión
// Aunque el campo se llama 'email', internamente se usa como 'NOMBRE_USUARIO' en Oracle
router.post('/login', login);

//Ruta protegida 
router.get('/test', verificarToken, (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Acceso autorizado, el token es valido!.',
    usuario: req.usuario, // muestra los datos del usuario decodificados del token
  });
});

module.exports = router;
