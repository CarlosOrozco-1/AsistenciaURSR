// src/middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

/**
 * Middleware para proteger rutas privadas.
 * Verifica que el token JWT esté presente y sea válido.
 */
const verificarToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  // El token debe venir en formato: Bearer <token>
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'error',
      message: 'No tiene autorización para el ingreso al sistema.',
    });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded; // Puedes acceder a los datos del usuario en las rutas protegidas
    next();
  } catch (error) {
    return res.status(403).json({
      status: 'error',
      message: 'Token inválido o expirado.',
    });
  }
};

module.exports = { verificarToken };
